# Supabase Edge Functions

## 설계 요약

Edge Function은 앱 클라이언트가 직접 민감한 작업을 하지 않도록 막는 서버 경계다.

- `create-free-reading`: 무료 해석 생성. AI 호출 없음.
- `create-ai-reading`: Plus 사용자만 AI 개인화 해석 생성.
- `sync-revenuecat-subscription`: RevenueCat webhook을 받아 구독 상태 갱신.

## 공통 규칙

- 모든 사용자 요청 함수는 Supabase JWT에서 `user.id`를 확인한다.
- 무료 해석은 `interpretations` 테이블만 사용한다.
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

처리:

1. 사용자 확인
2. 일일 무료 사용량 확인 및 증가
3. 활성 점술 유형 조회
4. 활성 항목 중 랜덤 선택
5. 선택 항목의 무료 해석 조회
6. `readings`, `reading_items` 저장
7. 해석 결과 반환

## create-ai-reading

처리:

1. 사용자 확인
2. Plus 구독 확인
3. AI 일일 사용량 확인 및 증가
4. 기본 해석 생성에 필요한 항목/해석 조회
5. 프롬프트 템플릿 조회
6. OpenAI 호출
7. `readings`, `reading_items`, `ai_results` 저장
8. AI 해석 결과 반환

## sync-revenuecat-subscription

RevenueCat webhook payload를 받아 `subscriptions`에 upsert한다. Webhook secret 검증은 초안에서는 `Authorization: Bearer <secret>` 방식으로 둔다.
