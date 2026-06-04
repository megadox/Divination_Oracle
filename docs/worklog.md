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
- 다음 작업: Supabase Cloud 연결 또는 Docker Desktop 실행 후 `npx supabase start`, Edge Function serve 검증

project/
 ├─ AGENTS.md
 ├─ README.md
 ├─ docs/
 │   ├─ architecture.md
 │   ├─ db_schema.md
 │   ├─ edge_functions.md
 │   ├─ setup_tools.md
 │   ├─ worklog.md
 │   └─ decisions.md
 ├─ app/
 │   └─ flutter_app/
 └─ supabase/
     ├─ functions/
     └─ migrations/
         └─ 20260602000001_initial_schema.sql
