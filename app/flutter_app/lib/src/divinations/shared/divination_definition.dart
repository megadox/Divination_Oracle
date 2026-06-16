import 'package:flutter/material.dart';

import '../../features/divination/domain/reading_detail.dart';
import 'reading_result_section.dart';

class DivinationHeroData {
  const DivinationHeroData({
    required this.assetPath,
    required this.title,
    required this.accentColor,
    this.subtitle,
    this.tags = const [],
  });

  final String assetPath;
  final String title;
  final String? subtitle;
  final List<String> tags;
  final Color accentColor;
}

abstract class DivinationDefinition {
  const DivinationDefinition();

  String get code;

  DivinationHeroData? buildHero(ReadingDetail detail);

  List<ReadingResultSection> buildResultSections(ReadingDetail detail);
}
