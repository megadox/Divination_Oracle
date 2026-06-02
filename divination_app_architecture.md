# 글로벌 점술 서비스 앱 상세 아키텍처

## 1. 프로젝트 개요

본 문서는 타로를 시작으로 전 세계의 다양한 점술 서비스를 제공하는 모바일 앱의 상세 아키텍처를 정의한다.

서비스의 핵심 방향은 다음과 같다.

> 무료 사용자는 사전에 구축된 점술 지식창고 기반의 기본 해석을 제공받고, Plus 사용자는 AI를 활용한 개인화 해석을 제공받는다.

초기 MVP는 타로 중심으로 구현하고, 이후 룬, 오미쿠지, 주역, 사주, 별자리, 베다 점성술 등으로 확장한다.

---

## 2. 서비스 구조

### 2.1 사용자 등급 구조

| 구분 | 무료 사용자 | Plus 사용자 |
|---|---|---|
| 점술 유형 | 일부 제공 | 전체 제공 |
| 타로 해석 | 기본 해석 제공 | AI 개인화 해석 제공 |
| 질문 입력 | 가능 | 가능 |
| AI 해석 | 제한 또는 미제공 | 제공 |
| 일일 이용 횟수 | 제한 | 확장 또는 무제한 |
| 광고 | 표시 가능 | 제거 |
| 기록 저장 | 제한 | 전체 저장 |
| 여러 점술 통합 분석 | 미제공 | 제공 |

---

### 2.2 무료 버전 구조

무료 버전은 AI API 비용을 최소화하기 위해 DB에 저장된 해석 데이터를 사용한다.

예시 흐름:

1. 사용자가 질문을 입력한다.
2. 사용자가 타로 카드를 선택하거나 앱이 랜덤으로 카드를 뽑는다.
3. 선택된 카드, 방향, 질문 카테고리에 맞는 해석을 DB에서 조회한다.
4. 정해진 템플릿에 따라 결과를 보여준다.

무료 결과 예시:

```text
카드: The Fool
방향: 정방향
분야: 직업

새로운 시작과 도전을 의미합니다.
현재 상황은 가능성이 있지만 준비가 부족할 수 있습니다.
충동적인 결정은 피하고, 계획을 세운 뒤 움직이는 것이 좋습니다.
```

---

### 2.3 Plus 버전 구조

Plus 버전은 사용자 질문, 선택된 점술 결과, 지식창고 데이터를 AI 프롬프트에 포함하여 개인화 해석을 생성한다.

예시 흐름:

1. 사용자가 질문을 입력한다.
2. 카드 또는 점술 결과가 생성된다.
3. DB에서 기본 해석 데이터를 조회한다.
4. 사용자 질문과 기본 해석을 AI 프롬프트에 넣는다.
5. AI가 자연스러운 상담형 해석을 생성한다.
6. 결과를 저장하고 사용자에게 보여준다.

Plus 결과 예시:

```text
질문: 지금 회사를 그만두고 이직을 준비해도 될까요?
카드: The Fool, The Star, The Magician

새로운 시작의 가능성이 강하게 보입니다.
다만 The Fool은 준비 없는 출발을 경고하기도 합니다.
현재 회사를 즉시 그만두기보다는, 이직 준비와 포트폴리오 정리를 먼저 진행하는 것이 좋습니다.
The Magician은 이미 필요한 능력을 어느 정도 갖추고 있음을 의미하므로, 준비 기간을 가진다면 더 좋은 기회를 만들 수 있습니다.
```

---

## 3. 추천 기술 구조

## 3.1 전체 기술 스택

| 영역 | 추천 기술 | 선택 이유 |
|---|---|---|
| 모바일 앱 | Flutter | iOS/Android 동시 개발, UI 품질 우수 |
| 백엔드 | Supabase | 인증, DB, Storage, Edge Function 제공 |
| 데이터베이스 | PostgreSQL | Supabase 기본 DB, 확장성 우수 |
| AI 해석 | OpenAI API | Plus 사용자 개인화 해석 생성 |
| 결제/구독 | RevenueCat | 앱스토어/플레이스토어 구독 통합 관리 |
| 이미지 저장 | Supabase Storage | 카드 이미지, 점술 이미지 저장 |
| 관리자 페이지 | Supabase Studio 또는 Flutter Web | 초기 관리 기능 빠르게 구현 |
| 푸시 알림 | Firebase Cloud Messaging | 오늘의 운세, 재방문 유도 |
| 분석 | Firebase Analytics / Amplitude | 사용자 행동 분석 |

---

## 3.2 전체 시스템 구성도

```text
[Flutter App]
     |
     | Auth / API / DB Query
     v
[Supabase]
     |
     | PostgreSQL
     | Storage
     | Edge Functions
     v
[Knowledge DB]

[Flutter App]
     |
     | Plus User Only
     v
[Supabase Edge Function]
     |
     | Secure API Call
     v
[OpenAI API]

[Flutter App]
     |
     | Subscription Check
     v
[RevenueCat]
     |
     v
[App Store / Google Play Billing]
```

---

## 4. 핵심 기능 모듈

### 4.1 사용자 모듈

기능:

- 익명 사용자 시작
- 이메일 로그인
- Google/Apple 로그인
- 사용자 프로필
- 무료/Plus 상태 확인
- 일일 사용량 제한

초기에는 로그인 없이 시작할 수 있게 하는 것이 좋다.

권장 방식:

```text
앱 설치 → 익명 사용자 생성 → 무료 체험 → Plus 전환 시 로그인 유도
```

---

### 4.2 점술 유형 모듈

초기 MVP 점술 유형:

1. 타로
2. 룬
3. 오미쿠지

확장 점술 유형:

1. 사주
2. 주역
3. 별자리
4. 베다 점성술
5. 마야 달력
6. 이파
7. 오검

---

### 4.3 지식창고 모듈

지식창고는 무료 해석과 AI 해석의 기반 데이터로 사용된다.

저장 대상:

- 점술 유형
- 카드/상징/괘/룬 정보
- 기본 의미
- 분야별 의미
- 정방향/역방향 의미
- 조언
- 경고
- 키워드
- 이미지
- 난이도
- 문화권/기원 정보

---

### 4.4 무료 해석 모듈

무료 해석은 AI를 사용하지 않고 DB 템플릿을 조합한다.

예시 조합 방식:

```text
[카드 요약]
+ [분야별 해석]
+ [조언]
+ [주의사항]
```

무료 해석 장점:

- API 비용 없음
- 빠른 응답
- 결과 품질 통제 가능
- 앱스토어 심사 리스크 감소

---

### 4.5 Plus AI 해석 모듈

Plus AI 해석은 Supabase Edge Function을 통해서만 OpenAI API를 호출한다.

중요 원칙:

- 앱에서 OpenAI API Key 직접 호출 금지
- Supabase Edge Function에서 API Key 보관
- Plus 사용자 여부 확인 후 AI 호출
- 호출 내역 저장
- 비용 추적

AI 해석 입력 데이터:

```json
{
  "user_question": "이직해도 될까요?",
  "divination_type": "tarot",
  "selected_items": ["The Fool", "The Star", "The Magician"],
  "base_interpretations": [...],
  "category": "career",
  "language": "ko"
}
```

AI 해석 출력 데이터:

```json
{
  "summary": "새로운 시작의 가능성이 있습니다.",
  "detailed_reading": "현재 상황에서는 무작정 움직이기보다 준비가 중요합니다...",
  "advice": "퇴사 전 포트폴리오와 재정 계획을 먼저 준비하세요.",
  "caution": "충동적인 결정은 피하는 것이 좋습니다."
}
```

---

## 5. DB 구조

## 5.1 ERD 개요

```text
users
 └── readings
      ├── reading_items
      └── ai_results

divination_types
 └── divination_items
      └── interpretations

subscriptions
usage_limits
prompts
```

---

## 5.2 테이블 설계

### users

사용자 정보를 저장한다.

```sql
create table users (
    id uuid primary key,
    email text,
    display_name text,
    provider text,
    is_anonymous boolean default true,
    language_code text default 'ko',
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

---

### divination_types

점술 유형을 저장한다.

```sql
create table divination_types (
    id uuid primary key default gen_random_uuid(),
    code text unique not null,
    name text not null,
    description text,
    origin_region text,
    is_active boolean default true,
    sort_order int default 0,
    created_at timestamp default now()
);
```

예시 데이터:

```text
tarot, Tarot, 서양 타로
rune, Rune, 북유럽 룬
omikuji, Omikuji, 일본 오미쿠지
```

---

### divination_items

카드, 룬, 괘, 오미쿠지 결과 등 점술 항목을 저장한다.

```sql
create table divination_items (
    id uuid primary key default gen_random_uuid(),
    divination_type_id uuid references divination_types(id),
    code text not null,
    name text not null,
    display_name text,
    image_url text,
    keywords text[],
    order_no int default 0,
    is_active boolean default true,
    created_at timestamp default now()
);
```

타로 예시:

```text
fool, The Fool, 바보, 시작/자유/모험
magician, The Magician, 마법사, 능력/실행/창조
```

---

### interpretations

무료 해석용 기본 데이터를 저장한다.

```sql
create table interpretations (
    id uuid primary key default gen_random_uuid(),
    item_id uuid references divination_items(id),
    orientation text default 'none',
    category text default 'general',
    summary text not null,
    detail text,
    advice text,
    warning text,
    keywords text[],
    language_code text default 'ko',
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

orientation 예시:

```text
upright
reversed
none
```

category 예시:

```text
general
love
career
money
health
relationship
```

---

### readings

사용자의 점술 실행 기록을 저장한다.

```sql
create table readings (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id),
    divination_type_id uuid references divination_types(id),
    question text,
    category text default 'general',
    result_type text default 'free',
    result_text text,
    is_ai_generated boolean default false,
    language_code text default 'ko',
    created_at timestamp default now()
);
```

result_type 예시:

```text
free
plus_ai
```

---

### reading_items

한 번의 점술에서 선택된 카드/룬/항목을 저장한다.

```sql
create table reading_items (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    item_id uuid references divination_items(id),
    orientation text default 'none',
    position_name text,
    position_order int default 0,
    created_at timestamp default now()
);
```

타로 3장 배열 예시:

```text
past
present
future
```

---

### ai_results

AI 해석 결과와 비용 추적 정보를 저장한다.

```sql
create table ai_results (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    model_name text,
    prompt_tokens int,
    completion_tokens int,
    total_tokens int,
    prompt_text text,
    result_json jsonb,
    created_at timestamp default now()
);
```

---

### subscriptions

사용자의 구독 상태를 저장한다.

```sql
create table subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id),
    provider text default 'revenuecat',
    product_id text,
    status text,
    current_period_start timestamp,
    current_period_end timestamp,
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

status 예시:

```text
active
expired
cancelled
trial
```

---

### usage_limits

무료 사용자와 Plus 사용자의 사용량을 관리한다.

```sql
create table usage_limits (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id),
    usage_date date not null,
    free_reading_count int default 0,
    ai_reading_count int default 0,
    created_at timestamp default now(),
    updated_at timestamp default now(),
    unique(user_id, usage_date)
);
```

---

### prompts

AI 프롬프트 템플릿을 관리한다.

```sql
create table prompts (
    id uuid primary key default gen_random_uuid(),
    code text unique not null,
    name text not null,
    system_prompt text not null,
    user_prompt_template text not null,
    language_code text default 'ko',
    version int default 1,
    is_active boolean default true,
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

---

## 6. API / Edge Function 설계

### 6.1 get-divination-types

점술 유형 목록을 반환한다.

```text
GET /functions/v1/get-divination-types
```

응답:

```json
[
  {
    "code": "tarot",
    "name": "Tarot",
    "description": "서양 타로 카드 점술"
  }
]
```

---

### 6.2 create-free-reading

무료 점술 결과를 생성한다.

```text
POST /functions/v1/create-free-reading
```

요청:

```json
{
  "user_id": "uuid",
  "divination_type": "tarot",
  "question": "이직해도 될까요?",
  "category": "career",
  "spread_type": "three_card"
}
```

처리:

1. 사용량 확인
2. 카드 랜덤 선택
3. 해석 DB 조회
4. 템플릿 조합
5. readings 저장
6. 결과 반환

---

### 6.3 create-ai-reading

Plus 사용자용 AI 점술 결과를 생성한다.

```text
POST /functions/v1/create-ai-reading
```

처리:

1. 사용자 구독 상태 확인
2. AI 사용량 확인
3. 카드 또는 점술 항목 생성
4. 기본 해석 조회
5. AI 프롬프트 생성
6. OpenAI API 호출
7. 결과 저장
8. 사용량 업데이트
9. 결과 반환

---

### 6.4 get-reading-history

사용자의 점술 기록을 조회한다.

```text
GET /functions/v1/get-reading-history?user_id={user_id}
```

---

### 6.5 check-subscription

RevenueCat 구독 상태를 확인한다.

```text
POST /functions/v1/check-subscription
```

---

## 7. Flutter 앱 화면 구조

### 7.1 화면 목록

```text
/lib
  /screens
    splash_screen.dart
    home_screen.dart
    divination_select_screen.dart
    tarot_reading_screen.dart
    rune_reading_screen.dart
    omikuji_screen.dart
    result_screen.dart
    ai_result_screen.dart
    history_screen.dart
    subscription_screen.dart
    settings_screen.dart

  /widgets
    mystic_card.dart
    divination_button.dart
    result_section.dart
    premium_banner.dart

  /services
    supabase_service.dart
    reading_service.dart
    subscription_service.dart
    analytics_service.dart

  /models
    divination_type.dart
    divination_item.dart
    reading.dart
    interpretation.dart
```

---

### 7.2 주요 화면 흐름

```text
Splash
  ↓
Home
  ↓
점술 선택
  ↓
질문 입력
  ↓
카드/룬 선택 또는 랜덤 뽑기
  ↓
무료 결과 화면
  ↓
Plus AI 해석 유도
  ↓
구독 화면
  ↓
AI 개인화 결과
```

---

## 8. 디자인 방향

### 8.1 디자인 컨셉

키워드:

- 신비로운
- 고급스러운
- 어두운 배경
- 금색 포인트
- 카드 애니메이션
- 별, 달, 빛, 안개 효과

추천 색상:

```text
Background: #11101A
Card: #1D1B2F
Primary: #D6B56D
Accent: #8E6CFF
Text: #F5F1E8
SubText: #A9A2B8
```

---

### 8.2 UX 원칙

- 첫 화면에서 바로 점술을 시작할 수 있어야 한다.
- 회원가입은 나중에 유도한다.
- 무료 결과를 먼저 보여준 뒤 Plus 해석을 자연스럽게 제안한다.
- AI 해석은 “더 깊은 해석 보기” 버튼으로 유도한다.
- 결과 공유 이미지를 제공하면 바이럴에 유리하다.

---

## 9. AI 프롬프트 설계

### 9.1 System Prompt 예시

```text
당신은 전 세계 점술 지식에 기반하여 사용자에게 자기 성찰과 의사결정 참고용 해석을 제공하는 AI 점술 해석가입니다.

규칙:
- 미래를 확정적으로 단정하지 마세요.
- 의료, 법률, 투자 결정은 전문가 상담을 권장하세요.
- 사용자를 불안하게 만들거나 공포를 조장하지 마세요.
- 점술 결과는 오락과 자기 성찰 목적임을 자연스럽게 유지하세요.
- 따뜻하고 차분한 어조로 답변하세요.
```

---

### 9.2 User Prompt Template 예시

```text
사용자 질문:
{{question}}

점술 유형:
{{divination_type}}

선택된 항목:
{{selected_items}}

기본 해석 데이터:
{{base_interpretations}}

분야:
{{category}}

위 정보를 바탕으로 다음 형식의 JSON으로 응답하세요.

{
  "summary": "짧은 요약",
  "detailed_reading": "상세 해석",
  "advice": "현실적인 조언",
  "caution": "주의할 점"
}
```

---

## 10. 보안 및 비용 관리

### 10.1 보안 원칙

- OpenAI API Key는 앱에 포함하지 않는다.
- API Key는 Supabase Edge Function 환경 변수에 저장한다.
- Plus 여부는 서버에서 검증한다.
- 사용량 제한은 서버에서 처리한다.
- RLS 정책으로 사용자별 데이터 접근을 제한한다.

---

### 10.2 비용 관리

무료 사용자는 AI 호출을 하지 않는다.

Plus 사용자도 다음 제한을 둔다.

예시:

```text
Plus 월 구독:
- AI 해석 1일 30회
- 고급 통합 해석 1일 5회
```

비용 추적 항목:

- 사용자별 AI 호출 횟수
- 토큰 사용량
- 모델별 비용
- 실패율
- Plus 전환율

---

## 11. 앱스토어 심사 및 법적 주의사항

점술 서비스는 다음 표현을 피해야 한다.

피해야 할 표현:

```text
100% 정확한 미래 예측
반드시 일어납니다
투자 성공 보장
질병 치료 가능
운명을 바꿔드립니다
```

권장 표현:

```text
오락과 자기 성찰을 위한 서비스입니다.
결과는 참고용이며 중요한 결정은 전문가와 상담하세요.
미래를 확정적으로 보장하지 않습니다.
```

앱 내 고지 문구 예시:

```text
본 서비스의 점술 및 AI 해석 결과는 오락, 자기 성찰, 참고 목적으로 제공됩니다.
의료, 법률, 투자, 심리상담 등 전문적인 판단이 필요한 문제는 반드시 전문가와 상담하시기 바랍니다.
```

---

## 12. MVP 개발 범위

### 12.1 1차 MVP

목표:

> 타로 기반 무료 해석 + Plus AI 해석 구조 검증

기능:

- Flutter 앱 기본 UI
- Supabase Auth 익명 로그인
- 타로 카드 22장 또는 78장 등록
- 무료 해석 DB 구축
- 1장 뽑기
- 3장 뽑기
- 무료 결과 화면
- Plus 구독 화면
- AI 해석 Edge Function
- 사용량 제한
- 결과 기록 저장

---

### 12.2 2차 버전

추가 기능:

- 룬 점술
- 오미쿠지
- 결과 공유 이미지
- 푸시 알림
- 다국어 지원
- 관리자 페이지

---

### 12.3 3차 버전

추가 기능:

- 여러 점술 통합 해석
- 사주/주역 추가
- 오늘의 운세
- 커뮤니티 기능
- 사용자 맞춤 추천

---

## 13. 개발 순서

### Phase 1. 기획 및 콘텐츠 구축

1. 점술 유형 확정
2. 타로 카드 데이터 정리
3. 무료 해석 문장 작성
4. Plus AI 해석 프롬프트 설계
5. 앱 디자인 레퍼런스 수집

---

### Phase 2. 백엔드 구축

1. Supabase 프로젝트 생성
2. DB 테이블 생성
3. RLS 정책 설정
4. Storage 버킷 생성
5. Edge Function 기본 구조 생성
6. OpenAI API 연동

---

### Phase 3. 앱 개발

1. Flutter 프로젝트 생성
2. 앱 테마 적용
3. 홈 화면 개발
4. 점술 선택 화면 개발
5. 타로 카드 뽑기 화면 개발
6. 결과 화면 개발
7. 구독 화면 개발
8. 기록 화면 개발

---

### Phase 4. 결제 및 구독

1. RevenueCat 프로젝트 생성
2. Google Play 상품 등록
3. App Store 상품 등록
4. Flutter RevenueCat SDK 연동
5. Plus 여부 서버 검증

---

### Phase 5. 테스트 및 출시

1. Android 내부 테스트
2. iOS TestFlight 테스트
3. AI 비용 테스트
4. 앱스토어 심사 문구 정리
5. 개인정보처리방침 작성
6. 서비스 이용약관 작성
7. 1차 출시

---

## 14. 폴더 구조 예시

```text
divination_app/
  app/
    flutter_app/
      lib/
        main.dart
        screens/
        widgets/
        services/
        models/
        themes/

  backend/
    supabase/
      migrations/
      functions/
        create-free-reading/
        create-ai-reading/
        check-subscription/
        get-reading-history/

  docs/
    architecture.md
    db_schema.md
    prompt_design.md
    app_store_policy.md

  assets/
    tarot/
    rune/
    omikuji/
```

---

## 15. 최종 추천 방향

가장 현실적인 구현 방향은 다음과 같다.

```text
Flutter 앱
+ Supabase PostgreSQL
+ Supabase Edge Functions
+ 지식창고 기반 무료 해석
+ OpenAI API 기반 Plus 해석
+ RevenueCat 구독 결제
```

이 구조는 다음 장점이 있다.

1. 혼자서도 빠르게 개발 가능하다.
2. 서버 개발 부담이 적다.
3. 디자인 품질을 높이기 쉽다.
4. 무료 사용자의 AI 비용을 최소화할 수 있다.
5. Plus 전환 구조가 명확하다.
6. 이후 다양한 점술 콘텐츠로 확장하기 쉽다.

초기에는 너무 많은 점술을 넣지 말고, 타로를 완성도 있게 구현한 뒤 룬과 오미쿠지를 추가하는 방식이 좋다.

