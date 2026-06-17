import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/page_index_card.dart';
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plus'),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            PageIndexCard(index: 'p_6', label: 'Plus / Subscription'),
            SizedBox(height: 16),
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
