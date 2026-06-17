import 'package:flutter/material.dart';

enum ReadingResultSectionType {
  text,
  badges,
  metrics,
  list,
}

class ReadingResultSection {
  const ReadingResultSection.text({
    required this.title,
    required this.body,
  })  : type = ReadingResultSectionType.text,
        badges = const [],
        metrics = const [],
        items = const [];

  const ReadingResultSection.badges({
    required this.title,
    required this.badges,
  })  : type = ReadingResultSectionType.badges,
        body = null,
        metrics = const [],
        items = const [];

  const ReadingResultSection.metrics({
    required this.title,
    required this.metrics,
  })  : type = ReadingResultSectionType.metrics,
        body = null,
        badges = const [],
        items = const [];

  const ReadingResultSection.list({
    required this.title,
    required this.items,
  })  : type = ReadingResultSectionType.list,
        body = null,
        badges = const [],
        metrics = const [];

  final ReadingResultSectionType type;
  final String title;
  final String? body;
  final List<ReadingResultBadge> badges;
  final List<ReadingResultMetric> metrics;
  final List<ReadingResultListItem> items;
}

class ReadingResultBadge {
  const ReadingResultBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class ReadingResultMetric {
  const ReadingResultMetric({
    required this.label,
    required this.value,
    this.maxValue = 4,
  });

  final String label;
  final int value;
  final int maxValue;
}

class ReadingResultListItem {
  const ReadingResultListItem({
    required this.title,
    this.subtitle,
    this.body,
    this.color,
  });

  final String title;
  final String? subtitle;
  final String? body;
  final Color? color;
}
