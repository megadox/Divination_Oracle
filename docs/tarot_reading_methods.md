# 타로 리딩 방식 정리

## 설계 요약

타로는 단순히 카드를 랜덤으로 뽑는 기능이 아니라, 질문의 성격에 맞는 `스프레드(spread)`를 선택하고 각 카드의 `위치(position)` 의미를 함께 해석하는 흐름이다.

현재 앱은 질문, 분야, 무료/Plus 버튼 중심으로 구성되어 있다. 타로 중심 MVP로 가려면 화면을 아래 흐름으로 재구성한다.

```text
홈
 -> 질문 입력
 -> 분야 선택
 -> 스프레드 선택
 -> 카드 뽑기
 -> 결과 해석
```

무료 사용자는 DB 기반 고정 해석을 조합한다. Plus 사용자는 같은 카드, 방향, 포지션, 기본 해석을 AI 프롬프트에 넣어 개인화 해석을 생성한다.

## 핵심 개념

### 카드

타로 카드는 보통 78장이다.

- Major Arcana 22장
- Minor Arcana 56장

MVP에서는 Major Arcana 22장으로 시작했고, 현재는 Minor Arcana 56장까지 포함한 **78장 전체** 덱을 사용한다.

### 카드 코드 규칙

- Major: `fool`, `magician`, `star` 등 (`metadata.arcana = major`)
- Minor: `{suit}_{rank}` 예) `wands_ace`, `cups_knight`, `pentacles_ten` (`metadata.arcana = minor`)
- 이미지:
  - Major: `asset://tarot/rws_major/<code>.jpg`
  - Minor: `asset://tarot/rws_minor/<code>.jpg`

### 방향

카드는 보통 두 방향으로 해석한다.

- `upright`: 정방향
- `reversed`: 역방향

초보자용 모드에서는 역방향을 끌 수 있게 할 수도 있다. 무료 MVP에서는 정방향/역방향 모두 지원하되, 스프레드 설정에서 역방향 허용 여부를 둘 수 있다.

### 스프레드

스프레드는 한 번의 리딩에서 몇 장을 어떤 위치 의미로 뽑는지 정의한다.

예:

- 1장: 지금의 핵심 메시지
- 3장: 과거/현재/미래
- 선택지 비교: A/B 선택의 흐름
- 켈틱 크로스: 깊은 종합 분석

### 포지션

같은 카드라도 놓인 위치에 따라 의미가 달라진다.

예:

```text
The Fool + past: 과거에 시작한 흐름
The Fool + present: 현재의 도전과 가능성
The Fool + future: 앞으로 열릴 새 출발
```

따라서 해석 조합은 최소한 아래 요소를 함께 고려해야 한다.

```text
카드 + 방향 + 분야 + 스프레드 포지션
```

## 추천 스프레드 목록

### 1. Daily One Card

코드:

```text
daily_one_card
```

카드 수:

```text
1
```

포지션:

```text
message
```

용도:

- 오늘의 운세
- 가벼운 조언
- 앱 첫 화면에서 가장 빠른 무료 경험

무료/Plus:

- 무료 제공

화면:

- 질문 입력 없이도 실행 가능
- “오늘의 카드” UX로 분리 가능

### 2. Single Question

코드:

```text
single_question
```

카드 수:

```text
1
```

포지션:

```text
answer
```

용도:

- 특정 질문에 대한 핵심 메시지
- 현재 앱의 `single`을 대체할 기본 질문 리딩

무료/Plus:

- 무료 제공

화면:

- 질문 입력
- 분야 선택
- 1장 뽑기

### 3. Three Card Timeline

코드:

```text
three_card_timeline
```

카드 수:

```text
3
```

포지션:

```text
past
present
future
```

용도:

- 상황의 흐름 파악
- 직업, 연애, 관계 질문에 잘 맞음

무료/Plus:

- 무료 제공 가능
- Plus에서는 각 카드 연결성을 더 자세히 설명

화면:

- 3장의 카드 슬롯을 가로 또는 세로로 배치
- 각 슬롯에 포지션 라벨 표시

### 4. Situation Advice

코드:

```text
situation_advice
```

카드 수:

```text
3
```

포지션:

```text
situation
challenge
advice
```

용도:

- 문제 해결형 질문
- “어떻게 해야 할까요?”에 적합

무료/Plus:

- 무료 제공 가능
- Plus 전환 유도에 좋음

화면:

- 상황, 장애물, 조언을 명확히 나눠 보여준다.

### 5. Choice A/B

코드:

```text
choice_ab
```

카드 수:

```text
5
```

포지션:

```text
current
option_a
option_a_outcome
option_b
option_b_outcome
```

용도:

- 선택지 비교
- 이직/연애/금전 결정 질문

무료/Plus:

- Plus 추천

화면:

- A/B 열을 나눈 비교형 UI
- 질문 입력 외에 선택지 A, 선택지 B 입력 필드 필요

### 6. Relationship Spread

코드:

```text
relationship
```

카드 수:

```text
5
```

포지션:

```text
me
other
connection
challenge
advice
```

용도:

- 연애, 인간관계

무료/Plus:

- Plus 추천

화면:

- 나/상대/관계 중심 구조
- 민감한 관계 질문에 대한 고지 문구 필요

### 7. Celtic Cross

코드:

```text
celtic_cross
```

카드 수:

```text
10
```

포지션:

```text
present
challenge
past
future
above
below
advice
external
hopes_fears
outcome
```

용도:

- 깊은 종합 분석

무료/Plus:

- Plus 전용 추천

화면:

- 모바일에서 복잡하므로 상세 리딩 화면에 접이식 섹션 필요
- 카드 배치보다 해석 읽기 편의성이 우선

## MVP 추천 범위

1차 MVP에서는 너무 많은 스프레드를 넣지 않는다.

추천:

```text
무료:
- daily_one_card
- single_question
- three_card_timeline

Plus:
- situation_advice
- choice_ab
- relationship
- celtic_cross
```

초기 구현은 아래 3개만 충분하다.

```text
single_question
three_card_timeline
situation_advice
```

이 3개면 질문형, 흐름형, 조언형을 모두 검증할 수 있다.

## 화면 구조 제안

### HomeScreen

역할:

- 오늘의 카드 진입
- 질문 리딩 시작
- 기록/Plus 진입

구성:

```text
상단: 앱 제목, 기록, Plus
본문:
  - 오늘의 카드 버튼
  - 질문 입력 영역
  - 분야 선택
  - 스프레드 선택 카드 목록
```

현재처럼 모든 점술 유형 버튼을 한 화면에 놓기보다, MVP에서는 타로 리딩 작성 화면으로 가는 것이 더 자연스럽다.

### TarotReadingSetupScreen

역할:

- 질문, 분야, 스프레드 설정

구성:

```text
질문 입력
분야 선택
스프레드 선택
역방향 사용 여부
무료/Plus 모드 선택
```

### TarotDrawScreen

역할:

- 카드 뽑기 경험

구성:

```text
스프레드 포지션 슬롯
카드 뒷면 리스트 또는 셔플 애니메이션
뽑은 카드 표시
결과 보기 버튼
```

MVP에서는 애니메이션 없이 “카드 뽑기” 버튼으로 충분하다.

### ReadingResultScreen

역할:

- 전체 요약과 카드별 해석 표시
- 선택된 타로 카드 이미지 표시

구성:

```text
질문
분야
스프레드 이름
전체 요약
카드 이미지 그리드
카드별 포지션/방향/해석
조언
주의 문구
Plus 개인화 CTA
```

카드 이미지는 `divination_items.image_url`이 있으면 실제 이미지를 표시한다. 이미지가 없으면 카드 이름, 방향, 코드가 들어간 대체 카드 비주얼을 보여준다.

MVP의 Major Arcana 이미지는 Flutter 로컬 asset으로 관리한다. DB에는 외부 URL이 아니라 아래 형식의 논리 경로를 저장한다.

```text
asset://tarot/rws_major/fool.jpg
```

Flutter 앱은 이를 아래 경로로 변환해 `Image.asset`으로 표시한다.

```text
app/flutter_app/assets/tarot/rws_major/fool.jpg
```

이미지를 교체할 때는 파일명만 유지하면 DB와 앱 코드를 바꾸지 않아도 된다. 예를 들어 `fool.jpg`를 자체 제작 이미지로 바꾸면 다음 실행부터 같은 카드에 새 이미지가 표시된다.

## DB 구조 변경 제안

현재 `readings.spread_code`, `reading_items.position_name`, `reading_items.position_order`가 있으므로 최소 구현은 가능하다.

하지만 확장성을 위해 아래 테이블을 추가하는 것이 좋다.

### spreads

스프레드 정의 테이블.

```sql
create table spreads (
  id uuid primary key default gen_random_uuid(),
  divination_type_id uuid not null references divination_types(id),
  code text not null,
  name text not null,
  description text,
  card_count int not null,
  is_plus_only boolean not null default false,
  allow_reversed boolean not null default true,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(divination_type_id, code)
);
```

### spread_positions

스프레드별 포지션 정의 테이블.

```sql
create table spread_positions (
  id uuid primary key default gen_random_uuid(),
  spread_id uuid not null references spreads(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  position_order int not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(spread_id, code),
  unique(spread_id, position_order)
);
```

### readings 보강

현재 `spread_code`는 유지하되, 향후 `spread_id`를 추가하는 것이 좋다.

```sql
alter table readings
add column spread_id uuid references spreads(id);
```

### reading_items 보강

현재 `position_name`은 유지하되, 향후 `spread_position_id`를 추가하는 것이 좋다.

```sql
alter table reading_items
add column spread_position_id uuid references spread_positions(id);
```

## Edge Function 변경 제안

현재 `spreadCount()`는 코드 안에서 `single`, `three_card`만 처리한다.

변경 방향:

1. 요청에서 `spread_code`를 받는다.
2. DB에서 `spreads`와 `spread_positions`를 조회한다.
3. `card_count`만큼 카드를 뽑는다.
4. 각 카드에 `spread_position_id`, `position_name`, `position_order`를 저장한다.
5. 무료 해석은 카드별 기본 해석 + 포지션 설명을 조합한다.
6. Plus AI 해석은 포지션 설명까지 프롬프트에 포함한다.

## Flutter 구조 변경 제안

현재:

```text
features/divination/
  data/
  domain/
  presentation/home_screen.dart
```

변경:

```text
features/tarot/
  domain/
    tarot_spread.dart
    tarot_spread_position.dart
    tarot_reading_request.dart
  data/
    tarot_repository.dart
  application/
    tarot_spread_providers.dart
    tarot_reading_controller.dart
  presentation/
    tarot_reading_setup_screen.dart
    tarot_draw_screen.dart
    tarot_result_sections.dart
```

기존 `features/divination`은 점술 유형 목록과 공통 모델 중심으로 남기고, 타로 전용 경험은 `features/tarot`으로 분리한다.

## 구현 순서

1. `spreads`, `spread_positions` migration 작성
2. 타로 스프레드 seed 작성
3. Edge Function에서 DB 기반 스프레드 조회로 변경
4. Flutter에 스프레드 모델/리포지토리 추가
5. HomeScreen을 타로 리딩 진입 중심으로 재구성
6. TarotReadingSetupScreen 구현
7. ReadingResultScreen에서 카드별 포지션 해석 표시
8. ReadingResultScreen에서 카드 이미지 표시
9. 무료 1장/3장/10장 리딩 검증
