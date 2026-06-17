import 'package:flutter/material.dart';

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Required',
      home: Scaffold(
        appBar: AppBar(title: const Text('설정 필요')),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supabase 설정이 전달되지 않았습니다.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text(
                  '앱 실행 시 SUPABASE_URL과 SUPABASE_ANON_KEY를 dart define으로 전달해야 합니다.',
                ),
                SizedBox(height: 12),
                SelectableText(
                  'flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
