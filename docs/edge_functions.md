# Supabase Edge Functions

## 설계 요약

Edge Function은 앱 클라이언트가 직접 민감한 작업을 하지 않도록 막는 서버 경계다.

- `create-free-reading`: 무료 해석 생성. AI 호출 없음.
- `create-ai-reading`: Plus 사용자만 AI 개인화 해석 생성.
- `get-divination-catalog`: 활성 점술 목록 조회.
- `get-divination-detail`: 점술 상세 메타/입력 정보 조회.
- `sync-revenuecat-subscription`: RevenueCat webhook을 받아 구독 상태 갱신.

## 공통 규칙

- 모든 사용자 요청 함수는 Supabase JWT에서 `user.id`를 확인한다.
- MVP 앱은 익명 로그인을 먼저 생성하므로 Supabase Auth의 Anonymous sign-ins를 활성화해야 한다.
- 무료 해석은 `interpretations` 테이블만 사용한다.
- 타로 카드 수와 포지션은 `spreads`, `spread_positions`에서 조회한다.
- 입력형/규칙형 점술은 `reading_inputs`, `reading_payloads`를 함께 저장한다.
- AI 해석은 `subscriptions.status in ('active', 'trial')`와 `current_period_end > now()`를 통과해야 한다.
- AI 해석은 `daily_usage.ai_reading_count` 제한을 통과해야 한다.
- OpenAI API Key는 Edge Function 환경 변수에만 저장한다.

## 환경 변수

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `REVENUECAT_WEBHOOK_SECRET`

## create-free-reading

입력:

```json
{
  "divination_type_code": "tarot",
  "spread_code": "single",
  "category": "career",
  "question": "이직해도 될까요?",
  "language_code": "ko"
}
```

또는 입력형 점술 예시:

```json
{
  "divination_type_code": "saju",
  "category": "career",
  "question": "올해 직업 흐름이 궁금합니다.",
  "language_code": "ko",
  "inputs": {
    "birth_date": "1994-03-21",
    "birth_time": "14:30",
    "calendar_type": "solar",
    "gender": "female"
  }
}
```

처리:

1. 사용자 확인
2. 일일 무료 사용량 확인 및 증가
3. 활성 점술 유형 조회
4. 점술 유형별 분기
5. 추첨형 점술:
6. 요청한 `spread_code`로 스프레드와 포지션 조회
7. 포지션 수만큼 활성 항목 중 랜덤 선택
8. 선택 항목의 무료 해석 조회
9. 입력형/규칙형 점술:
10. 입력값 검증
11. rule-based 해석 생성
12. `readings`, `reading_items`, `reading_inputs`, `reading_payloads` 저장
13. 해석 결과 반환

검증 스크립트:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\test_free_reading.ps1
```

다중 점술 무료 검증:

```powershell
cd E:\Project\Divination_app
& 'C:\Program Files\PowerShell\7\pwsh.exe' -File scripts\test_multi_divinations.ps1
```

현재 무료 검증 대상:

- `saju`
- `zodiac`
- `rune`
- `omikuji`
- 필요 시 `-IncludeTarot`로 타로 회귀 포함

`anonymous_provider_disabled` 오류가 나오면 Supabase Dashboard에서 Anonymous sign-ins를 켠 뒤 다시 실행한다.

## create-ai-reading

검증 스크립트:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\test_ai_reading.ps1
```

- 1단계: Plus가 아닌 사용자는 `Plus subscription is required.`로 차단되는지 확인한다.
- 2단계: `.env`에 `SUPABASE_SERVICE_ROLE_KEY`를 넣으면 테스트용 `subscriptions` 행을 upsert한 뒤 실제 AI 해석 생성까지 확인한다.
- OpenAI secret이 없으면 2단계에서 OpenAI 관련 오류가 난다. Dashboard > Edge Functions > Secrets에서 `OPENAI_API_KEY`, `OPENAI_MODEL`을 확인한다.
- 사주/별자리/룬/오미쿠지 AI 분기는 코드상 연결되어 있으나, 실제 Plus 성공 호출 검증은 후속 진행한다.

처리:

1. 사용자 확인
2. Plus 구독 확인
3. AI 일일 사용량 확인 및 증가
4. 점술 유형별 기본 해석 데이터 준비
5. 타로는 스프레드/항목 기반 해석 사용
6. 사주/별자리/룬/오미쿠지는 rule-based 무료 초안과 payload를 기반으로 프롬프트 구성
7. 프롬프트 템플릿 조회
8. OpenAI 호출
9. `readings`, `reading_items`, `reading_inputs`, `reading_payloads`, `ai_results` 저장
10. AI 해석 결과 반환

## get-divination-catalog

역할:

- 활성 점술 목록 반환
- 홈/카탈로그 화면에서 사용

반환 메타 예시:

- `code`
- `display_name`
- `short_description`
- `input_mode`
- `resolver_type`
- `interpretation_mode`

## get-divination-detail

역할:

- 점술 상세 정보 반환
- 입력형 점술의 입력 정의 반환
- 타로는 스프레드 정보까지 함께 반환

반환 예시:

- 점술 메타데이터
- `divination_input_definitions`
- `spreads` (타로일 때)

## sync-revenuecat-subscription

RevenueCat webhook payload를 받아 `subscriptions`에 upsert한다. Webhook secret 검증은 초안에서는 `Authorization: Bearer <secret>` 방식으로 둔다.
