import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/page_index_card.dart';
import '../application/divination_providers.dart';
import '../domain/divination_type.dart';
import 'divination_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedDivinationTitle(language)),
        actions: [
          PopupMenuButton<AppLanguage>(
            initialValue: language,
            tooltip: language == AppLanguage.ko ? '언어 선택' : 'Choose language',
            onSelected: (value) {
              ref.read(appLanguageProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              for (final value in AppLanguage.values)
                PopupMenuItem<AppLanguage>(
                  value: value,
                  child: Text(value.label),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(
                child: Text(
                  language.label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: language == AppLanguage.ko ? '기록' : 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: language == AppLanguage.ko ? '플러스' : 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            tooltip: language == AppLanguage.ko ? '설정' : 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PageIndexCard(
              index: 'main',
              label: language == AppLanguage.ko ? '메인 화면' : 'Main screen',
            ),
            const SizedBox(height: 16),
            _HeroPanel(
              language: language,
              onBrowseCatalog: () => context.push('/catalog'),
              onStartTarot: () => context.push('/reading/tarot'),
            ),
            const SizedBox(height: 24),
            Text(
              language == AppLanguage.ko ? '추천 점술' : 'Featured Divinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            types.when(
              data: (items) => _FeaturedDivinations(
                types: items.take(3).toList(),
                language: language,
              ),
              error: (error, stackTrace) => _InfoCard(
                title: language == AppLanguage.ko
                    ? '점술 목록을 불러오지 못했습니다.'
                    : 'Failed to load divinations',
                body: '$error',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              title: language == AppLanguage.ko ? '이용 흐름' : 'Reading Flow',
              body: language == AppLanguage.ko
                  ? '점술을 선택하고 질문을 입력한 뒤, 무료 해석을 먼저 보고 더 깊은 개인화 해석이 필요할 때 Plus AI로 확장할 수 있습니다.'
                  : 'Choose a divination, enter your question, review the free reading first, and expand to Plus AI when you want a deeper personalized interpretation.',
            ),
            const SizedBox(height: 16),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final packageInfo = snapshot.data;
                return _InfoCard(
                  title: language == AppLanguage.ko ? '앱 버전' : 'App Version',
                  body: packageInfo == null
                      ? (language == AppLanguage.ko ? '불러오는 중...' : 'Loading...')
                      : 'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.language,
    required this.onBrowseCatalog,
    required this.onStartTarot,
  });

  final AppLanguage language;
  final VoidCallback onBrowseCatalog;
  final VoidCallback onStartTarot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == AppLanguage.ko
                  ? '오늘은 어떤 점술로 흐름을 볼까요?'
                  : 'What kind of reading do you want today?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              language == AppLanguage.ko
                  ? '타로, 사주, 룬, 오미쿠지, 별자리를 같은 흐름에서 선택하고 진행할 수 있도록 앱 구조를 맞추고 있습니다.'
                  : 'Tarot, Saju, Rune, Omikuji, and Zodiac now follow the same reading flow so each type can expand cleanly from the same app structure.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onBrowseCatalog,
                  icon: const Icon(Icons.explore),
                  label: Text(
                    language == AppLanguage.ko
                        ? '점술 선택하기'
                        : 'Browse Divinations',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onStartTarot,
                  icon: const Icon(Icons.style),
                  label: Text(
                    language == AppLanguage.ko ? '바로 타로 보기' : 'Start Tarot',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedDivinations extends StatelessWidget {
  const _FeaturedDivinations({
    required this.types,
    required this.language,
  });

  final List<DivinationType> types;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return _InfoCard(
        title: language == AppLanguage.ko
            ? '준비된 점술이 없습니다.'
            : 'No divinations available',
        body: language == AppLanguage.ko
            ? '활성화된 점술이 등록되면 여기서 바로 선택할 수 있습니다.'
            : 'Active divinations will appear here once they are configured.',
      );
    }

    return Column(
      children: [
        for (final type in types) ...[
          _DivinationPreviewCard(type: type, language: language),
          if (type != types.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DivinationPreviewCard extends StatelessWidget {
  const _DivinationPreviewCard({
    required this.type,
    required this.language,
  });

  final DivinationType type;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/catalog/${type.code}'),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                _typeIcon(type),
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedDivinationDisplayName(type, language),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedDivinationSummary(type, language),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(
                        label: localizedInputModePill(type.inputMode, language),
                      ),
                      if (type.isPlusOnly)
                        _Pill(
                          label: language == AppLanguage.ko
                              ? 'Plus 전용'
                              : 'Plus only',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(DivinationType type) {
  return switch (type.code) {
    'tarot' => Icons.style,
    'saju' => Icons.calendar_month,
    'rune' => Icons.circle_outlined,
    'omikuji' => Icons.receipt_long,
    'zodiac' => Icons.stars,
    _ => Icons.auto_awesome,
  };
}

