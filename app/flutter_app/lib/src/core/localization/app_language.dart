import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  ko('ko'),
  en('en');

  const AppLanguage(this.code);

  final String code;
}

final appLanguageProvider = StateProvider<AppLanguage>((ref) {
  return AppLanguage.ko;
});

extension AppLanguageLabel on AppLanguage {
  String get label {
    return switch (this) {
      AppLanguage.ko => '한국어',
      AppLanguage.en => 'English',
    };
  }
}
