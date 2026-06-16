# Divination App 배포/빌드 가이드

## 간단한 설계

- 목적: 이 저장소에서 Supabase 변경과 Flutter APK 빌드를 같은 흐름으로 반복 가능하게 정리한다.
- 원칙: DB 변경은 migration으로 반영하고, Edge Function 변경은 별도 재배포한다.
- 구분: 무료 기능은 `create-free-reading`, Plus 기능은 `create-ai-reading` 경로로 유지한다.
- 이번 수정 반영 포인트:
  - `supabase/migrations/20260616000001_localize_divination_type_metadata.sql`
  - `supabase/functions/get-divination-detail/index.ts`

## 1. 사전 준비

프로젝트 루트:

```powershell
cd E:\Project\Divination_app
```

필수 도구:

- Flutter SDK
- Android SDK / adb
- Supabase CLI
- Deno

버전 확인 예시:

```powershell
flutter --version
npx supabase --version
C:\Users\megadox\.deno\bin\deno.exe --version
```

## 2. `.env` 준비

루트에 `.env`를 준비한다.

예시:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
DISABLE_FREE_READING_LIMIT=false

# 선택: Plus AI 테스트 스크립트에서만 사용
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

주의:

- 실제 `SUPABASE_SERVICE_ROLE_KEY`는 커밋하지 않는다.
- 앱 빌드에는 `SUPABASE_URL`, `SUPABASE_ANON_KEY`가 필요하다.
- Edge Function 배포 전에는 Supabase Dashboard에 secret도 맞춰야 한다.

## 3. 로컬 점검

Flutter 정적 점검:

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter pub get
flutter analyze
```

Edge Function 타입 점검:

```powershell
cd E:\Project\Divination_app
C:\Users\megadox\.deno\bin\deno.exe check supabase/functions/get-divination-detail/index.ts
```

## 4. Supabase 변경 반영

### 4.1 로그인 / 링크

프로젝트에 처음 연결하는 경우:

```powershell
cd E:\Project\Divination_app
npx supabase login
npx supabase link --project-ref <your-project-ref>
```

### 4.2 migration 적용

DB 변경은 migration으로 반영한다.

```powershell
cd E:\Project\Divination_app
npx supabase db push
```

이번 배포에서 특히 포함되어야 하는 migration:

- `supabase/migrations/20260616000001_localize_divination_type_metadata.sql`

이 migration이 적용되어야 홈/카탈로그/소개 화면의 점술 설명 한글 정리가 실제 DB에 반영된다.

### 4.3 Edge Function secret 확인

Supabase Dashboard > Project Settings > Edge Functions > Secrets

필수 secret:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `REVENUECAT_WEBHOOK_SECRET`

### 4.4 Edge Function 재배포

최소 재배포 대상:

- `get-divination-detail`

권장 재배포 대상:

- `get-divination-catalog`
- `get-divination-detail`
- `create-free-reading`
- `create-ai-reading`
- `sync-revenuecat-subscription`

개별 배포 예시:

```powershell
cd E:\Project\Divination_app
npx supabase functions deploy get-divination-detail
```

한 번에 주요 함수 재배포 예시:

```powershell
cd E:\Project\Divination_app
npx supabase functions deploy get-divination-catalog
npx supabase functions deploy get-divination-detail
npx supabase functions deploy create-free-reading
npx supabase functions deploy create-ai-reading
npx supabase functions deploy sync-revenuecat-subscription
```

이번 오류와 직접 연결되는 포인트:

- `get-divination-detail`은 반드시 재배포해야 한다.
- 이 함수가 최신 코드여야 `Missing divination code.` 오류 없이 query/body 양쪽 입력을 받을 수 있다.

## 5. 서버 기능 검증

무료 점술 검증:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\test_multi_divinations.ps1
```

타로 회귀까지 포함:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\test_multi_divinations.ps1 -IncludeTarot
```

Plus AI 검증:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\test_ai_reading.ps1
```

설명:

- `test_multi_divinations.ps1`는 익명 사용자 생성 후 `saju`, `zodiac`, `rune`, `omikuji` 무료 해석을 확인한다.
- `test_ai_reading.ps1`는 비구독 차단과 Plus 사용자 AI 해석 흐름을 점검한다.

## 6. Flutter 실행 확인

Android 실기기/에뮬레이터 실행:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\run_flutter_android.ps1
```

웹 실행:

```powershell
cd E:\Project\Divination_app
powershell -ExecutionPolicy Bypass -File scripts\run_flutter_web.ps1
```

## 7. APK 빌드

릴리스 APK 빌드:

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

산출물:

- `app/flutter_app/build/app/outputs/flutter-apk/app-release.apk`

참고:

- 현재 앱은 `OPENAI_API_KEY`를 클라이언트에 넣지 않는다.
- AI 호출은 Plus 사용자만 Supabase Edge Function을 통해 서버에서 수행한다.

## 8. 스마트폰 설치

ADB 사용 예시:

```powershell
cd E:\Project\Divination_app\app\flutter_app
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

연결 기기 확인:

```powershell
adb devices
```

## 9. 설치 후 체크리스트

이번 배포 기준 확인 항목:

1. 메인 화면 앱바가 `점술`, `기록`, `플러스`로 보이는지 확인
2. 홈 추천 점술 설명에 영어/한글 혼용이 남아 있는지 확인
3. 점술 선택 후 소개 화면 진입이 정상인지 확인
4. 점술 페이지 진입 시 `Missing divination code.` 오류가 사라졌는지 확인
5. 타로 / 사주 / 별자리 / 룬 / 오미쿠지 무료 해석이 정상 동작하는지 확인
6. Plus가 아닌 계정에서 AI 해석이 차단되는지 확인
7. Plus 계정에서 AI 해석이 정상 생성되는지 확인

## 10. 이번 수정 반영용 빠른 배포 순서

가장 짧은 실전 순서:

```powershell
cd E:\Project\Divination_app
npx supabase db push
npx supabase functions deploy get-divination-detail
```

그 다음 APK 재빌드:

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

설치:

```powershell
adb install -r E:\Project\Divination_app\app\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

## 11. 트러블슈팅

`Missing divination code.`가 계속 나올 때:

- `get-divination-detail`이 최신 코드로 재배포됐는지 확인
- 배포 대상 프로젝트가 맞는지 확인
- APK가 예전 빌드인지 확인 후 다시 설치

홈 화면 설명이 아직 영어일 때:

- `npx supabase db push`가 성공했는지 확인
- 실제 연결된 Supabase 프로젝트가 올바른지 확인
- `divination_types` 테이블의 `description`, `short_description`, `origin_region` 값이 갱신됐는지 확인

Plus AI 해석이 실패할 때:

- `OPENAI_API_KEY` secret 확인
- `OPENAI_MODEL` secret 확인
- `subscriptions.status`가 `active` 또는 `trial`인지 확인
- `current_period_end > now()`인지 확인
