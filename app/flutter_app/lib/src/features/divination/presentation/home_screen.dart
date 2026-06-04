import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/divination_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _questionController = TextEditingController();
  var _category = 'general';
  var _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Divination'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.go('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '오늘의 질문',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '궁금한 일을 짧게 적어주세요.',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('일반')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 20),
            types.when(
              data: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FilledButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _createReading(item.code, useAi: false),
                        icon: const Icon(Icons.style),
                        label: Text('${item.displayName} 무료 해석'),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _createReading('tarot', useAi: true),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Plus AI 타로 해석'),
                  ),
                ],
              ),
              error: (error, stackTrace) => Text('점술 목록을 불러오지 못했습니다: $error'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createReading(String typeCode, {required bool useAi}) async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
      final reading = useAi
          ? await repository.createAiReading(
              divinationTypeCode: typeCode,
              category: _category,
              question: _questionController.text,
            )
          : await repository.createFreeReading(
              divinationTypeCode: typeCode,
              category: _category,
              question: _questionController.text,
            );
      if (mounted) {
        context.go('/result/${reading.id}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
