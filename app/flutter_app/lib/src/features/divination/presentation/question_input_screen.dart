import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/page_index_card.dart';
import '../application/divination_providers.dart';
import '../application/reading_flow_controller.dart';
import 'divination_localizations.dart';

class QuestionInputScreen extends ConsumerStatefulWidget {
  const QuestionInputScreen({required this.divinationCode, super.key});

  final String divinationCode;

  @override
  ConsumerState<QuestionInputScreen> createState() => _QuestionInputScreenState();
}

class _QuestionInputScreenState extends ConsumerState<QuestionInputScreen> {
  late final TextEditingController _questionController;
  late String _category;
  late bool _useAi;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(readingFlowControllerProvider(widget.divinationCode));
    _questionController = TextEditingController(text: draft.question);
    _category = draft.category;
    _useAi = draft.useAi;
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final detail = ref.watch(divinationTypeProvider(widget.divinationCode));

    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.ko ? '질문 설정' : 'Question'),
        actions: [
          IconButton(
            tooltip: language == AppLanguage.ko ? '홈' : 'Home',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: detail.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PageIndexCard(
                index: 'p_3',
                label: language == AppLanguage.ko ? '질문 입력' : 'Question step',
              ),
              const SizedBox(height: 16),
              Text(
                localizedDivinationDisplayName(value.type, language),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                language == AppLanguage.ko
                    ? '질문과 해석 모드를 먼저 정한 뒤, 점술별 입력 단계로 진행하세요.'
                    : 'Set your question and mode first, then continue to the divination-specific input step.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _questionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: language == AppLanguage.ko ? '질문' : 'Question',
                  hintText: language == AppLanguage.ko
                      ? '일반 흐름만 보고 싶다면 비워둘 수 있습니다.'
                      : 'You can leave this blank if you want a general reading.',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: language == AppLanguage.ko ? '카테고리' : 'Category',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'general',
                    child: Text(language == AppLanguage.ko ? '일반' : 'General'),
                  ),
                  DropdownMenuItem(
                    value: 'love',
                    child: Text(language == AppLanguage.ko ? '연애' : 'Love'),
                  ),
                  DropdownMenuItem(
                    value: 'career',
                    child: Text(language == AppLanguage.ko ? '직업' : 'Career'),
                  ),
                  DropdownMenuItem(
                    value: 'money',
                    child: Text(language == AppLanguage.ko ? '금전' : 'Money'),
                  ),
                  DropdownMenuItem(
                    value: 'health',
                    child: Text(language == AppLanguage.ko ? '건강' : 'Health'),
                  ),
                  DropdownMenuItem(
                    value: 'relationship',
                    child: Text(language == AppLanguage.ko ? '관계' : 'Relationship'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.style),
                    label: Text(language == AppLanguage.ko ? '무료' : 'Free'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(language == AppLanguage.ko ? 'AI' : 'AI'),
                  ),
                ],
                selected: {_useAi},
                onSelectionChanged: (value) {
                  setState(() => _useAi = value.first);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _goToNextStep,
                icon: const Icon(Icons.arrow_forward),
                label: Text(language == AppLanguage.ko ? '다음으로' : 'Continue'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: Text(language == AppLanguage.ko ? '메인으로 이동' : 'Go Home'),
              ),
            ],
          ),
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void _goToNextStep() {
    final notifier = ref.read(
      readingFlowControllerProvider(widget.divinationCode).notifier,
    );
    notifier.setQuestion(_questionController.text);
    notifier.setCategory(_category);
    notifier.setUseAi(_useAi);
    context.push('/reading/${widget.divinationCode}/input');
  }
}
