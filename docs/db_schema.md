# Supabase DB Schema

## 설계 요약

MVP DB는 무료 해석과 Plus AI 해석을 분리한다.

- `profiles`, `subscriptions`, `daily_usage`: 사용자, 구독 상태, 일일 사용량 제한
- `divination_types`, `divination_items`, `interpretations`: 기존 타로 중심 무료 지식창고
- `divination_input_definitions`, `reading_inputs`, `reading_payloads`: 다중 점술 입력/계산 결과 저장
- `divination_interpretations`: 점술 공통 무료 해석 계층
- `spreads`, `spread_positions`: 타로 리딩 방식과 카드 위치 의미
- `readings`, `reading_items`: 사용자 점술 실행 기록
- `ai_results`, `prompt_templates`: Plus AI 해석 결과와 프롬프트 버전 관리

무료 사용자는 `interpretations` 기반 결과만 받는다. OpenAI API 호출 이력은 `ai_results`에만 저장하며, Plus 사용자 확인과 사용량 차감은 Supabase Edge Function에서 service role로 처리한다.

## 주요 정책

- 공개 콘텐츠 테이블은 인증 사용자에게 읽기 허용
- 사용자별 테이블은 `auth.uid()`와 동일한 행만 읽기 허용
- 클라이언트가 직접 `ai_results`를 생성하지 못하게 하고, Edge Function에서만 insert
- `readings.result_type = 'plus_ai'`는 Plus 검증 후 서버에서 생성

## 테이블

### profiles

Supabase `auth.users`와 1:1로 연결되는 앱 프로필이다.

주요 컬럼:

- `id`: `auth.users.id`
- `display_name`
- `is_anonymous`
- `language_code`
- `timezone`

### subscriptions

RevenueCat 구독 상태 캐시다.

주요 컬럼:

- `user_id`
- `provider`
- `revenuecat_app_user_id`
- `product_id`
- `entitlement_id`
- `status`: `active`, `trial`, `expired`, `cancelled`
- `current_period_start`, `current_period_end`

### daily_usage

일일 무료/AI 사용량을 저장한다.

주요 컬럼:

- `user_id`
- `usage_date`
- `free_reading_count`
- `ai_reading_count`
- `integrated_ai_count`

### divination_types

타로, 룬, 오미쿠지 같은 점술 유형이다.

다중 점술 확장 이후에는 아래 메타데이터를 추가로 가진다.

- `short_description`
- `icon_key`
- `input_mode`: `draw_based`, `birth_data_based`, `hybrid`
- `resolver_type`: `random_draw`, `saju_chart`, `zodiac_sign`, `rule_engine`
- `interpretation_mode`: `prewritten_lookup`, `rule_based`, `lookup_plus_ai`, `rule_plus_ai`

### divination_items

카드, 룬, 오미쿠지 결과 같은 점술 항목이다.

타로 카드 이미지는 `image_url` 컬럼을 재사용하되, 외부 URL 대신 Flutter 로컬 asset 참조를 저장할 수 있다.

예:

```text
asset://tarot/rws_major/fool.jpg
asset://tarot/rws_minor/wands_ace.jpg
```

Flutter 앱은 위 값을 `assets/tarot/rws_major/fool.jpg`, `assets/tarot/rws_minor/wands_ace.jpg`로 변환해 `Image.asset`으로 표시한다.

타로 덱은 Major Arcana 22장 + Minor Arcana 56장 = **78장**이다. Minor 카드 코드는 `{suit}_{rank}` 형식을 사용한다.

### interpretations

무료 사용자에게 제공되는 고정 해석이며, Plus AI 해석의 참고 지식으로도 사용한다.

주요 컬럼:

- `item_id`
- `orientation`: `upright`, `reversed`, `none`
- `category`: `general`, `love`, `career`, `money`, `health`, `relationship`
- `summary`, `detail`, `advice`, `warning`
- `language_code`

현재는 타로 중심 테이블로 유지한다. 다중 점술 일반화는 `divination_interpretations`를 통해 확장한다.

### divination_input_definitions

점술별 입력 필드 정의 테이블이다.

예:

- 타로: `spread_code`
- 사주: `birth_date`, `birth_time`, `calendar_type`, `gender`
- 별자리: `birth_date`

### divination_interpretations

점술 공통 무료 해석 테이블이다.

지원 방식:

- `item_id` 기반 해석
  - 타로, 룬, 오미쿠지
- `interpretation_key` 기반 해석
  - 사주, 별자리, 향후 규칙형 점술

### reading_inputs

사용자가 실제로 입력한 점술 원본값을 저장한다.

예:

- 사주 출생일
- 출생시간
- 양력/음력
- 타로 spread_code

### reading_payloads

계산형 점술 결과 원천 JSON을 저장한다.

예:

- 사주 원국 계산 결과
- 오행 분포
- 별자리 계산 결과

### spreads

타로 리딩 방식이다. 모든 스프레드는 UI에서 일단 제한 없이 보여준다.

주요 컬럼:

- `divination_type_id`
- `code`: `single_question`, `three_card_timeline`, `celtic_cross` 등
- `name`
- `description`
- `card_count`
- `is_plus_only`
- `allow_reversed`

### spread_positions

스프레드 안에서 각 카드가 놓이는 위치 의미다.

주요 컬럼:

- `spread_id`
- `code`: `past`, `present`, `future`, `advice` 등
- `name`
- `description`
- `position_order`

### readings

사용자의 점술 실행 기록이다.

주요 컬럼:

- `user_id`
- `divination_type_id`
- `spread_code`
- `spread_id`
- `question`
- `category`
- `result_type`: `free`, `plus_ai`
- `result_text`
- `is_ai_generated`

### reading_items

한 번의 점술에서 선택된 항목 목록이다.

주요 컬럼:

- `reading_id`
- `item_id`
- `spread_position_id`
- `orientation`
- `position_name`
- `position_order`

### ai_results

Plus AI 해석 결과와 비용 추적 정보다.

주요 컬럼:

- `reading_id`
- `prompt_template_id`
- `model_name`
- `prompt_tokens`, `completion_tokens`, `total_tokens`
- `estimated_cost_usd`
- `prompt_text`
- `result_json`
- `status`, `error_message`

### prompt_templates

AI 프롬프트 템플릿의 버전 관리 테이블이다.

## Migration

초기 스키마는 `supabase/migrations/20260602000001_initial_schema.sql`에 정의한다.
