import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Text(
              'Plus',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text('AI 개인화 해석, 기록 확장, 광고 제거를 제공합니다.'),
            SizedBox(height: 20),
            FilledButton(
              onPressed: null,
              child: Text('RevenueCat 연동 예정'),
            ),
          ],
        ),
      ),
    );
  }
}
