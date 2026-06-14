# 작업 로그

## 2026-06-02
- 점술 앱 아키텍처 결정
- Flutter + Supabase + OpenAI API + RevenueCat 구조 선택
- 무료: 지식창고 기반 해석
- Plus: AI 개인화 해석
- Supabase DB schema 설계 및 초기 migration 작성
- 무료/Plus 분리를 위한 RLS 정책 초안 작성
- Flutter 앱 기본 소스 구조 생성
- Supabase Edge Function 설계 문서 및 함수 초안 작성
- 로컬 Flutter CLI 미설치로 `flutter create` 정식 플랫폼 폴더 생성은 보류
- 개발 환경 설치 가이드 작성
- 다음 작업: Flutter SDK 설치 후 플랫폼 폴더 생성 및 `flutter analyze`, Supabase CLI로 function serve 검증

## 2026-06-04

- Flutter SDK, Android toolchain, Node.js, Supabase CLI, Deno 설치 확인
- 확인 버전: Flutter 3.44.1, Dart 3.12.1, Node.js 24.14.0, Supabase CLI 2.104.0, Deno 2.8.2
- `flutter doctor` 결과 `No issues found!` 확인
- Flutter Android/iOS 플랫폼 폴더 생성
- Flutter 의존성 설치 및 `pubspec.lock` 생성
- Flutter 기본 테스트를 현재 앱 구조에 맞게 수정
- Flutter 최신 API에 맞춰 `DropdownButtonFormField.initialValue` 사용
- `flutter analyze`, `flutter test`, `flutter doctor` 통과 확인
- Supabase CLI dev dependency 추가: `package.json`, `package-lock.json`
- Deno는 설치되어 있으나 사용자 PATH 보정 필요: `C:\Users\megadox\.deno\bin`
- Android Studio에서는 `E:\Project\Divination_app\app\flutter_app` 폴더를 Flutter 프로젝트 루트로 오픈
- 다음 작업:
  1. Supabase Cloud 프로젝트 생성 및 `npx supabase link --project-ref ...` 연결
  2. 초기 DB migration 적용: `npx supabase db push`
  3. 테스트용 타로 seed 데이터 작성
  4. Edge Function `create-free-reading`, `create-ai-reading`, `sync-revenuecat-subscription` 검증
  5. Flutter 앱에 `SUPABASE_URL`, `SUPABASE_ANON_KEY`를 전달해 실제 무료 해석 흐름 테스트

## 2026-06-04 Supabase 진행

- Supabase Cloud 프로젝트 연결 후 `npx supabase db push` 진행
- 테스트용 타로 seed migration 작성: `20260604000001_seed_test_tarot.sql`
- Seed 범위: Major Arcana 테스트 카드 3장(`fool`, `magician`, `star`)
- Seed 해석 범위: `general`, `love`, `career`, `money`, `health`, `relationship` 카테고리와 `upright`, `reversed` 방향
- Web 플랫폼 추가 및 Chrome/web-server 실행 스크립트 작성: `scripts/run_flutter_web.ps1`
- 로컬 Supabase 실행값은 `.env`에서 읽도록 구성하고, 커밋용 예시는 `.env.example`에 작성
- `.env`는 로컬 설정으로 Git 추적 제외
- 다음 작업: `npx supabase db push`로 seed migration 적용 확인 후 무료 해석 Edge Function 검증

## 2026-06-05

- 웹 화면 정상 표시 확인
- 원격 Supabase migration 상태 확인: `20260602000001`, `20260604000001` 적용됨
- Edge Function 배포 확인 및 최신 배포 진행
  - `create-free-reading`
  - `create-ai-reading`
  - `sync-revenuecat-subscription`
- Flutter 앱 시작 시 익명 세션을 먼저 보장하도록 수정
- 분야 선택 옵션에 `health` 추가
- 무료 해석 생성 실패 시 SnackBar로 오류 표시하도록 수정
- `flutter analyze`, `flutter test` 통과 확인
- 무료 해석 호출 검증 스크립트 작성: `scripts/test_free_reading.ps1`
- 검증 결과: Supabase Auth Anonymous sign-ins 비활성화로 익명 로그인 실패
- Android 빌드 실패 원인 확인: `purchases_flutter 6.30.2`가 제거된 Flutter v1 Android embedding API를 참조
- `purchases_flutter`를 `10.2.2`로 업그레이드
- Windows 다중 드라이브 Kotlin incremental cache 오류 완화를 위해 `kotlin.incremental=false` 설정
- `flutter clean`, `flutter pub get` 후 `flutter build apk --debug` 통과 확인
- Android 실행 스크립트 추가: `scripts/run_flutter_android.ps1`
- 남은 경고: `purchases_flutter`가 Kotlin Gradle Plugin을 적용한다는 Flutter 향후 호환성 경고
- 모바일 에뮬레이터 실행 중 dart define 미전달로 `No host specified in URI /auth/v1/signup` 오류 확인
- Supabase 설정 누락 시 명확한 설정 오류 화면을 표시하도록 수정
- Android Studio 직접 Run 시 `Additional run args`에 `SUPABASE_URL`, `SUPABASE_ANON_KEY`를 넣어야 함을 문서화
- 다음 작업: Android Studio Run 설정 또는 `scripts/run_flutter_android.ps1`로 dart define 전달 후 Android 앱 무료 해석 흐름 테스트
- 타로 리딩 방식 정리 필요 확인
- 타로 스프레드/화면/DB/Edge Function 재구성 문서 작성: `docs/tarot_reading_methods.md`
- `spreads`, `spread_positions` migration 작성 및 Supabase Cloud 적용
- 모든 스프레드는 UI 제한 없이 노출하도록 seed 작성
- Major Arcana 22장 seed와 카테고리/정역방향 해석 seed 작성
- Edge Function을 DB 기반 스프레드/포지션 조회 방식으로 변경
- Flutter 홈 화면을 질문/분야/스프레드/무료·AI 모드 선택 구조로 변경
- 결과 화면에서 포지션별 카드 목록 표시
- 결과 화면에서 선택된 타로 카드 이미지 표시
- `divination_items.image_url`이 있으면 실제 이미지 표시, 없으면 카드형 대체 비주얼 표시
- Major Arcana 카드 이미지 URL migration 작성: Wikimedia Commons public domain Rider-Waite-Smith 이미지
- 카드 이미지를 외부 URL 방식에서 Flutter 로컬 asset 방식으로 변경
- Major Arcana 22장 이미지를 `app/flutter_app/assets/tarot/rws_major/`에 저장
- `divination_items.image_url`은 `asset://tarot/rws_major/<card_code>.jpg` 형식으로 저장하도록 migration 작성
- 결과 화면은 `asset://` 값을 `Image.asset`으로 표시하고, 외부 URL은 기존처럼 fallback 지원
- Deno check, `flutter analyze`, `flutter test` 통과
- `create-free-reading`, `create-ai-reading`, `sync-revenuecat-subscription` 배포
- 무료 리딩 검증: `single_question`, `three_card_timeline`, `celtic_cross` 생성 성공
- 다음 작업: Android 앱에서 스프레드 선택 UI와 결과 화면 직접 확인, AI 모드 Plus 검증/구독 처리 흐름 설계

## 2026-06-07

- 다른 PC에서 Android 모바일 에뮬레이터가 정상 실행되는 것을 확인했다.
- 현재 PC는 메모리 사용량과 디스크 공간 부족으로 에뮬레이터/Gradle 빌드가 불안정할 수 있으므로, Android 검증은 리소스가 충분한 PC 또는 실제 Android 기기에서 우선 진행한다.
- 웹 실행에서는 기본 무료 리딩 흐름이 정상 동작하는 것으로 확인했다.
- Android 실행 시에는 `.env`가 Android Studio Run에 자동 전달되지 않으므로, `scripts/run_flutter_android.ps1`을 사용하거나 Android Studio Run Configuration의 Additional run args에 `SUPABASE_URL`, `SUPABASE_ANON_KEY` dart define을 직접 넣어야 한다.

## 2026-06-09

- Minor Arcana 56장 추가: 전체 78장 타로 덱 지원
- migration `20260608000001_seed_minor_arcana.sql`: `divination_items` 56장 + `interpretations` 672행 seed
- migration `20260608000002_add_minor_arcana_asset_paths.sql`: `asset://tarot/rws_minor/<code>.jpg` 경로 설정
- 로컬 이미지 56장 추가: `app/flutter_app/assets/tarot/rws_minor/`
- 다운로드 스크립트: `scripts/download_tarot_minor_assets.ps1`, 생성 스크립트: `scripts/generate_minor_arcana_seed.py`
- `pubspec.yaml`에 `assets/tarot/rws_minor/` 등록
- 카드 코드 규칙: `{suit}_{rank}` (예: `wands_ace`, `cups_knight`, `pentacles_king`)
- `npx supabase db push`로 원격 DB 적용 완료
- Edge Function `selectItems`는 별도 수정 없이 78장 풀에서 랜덤 추첨

- Android 앱 실행 검증 완료: 에뮬레이터에서 앱 시작 및 기본 화면 표시 확인
- 뒤로가기 이슈 원인 확인: `context.go()`가 라우트 스택을 교체해 결과/기록/Plus 화면에서도 홈으로 돌아가지 못하고 앱이 종료됨
- 네비게이션 수정: 결과/기록/Plus 이동을 `context.push()`로 변경, 결과 화면에 `새 해석하기` 버튼 추가, 기록 화면에서 결과 상세로 이동 가능
- Android 무료 리딩 API end-to-end 검증 스크립트 추가: `scripts/test_android_free_reading_e2e.ps1`
- API 검증 결과: `single_question`(1장), `three_card_timeline`(3장), `celtic_cross`(10장) 생성 성공, `readings`/`reading_items`/`daily_usage` 반영 확인
- `flutter analyze`, `flutter test` 통과
- 무료 해석 일일 제한(5회) 도달 시 `Daily usage limit reached` 오류 확인
- 홈 화면에 남은 무료 해석 횟수 표시, 한도 도달 시 버튼 비활성화 및 한국어 안내 메시지 추가
- Android 무료 리딩 end-to-end 검증 완료: `single_question`, `three_card_timeline`, `celtic_cross` UI에서 정상 동작 확인
- Android UI/이미지 검증 완료: `asset://tarot/rws_major/` 카드 이미지, 레이아웃, 스크롤/줄바꿈 정상 확인
- 인증/사용량 정책 확인 완료: MVP는 익명 로그인 유지, Plus 전환 시 로그인 유도는 후속 구현
- 사용량 정책 확정: 무료 해석 5회/일, AI 해석 30회/일(Plus), Android·서버·UI 동작 일치 확인
- Supabase Anonymous sign-ins 활성화 상태 확인: Android 무료 리딩 정상 동작으로 검증됨
- Plus/AI 기능 검증 준비 완료: `scripts/test_ai_reading.ps1` 추가, 비Plus 사용자 AI 요청 차단 확인
- Edge Function secrets 체크리스트 정리: `docs/edge_functions.md`, Dashboard에서 `OPENAI_API_KEY`, `OPENAI_MODEL`, `SUPABASE_SERVICE_ROLE_KEY`, `REVENUECAT_WEBHOOK_SECRET` 확인 필요
- Plus AI 생성 end-to-end는 `.env`에 `SUPABASE_SERVICE_ROLE_KEY` 추가 후 `scripts/test_ai_reading.ps1` 재실행으로 OpenAI 호출까지 검증
- 다음 작업: RevenueCat 구독 흐름 설계/검증

### 에뮬레이터 실행 확인 이후 진행할 일

1. ~~Android 앱 실행 검증~~ (완료)
   - `scripts/run_flutter_android.ps1` 또는 Android Studio Run Configuration으로 Android 앱을 실행한다.
   - 앱 시작, Supabase 초기화, 무료 리딩 생성, 카드 이미지 표시, 결과 화면 표시, 뒤로가기/재실행 흐름을 확인한다.
   - 확인 명령 예시:
     ```powershell
     .\scripts\run_flutter_android.ps1 -Device <device-id>
     ```
   - 참고: 홈 화면에서 뒤로가기를 누르면 앱이 종료되는 것은 Android 기본 동작이다. 결과/기록/Plus 화면에서는 뒤로가기로 홈으로 돌아가야 한다.

2. ~~Android 무료 리딩 end-to-end 검증~~ (완료)
   - API 검증은 `scripts/test_android_free_reading_e2e.ps1`로 완료
   - Android UI에서 `single_question`, `three_card_timeline`, `celtic_cross` 스프레드를 각각 실행해 카드 이미지와 해석 표시를 직접 확인한다.

3. ~~Android UI/이미지 검증~~ (완료)
   - Major Arcana 카드 이미지가 `asset://tarot/rws_major/<card_code>.jpg` 기반으로 정상 표시되는지 확인한다.
   - 작은 화면에서 카드 목록, 해석 텍스트, 버튼 영역이 겹치지 않는지 확인한다.
   - 긴 질문/긴 해석 문구에서도 스크롤과 줄바꿈이 자연스러운지 확인한다.

4. ~~인증/사용량 정책 확인~~ (완료)
   - 익명 사용자 흐름을 계속 사용할지, 로그인 기반으로 전환할지 결정한다.
   - 무료 일일 사용량 제한이 Android에서도 동일하게 적용되는지 확인한다.
   - Supabase Auth Anonymous sign-ins 설정 상태를 다시 확인한다.

5. ~~Plus/AI 기능 검증 준비~~ (완료)
   - Edge Function secrets에 `OPENAI_API_KEY`, `OPENAI_MODEL`, `SUPABASE_SERVICE_ROLE_KEY`, `REVENUECAT_WEBHOOK_SECRET`이 설정되어 있는지 확인한다.
   - Plus가 아닌 사용자가 AI 리딩을 요청했을 때 차단되는지 확인한다.
   - 테스트용 Plus 구독 상태를 DB에 넣고 `create-ai-reading` 흐름을 검증한다.
   - 검증 스크립트: `scripts/test_ai_reading.ps1`
   - 비Plus 차단 확인: `Plus subscription is required.` 응답 PASS
   - Plus+OpenAI 전체 검증: `.env`에 `SUPABASE_SERVICE_ROLE_KEY` 설정 후 스크립트 재실행

6. RevenueCat 구독 흐름 설계/검증
   - RevenueCat entitlement id, product id, webhook URL을 확정한다.
   - `sync-revenuecat-subscription` webhook payload 테스트를 진행한다.
   - Supabase `subscriptions` 테이블에 구독 상태가 upsert되는지 확인한다.

7. 릴리즈 전 품질 점검
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --debug`
   - Android 실기기 또는 에뮬레이터에서 무료 리딩 회귀 테스트
   - `.env.example`, `docs/setup_tools.md`, Android Studio 실행 설정 문서 최신화

project/
 ├─ AGENTS.md
 ├─ README.md
 ├─ docs/
 │   ├─ architecture.md
 │   ├─ db_schema.md
 │   ├─ edge_functions.md
 │   ├─ setup_tools.md
 │   ├─ tarot_reading_methods.md
 │   ├─ worklog.md
 │   └─ decisions.md
 ├─ app/
 │   └─ flutter_app/
 ├─ scripts/
 │   └─ run_flutter_web.ps1
 └─ supabase/
     ├─ functions/
     └─ migrations/
         ├─ 20260602000001_initial_schema.sql
         ├─ 20260604000001_seed_test_tarot.sql
         ├─ 20260605000001_add_tarot_spreads.sql
         ├─ 20260605000002_seed_major_arcana.sql
         └─ 20260605000003_add_major_arcana_image_urls.sql

## 2026-06-11

- 다중 점술 확장 아키텍처 문서 재작성: `divination_app_architecture.md`
- 타로 전용 구조에서 `점술 카탈로그 + 점술 모듈 등록 구조`로 전환하는 설계 정리
- 사주, 룬, 오미쿠지, 별자리 추가를 위한 공통 도메인 개념 정리
  - `divination_types`
  - `input schema`
  - `resolver`
  - `interpretation strategy`
  - `reading payload`

- 다중 점술 DB 마이그레이션 설계 문서 추가
  - `docs/multi_divination_migration_plan.md`
- 다중 점술 Flutter 리팩터링 설계 문서 추가
  - `docs/multi_divination_flutter_refactor.md`

- Supabase 다중 점술 확장 migration 초안 작성
  - `20260611000001_expand_divination_types_for_multi_divination.sql`
  - `20260611000002_create_divination_input_definitions.sql`
  - `20260611000003_create_reading_inputs_and_payloads.sql`
  - `20260611000004_create_divination_interpretations.sql`
- `divination_types`에 다중 점술 메타 컬럼 추가
  - `short_description`
  - `icon_key`
  - `input_mode`
  - `resolver_type`
  - `interpretation_mode`
- 신규 점술 타입 seed 추가
  - `saju`
  - `zodiac`
- 점술별 입력 정의 테이블 추가
  - `divination_input_definitions`
- 입력형 점술 저장용 테이블 추가
  - `reading_inputs`
  - `reading_payloads`
- item 기반/규칙 기반 공통 무료 해석용 테이블 추가
  - `divination_interpretations`
- `docs/db_schema.md`를 다중 점술 구조 기준으로 갱신

- Supabase Edge Function 확장
  - `get-divination-catalog` 추가
  - `get-divination-detail` 추가
  - `_shared/divination_catalog.ts` 추가
- `create-ai-reading` 프롬프트 코드 조회를 다중 점술 naming convention에 맞게 확장
  - `plus_<divination>_reading_<language>_v1`
  - `plus_<divination>_reading`
- `_shared/readings.ts` 확장
  - `inputs` payload 정규화 추가
  - `reading_inputs` 저장 추가
  - `reading_payloads` 저장 추가
  - 입력형 점술도 저장 가능한 공통 `saveReading` 구조로 확장
  - `getDivinationType` helper 추가

- Flutter 라우터/홈 구조 개편
  - `HomeScreen`을 타로 실행기에서 점술 선택형 홈으로 전환
  - `/catalog`, `/catalog/:code`, `/reading/:code` 라우트 추가
  - 새 화면 추가
    - `divination_catalog_screen.dart`
    - `divination_intro_screen.dart`
    - `divination_reading_screen.dart`
- 기존 타로 생성 UI는 `/reading/tarot`로 이동해 현재 기능 유지
- `DivinationType` 모델을 카탈로그 표시용 메타데이터까지 포함하도록 확장
- `divinationRepository`, `divinationProviders`에 점술 단건 조회 지원 추가
- `flutter analyze` 통과 확인

- 사주 입력 폼 Flutter 구현
  - 생년월일
  - 출생시간
  - 출생시간 모름 토글
  - 양력/음력
  - 성별
  - 이름/별칭
  - 질문
  - 상담 분야
  - 무료/AI 모드 선택
- `createFreeReading`, `createAiReading`가 `inputs` payload를 함께 전달하도록 확장
- 현재 상태:
  - 타로는 실제 실행 가능
  - 사주는 입력 UI와 요청 payload 연결 완료
  - 룬/오미쿠지/별자리는 카탈로그/소개까지만 연결

- 서버 쪽 사주 무료 해석 초안 연결
  - `create-free-reading`에 `saju` 분기 추가
  - `_shared/saju.ts` 추가
  - 사주 입력값 기반 임시 rule-based 무료 해석 생성
- 현재 사주 무료 해석 초안이 만드는 요소
  - 띠
  - 계절 흐름
  - 우세 오행
  - 음/양 경향
  - 질문 카테고리별 요약/상세/조언/주의 문구
- 사주 결과는 아래 형태로 저장되도록 연결
  - `readings.result_text`
  - `readings.result_json`
  - `reading_inputs`
  - `reading_payloads(payload_type='saju_chart')`

### 사주 해석 보강 작업 기록

- 현재 구현된 사주 해석은 "임시 rule-based 초안"이다.
- 전통 명리학 수준의 정밀 계산이 아니라, 입력형 점술 구조 검증과 UI/서버 흐름 연결을 위한 1차 버전으로 구현했다.
- 현재 한계:
  - 실제 사주 원국 천간/지지 계산 없음
  - 일간, 월령, 십성, 신강/신약 계산 없음
  - 대운/세운 계산 없음
  - 양력/음력 변환 로직 없음
  - 출생지/표준시/절기 기준 반영 없음
  - `divination_interpretations` 기반 세밀 문구 매핑은 아직 미연결

- 사주 해석 보강을 위해 다음 작업이 필요함
  1. 사주 원국 계산 로직 도입
  2. 양력/음력 및 절기 기준 처리
  3. 일간/오행/십성/신강약 구조화 payload 확장
  4. `divination_interpretations`에 사주 규칙 문구 seed 구축
  5. `create-ai-reading`에도 사주 분기 추가
  6. 결과 화면에 사주 전용 섹션 표시
    - 오행 분포
    - 일간 설명
    - 원국 요약
  7. 사주 무료/AI 결과 품질 검증용 테스트 케이스 작성

- 오늘 작업의 성격 정리:
  - 다중 점술 확장 기반 설계 완료
  - Flutter 카탈로그 흐름 전환 완료
  - 사주 입력 폼 연결 완료
  - 사주 무료 해석은 "흐름 검증용 초안"까지 연결 완료

- 다음 작업 추천:
  1. Supabase migration 실제 적용 및 함수 배포
  2. `get-divination-catalog`, `get-divination-detail`를 Flutter에서 직접 사용하도록 연동
  3. 사주 결과 화면 전용 섹션 추가
  4. 사주 원국 계산 로직 보강
  5. `create-ai-reading` 사주 분기 추가

## 2026-06-11 추가 진행

- 사주 결과 화면 전용 섹션 구현
  - `reading_result_screen.dart`
  - 띠, 우세 오행, 기본 기운, 계절 흐름, 음양, 오행 분포 표시
- 결과 화면이 `reading_payloads`와 `readings.result_json`를 함께 읽도록 확장
- `Reading` 모델에 `resultJson` 추가

- 사주 Plus AI 해석 분기 구현
  - `create-ai-reading`에 `saju` 분기 추가
  - 무료 사주 초안 payload를 AI 프롬프트 입력 데이터로 재사용
  - 사주용 프롬프트 seed migration 추가
    - `20260611000005_seed_saju_prompt_template.sql`
- `deno check` 통과 확인

- Supabase 원격 반영 완료
  - `supabase link --project-ref ldumzdzylpuhdxpmnvrg`
  - `npx supabase db push`로 다중 점술 migration 반영
  - 원격 배포 완료:
    - `get-divination-catalog`
    - `get-divination-detail`
    - `create-free-reading`
    - `create-ai-reading`

- 별자리, 룬, 오미쿠지 구현 확장
  - Flutter 입력 화면 추가
    - `zodiac`
    - `rune`
    - `omikuji`
  - 결과 화면 전용 섹션 추가
    - 별자리: 별자리/원소/성향/핵심 특성
    - 룬: 뽑힌 룬 목록과 역할별 의미
    - 오미쿠지: 운세 등급과 집중 영역
- 서버 규칙형 해석 helper 추가
  - `_shared/extended_divinations.ts`
- 무료 해석 분기 추가
  - `zodiac`
  - `rune`
  - `omikuji`
- AI 해석 분기 추가
  - `zodiac`
  - `rune`
  - `omikuji`
- 추가 프롬프트 seed migration 작성
  - `20260611000006_seed_additional_divination_prompts.sql`

- 검증 스크립트 추가
  - `scripts/test_multi_divinations.ps1`
- PowerShell 7 기준 무료 다중 점술 검증 완료
  - `saju` PASS
  - `zodiac` PASS
  - `rune` PASS
  - `omikuji` PASS
- 검증 reading_id 기록
  - `saju`: `adf4c5e8-0996-4490-8669-6676f95fcec7`
  - `zodiac`: `a3c0c977-b2d9-400f-b90d-263cd6df6c0c`
  - `rune`: `0a6873c5-277c-4a2a-8f16-4903c9aa2419`
  - `omikuji`: `2bbd5dad-9346-4d96-9297-bd724275e246`

- 현재 상태 정리
  - 무료 흐름:
    - `tarot`
    - `saju`
    - `zodiac`
    - `rune`
    - `omikuji`
    모두 연결 및 기본 검증 완료
  - AI 흐름:
    - `tarot`
    - `saju`
    - `zodiac`
    - `rune`
    - `omikuji`
    코드 분기와 프롬프트 seed 반영 완료
  - Plus 성공 호출 검증은 후속 진행

- 다음 작업 추천
  1. `get-divination-catalog`, `get-divination-detail`를 Flutter에서 직접 사용하도록 전환
  2. 각 점술별 디자인 polish
  3. 사주 원국 계산 고도화
  4. 룬/오미쿠지/별자리 결과 문구 고도화
  5. Plus 성공 호출 검증과 AI 응답 품질 점검

## 2026-06-13

- 비타로 점술 이미지 표시 1차 확장
  - `saju`, `omikuji`, `rune`, `zodiac` 대표 이미지를 Flutter asset으로 추가
  - asset 경로: `app/flutter_app/assets/divinations/`
  - `pubspec.yaml`에 `assets/divinations/` 등록
- 결과 화면 이미지 노출 구조 확장
  - `reading_result_screen.dart`에서 타로 외 점술도 결과 상단에 전용 이미지를 표시하도록 반영
  - 타로는 기존 카드 이미지 표시 흐름 유지
- Android 테스트 APK 생성
  - `flutter build apk --release`
  - 산출물: `app/flutter_app/build/app/outputs/flutter-apk/app-release.apk`
- 로컬 Android 빌드 환경 이슈 대응
  - 손상된 NDK 폴더(`C:\Users\megad\AppData\Local\Android\Sdk\ndk\28.2.13676358`) 제거 후 Gradle 재다운로드로 복구
- 검증
  - `flutter analyze` 통과
  - `flutter test` 통과

## 2026-06-13 추가 진행

- 비타로 점술 결과 이미지 개인화 2차 확장
  - 대표 이미지 1장 고정 표시에서 payload 기반 hero overlay 방식으로 확장
  - `saju`: dominant element, zodiac animal, season, yin/yang 반영
  - `zodiac`: resolved sign, element, modality 반영
  - `rune`: selected rune set 중심 요약 반영
  - `omikuji`: fortune grade, focus 반영
- 설계 메모 추가
  - `docs/divination_result_image_plan.md`
- Android 테스트 APK 재생성
  - 산출물 갱신: `app/flutter_app/build/app/outputs/flutter-apk/app-release.apk`
- 검증
  - `flutter analyze` 통과
  - `flutter test` 통과
