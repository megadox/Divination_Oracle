import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/usage_limits.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionTitle('App'),
            const SizedBox(height: 12),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final packageInfo = snapshot.data;
                return _SettingsCard(
                  title: 'Version',
                  rows: [
                    _SettingsRow(
                      label: 'App Version',
                      value: packageInfo == null
                          ? 'Loading...'
                          : '${packageInfo.version} (${packageInfo.buildNumber})',
                    ),
                    _SettingsRow(
                      label: 'Package',
                      value: packageInfo?.packageName ?? 'Loading...',
                    ),
                    const _SettingsRow(
                      label: 'Build Mode',
                      value: kReleaseMode ? 'release' : 'development',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Configuration'),
            const SizedBox(height: 12),
            _SettingsCard(
              title: 'Runtime',
              rows: [
                _SettingsRow(
                  label: 'Supabase',
                  value: AppConfig.hasSupabaseConfig ? 'configured' : 'missing',
                ),
                _SettingsRow(
                  label: 'Free Reading Limit',
                  value: UsageLimits.isFreeReadingLimitEnabled
                      ? 'enabled (${UsageLimits.freeDailyReadingLimit}/day)'
                      : 'disabled',
                ),
                const _SettingsRow(
                  label: 'Plus AI Limit',
                  value: '${UsageLimits.aiDailyReadingLimit}/day',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Notes'),
            const SizedBox(height: 12),
            const _InfoCard(
              title: 'Development build',
              body:
                  'Use this screen to confirm the installed build version and current runtime configuration before local testing or APK validation.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              title: 'Server deployment',
              body:
                  'If Edge Functions, migrations, or server-side usage rules changed, deploy the Supabase backend separately from the app build.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final row in rows) ...[
              _SettingsRowView(row: row),
              if (row != rows.last) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow {
  const _SettingsRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _SettingsRowView extends StatelessWidget {
  const _SettingsRowView({required this.row});

  final _SettingsRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            row.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            row.value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
