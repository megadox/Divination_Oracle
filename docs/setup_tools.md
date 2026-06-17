# 개발 환경 설치 가이드

이 문서는 Divination App 구현에 필요한 SDK와 개발 도구 설치 절차를 정리한다.

## 설치 대상 요약

### 필수

- Flutter SDK: Flutter 앱 개발, 의존성 설치, 분석, 실행
- Android SDK: Android 빌드와 기기/에뮬레이터 실행
- Git: 버전 관리
- Node.js 20 이상: Supabase CLI 실행
- Supabase CLI: migration, Edge Function serve/deploy

### 로컬 백엔드 검증 시 필요

- Docker Desktop: 로컬 Supabase 스택 실행

### 선택 추천

- Deno: Supabase Edge Function TypeScript 점검
- VS Code 확장: Flutter, Dart, Supabase, Deno

## 1. Flutter SDK

Flutter 앱 개발에 필요하다. Dart SDK는 Flutter SDK에 포함된다.

공식 문서:

- https://docs.flutter.dev/install/manual

설치 후 새 PowerShell을 열고 확인한다.

```powershell
flutter --version
dart --version
flutter doctor
```

이 프로젝트의 `pubspec.yaml`은 Dart SDK `^3.4.0`을 요구하므로 최신 Flutter stable을 사용하면 된다.

## 2. Android 개발 도구

Android 앱을 빌드하거나 실행하려면 Android SDK가 필요하다.

선택지는 두 가지다.

### 권장: Android Studio 설치

가장 간단한 방법이다. Android Studio 설치 과정에서 Android SDK, platform tools, build tools, emulator를 함께 설치할 수 있다.

공식 다운로드:

- https://developer.android.com/studio

설치 후 Android Studio의 SDK Manager에서 아래 항목을 확인한다.

- Android SDK Platform
- Android SDK Build-Tools
- Android SDK Command-line Tools
- Android Emulator
- Android Platform-Tools

그 다음 PowerShell에서 실행한다.

```powershell
flutter doctor
flutter doctor --android-licenses
```

### 가벼운 대안: Android Command Line Tools만 설치

Android Studio가 부담되면 command-line tools만 설치할 수 있다. 단, SDK 패키지와 환경 변수를 직접 관리해야 한다.

공식 다운로드:

- https://developer.android.com/studio

예시 설치 경로:

```text
C:\Android\Sdk\cmdline-tools\latest\
```

환경 변수:

```text
ANDROID_HOME=C:\Android\Sdk
Path += C:\Android\Sdk\cmdline-tools\latest\bin
Path += C:\Android\Sdk\platform-tools
```

필요 SDK 설치:

```powershell
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "cmdline-tools;latest"
flutter config --android-sdk C:\Android\Sdk
flutter doctor --android-licenses
flutter doctor
```

## 3. Node.js 20 이상

Supabase CLI를 `npx supabase`로 실행하려면 Node.js 20 이상이 필요하다.

공식 다운로드:

- https://nodejs.org/en/download

설치 후 확인한다.

```powershell
node --version
npm --version
```

## 4. Supabase CLI

Supabase migration 적용과 Edge Function serve/deploy에 필요하다.

Supabase 공식 문서에서는 `npm install -g supabase` 글로벌 설치를 지원하지 않는다. 이 프로젝트에서는 dev dependency로 설치하고 `npx`로 실행한다.

공식 문서:

- https://supabase.com/docs/guides/cli/getting-started

설치:

```powershell
cd E:\Project\Divination_app
npm install supabase --save-dev
npx supabase --help
```

## 5. Docker Desktop

로컬에서 Supabase 전체 스택을 실행하려면 Docker Desktop이 필요하다.

공식 문서:

- https://supabase.com/docs/guides/cli

로컬 Supabase 실행:

```powershell
cd E:\Project\Divination_app
npx supabase start
```

Docker 없이도 Supabase Cloud 프로젝트에 직접 연결해 deploy 중심으로 작업할 수 있지만, 로컬 DB와 Edge Function 검증에는 Docker가 편하다.

## 6. Deno

Supabase Edge Function은 Deno 런타임 기반이다. Supabase CLI만으로도 serve/deploy는 가능하지만, Deno를 설치하면 TypeScript 함수 점검이 편하다.

공식 문서:

- https://docs.deno.com/runtime/manual/getting_started/installation

설치:

```powershell
irm https://deno.land/install.ps1 | iex
deno --version
```

## 7. 프로젝트 초기화 명령

Flutter SDK와 Android SDK 설치 후 앱 플랫폼 폴더를 생성한다.

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter create . --platforms android
flutter pub get
flutter analyze
```

Supabase CLI 설치 후 확인한다.

```powershell
cd E:\Project\Divination_app
npx supabase --help
```

로컬 Supabase까지 사용할 경우:

```powershell
npx supabase start
```

## 추천 설치 순서

1. Flutter SDK
2. Android Studio 또는 Android Command Line Tools
3. Node.js 20 이상
4. Supabase CLI
5. Docker Desktop
6. Deno

Android Studio가 부담되면 처음에는 Android Command Line Tools 방식으로 진행하고, 에뮬레이터 관리가 번거로워지는 시점에 Android Studio 설치를 검토한다.

## 설치 검증 기록

2026-06-04 기준 프로젝트 터미널에서 확인한 결과:

- Flutter: `3.44.1`
- Dart: `3.12.1`
- Node.js: `24.14.0`
- Supabase CLI: `2.104.0`
- Deno: `2.8.2`
- Android toolchain: Android SDK `36.1.0`

`flutter doctor` 결과는 `No issues found!` 상태다.

Flutter 프로젝트 플랫폼 폴더 생성과 의존성 설치도 완료했다.

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter create . --platforms android,ios
flutter pub get
flutter analyze
flutter test
```

검증 결과:

- `flutter analyze`: 통과
- `flutter test`: 통과
- `flutter build apk --debug`: 통과

Android 실행 스크립트:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\run_flutter_android.ps1
```

Android APK 빌드 스크립트:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\build_flutter_apk.ps1
```

특정 에뮬레이터나 기기를 지정하려면:

```powershell
flutter devices
powershell -ExecutionPolicy Bypass -File scripts\run_flutter_android.ps1 -Device emulator-5554
```

Android Studio에서 직접 Run할 경우 `.env` 파일은 자동으로 읽히지 않는다. Run 설정에 dart define을 추가해야 한다.

Android Studio:

1. `Run`
2. `Edit Configurations`
3. Flutter 실행 설정 선택
4. `Additional run args`에 아래 형식으로 입력

```text
--dart-define=SUPABASE_URL=https://ldumzdzylpuhdxpmnvrg.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

`SUPABASE_URL`이 누락되면 앱에서 `/auth/v1/signup`처럼 host 없는 URL을 호출하며 인증 오류가 발생한다.

### Deno PATH 보정

Deno 실행 파일은 아래 위치에서 확인했다.

```text
C:\Users\megadox\.deno\bin\deno.exe
```

현재 터미널에서 `deno --version`이 인식되지 않으면 사용자 `Path`에 아래 경로를 추가한다.

```text
C:\Users\megadox\.deno\bin
```

PowerShell에서 영구 추가:

```powershell
$denoBin = "C:\Users\megadox\.deno\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if (($userPath -split ";") -notcontains $denoBin) {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$denoBin", "User")
}
```

PowerShell과 IDE 터미널을 새로 연 뒤 확인한다.

```powershell
deno --version
```
