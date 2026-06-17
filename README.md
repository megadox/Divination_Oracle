
# Divination_Oracle
점술과 예언

Flutter + Supabase 기반 점술 서비스 앱입니다.

## MVP 방향

- 무료 사용자: Supabase DB에 저장된 고정 해석 제공
- Plus 사용자: Supabase Edge Function에서 구독/사용량 확인 후 OpenAI 개인화 해석 제공
- 구독 상태: RevenueCat webhook으로 Supabase `subscriptions`에 동기화

## 구조

```text
app/
  flutter_app/
    lib/
      src/
        core/
        features/
supabase/
  migrations/
  functions/
docs/
```

## Flutter 실행 준비

현재 저장소에는 Flutter 앱 소스 구조와 `pubspec.yaml`이 생성되어 있습니다.
로컬에 Flutter SDK를 설치한 뒤 아래 순서로 플랫폼 폴더를 보강합니다.

```powershell
cd app/flutter_app
flutter create . --platforms android,ios
flutter pub get
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Supabase Edge Function 환경 변수

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `REVENUECAT_WEBHOOK_SECRET`
