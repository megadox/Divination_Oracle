# 다중 점술 DB 마이그레이션 설계안

## 1. 문서 목적

본 문서는 현재 타로 중심 Supabase 스키마를 다중 점술 구조로 확장하기 위한 DB 마이그레이션 설계안이다.

대상:

- 타로 유지
- 사주 추가
- 룬, 오미쿠지, 별자리 추가 준비

목표:

1. 기존 타로 기능을 깨지 않고 확장한다.
2. 입력형 점술과 추첨형 점술을 모두 저장할 수 있게 한다.
3. 무료/Plus 분리 원칙을 DB와 Edge Function 레벨에서 유지한다.

---

## 2. 현재 스키마 기준 핵심 한계

현재 스키마는 아래 흐름에 최적화되어 있다.

```text
divination_types
  -> divination_items
  -> interpretations

readings
  -> reading_items
```

이 구조의 한계:

1. `divination_items`가 카드/룬 같은 "항목" 중심이라 사주 입력값 저장이 어렵다.
2. `readings`가 `spread_code`를 직접 가지므로 타로 전용 성격이 강하다.
3. 계산형 결과를 구조화해 저장할 테이블이 없다.
4. 점술별 입력 폼을 서버 메타데이터로 내려주기 어렵다.

---

## 3. 마이그레이션 전략

### 3.1 기본 원칙

- 기존 테이블을 즉시 삭제하지 않는다.
- rename보다 additive migration을 우선한다.
- 앱/Edge Function 이관 완료 후 정리 migration을 별도로 둔다.

이유:

- 현재 `create-free-reading`, `create-ai-reading`, Flutter 앱이 기존 스키마에 의존하고 있다.
- 신규 구조를 먼저 추가한 뒤 타로를 이관하는 방식이 회귀 위험이 낮다.

### 3.2 권장 방식

Phase A:

- 신규 메타/입력/페이로드 테이블 추가
- 기존 테이블 유지

Phase B:

- 타로를 신규 구조도 함께 쓰도록 Edge Function 수정

Phase C:

- 사주/별자리 추가

Phase D:

- 구 스키마 명칭 정리 또는 통합

---

## 4. 제안하는 스키마 변경

### 4.1 `divination_types` 확장

기존 테이블에 아래 컬럼을 추가한다.

추가 컬럼:

- `short_description text`
- `icon_key text`
- `banner_image_url text`
- `input_mode text not null default 'draw_based'`
- `resolver_type text not null default 'random_draw'`
- `interpretation_mode text not null default 'prewritten_lookup'`

체크 제약 예시:

```text
input_mode:
- draw_based
- birth_data_based
- hybrid

resolver_type:
- random_draw
- saju_chart
- zodiac_sign
- rule_engine

interpretation_mode:
- prewritten_lookup
- rule_based
- lookup_plus_ai
- rule_plus_ai
```

### 4.2 `divination_input_definitions` 신설

역할:

- 점술별 입력 필드 정의
- 앱 동적 폼 구성
- 필수/선택 여부 제어

예시 컬럼:

```sql
create table public.divination_input_definitions (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  field_key text not null,
  field_label text not null,
  field_type text not null,
  is_required boolean not null default true,
  options_json jsonb not null default '[]'::jsonb,
  placeholder text,
  help_text text,
  validation_json jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (divination_type_id, field_key)
);
```

활용 예시:

- 타로: `spread_code`
- 사주: `birth_date`, `birth_time`, `calendar_type`, `gender`
- 별자리: `birth_date`

### 4.3 `reading_inputs` 신설

역할:

- 사용자 입력 원본 저장
- 사주/별자리 같은 입력형 점술 지원
- 타로의 `spread_code`도 장기적으로 이관 가능

예시 컬럼:

```sql
create table public.reading_inputs (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null references public.readings(id) on delete cascade,
  field_key text not null,
  field_value text,
  field_value_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
```

### 4.4 `reading_payloads` 신설

역할:

- 계산형 점술의 결과 원천 저장
- 무료/AI 결과 재생성 가능성 확보

예시 컬럼:

```sql
create table public.reading_payloads (
  id uuid primary key default gen_random_uuid(),
  reading_id uuid not null references public.readings(id) on delete cascade,
  payload_type text not null,
  payload_json jsonb not null,
  created_at timestamptz not null default now()
);
```

예시:

- `payload_type = 'saju_chart'`
- `payload_type = 'five_elements_summary'`
- `payload_type = 'zodiac_profile'`

### 4.5 `interpretations` 확장 또는 신규 일반화

선택지 2개가 있다.

#### 선택지 A. 기존 `interpretations` 확장

추가 컬럼:

- `divination_type_id uuid`
- `interpretation_key text`
- `variant text default 'default'`

장점:

- 기존 코드 수정량이 작다.

단점:

- `item_id not null` 제약이 사주 같은 규칙형 해석과 충돌한다.

#### 선택지 B. `divination_interpretations` 신규 생성

추천한다.

이유:

- `item_id` 기반 해석과 `interpretation_key` 기반 해석을 자연스럽게 공존시킬 수 있다.
- 기존 타로 해석은 이관 전까지 유지 가능하다.

추천 스키마:

```sql
create table public.divination_interpretations (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references public.divination_types(id) on delete cascade,
  item_id uuid references public.divination_items(id) on delete cascade,
  interpretation_key text,
  category text not null default 'general',
  variant text not null default 'default',
  summary text not null,
  detail text,
  advice text,
  warning text,
  tags text[] not null default '{}',
  language_code text not null default 'ko',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint divination_interpretations_item_or_key_check
    check (item_id is not null or interpretation_key is not null)
);
```

### 4.6 `readings` 확장

기존 `readings`는 유지하되 아래 방향으로 확장한다.

권장 추가 컬럼:

- `status text not null default 'completed'`
- `summary text`

권장 변경:

- `spread_code`는 당장 유지
- 향후 타로 외 점술에서는 nullable로 완화 검토

실무적으로는 바로 nullable로 바꾸기보다 아래 순서를 추천한다.

1. 신규 점술 생성 시 `spread_code = 'default'` 허용
2. 앱/함수 이관 후 nullable 변경 또는 제거

### 4.7 `prompt_templates` 유지 + 프로필 개념 추가

현재 `prompt_templates`는 계속 사용할 수 있다.

다만 코드 체계를 아래처럼 바꾸는 것을 추천한다.

- `plus_tarot_reading_ko_v1`
- `plus_saju_reading_ko_v1`
- `plus_rune_reading_ko_v1`

즉 별도 테이블 추가보다 naming convention 정리가 먼저다.

---

## 5. 테이블별 마이그레이션 순서

### Step 1. `divination_types` 확장

목적:

- 점술 메타데이터를 UI/서버 공통 기준으로 만든다.

예상 migration:

- `20260611xxxx01_expand_divination_types_for_multi_divination.sql`

### Step 2. `divination_input_definitions` 생성

목적:

- 점술별 입력 스키마 등록 가능하게 한다.

예상 migration:

- `20260611xxxx02_create_divination_input_definitions.sql`

### Step 3. `reading_inputs` 생성

목적:

- 사주 입력값 저장
- 타로 spread 이관 준비

예상 migration:

- `20260611xxxx03_create_reading_inputs.sql`

### Step 4. `reading_payloads` 생성

목적:

- 계산형 결과 저장

예상 migration:

- `20260611xxxx04_create_reading_payloads.sql`

### Step 5. `divination_interpretations` 생성

목적:

- item 기반과 rule 기반 해석 동시 지원

예상 migration:

- `20260611xxxx05_create_divination_interpretations.sql`

### Step 6. 신규 점술 seed 추가

추가 대상:

- `saju`
- `zodiac`
- 필요 시 `rune`, `omikuji` 메타 보강

예상 migration:

- `20260611xxxx06_seed_multi_divination_types.sql`

### Step 7. 타로 해석 백필

작업:

- 기존 `interpretations` -> `divination_interpretations` 복사

예상 migration:

- `20260611xxxx07_backfill_tarot_interpretations.sql`

---

## 6. 백필 전략

### 6.1 타로 데이터

타로는 이미 `divination_items`, `interpretations`, `spreads`, `spread_positions`가 있으므로 아래처럼 이관한다.

1. `divination_types`의 `tarot`에 메타 필드 업데이트
2. `divination_input_definitions`에 `spread_code` 등록
3. 기존 `interpretations`를 `divination_interpretations`로 복사
4. Edge Function은 우선 타로에서 신규/기존 해석 테이블 중 하나만 읽도록 고정

추천:

- 백필 완료 후 읽기는 신규 `divination_interpretations`만 사용

### 6.2 기록 데이터

기존 `readings`/`reading_items`는 그대로 유지 가능하다.

선택적 백필:

- 과거 타로 리딩의 `spread_code`를 `reading_inputs`에도 저장

하지만 필수는 아니다. 과거 데이터는 레거시 형식으로 두고 신규 생성분부터 `reading_inputs`를 쓰는 편이 현실적이다.

---

## 7. RLS 정책 추가 방향

신규 테이블에도 현재 정책 철학을 유지한다.

### `divination_input_definitions`

- 인증 사용자 read 허용
- client write 금지

### `divination_interpretations`

- 활성 데이터 read 허용
- client write 금지

### `reading_inputs`

- 본인 reading에 속한 데이터만 read 허용
- insert는 본인 free reading 또는 Edge Function 허용

### `reading_payloads`

- 본인 reading에 속한 데이터만 read 허용
- client direct insert는 지양
- Edge Function/service role에서 생성

---

## 8. Edge Function 영향 범위

### `create-free-reading`

변경 필요:

1. `divination_code`별 분기 추가
2. 입력 검증 로직 추가
3. 타로는 기존 로직 유지
4. 사주는 resolver 결과를 `reading_payloads`에 저장
5. 공통 결과 JSON 구조로 응답 정리

### `create-ai-reading`

변경 필요:

1. 기존 Plus 검증 유지
2. 점술별 prompt template 선택
3. 타로는 `reading_items` 기반
4. 사주는 `reading_payloads` 기반

### 신규 함수 추천

- `get-divination-catalog`
- `get-divination-detail`

이 2개는 앱 홈/선택 화면 개편에 필요하다.

---

## 9. 사주 추가를 위한 최소 스키마 세트

사주를 가장 빠르게 붙이려면 아래까지만 먼저 있어도 된다.

필수:

1. `divination_types` 확장
2. `divination_input_definitions`
3. `reading_inputs`
4. `reading_payloads`
5. `prompt_templates`에 사주 프롬프트 추가

선택:

6. `divination_interpretations`

만약 초기 사주 무료 해석을 코드 내부 규칙 조합으로 먼저 구현한다면, `divination_interpretations` 없이도 시작은 가능하다. 하지만 장기적으로는 DB화하는 편이 운영성이 훨씬 좋다.

---

## 10. 권장 구현 순서

1. `divination_types` 확장 migration 작성
2. `divination_input_definitions`, `reading_inputs`, `reading_payloads` migration 작성
3. `get-divination-catalog`, `get-divination-detail` 추가
4. Flutter 홈을 점술 선택형으로 개편
5. 타로를 registry 구조로 이관
6. 사주 입력/결과 추가
7. `divination_interpretations`로 무료 해석 운영 체계 통합

---

## 11. 결론

이번 확장에서 가장 중요한 점은 "사주를 위한 예외 구조"를 만드는 것이 아니라, 사주도 들어갈 수 있는 공통 구조를 만드는 것이다.

DB 기준 핵심 추가는 아래 3개다.

1. `divination_input_definitions`
2. `reading_inputs`
3. `reading_payloads`

그리고 해석 계층을 일반화하려면 최종적으로 아래까지 가는 것이 가장 안정적이다.

4. `divination_interpretations`

즉, 추천 전략은 다음과 같다.

> 기존 타로 스키마를 바로 뒤엎지 말고, 입력형/계산형 점술을 위한 테이블을 먼저 additive하게 추가한 뒤 타로부터 점진적으로 새 구조로 이관한다.
