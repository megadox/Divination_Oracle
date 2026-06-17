import '../../../core/localization/app_language.dart';
import '../domain/divination_input_definition.dart';
import '../domain/divination_type.dart';
import '../domain/tarot_spread.dart';

String localizedDivinationTitle(AppLanguage language) {
  return switch (language) {
    AppLanguage.ko => '점술',
    AppLanguage.en => 'Divination',
  };
}

String localizedDivinationDisplayName(
  DivinationType type,
  AppLanguage language,
) {
  return switch ((type.code, language)) {
    ('tarot', AppLanguage.ko) => '타로',
    ('tarot', AppLanguage.en) => 'Tarot',
    ('saju', AppLanguage.ko) => '사주',
    ('saju', AppLanguage.en) => 'Saju',
    ('rune', AppLanguage.ko) => '룬',
    ('rune', AppLanguage.en) => 'Rune',
    ('omikuji', AppLanguage.ko) => '오미쿠지',
    ('omikuji', AppLanguage.en) => 'Omikuji',
    ('zodiac', AppLanguage.ko) => '별자리',
    ('zodiac', AppLanguage.en) => 'Zodiac',
    _ => type.displayName,
  };
}

String localizedDivinationNameFromCode(
  String code,
  String fallback,
  AppLanguage language,
) {
  return switch ((code, language)) {
    ('tarot', AppLanguage.ko) => '타로',
    ('tarot', AppLanguage.en) => 'Tarot',
    ('saju', AppLanguage.ko) => '사주',
    ('saju', AppLanguage.en) => 'Saju',
    ('rune', AppLanguage.ko) => '룬',
    ('rune', AppLanguage.en) => 'Rune',
    ('omikuji', AppLanguage.ko) => '오미쿠지',
    ('omikuji', AppLanguage.en) => 'Omikuji',
    ('zodiac', AppLanguage.ko) => '별자리',
    ('zodiac', AppLanguage.en) => 'Zodiac',
    _ => fallback,
  };
}

String localizedDivinationSummary(
  DivinationType type,
  AppLanguage language,
) {
  return switch ((type.code, language)) {
    ('tarot', AppLanguage.ko) => '카드로 현재 흐름과 조언을 살펴봅니다.',
    ('tarot', AppLanguage.en) => 'Use cards to explore the current flow and guidance.',
    ('saju', AppLanguage.ko) => '생년월일시를 기반으로 기질과 흐름을 봅니다.',
    ('saju', AppLanguage.en) => 'Read temperament and life flow from birth date and time.',
    ('rune', AppLanguage.ko) => '룬 상징으로 현재 에너지와 방향을 읽습니다.',
    ('rune', AppLanguage.en) => 'Read the current energy and direction through rune symbols.',
    ('omikuji', AppLanguage.ko) => '제비를 뽑아 오늘의 길흉과 메시지를 확인합니다.',
    ('omikuji', AppLanguage.en) => 'Draw a fortune slip to check today\'s luck and message.',
    ('zodiac', AppLanguage.ko) => '생년월일을 기반으로 별자리 성향과 흐름을 봅니다.',
    ('zodiac', AppLanguage.en) => 'Read zodiac traits and flow from the birth date.',
    _ => type.shortDescription ?? type.description ?? _defaultDescription(language),
  };
}

String localizedDivinationDescription(
  DivinationType type,
  AppLanguage language,
) {
  return switch ((type.code, language)) {
    ('tarot', AppLanguage.ko) => '카드 상징을 통해 현재 흐름과 조언을 읽는 점술',
    ('tarot', AppLanguage.en) => 'A card-based divination that reads the current flow and guidance.',
    ('saju', AppLanguage.ko) => '생년월일시를 바탕으로 기질과 인생 흐름을 해석하는 동아시아 명리 점술',
    ('saju', AppLanguage.en) => 'An East Asian destiny reading that interprets temperament and life flow from birth data.',
    ('rune', AppLanguage.ko) => '룬 상징을 통해 현재 에너지와 방향성을 읽는 점술',
    ('rune', AppLanguage.en) => 'A rune reading that interprets current energy and direction through symbols.',
    ('omikuji', AppLanguage.ko) => '제비를 뽑아 오늘의 길흉과 메시지를 확인하는 점술',
    ('omikuji', AppLanguage.en) => 'A fortune-slip reading that reveals today\'s luck and message.',
    ('zodiac', AppLanguage.ko) => '생년월일을 바탕으로 별자리 성향과 흐름을 읽는 입문형 점성술',
    ('zodiac', AppLanguage.en) => 'An introductory astrology reading that explores zodiac traits and flow from birth date.',
    _ => type.description ?? type.shortDescription ?? _defaultDescription(language),
  };
}

String localizedDivinationOrigin(
  DivinationType type,
  AppLanguage language,
) {
  return switch ((type.code, language)) {
    ('tarot', AppLanguage.ko) => '서유럽',
    ('tarot', AppLanguage.en) => 'Western Europe',
    ('saju', AppLanguage.ko) => '한국 · 동아시아',
    ('saju', AppLanguage.en) => 'Korea · East Asia',
    ('rune', AppLanguage.ko) => '북유럽',
    ('rune', AppLanguage.en) => 'Northern Europe',
    ('omikuji', AppLanguage.ko) => '일본',
    ('omikuji', AppLanguage.en) => 'Japan',
    ('zodiac', AppLanguage.ko) => '전 세계',
    ('zodiac', AppLanguage.en) => 'Global',
    _ => type.originRegion ?? '',
  };
}

String localizedInputModePill(String inputMode, AppLanguage language) {
  return switch ((inputMode, language)) {
    ('draw_based', AppLanguage.ko) => '추첨형',
    ('draw_based', AppLanguage.en) => 'Draw-based',
    ('birth_data_based', AppLanguage.ko) => '생년월일형',
    ('birth_data_based', AppLanguage.en) => 'Birth-data',
    ('hybrid', AppLanguage.ko) => '복합형',
    ('hybrid', AppLanguage.en) => 'Hybrid',
    (_, AppLanguage.ko) => '기타',
    (_, AppLanguage.en) => 'Other',
  };
}

String localizedInputModeDescription(String inputMode, AppLanguage language) {
  return switch ((inputMode, language)) {
    ('draw_based', AppLanguage.ko) => '카드나 상징을 먼저 뽑고 결과를 해석합니다.',
    ('draw_based', AppLanguage.en) => 'Draw cards or symbols first, then interpret the result.',
    ('birth_data_based', AppLanguage.ko) => '생년월일과 시간 같은 입력값을 바탕으로 계산합니다.',
    ('birth_data_based', AppLanguage.en) => 'Calculate the result from birth date and time input.',
    ('hybrid', AppLanguage.ko) => '사용자 입력과 내장 규칙을 조합해 결과를 만듭니다.',
    ('hybrid', AppLanguage.en) => 'Combine user input with built-in rules to produce the result.',
    (_, AppLanguage.ko) => '구성이 준비 중입니다.',
    (_, AppLanguage.en) => 'Configuration is being prepared.',
  };
}

String localizedInterpretationLabel(
  String interpretationMode,
  AppLanguage language,
) {
  return switch ((interpretationMode, language)) {
    ('lookup_plus_ai', AppLanguage.ko) => '고정 해석 + Plus AI 확장',
    ('lookup_plus_ai', AppLanguage.en) => 'Static reading with optional Plus AI expansion',
    ('rule_plus_ai', AppLanguage.ko) => '규칙 해석 + Plus AI 확장',
    ('rule_plus_ai', AppLanguage.en) => 'Rule-based reading with optional Plus AI expansion',
    ('rule_based', AppLanguage.ko) => '규칙 기반 무료 해석',
    ('rule_based', AppLanguage.en) => 'Rule-based free reading',
    ('prewritten_lookup', AppLanguage.ko) => '사전 작성 해석 조회',
    ('prewritten_lookup', AppLanguage.en) => 'Prewritten reading lookup',
    (_, AppLanguage.ko) => '구성이 준비 중입니다.',
    (_, AppLanguage.en) => 'Configuration is being prepared.',
  };
}

String localizedFlowDescription(String code, AppLanguage language) {
  return switch ((code, language)) {
    ('tarot', AppLanguage.ko) => '질문을 입력하고 스프레드를 선택한 뒤 카드를 뽑아 해석을 확인합니다.',
    ('tarot', AppLanguage.en) => 'Enter a question, choose a spread, draw cards, and review the reading.',
    ('saju', AppLanguage.ko) => '생년월일시를 입력해 흐름을 계산하고 무료 또는 AI 해석을 확인합니다.',
    ('saju', AppLanguage.en) => 'Enter birth data, calculate the flow, and review the free or AI reading.',
    ('zodiac', AppLanguage.ko) => '생년월일을 입력해 별자리를 계산하고 성향과 흐름을 살펴봅니다.',
    ('zodiac', AppLanguage.en) => 'Enter the birth date, resolve the sign, and review traits and flow.',
    ('rune', AppLanguage.ko) => '룬을 뽑아 현재 상황에 대한 상징과 조언을 읽습니다.',
    ('rune', AppLanguage.en) => 'Draw runes and review symbolic guidance for the current situation.',
    ('omikuji', AppLanguage.ko) => '제비를 뽑아 오늘의 운세 분위기와 메시지를 확인합니다.',
    ('omikuji', AppLanguage.en) => 'Draw a fortune slip and review today\'s luck and message.',
    (_, AppLanguage.ko) => '각 점술은 같은 입력과 결과 흐름 안에서 동작합니다.',
    (_, AppLanguage.en) => 'Each divination follows the same overall input and result flow.',
  };
}

String localizedSpreadName(TarotSpread spread, AppLanguage language) {
  return switch ((spread.code, language)) {
    ('daily_one_card', AppLanguage.ko) => '오늘의 카드',
    ('daily_one_card', AppLanguage.en) => 'Card of the Day',
    ('single_question', AppLanguage.ko) => '질문 1장',
    ('single_question', AppLanguage.en) => 'Single Question',
    ('three_card_timeline', AppLanguage.ko) => '과거-현재-미래',
    ('three_card_timeline', AppLanguage.en) => 'Past-Present-Future',
    ('situation_advice', AppLanguage.ko) => '상황-장애물-조언',
    ('situation_advice', AppLanguage.en) => 'Situation-Challenge-Advice',
    ('choice_ab', AppLanguage.ko) => '선택 A/B 비교',
    ('choice_ab', AppLanguage.en) => 'Choice A/B Comparison',
    ('relationship', AppLanguage.ko) => '관계 리딩',
    ('relationship', AppLanguage.en) => 'Relationship Reading',
    ('celtic_cross', AppLanguage.ko) => '켈틱 크로스',
    ('celtic_cross', AppLanguage.en) => 'Celtic Cross',
    _ => spread.name,
  };
}

String localizedSpreadDescription(TarotSpread spread, AppLanguage language) {
  return switch ((spread.code, language)) {
    ('daily_one_card', AppLanguage.ko) => '오늘 하루를 위한 핵심 메시지를 한 장으로 확인합니다.',
    ('daily_one_card', AppLanguage.en) => 'Review the core message for today with one card.',
    ('single_question', AppLanguage.ko) => '구체적인 질문에 대한 핵심 답변을 한 장으로 확인합니다.',
    ('single_question', AppLanguage.en) => 'Review the core answer to a specific question with one card.',
    ('three_card_timeline', AppLanguage.ko) => '상황의 흐름을 과거, 현재, 미래 세 장으로 살펴봅니다.',
    ('three_card_timeline', AppLanguage.en) => 'Review the flow of a situation across past, present, and future.',
    ('situation_advice', AppLanguage.ko) => '현재 상황, 넘어야 할 지점, 실천 조언을 세 장으로 확인합니다.',
    ('situation_advice', AppLanguage.en) => 'Review the situation, challenge, and practical advice with three cards.',
    ('choice_ab', AppLanguage.ko) => '두 선택지의 흐름과 결과를 비교합니다.',
    ('choice_ab', AppLanguage.en) => 'Compare the flow and outcome of two choices.',
    ('relationship', AppLanguage.ko) => '나, 상대, 관계의 흐름과 조언을 살펴봅니다.',
    ('relationship', AppLanguage.en) => 'Review you, the other person, and the relationship flow with guidance.',
    ('celtic_cross', AppLanguage.ko) => '상황을 깊고 종합적으로 분석하는 10장 스프레드입니다.',
    ('celtic_cross', AppLanguage.en) => 'A ten-card spread for a deep and comprehensive analysis.',
    _ => spread.description ?? _defaultDescription(language),
  };
}

String localizedInputFieldLabel(
  DivinationInputDefinition input,
  AppLanguage language,
) {
  return switch ((input.fieldKey, language)) {
    ('spread_code', AppLanguage.ko) => '스프레드',
    ('spread_code', AppLanguage.en) => 'Spread',
    ('name', AppLanguage.ko) => '이름 또는 별칭',
    ('name', AppLanguage.en) => 'Name or Nickname',
    ('birth_date', AppLanguage.ko) => '생년월일',
    ('birth_date', AppLanguage.en) => 'Birth Date',
    ('birth_time', AppLanguage.ko) => '출생시간',
    ('birth_time', AppLanguage.en) => 'Birth Time',
    ('calendar_type', AppLanguage.ko) => '달력 종류',
    ('calendar_type', AppLanguage.en) => 'Calendar Type',
    ('gender', AppLanguage.ko) => '성별',
    ('gender', AppLanguage.en) => 'Gender',
    _ => input.fieldLabel,
  };
}

String localizedInputFieldType(
  DivinationInputDefinition input,
  AppLanguage language,
) {
  return switch ((input.fieldType, language)) {
    ('select', AppLanguage.ko) => '선택형',
    ('select', AppLanguage.en) => 'Select',
    ('text', AppLanguage.ko) => '텍스트',
    ('text', AppLanguage.en) => 'Text',
    ('date', AppLanguage.ko) => '날짜',
    ('date', AppLanguage.en) => 'Date',
    ('time', AppLanguage.ko) => '시간',
    ('time', AppLanguage.en) => 'Time',
    ('boolean', AppLanguage.ko) => '참/거짓',
    ('boolean', AppLanguage.en) => 'Boolean',
    _ => input.fieldType,
  };
}

String localizedInputHelpText(
  DivinationInputDefinition input,
  AppLanguage language,
) {
  return switch ((input.fieldKey, language)) {
    ('spread_code', AppLanguage.ko) => '질문에 맞는 타로 전개 방식을 선택합니다.',
    ('spread_code', AppLanguage.en) => 'Choose the tarot spread format that best fits your question.',
    ('birth_time', AppLanguage.ko) => '모르면 비워둘 수 있지만 해석 정확도가 낮아질 수 있습니다.',
    ('birth_time', AppLanguage.en) => 'You may leave it empty if unknown, but the reading can be less precise.',
    ('calendar_type', AppLanguage.ko) => '양력과 음력 중 출생 기준을 선택합니다.',
    ('calendar_type', AppLanguage.en) => 'Choose whether the birth date follows the solar or lunar calendar.',
    ('gender', AppLanguage.ko) => '사주 계산 기준에 사용할 성별을 선택합니다.',
    ('gender', AppLanguage.en) => 'Choose the gender used for the saju calculation.',
    _ => input.helpText ?? '',
  };
}

String _defaultDescription(AppLanguage language) {
  return switch (language) {
    AppLanguage.ko => '설명이 준비 중입니다.',
    AppLanguage.en => 'Description is being prepared.',
  };
}
