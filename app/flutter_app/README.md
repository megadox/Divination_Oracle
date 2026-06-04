# Divination Flutter App

Divination App의 Flutter 클라이언트입니다.

## 실행 준비

루트 프로젝트의 `docs/setup_tools.md`를 먼저 확인한다.

```powershell
cd E:\Project\Divination_app\app\flutter_app
flutter pub get
flutter analyze
flutter test
```

Supabase 연결값은 실행 시 dart define으로 전달한다.

```powershell
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
