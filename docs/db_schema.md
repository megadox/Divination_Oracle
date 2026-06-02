# Supabase DB Schema

## 설계 요약

MVP DB는 무료 해석과 Plus AI 해석을 분리한다.

- `profiles`, `subscriptions`, `daily_usage`: 사용자, 구독 상태, 일일 사용량 제한
- `divination_types`, `divination_items`, `interpretations`: 무료 지식창고와 AI 프롬프트 기반 데이터
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

### divination_items

카드, 룬, 오미쿠지 결과 같은 점술 항목이다.

### interpretations

무료 사용자에게 제공되는 고정 해석이며, Plus AI 해석의 참고 지식으로도 사용한다.

주요 컬럼:

- `item_id`
- `orientation`: `upright`, `reversed`, `none`
- `category`: `general`, `love`, `career`, `money`, `health`, `relationship`
- `summary`, `detail`, `advice`, `warning`
- `language_code`

### readings

사용자의 점술 실행 기록이다.

주요 컬럼:

- `user_id`
- `divination_type_id`
- `spread_code`
- `question`
- `category`
- `result_type`: `free`, `plus_ai`
- `result_text`
- `is_ai_generated`

### reading_items

한 번의 점술에서 선택된 항목 목록이다.

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
