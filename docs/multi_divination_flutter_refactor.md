# 다중 점술 Flutter 리팩터링 설계안

## 1. 문서 목적

본 문서는 현재 Flutter 앱의 타로 중심 화면 구조를 다중 점술 선택 구조로 전환하기 위한 리팩터링 설계안이다.

현재 구조 핵심:

- `HomeScreen`에서 바로 질문 입력
- 타로 스프레드 선택
- 무료/AI 타로 해석 생성

목표 구조 핵심:

- 홈에서 점술을 선택
- 점술 소개 화면 진입
- 공통 질문 입력
- 점술별 입력 UI 실행
- 공통 결과 화면 표시

---

## 2. 현재 구조 한계

현재 [app_router.dart](/e:/Project/Divination_app/app/flutter_app/lib/src/core/router/app_router.dart:1) 와 [home_screen.dart](/e:/Project/Divination_app/app/flutter_app/lib/src/features/divination/presentation/home_screen.dart:1) 기준 한계는 다음과 같다.

1. 라우팅이 `home -> result -> history -> plus` 정도로 단순하며 점술 선택 단계가 없다.
2. 홈 화면이 사실상 `타로 생성 화면` 역할을 하고 있다.
3. `divinationTypeCode: 'tarot'`가 UI에 하드코딩되어 있다.
4. 입력 방식이 모두 타로 스프레드 중심이다.

따라서 이제는 `화면 단위 점술 추가`가 아니라 `공통 흐름 + 점술별 모듈` 구조로 바꾸는 것이 필요하다.

---

## 3. 목표 UX 흐름

```text
Home
  ↓
Divination Catalog
  ↓
Divination Intro
  ↓
Question Input
  ↓
Divination Input
  ↓
Free Result
  ↓
AI Upsell / Subscription
  ↓
AI Result
```

핵심은 사용자가 "타로를 한다"가 아니라 "점술을 고른다"에서 시작하는 것이다.

---

## 4. 리팩터링 원칙

1. 공통 화면과 점술별 화면을 분리한다.
2. 점술별 차이는 `definition` 객체로 모은다.
3. API 응답도 최대한 공통 결과 모델로 받는다.
4. 현재 타로 기능은 첫 번째 등록 모듈로 이관한다.
5. 사주 추가 시 홈/결과/기록 화면 재작업이 없도록 만든다.

---

## 5. 추천 폴더 구조

```text
lib/src
  /core
    /router
    /theme
    /supabase
    /constants

  /features
    /home
      presentation/
        home_screen.dart
    /catalog
      presentation/
        divination_catalog_screen.dart
        divination_intro_screen.dart
    /reading
      presentation/
        question_input_screen.dart
        divination_input_screen.dart
        free_result_screen.dart
        ai_result_screen.dart
      application/
        reading_flow_controller.dart
      domain/
        reading_request.dart
        reading_result.dart
    /history
      presentation/
        history_screen.dart
    /subscription
      presentation/
        subscription_screen.dart

  /divinations
    /shared
      divination_definition.dart
      divination_registry.dart
      divination_input_config.dart
      divination_result_builder.dart
    /tarot
      tarot_definition.dart
      tarot_input_widget.dart
      tarot_result_builder.dart
    /saju
      saju_definition.dart
      saju_input_widget.dart
      saju_result_builder.dart
    /rune
      rune_definition.dart
      rune_input_widget.dart
    /omikuji
      omikuji_definition.dart
      omikuji_input_widget.dart
    /zodiac
      zodiac_definition.dart
      zodiac_input_widget.dart

  /data
    /models
    /repositories
```

---

## 6. 라우팅 개편안

### 6.1 추천 라우트

```text
/
/catalog
/catalog/:code
/reading/:code/question
/reading/:code/input
/reading/result/:readingId
/reading/result/:readingId/ai
/history
/plus
```

### 6.2 라우트 역할

#### `/`

- 홈 진입
- 추천 점술, 최근 기록, Plus 배너 노출

#### `/catalog`

- 전체 점술 목록
- 무료/Plus, 추천 상황, 입력 방식 표시

#### `/catalog/:code`

- 점술 소개
- 필요한 입력값, 안내 문구, 주의사항 표시

#### `/reading/:code/question`

- 공통 질문 입력

#### `/reading/:code/input`

- 점술별 입력 위젯 표시

#### `/reading/result/:readingId`

- 무료 결과

#### `/reading/result/:readingId/ai`

- AI 결과 또는 AI 생성 요청 후 결과

---

## 7. 상태 관리 구조

현재는 화면에서 바로 repository를 호출하는 구조가 많다. 다중 점술로 가면 공통 흐름 상태를 분리하는 편이 좋다.

### 7.1 추천 상태 객체

#### `ReadingDraft`

역할:

- 사용자가 결과 생성 전까지 입력한 임시 데이터 보관

예시 필드:

- `divinationCode`
- `question`
- `category`
- `inputs`
- `useAi`

#### `ReadingResult`

역할:

- 무료/AI 공통 결과 모델

예시 필드:

- `readingId`
- `divinationCode`
- `resultMode`
- `summary`
- `sections`
- `sourceItems`
- `sourcePayload`

### 7.2 추천 컨트롤러

#### `ReadingFlowController`

역할:

1. 선택한 점술 코드 보관
2. 질문/입력값 저장
3. free reading 생성 요청
4. AI reading 생성 요청
5. 결과 상태 갱신

이렇게 하면 `HomeScreen`이 직접 타로 API를 호출하는 구조를 제거할 수 있다.

---

## 8. 점술 모듈 구조

### 8.1 `DivinationDefinition`

점술별 차이를 코드 한 곳에 모으는 인터페이스다.

예시 책임:

- 점술 코드
- 표시 이름
- 입력 모드
- 질문 필요 여부
- 입력 위젯 빌더
- 결과 섹션 빌더

예시 형태:

```dart
abstract class DivinationDefinition {
  String get code;
  String get displayName;
  Widget buildInputWidget();
  List<ResultSection> buildResultSections(ReadingResult result);
}
```

### 8.2 `DivinationRegistry`

역할:

- 등록된 점술 모듈 조회
- 코드로 definition 반환
- 카탈로그 화면에서 점술 목록 노출

초기 등록 예시:

- tarot
- saju
- rune
- omikuji
- zodiac

### 8.3 `TarotDefinition`

현재 타로 전용 로직을 여기로 이동한다.

포함 대상:

- 스프레드 선택 UI
- 카드 뽑기 표시
- 결과 카드 섹션 렌더링

### 8.4 `SajuDefinition`

사주 추가 시 필요한 항목:

- 생년월일 입력
- 출생시간 입력
- 양력/음력 선택
- 성별 선택
- 결과에 오행/일간/핵심 해석 섹션 표시

---

## 9. 화면별 구체 설계

### 9.1 HomeScreen

현재 `질문 입력 + 타로 생성` 중심 구조를 아래처럼 바꾼다.

추천 섹션:

- Hero banner
- 인기 점술
- 오늘 추천 점술
- 최근 기록
- Plus 안내

중요:

- 홈에서 바로 타로를 실행하지 않는다.
- 첫 CTA는 `점술 선택하기`가 된다.

### 9.2 DivinationCatalogScreen

목록 카드에 표시할 정보:

- 점술 이름
- 한 줄 설명
- 입력 방식
- 무료 가능 여부
- Plus 전용 여부

카테고리 구분 예시:

- 카드/추첨형
- 생년월일 기반
- 준비 중

### 9.3 DivinationIntroScreen

점술별 안내가 필요한 이유:

- 사주는 입력 정보가 많다.
- 오미쿠지는 거의 즉시 진행 가능하다.
- 타로는 스프레드 선택이 필요할 수 있다.

필수 영역:

- 점술 설명
- 필요한 정보
- 소요 시간
- 결과 스타일
- 무료/Plus 차이

### 9.4 QuestionInputScreen

공통 요소:

- 질문 입력
- 카테고리 선택
- 건너뛰기 가능 여부

점술별 옵션:

- 어떤 점술은 질문 없이도 진행 가능
- 어떤 점술은 카테고리 기본값이 더 중요

### 9.5 DivinationInputScreen

공통 컨테이너 역할만 한다.

내부 위젯은 registry에서 가져온다.

예시:

- `tarot_input_widget.dart`
- `saju_input_widget.dart`
- `omikuji_input_widget.dart`

### 9.6 FreeResultScreen

현재 `reading_result_screen.dart`를 공통 결과 화면으로 일반화하는 방향이 좋다.

공통 섹션:

- 요약
- 핵심 해석
- 조언
- 주의할 점

점술별 확장 영역:

- 타로: 카드 리스트
- 사주: 원국/오행 요약
- 룬: 룬 상징 해설

### 9.7 AiResultScreen

무료 결과 대비 차이를 명확히 보여주는 것이 중요하다.

추천 구성:

- 한 줄 요약
- 질문 맞춤 해석
- 행동 조언
- 주의사항

---

## 10. 현재 코드 기준 리팩터링 순서

### Step 1. domain 모델 일반화

현재 [divination_type.dart](/e:/Project/Divination_app/app/flutter_app/lib/src/features/divination/domain/divination_type.dart:1) 는 메타데이터가 적다.

확장 후보:

- `shortDescription`
- `inputMode`
- `resolverType`
- `iconKey`

### Step 2. 라우터 분리

현재 [app_router.dart](/e:/Project/Divination_app/app/flutter_app/lib/src/core/router/app_router.dart:1) 에서 홈과 결과 중심 라우트만 있다.

해야 할 일:

- catalog route 추가
- intro route 추가
- question/input route 추가

### Step 3. HomeScreen 역할 축소

현재 [home_screen.dart](/e:/Project/Divination_app/app/flutter_app/lib/src/features/divination/presentation/home_screen.dart:1) 의 타로 생성 책임을 제거한다.

변경 방향:

- 질문 입력 제거
- 스프레드 선택 제거
- CTA만 유지

### Step 4. reading flow state 도입

새 컨트롤러에서 공통 흐름을 관리한다.

### Step 5. tarot UI 분리

현재 홈에 있는 타로 입력 UI를 `tarot_input_widget.dart`로 옮긴다.

### Step 6. result screen 공통화

기존 결과 화면이 타로에 의존하는 부분을 제거하고 섹션 렌더링 구조로 바꾼다.

### Step 7. saju 모듈 추가

이후 사주 입력/결과 UI를 같은 구조에 붙인다.

---

## 11. API 연동 관점 변경

현재 프론트는 사실상 타로 생성 API를 직접 부르는 형태다.

다중 점술 구조에서는 아래 API가 필요하다.

### 필수

- `get-divination-catalog`
- `get-divination-detail`
- `create-free-reading`
- `create-ai-reading`

### 프론트 처리 방식

1. catalog 조회
2. code별 detail 조회
3. 입력 폼 렌더링
4. submit 시 공통 payload 생성

공통 payload 예시:

```json
{
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

---

## 12. MVP 기준 권장 구현 범위

한 번에 전부 바꾸기보다 아래 범위를 1차로 추천한다.

### 1차

1. 홈 -> 카탈로그 -> 소개 흐름 추가
2. 타로만 새 구조에 먼저 연결
3. 결과 화면 공통화

### 2차

1. 사주 입력 화면 추가
2. 사주 API 연결
3. 사주 무료 결과 표시

### 3차

1. 룬/오미쿠지/별자리 추가
2. 기록 화면 필터 강화

---

## 13. 결론

Flutter 쪽 핵심은 아래 한 줄로 요약된다.

> `HomeScreen`을 타로 실행기에서 홈 화면으로 되돌리고, 점술별 차이는 `divination registry + input widget + result builder` 구조로 분리한다.

이 방식의 장점:

1. 신규 점술 추가 시 라우트와 홈 화면을 반복 수정하지 않아도 된다.
2. 사주처럼 입력형 점술도 같은 읽기 흐름에 넣을 수 있다.
3. 무료/AI 결과 화면을 공통화할 수 있다.

실제 구현 우선순위는 다음이 가장 안전하다.

1. 라우팅 개편
2. 공통 reading flow 도입
3. 타로 모듈 분리
4. 사주 모듈 추가
