import type { ReadingRequest } from './readings.ts';

type SajuPayload = {
  zodiac_animal: string;
  heavenly_element: string;
  season: string;
  yin_yang: 'yin' | 'yang';
  dominant_element: string;
  element_counts: Record<string, number>;
  has_birth_time: boolean;
  calendar_type: string;
  gender: string;
};

type SajuResolution = {
  resultText: string;
  resultJson: Record<string, unknown>;
  payloads: Array<{
    payload_type: string;
    payload_json: Record<string, unknown>;
  }>;
};

const zodiacAnimals = [
  '쥐',
  '소',
  '호랑이',
  '토끼',
  '용',
  '뱀',
  '말',
  '양',
  '원숭이',
  '닭',
  '개',
  '돼지',
];

const fiveElements = ['wood', 'fire', 'earth', 'metal', 'water'] as const;

export function resolveFreeSajuReading(request: ReadingRequest): SajuResolution {
  const inputs = request.inputs ?? {};
  const birthDateRaw = asString(inputs.birth_date);
  const birthTimeRaw = asString(inputs.birth_time);
  const calendarType = asString(inputs.calendar_type) ?? 'solar';
  const gender = asString(inputs.gender) ?? 'female';
  const name = asString(inputs.name);
  const birthTimeUnknown = Boolean(inputs.birth_time_unknown);

  if (!birthDateRaw) {
    throw new Error('Saju reading requires birth_date input.');
  }

  const birthDate = parseDateOnly(birthDateRaw);
  if (!birthDate) {
    throw new Error('Invalid birth_date format. Use YYYY-MM-DD.');
  }

  const zodiacAnimal = zodiacAnimals[(birthDate.getUTCFullYear() - 4) % 12];
  const heavenlyElement = elementFromNumber(birthDate.getUTCFullYear());
  const season = seasonFromMonth(birthDate.getUTCMonth() + 1);
  const seasonElement = elementFromSeason(season);
  const dayElement = elementFromNumber(birthDate.getUTCDate());
  const timeElement = birthTimeRaw ? elementFromTime(birthTimeRaw) : null;
  const yinYang = (birthDate.getUTCFullYear() + birthDate.getUTCMonth() + birthDate.getUTCDate()) % 2 === 0
    ? 'yang'
    : 'yin';

  const elementCounts = {
    wood: 0,
    fire: 0,
    earth: 0,
    metal: 0,
    water: 0,
  };

  elementCounts[heavenlyElement] += 2;
  elementCounts[seasonElement] += 2;
  elementCounts[dayElement] += 1;
  if (timeElement) {
    elementCounts[timeElement] += 1;
  }

  const dominantElement = fiveElements.reduce((best, current) =>
    elementCounts[current] > elementCounts[best] ? current : best
  );

  const summary = buildSummary({
    name,
    dominantElement,
    category: request.category ?? 'general',
    season,
  });
  const detailedReading = buildDetailedReading({
    zodiacAnimal,
    heavenlyElement,
    season,
    yinYang,
    dominantElement,
    hasBirthTime: Boolean(birthTimeRaw) && !birthTimeUnknown,
    category: request.category ?? 'general',
    question: request.question ?? '',
  });
  const advice = buildAdvice({
    dominantElement,
    category: request.category ?? 'general',
  });
  const caution = buildCaution({
    dominantElement,
    birthTimeUnknown,
  });

  const payload: SajuPayload = {
    zodiac_animal: zodiacAnimal,
    heavenly_element: heavenlyElement,
    season,
    yin_yang: yinYang,
    dominant_element: dominantElement,
    element_counts: elementCounts,
    has_birth_time: Boolean(birthTimeRaw) && !birthTimeUnknown,
    calendar_type: calendarType,
    gender,
  };

  const resultJson: Record<string, unknown> = {
    summary,
    detailed_reading: detailedReading,
    advice,
    caution,
    source_payload: payload,
  };

  const resultText = [
    summary,
    detailedReading,
    `조언: ${advice}`,
    `주의: ${caution}`,
  ].join('\n\n');

  return {
    resultText,
    resultJson,
    payloads: [
      {
        payload_type: 'saju_chart',
        payload_json: payload,
      },
    ],
  };
}

export function buildSajuAiBaseInterpretations(request: ReadingRequest) {
  const freeReading = resolveFreeSajuReading(request);

  return {
    freeReading,
    baseInterpretations: {
      summary: freeReading.resultJson.summary,
      detailed_reading: freeReading.resultJson.detailed_reading,
      advice: freeReading.resultJson.advice,
      caution: freeReading.resultJson.caution,
      source_payload: freeReading.resultJson.source_payload,
      inputs: request.inputs ?? {},
    },
  };
}

function asString(value: unknown): string | null {
  return typeof value === 'string' && value.trim().length > 0
    ? value.trim()
    : null;
}

function parseDateOnly(value: string): Date | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) {
    return null;
  }

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const date = new Date(Date.UTC(year, month - 1, day));

  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }

  return date;
}

function elementFromNumber(value: number): typeof fiveElements[number] {
  return fiveElements[Math.abs(value) % fiveElements.length];
}

function elementFromTime(value: string): typeof fiveElements[number] {
  const [hourText = '0'] = value.split(':');
  return elementFromNumber(Number(hourText) || 0);
}

function seasonFromMonth(month: number): string {
  if (month >= 3 && month <= 5) {
    return 'spring';
  }
  if (month >= 6 && month <= 8) {
    return 'summer';
  }
  if (month >= 9 && month <= 11) {
    return 'autumn';
  }
  return 'winter';
}

function elementFromSeason(season: string): typeof fiveElements[number] {
  switch (season) {
    case 'spring':
      return 'wood';
    case 'summer':
      return 'fire';
    case 'autumn':
      return 'metal';
    default:
      return 'water';
  }
}

function buildSummary(
  options: {
    name: string | null;
    dominantElement: string;
    category: string;
    season: string;
  },
): string {
  const prefix = options.name ? `${options.name}님의 흐름은` : '현재 흐름은';
  const elementLabel = elementLabelKo(options.dominantElement);

  switch (options.category) {
    case 'career':
      return `${prefix} ${elementLabel} 기운이 강해, 올해는 방향을 다지며 실력을 정리하는 쪽이 유리합니다.`;
    case 'love':
      return `${prefix} ${elementLabel} 기운이 중심이라, 감정 표현의 속도와 균형이 중요한 시기입니다.`;
    case 'money':
      return `${prefix} ${elementLabel} 기운이 중심이라, 확장보다 관리와 흐름 점검이 더 중요합니다.`;
    case 'relationship':
      return `${prefix} ${elementLabel} 기운이 강해, 관계에서는 주도성과 배려의 균형이 핵심입니다.`;
    default:
      return `${prefix} ${seasonLabelKo(options.season)}의 ${elementLabel} 기운이 두드러져 기반을 정리하며 흐름을 읽는 데 강점이 있습니다.`;
  }
}

function buildDetailedReading(
  options: {
    zodiacAnimal: string;
    heavenlyElement: string;
    season: string;
    yinYang: 'yin' | 'yang';
    dominantElement: string;
    hasBirthTime: boolean;
    category: string;
    question: string;
  },
): string {
  const animal = `${options.zodiacAnimal}띠`;
  const element = elementLabelKo(options.heavenlyElement);
  const dominant = elementLabelKo(options.dominantElement);
  const yinYangLabel = options.yinYang === 'yang' ? '양' : '음';
  const questionText = options.question
    ? `질문인 "${options.question}"을 기준으로 보면, `
    : '';
  const timeNote = options.hasBirthTime
    ? '출생시간 정보가 있어 해석의 결을 조금 더 구체적으로 잡을 수 있습니다.'
    : '출생시간이 없으므로 세부 결은 단순화해 읽고 있습니다.';

  return `${animal}의 흐름과 ${element} 성향, ${seasonLabelKo(options.season)}의 분위기가 함께 작동하고 있습니다. `
    + `${questionText}${dominant} 기운이 중심이라 무작정 밀어붙이기보다 흐름을 읽고 순서를 정하는 쪽이 잘 맞습니다. `
    + `${yinYangLabel}의 성향이 섞여 있어 겉으로 보이는 판단과 내면의 리듬을 함께 챙기는 것이 중요합니다. `
    + timeNote;
}

function buildAdvice(
  options: {
    dominantElement: string;
    category: string;
  },
): string {
  switch (options.dominantElement) {
    case 'wood':
      return '성장을 서두르기보다 계획을 세운 뒤 한 단계씩 확장해 보세요.';
    case 'fire':
      return '의욕이 앞서기 쉬우니 중요한 결정은 하루 정도 간격을 두고 다시 점검해 보세요.';
    case 'earth':
      return '기반을 다지는 일, 반복 관리, 생활 루틴 정비가 실제 운을 안정시키는 데 도움이 됩니다.';
    case 'metal':
      return '선택과 정리를 미루지 말고 기준을 분명히 세우는 것이 좋습니다.';
    case 'water':
      return '정보를 더 모으고 흐름을 관찰한 뒤 움직이면 실수가 줄어듭니다.';
    default:
      return '지금은 결과를 서두르기보다 리듬을 정리하는 쪽이 유리합니다.';
  }
}

function buildCaution(
  options: {
    dominantElement: string;
    birthTimeUnknown: boolean;
  },
): string {
  const timeWarning = options.birthTimeUnknown
    ? '출생시간이 없어 일부 세부 해석은 단순화되어 있습니다. '
    : '';

  let elementWarning: string;
  switch (options.dominantElement) {
    case 'wood':
      elementWarning = '성급한 확장은 오히려 집중력을 흩뜨릴 수 있습니다.';
      break;
    case 'fire':
      elementWarning = '감정이 올라온 상태에서 즉답하거나 단정하는 판단은 피하는 편이 좋습니다.';
      break;
    case 'earth':
      elementWarning = '안정만 추구하다 기회를 놓치지 않도록 작은 변화에는 열어두세요.';
      break;
    case 'metal':
      elementWarning = '지나친 단호함은 관계의 여지를 줄일 수 있습니다.';
      break;
    case 'water':
      elementWarning = '생각만 길어지고 실행이 늦어질 수 있으니 마감 기준을 정해 두세요.';
      break;
    default:
      elementWarning = '결과를 단정적으로 받아들이기보다 참고용 흐름으로 활용해 주세요.';
      break;
  }

  return `${timeWarning}${elementWarning}`;
}

function elementLabelKo(value: string): string {
  switch (value) {
    case 'wood':
      return '목(木)';
    case 'fire':
      return '화(火)';
    case 'earth':
      return '토(土)';
    case 'metal':
      return '금(金)';
    case 'water':
      return '수(水)';
    default:
      return value;
  }
}

function seasonLabelKo(value: string): string {
  switch (value) {
    case 'spring':
      return '봄';
    case 'summer':
      return '여름';
    case 'autumn':
      return '가을';
    case 'winter':
      return '겨울';
    default:
      return value;
  }
}
