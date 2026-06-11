# 글로벌 점술 서비스 앱 확장 아키텍처

## 1. 문서 목적

본 문서는 기존 타로 중심 구조를 다수 점술 플랫폼 구조로 확장하기 위한 설계 문서이다.

확장 대상 예시:

- 타로
- 사주
- 룬
- 오미쿠지
- 별자리

핵심 목표는 다음과 같다.

1. 점술이 늘어나도 앱 구조를 다시 갈아엎지 않도록 공통 구조를 만든다.
2. 무료 해석과 Plus AI 해석을 모든 점술에서 일관되게 분리한다.
3. 카드형 점술과 입력형 점술을 모두 수용할 수 있는 구조로 바꾼다.
4. 홈 화면에서 사용자가 점술을 선택하고 진입할 수 있는 UX로 전환한다.

---

## 2. 기존 구조의 한계

기존 구조는 타로를 중심으로 설계되어 있어 다음 문제가 있다.

1. 화면 구조가 `tarot_reading_screen` 같은 점술별 개별 화면 중심이다.
2. DB가 카드/룬 같은 "항목 뽑기형" 점술에 유리하고, 사주처럼 "입력값 계산형" 점술에는 맞지 않는다.
3. 무료 결과 생성 로직이 "카드 선택 -> 해석 조회" 흐름에 치우쳐 있다.
4. AI 프롬프트 구조가 타로 중심이며, 점술 종류별 입력 차이를 충분히 반영하지 못한다.

따라서 앞으로는 `타로 앱`이 아니라 `점술 카탈로그 + 점술 엔진 앱` 구조로 바꾸는 것이 필요하다.

---

## 3. 목표 구조 요약

### 3.1 설계 원칙

- 점술 메타데이터와 점술 실행 로직을 분리한다.
- 점술별 UI는 허용하되, 공통 진입/결과/기록 구조는 재사용한다.
- 점술 타입마다 `입력 방식`, `결과 생성 방식`, `해석 방식`을 설정으로 관리한다.
- AI 호출은 반드시 Plus 사용자에게만 허용한다.
- 무료 결과는 DB 기반 또는 계산 결과 기반의 고정 해석으로 제공한다.

### 3.2 점술 분류 방식

점술은 내부적으로 아래 두 축으로 분류한다.

#### A. 입력 방식 기준

- `draw_based`: 항목을 뽑는 방식
  - 타로, 룬, 오미쿠지
- `birth_data_based`: 생년월일/시간 등 사용자 입력 기반
  - 사주, 별자리
- `hybrid`: 입력값 + 계산 + 룰셋 조합
  - 향후 주역, 베다 점성술 등

#### B. 결과 생성 방식 기준

- `prewritten_lookup`: DB 해석 조회형
- `rule_based`: 계산 규칙 기반 조합형
- `lookup_plus_ai`: DB 해석 + Plus AI 확장형
- `rule_plus_ai`: 계산 결과 + Plus AI 확장형

---

## 4. 서비스 구조

### 4.1 사용자 등급 구조

| 구분 | 무료 사용자 | Plus 사용자 |
|---|---|---|
| 이용 가능 점술 | 일부 또는 제한 제공 | 전체 제공 |
| 기본 해석 | 제공 | 제공 |
| AI 개인화 해석 | 미제공 | 제공 |
| 기록 저장 | 제한 | 전체 저장 |
| 일일 사용량 | 제한 | 확장 |
| 광고 | 표시 가능 | 제거 |
| 고급 통합 해석 | 미제공 | 제공 가능 |

중요 원칙:

- 무료와 Plus의 차이는 "점술 종류"뿐 아니라 "해석 깊이"에서도 구분한다.
- 같은 점술이라도 무료는 고정 해석, Plus는 AI 개인화 해석으로 분리한다.

### 4.2 공통 사용자 흐름

```text
Splash
  ↓
Home
  ↓
점술 선택
  ↓
점술 소개 / 이용 조건 확인
  ↓
질문 입력
  ↓
점술별 입력 단계
  ├─ 타로: 카드 뽑기
  ├─ 룬: 룬 뽑기
  ├─ 오미쿠지: 제비 뽑기
  ├─ 사주: 생년월일/시간/성별 입력
  └─ 별자리: 생년월일 입력
  ↓
무료 결과 생성
  ↓
결과 화면
  ↓
Plus AI 해석 보기
  ↓
구독 또는 AI 결과
```

---

## 5. 핵심 도메인 구조

### 5.1 핵심 개념

#### divination type

앱에서 제공하는 하나의 점술 상품 단위이다.

예시:

- tarot
- saju
- rune
- omikuji
- zodiac

#### input schema

각 점술이 어떤 사용자 입력을 요구하는지 정의한다.

예시:

- 타로: 질문, spread_type
- 사주: 이름, 생년월일, 출생시간, 달력 종류, 성별
- 별자리: 생년월일

#### resolver

점술 결과 원천 데이터를 만드는 로직이다.

예시:

- 타로: 카드 3장 추출
- 룬: 룬 1~3개 추출
- 오미쿠지: 등급 추첨
- 사주: 사주 원국 계산
- 별자리: 태양궁 계산

#### interpretation strategy

무료 결과와 AI 결과를 어떤 방식으로 만드는지 정의한다.

예시:

- 타로: 카드 해석 조회
- 사주: 사주 요소별 의미 조합
- 별자리: 별자리 성향 + 운세 템플릿 조합

### 5.2 추천 아키텍처 패턴

각 점술은 아래 4계층으로 관리한다.

```text
Divination Catalog
  -> Input Schema
  -> Resolver
  -> Interpretation Strategy
  -> Result Presenter
```

설명:

- `Divination Catalog`: 홈/목록에서 보여줄 점술 메타데이터
- `Input Schema`: 점술별 입력 필드 정의
- `Resolver`: 원천 결과 계산 또는 추출
- `Interpretation Strategy`: 무료/Plus 해석 생성 방식
- `Result Presenter`: 결과 화면용 섹션 구성

이 구조를 쓰면 신규 점술 추가 시 "새 점술 모듈 등록" 방식으로 확장할 수 있다.

---

## 6. 점술별 처리 전략

### 6.1 타로

- 입력 방식: `draw_based`
- 결과 생성: 카드/방향/스프레드 추출
- 무료 해석: `interpretations` 조회
- Plus 해석: 카드 배열 + 질문 + 기본 해석 기반 AI 생성

### 6.2 룬

- 입력 방식: `draw_based`
- 결과 생성: 룬 추출
- 무료 해석: 룬별 기본 의미 조회
- Plus 해석: 조합 의미를 AI가 확장

### 6.3 오미쿠지

- 입력 방식: `draw_based`
- 결과 생성: 운세 등급 추첨
- 무료 해석: 등급 + 항목별 문구 조회
- Plus 해석: 질문 맥락을 반영한 AI 확장

### 6.4 사주

- 입력 방식: `birth_data_based`
- 결과 생성: 생년월일시 기반 원국 계산
- 무료 해석: 오행, 일간, 십성, 대운/세운 일부 템플릿 조합
- Plus 해석: 계산 결과 + 질문 + 사용자 맥락 기반 AI 설명

사주는 카드형 점술과 다르므로 별도 포인트가 필요하다.

1. 사용자 입력 검증이 중요하다.
2. 양력/음력, 출생시간 미상 여부를 다뤄야 한다.
3. 결과 원천은 랜덤 추출이 아니라 계산이다.
4. 해석 데이터는 단일 item lookup보다 복수 규칙 조합이 더 많다.

### 6.5 별자리

- 입력 방식: `birth_data_based`
- 결과 생성: 태양궁 또는 확장 시 출생 차트 계산
- 무료 해석: 성향/오늘의 운세/카테고리별 템플릿
- Plus 해석: 질문 기반 개인화 해석

---

## 7. DB 구조 개편안

기존 `divination_items` 중심 구조는 유지하되, 계산형 점술을 수용하기 위해 메타/입력/결과 스키마를 분리한다.

### 7.1 ERD 개요

```text
users
 └── readings
      ├── reading_inputs
      ├── reading_items
      ├── reading_payloads
      └── ai_results

divination_types
 ├── divination_input_definitions
 ├── divination_content_items
 ├── divination_interpretations
 └── divination_prompt_profiles

subscriptions
usage_limits
```

### 7.2 핵심 테이블

#### divination_types

점술 카탈로그의 최상위 메타데이터이다.

```sql
create table divination_types (
    id uuid primary key default gen_random_uuid(),
    code text unique not null,
    name text not null,
    short_description text,
    description text,
    icon_key text,
    banner_image_url text,
    input_mode text not null,
    resolver_type text not null,
    interpretation_mode text not null,
    is_premium_only boolean default false,
    is_active boolean default true,
    sort_order int default 0,
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

예시:

```text
tarot    | input_mode=draw_based       | resolver_type=random_draw
saju     | input_mode=birth_data_based | resolver_type=saju_chart
rune     | input_mode=draw_based       | resolver_type=random_draw
omikuji  | input_mode=draw_based       | resolver_type=random_draw
zodiac   | input_mode=birth_data_based | resolver_type=zodiac_sign
```

#### divination_input_definitions

점술별 입력 폼 구성을 관리한다.

```sql
create table divination_input_definitions (
    id uuid primary key default gen_random_uuid(),
    divination_type_id uuid references divination_types(id),
    field_key text not null,
    field_label text not null,
    field_type text not null,
    is_required boolean default true,
    options_json jsonb,
    placeholder text,
    help_text text,
    sort_order int default 0,
    created_at timestamp default now()
);
```

예시:

```text
saju.birth_date
saju.birth_time
saju.calendar_type
saju.gender
tarot.spread_type
```

#### divination_content_items

카드, 룬, 오미쿠지 결과 등 "콘텐츠 항목형" 점술에 사용한다.

```sql
create table divination_content_items (
    id uuid primary key default gen_random_uuid(),
    divination_type_id uuid references divination_types(id),
    code text not null,
    name text not null,
    display_name text,
    image_url text,
    metadata_json jsonb,
    order_no int default 0,
    is_active boolean default true,
    created_at timestamp default now()
);
```

설명:

- 타로 카드 정보 저장
- 룬 문자 정보 저장
- 오미쿠지 등급/항목 저장
- 계산형 점술은 필수는 아니다

#### divination_interpretations

무료 해석과 기본 해석 문장을 저장한다.

```sql
create table divination_interpretations (
    id uuid primary key default gen_random_uuid(),
    divination_type_id uuid references divination_types(id),
    item_id uuid null references divination_content_items(id),
    interpretation_key text,
    category text default 'general',
    variant text default 'default',
    summary text not null,
    detail text,
    advice text,
    warning text,
    language_code text default 'ko',
    tags text[],
    created_at timestamp default now(),
    updated_at timestamp default now()
);
```

활용 방식:

- 타로: `item_id + category + variant(upright/reversed)`
- 룬: `item_id + category`
- 오미쿠지: `item_id + category`
- 사주: `interpretation_key` 기반 규칙 문구
  - 예: `day_master_gapwood`, `five_elements_fire_strong`
- 별자리: `interpretation_key` 기반 문구
  - 예: `zodiac_aries_general`

#### readings

점술 실행 단위이다.

```sql
create table readings (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id),
    divination_type_id uuid references divination_types(id),
    question text,
    category text default 'general',
    result_mode text not null default 'free',
    status text not null default 'completed',
    summary text,
    result_text text,
    language_code text default 'ko',
    created_at timestamp default now()
);
```

#### reading_inputs

점술 실행 시 사용자가 입력한 원본값을 저장한다.

```sql
create table reading_inputs (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    field_key text not null,
    field_value text,
    field_value_json jsonb,
    created_at timestamp default now()
);
```

예시:

- 사주 출생일시
- 성별
- 양력/음력
- 타로 spread_type

#### reading_items

추첨 또는 선택된 항목을 저장한다.

```sql
create table reading_items (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    item_id uuid references divination_content_items(id),
    variant text default 'default',
    position_name text,
    position_order int default 0,
    created_at timestamp default now()
);
```

예시:

- 타로 카드 3장
- 룬 2개
- 오미쿠지 등급

#### reading_payloads

계산형 점술의 구조화된 결과 원천 데이터를 저장한다.

```sql
create table reading_payloads (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    payload_type text not null,
    payload_json jsonb not null,
    created_at timestamp default now()
);
```

예시:

- 사주 원국 계산 결과
- 오행 분포
- 별자리 계산 결과

#### ai_results

Plus AI 해석 저장 테이블이다.

```sql
create table ai_results (
    id uuid primary key default gen_random_uuid(),
    reading_id uuid references readings(id),
    model_name text,
    prompt_profile_code text,
    prompt_tokens int,
    completion_tokens int,
    total_tokens int,
    result_json jsonb,
    created_at timestamp default now()
);
```

### 7.3 핵심 변경 포인트

기존 대비 중요한 변경은 다음과 같다.

1. `divination_items`를 `divination_content_items`로 일반화한다.
2. `reading_inputs`를 추가해 사주 같은 입력형 점술을 저장한다.
3. `reading_payloads`를 추가해 계산 결과를 구조화 저장한다.
4. 무료/AI 결과를 모두 `readings` 중심으로 모으고, 세부 원천은 분리한다.

---

## 8. API / Edge Function 설계

### 8.1 get-divination-catalog

홈 화면과 점술 선택 화면에서 사용할 목록 API이다.

```text
GET /functions/v1/get-divination-catalog
```

응답 예시:

```json
[
  {
    "code": "tarot",
    "name": "타로",
    "short_description": "카드로 현재 흐름과 조언을 살펴봅니다.",
    "input_mode": "draw_based",
    "is_premium_only": false
  },
  {
    "code": "saju",
    "name": "사주",
    "short_description": "생년월일시를 바탕으로 기질과 흐름을 봅니다.",
    "input_mode": "birth_data_based",
    "is_premium_only": false
  }
]
```

### 8.2 get-divination-detail

선택한 점술의 소개, 입력 필드, 무료/Plus 정책을 내려준다.

```text
GET /functions/v1/get-divination-detail?code=saju
```

### 8.3 create-free-reading

무료 점술 결과 생성 API이다.

```text
POST /functions/v1/create-free-reading
```

요청 예시:

```json
{
  "user_id": "uuid",
  "divination_code": "saju",
  "question": "올해 이직운이 궁금해요.",
  "category": "career",
  "inputs": {
    "birth_date": "1994-03-21",
    "birth_time": "14:30",
    "calendar_type": "solar",
    "gender": "female"
  }
}
```

처리 순서:

1. 사용자 사용량 확인
2. 점술 타입 로딩
3. 입력 검증
4. resolver 실행
5. 무료 해석 조합
6. readings 및 하위 데이터 저장
7. 결과 반환

### 8.4 create-ai-reading

Plus 사용자 전용 개인화 해석 API이다.

```text
POST /functions/v1/create-ai-reading
```

처리 순서:

1. 서버에서 Plus 구독 상태 확인
2. 무료 결과의 원천 데이터 재조회
3. 점술 타입별 프롬프트 프로필 로딩
4. AI 호출
5. 결과 저장
6. 응답 반환

중요 원칙:

- 앱에서 OpenAI API 직접 호출 금지
- 서버에서만 Plus 여부 확인 후 AI 호출
- 무료 사용자는 어떤 점술이든 AI 요청 불가

### 8.5 get-reading-history

기록 화면에서 점술 유형별 필터를 지원한다.

```text
GET /functions/v1/get-reading-history?user_id={user_id}&divination_code=tarot
```

---

## 9. Flutter 앱 구조 개편안

점술마다 화면 파일을 늘리는 방식 대신, 공통 흐름 + 타입별 컴포넌트 구조로 바꾸는 것이 좋다.

### 9.1 추천 폴더 구조

```text
/lib
  /app
    app.dart
    router.dart

  /core
    /theme
    /network
    /widgets
    /utils

  /features
    /home
    /catalog
    /reading
    /history
    /subscription
    /settings

  /divinations
    /shared
      divination_definition.dart
      divination_registry.dart
      reading_input_schema.dart
      reading_result_mapper.dart

    /tarot
      tarot_definition.dart
      tarot_input_widget.dart
      tarot_resolve_request.dart
      tarot_result_sections.dart

    /saju
      saju_definition.dart
      saju_input_widget.dart
      saju_result_sections.dart

    /rune
      rune_definition.dart
      rune_input_widget.dart
      rune_result_sections.dart

    /omikuji
      omikuji_definition.dart
      omikuji_input_widget.dart
      omikuji_result_sections.dart

    /zodiac
      zodiac_definition.dart
      zodiac_input_widget.dart
      zodiac_result_sections.dart

  /data
    /models
    /repositories
    /services
```

### 9.2 핵심 구조 설명

#### `features`

앱의 공통 사용자 흐름을 관리한다.

- 홈
- 점술 선택
- 공통 결과 화면
- 기록
- 구독

#### `divinations`

점술별 정의와 전용 UI를 관리한다.

각 점술은 아래를 가진다.

- 점술 메타 정의
- 입력 위젯
- 요청 매핑 로직
- 결과 섹션 렌더링 로직

#### `divination_registry`

앱 시작 시 지원하는 점술 정의를 등록하는 레지스트리이다.

예시 역할:

- 코드로 점술 모듈 조회
- 각 점술의 입력 화면 연결
- 결과 화면 섹션 구성 연결

### 9.3 화면 설계

#### 1. HomeScreen

역할:

- 대표 배너
- 오늘 추천 점술
- 점술 카탈로그 진입
- 최근 기록 바로가기

추천 섹션:

- 오늘의 메시지
- 인기 점술
- 새로 추가된 점술
- Plus 전용 배너

#### 2. DivinationCatalogScreen

역할:

- 사용 가능한 점술 목록 표시
- 점술별 설명, 소요 시간, 무료/Plus 여부 표시
- 카테고리 필터 제공

카드 예시 정보:

- 점술 이름
- 한 줄 설명
- 입력 방식
- 추천 상황
- 무료 가능 여부

#### 3. DivinationIntroScreen

역할:

- 선택한 점술의 설명 제공
- 필요한 입력값 안내
- 주의사항 안내
- 시작 버튼 제공

사주 예시 안내:

- 생년월일과 출생시간이 필요합니다.
- 출생시간을 모르면 일부 정확도가 낮아질 수 있습니다.

#### 4. QuestionInputScreen

역할:

- 공통 질문 입력
- 카테고리 선택
- 질문 없이 진행도 허용 가능

#### 5. DivinationInputScreen

공통 컨테이너 화면이며, 내부는 점술별 위젯으로 교체한다.

예시:

- 타로: spread 선택 + 카드 뽑기
- 사주: 생년월일/시간/성별 입력 폼
- 오미쿠지: 바로 뽑기 애니메이션

#### 6. FreeResultScreen

공통 결과 화면이다.

공통 섹션:

- 요약
- 핵심 해석
- 조언
- 주의할 점
- 선택/계산 원천 결과

점술별 확장 섹션:

- 타로: 뽑은 카드 리스트
- 사주: 오행 분포, 일간 설명
- 별자리: 별자리 성향 카드

#### 7. PlusUpsellSheet / SubscriptionScreen

역할:

- "더 깊은 AI 해석 보기" 유도
- Plus 혜택 설명
- AI 해석 예시 미리보기 제공

#### 8. AiResultScreen

역할:

- 무료 결과보다 더 긴 개인화 해석 제공
- 질문 맥락 반영
- 실행 가능한 조언 제시

#### 9. HistoryScreen

역할:

- 전체 기록 보기
- 점술 유형별 필터
- 무료/AI 결과 구분

---

## 10. 공통 결과 모델 설계

UI와 API를 단순화하기 위해 점술별 결과를 공통 구조로 매핑한다.

### 10.1 공통 응답 모델 예시

```json
{
  "reading_id": "uuid",
  "divination_code": "saju",
  "result_mode": "free",
  "summary": "올해는 기반을 다지는 흐름이 강합니다.",
  "sections": [
    {
      "type": "core_interpretation",
      "title": "핵심 해석",
      "body": "지금은 크게 확장하기보다..."
    },
    {
      "type": "advice",
      "title": "조언",
      "body": "이직을 서두르기보다 준비를 먼저..."
    }
  ],
  "source_items": [],
  "source_payload": {
    "day_master": "갑목",
    "five_elements": {
      "wood": 3,
      "fire": 1,
      "earth": 2,
      "metal": 0,
      "water": 2
    }
  }
}
```

장점:

1. 결과 화면을 공통화할 수 있다.
2. 신규 점술 추가 시 프론트 변경 범위를 줄일 수 있다.
3. AI 결과도 동일 구조로 확장 가능하다.

---

## 11. 프롬프트 설계 방향

AI 프롬프트는 점술 공통 베이스 + 점술별 프로필로 나누는 것이 좋다.

### 11.1 공통 시스템 프롬프트

역할:

- 안전성
- 비확정적 표현
- 자기성찰 중심 표현
- 법률/의료/투자 고위험 문구 제한

### 11.2 점술별 프롬프트 프로필

예시:

- `tarot_ko_v1`
- `saju_ko_v1`
- `rune_ko_v1`
- `zodiac_ko_v1`

사주 프롬프트에는 추가로 아래 요소가 필요하다.

- 사주 계산 결과 설명 방식
- 지나치게 단정적 운명론 금지
- 출생시간 불명 시 불확실성 명시

---

## 12. 무료/Plus 분리 원칙

모든 점술에서 아래 규칙을 고정한다.

### 무료

- DB 또는 규칙 기반 고정 해석만 제공
- OpenAI API 호출 없음
- 응답 속도와 비용 안정성 우선

### Plus

- 무료 결과를 바탕으로 AI 개인화 해석 제공
- 질문 맥락 반영
- 더 긴 설명과 상황별 조언 제공

중요:

- Plus 해석은 무료 해석을 대체하는 것이 아니라 확장하는 방식이 좋다.
- 무료 결과를 먼저 보여주고, 이후 Plus 해석으로 자연스럽게 전환한다.

---

## 13. 단계별 개발 권장 순서

### Phase 1. 구조 개편

1. 점술 카탈로그 개념 도입
2. `divination_types` 확장
3. `reading_inputs`, `reading_payloads` 추가
4. Flutter `features` / `divinations` 구조로 정리

### Phase 2. 공통 화면 구축

1. HomeScreen 개편
2. DivinationCatalogScreen 추가
3. DivinationIntroScreen 추가
4. 공통 ResultScreen 리팩터링

### Phase 3. 기존 타로 이관

1. 타로를 새 registry 구조로 옮김
2. 기존 타로 결과를 공통 결과 모델로 매핑
3. 무료/AI 흐름 유지 검증

### Phase 4. 사주 추가

1. 사주 입력 폼 추가
2. 사주 계산 로직 연결
3. 사주 무료 해석 규칙 설계
4. 사주 Plus 프롬프트 추가

### Phase 5. 룬/오미쿠지/별자리 추가

1. draw_based 점술 재사용 구조 검증
2. birth_data_based 점술 재사용 구조 검증
3. 카탈로그와 기록 화면 필터 완성

---

## 14. 마이그레이션 권장 사항

DB 변경 시 migration 파일 생성 원칙에 맞춰 아래 순서로 진행하는 것이 좋다.

1. `divination_types` 확장 migration
2. `divination_input_definitions` 생성 migration
3. `divination_content_items` 생성 또는 기존 `divination_items` rename migration
4. `divination_interpretations` 생성 또는 기존 `interpretations` 확장 migration
5. `reading_inputs` 생성 migration
6. `reading_payloads` 생성 migration
7. 기존 타로 데이터 이관 migration

주의:

- 기존 운영 데이터가 있다면 rename + backfill 전략이 안전하다.
- 신규 개발 초기라면 재정의 후 seed 재구축이 더 단순할 수 있다.

---

## 15. 최종 추천 방향

추천 방향은 다음 한 줄로 정리할 수 있다.

> "점술별 화면을 계속 추가하는 구조"가 아니라 "점술 카탈로그 + 점술 모듈 등록 구조"로 전환한다.

특히 사주 추가를 고려하면 앞으로의 기준은 타로가 아니라 아래 세 가지여야 한다.

1. 점술별 입력 방식이 달라도 수용 가능한가
2. 무료/Plus 해석 분리가 유지되는가
3. 신규 점술 추가 시 공통 화면과 공통 데이터 모델을 재사용할 수 있는가

이 기준으로 보면 가장 적합한 구조는 다음과 같다.

```text
Flutter App
+ Divination Catalog
+ Divination Registry
+ Common Reading Flow
+ Type-specific Input UI

Supabase
+ Divination Metadata
+ Free Interpretation Data
+ Reading Inputs / Items / Payloads
+ Edge Functions

OpenAI API
+ Plus User Only
+ Type-specific Prompt Profiles
```

이 구조로 가면 타로 이후 사주, 룬, 오미쿠지, 별자리를 추가할 때도 큰 재설계 없이 확장할 수 있다.
