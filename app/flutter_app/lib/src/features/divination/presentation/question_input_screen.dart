import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';
import '../application/reading_flow_controller.dart';

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
    final detail = ref.watch(divinationTypeProvider(widget.divinationCode));

    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: SafeArea(
        child: detail.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                value.type.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Set your question and mode first, then continue to the divination-specific input step.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _questionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Question',
                  hintText: 'You can leave this blank if you want a general reading.',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(value: 'love', child: Text('Love')),
                  DropdownMenuItem(value: 'career', child: Text('Career')),
                  DropdownMenuItem(value: 'money', child: Text('Money')),
                  DropdownMenuItem(value: 'health', child: Text('Health')),
                  DropdownMenuItem(value: 'relationship', child: Text('Relationship')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.style),
                    label: Text('Free'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.auto_awesome),
                    label: Text('AI'),
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
                label: const Text('Continue'),
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
