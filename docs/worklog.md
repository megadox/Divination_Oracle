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
