import type { ReadingRequest } from './readings.ts';

type ResolutionPayload = {
  payload_type: string;
  payload_json: Record<string, unknown>;
};

export type RuleBasedResolution = {
  resultText: string;
  resultJson: Record<string, unknown>;
  payloads: ResolutionPayload[];
};

type RuneDefinition = {
  code: string;
  name: string;
  keyword: string;
  meaning: string;
};

const zodiacProfiles = [
  {
    sign: 'aries',
    displayName: '양자리',
    start: '03-21',
    end: '04-19',
    element: 'fire',
    modality: 'cardinal',
    trait: '시작을 이끄는 추진력',
  },
  {
    sign: 'taurus',
    displayName: '황소자리',
    start: '04-20',
    end: '05-20',
    element: 'earth',
    modality: 'fixed',
    trait: '꾸준히 쌓아가는 안정감',
  },
  {
    sign: 'gemini',
    displayName: '쌍둥이자리',
    start: '05-21',
    end: '06-21',
    element: 'air',
    modality: 'mutable',
    trait: '빠르게 연결하고 이해하는 감각',
  },
  {
    sign: 'cancer',
    displayName: '게자리',
    start: '06-22',
    end: '07-22',
    element: 'water',
    modality: 'cardinal',
    trait: '정서적 흐름을 세심하게 읽는 힘',
  },
  {
    sign: 'leo',
    displayName: '사자자리',
    start: '07-23',
    end: '08-22',
    element: 'fire',
    modality: 'fixed',
    trait: '존재감을 드러내고 표현하는 자신감',
  },
  {
    sign: 'virgo',
    displayName: '처녀자리',
    start: '08-23',
    end: '09-22',
    element: 'earth',
    modality: 'mutable',
    trait: '정리와 개선을 통해 흐름을 다듬는 힘',
  },
  {
    sign: 'libra',
    displayName: '천칭자리',
    start: '09-23',
    end: '10-22',
    element: 'air',
    modality: 'cardinal',
    trait: '균형과 관계 조율에 민감한 감각',
  },
  {
    sign: 'scorpio',
    displayName: '전갈자리',
    start: '10-23',
    end: '11-22',
    element: 'water',
    modality: 'fixed',
    trait: '깊이를 파고드는 집중력과 통찰',
  },
  {
    sign: 'sagittarius',
    displayName: '사수자리',
    start: '11-23',
    end: '12-24',
    element: 'fire',
    modality: 'mutable',
    trait: '시야를 넓히고 새로운 가능성을 찾는 움직임',
  },
  {
    sign: 'capricorn',
    displayName: '염소자리',
    start: '12-25',
    end: '01-19',
    element: 'earth',
    modality: 'cardinal',
    trait: '목표를 장기적으로 쌓아가는 책임감',
  },
  {
    sign: 'aquarius',
    displayName: '물병자리',
    start: '01-20',
    end: '02-18',
    element: 'air',
    modality: 'fixed',
    trait: '새로운 관점과 독립적인 사고',
  },
  {
    sign: 'pisces',
    displayName: '물고기자리',
    start: '02-19',
    end: '03-20',
    element: 'water',
    modality: 'mutable',
    trait: '감수성과 직관으로 흐름을 읽는 힘',
  },
] as const;

const runeDefinitions: RuneDefinition[] = [
  { code: 'fehu', name: 'Fehu', keyword: '풍요', meaning: '새로운 자원과 기회가 들어오는 흐름' },
  { code: 'uruz', name: 'Uruz', keyword: '힘', meaning: '체력과 의지를 회복하며 앞으로 나아가는 흐름' },
  { code: 'ansuz', name: 'Ansuz', keyword: '메시지', meaning: '의미 있는 조언이나 소통의 기회가 오는 흐름' },
  { code: 'raidho', name: 'Raidho', keyword: '이동', meaning: '방향을 정하고 실제로 움직일 시점이 다가오는 흐름' },
  { code: 'kenaz', name: 'Kenaz', keyword: '통찰', meaning: '어두웠던 부분이 밝혀지고 이해가 선명해지는 흐름' },
  { code: 'gebo', name: 'Gebo', keyword: '교환', meaning: '관계나 협력에서 균형 잡힌 주고받음이 중요한 흐름' },
  { code: 'algiz', name: 'Algiz', keyword: '보호', meaning: '자신의 경계를 세우고 안전을 챙겨야 하는 흐름' },
  { code: 'sowilo', name: 'Sowilo', keyword: '성취', meaning: '자신감을 가지고 밝은 방향으로 밀어붙일 수 있는 흐름' },
];

const omikujiFortunes = [
  {
    code: 'daikichi',
    label: '대길',
    tone: '아주 좋은 기운이 강하게 들어오는 시기',
    advice: '좋은 흐름이 들어올 때는 망설이기보다 준비된 일부터 실행해 보세요.',
  },
  {
    code: 'kichi',
    label: '길',
    tone: '안정적인 상승 흐름이 만들어지는 시기',
    advice: '작은 기회를 놓치지 않고 연결하면 좋은 결과로 이어지기 쉽습니다.',
  },
  {
    code: 'shokichi',
    label: '소길',
    tone: '무난하지만 세심함이 결과를 좌우하는 시기',
    advice: '조금 더 꼼꼼하게 챙기면 충분히 좋은 흐름을 만들 수 있습니다.',
  },
  {
    code: 'suekichi',
    label: '말길',
    tone: '지금보다 조금 늦게 빛이 드러나는 시기',
    advice: '성과가 느리게 보여도 방향이 맞다면 꾸준함이 중요합니다.',
  },
  {
    code: 'kyo',
    label: '흉',
    tone: '서두름보다는 점검이 먼저 필요한 시기',
    advice: '지금은 결론을 밀어붙이기보다 실수와 누락을 줄이는 편이 유리합니다.',
  },
] as const;

export function resolveFreeZodiacReading(request: ReadingRequest): RuleBasedResolution {
  const inputs = request.inputs ?? {};
  const birthDateRaw = asNonEmptyString(inputs.birth_date);
  if (!birthDateRaw) {
    throw new Error('Zodiac reading requires birth_date input.');
  }

  const birthDate = parseDateOnly(birthDateRaw);
  if (!birthDate) {
    throw new Error('Invalid birth_date format. Use YYYY-MM-DD.');
  }

  const monthDay = birthDateRaw.slice(5);
  const profile = zodiacProfiles.find((item) => inDateRange(monthDay, item.start, item.end));
  if (!profile) {
    throw new Error('Could not determine zodiac sign.');
  }

  const category = request.category ?? 'general';
  const summary = `${profile.displayName}의 흐름은 ${traitByCategory(profile.trait, category)}에 강점이 있습니다.`;
  const detailedReading =
    `${profile.displayName}은 ${elementLabel(profile.element)} 기운과 ${modalityLabel(profile.modality)} 성향을 함께 지닙니다. `
    + `질문 "${request.question ?? ''}"을 기준으로 보면, 지금은 ${profile.trait}을 너무 급하게 쓰기보다 상황에 맞게 조절하는 것이 중요합니다.`;
  const advice = zodiacAdvice(profile.element, category);
  const caution = `${profile.displayName} 특유의 리듬이 강할수록 한 방향으로 치우치기 쉬우니, 다른 사람의 반응과 현실 조건도 함께 확인해 주세요.`;

  const payload = {
    sign: profile.sign,
    display_name: profile.displayName,
    element: profile.element,
    modality: profile.modality,
    trait: profile.trait,
    birth_date: birthDateRaw,
  };

  return buildResolution('zodiac_profile', payload, summary, detailedReading, advice, caution);
}

export function resolveFreeRuneReading(request: ReadingRequest): RuleBasedResolution {
  const drawCount = Math.max(1, Math.min(3, Number(request.inputs?.draw_count ?? 1)));
  const shuffled = [...runeDefinitions].sort(() => Math.random() - 0.5).slice(0, drawCount);
  const roleLabels = drawCount === 1
    ? ['핵심 메시지']
    : ['과거 흐름', '현재 흐름', '조언'];
  const selectedRunes = shuffled.map((rune, index) => ({
    ...rune,
    role: roleLabels[index] ?? `메시지 ${index + 1}`,
  }));

  const summary = drawCount === 1
    ? `${selectedRunes[0].name} 룬이 나왔습니다. 지금은 ${selectedRunes[0].keyword}의 기운을 중심으로 흐름을 읽는 것이 좋습니다.`
    : `${selectedRunes.map((item) => item.name).join(', ')} 룬이 나왔습니다. 흐름의 이동과 조언을 함께 살펴볼 시기입니다.`;
  const detailedReading = selectedRunes
    .map((item) => `${item.role}: ${item.name} - ${item.meaning}`)
    .join(' ');
  const advice = selectedRunes.length > 1
    ? '과거와 현재의 흐름을 한 번에 해석하기보다, 지금 당장 실천할 수 있는 조언 카드부터 현실에 적용해 보세요.'
    : `${selectedRunes[0].keyword} 키워드를 오늘 하루의 행동 기준으로 삼아 보세요.`;
  const caution = '룬은 현재 에너지의 방향성을 읽는 참고 도구이므로, 결과를 단정적으로 받아들이기보다 선택의 힌트로 활용하는 것이 좋습니다.';

  const payload = {
    draw_count: drawCount,
    selected_runes: selectedRunes,
  };

  return buildResolution('rune_cast', payload, summary, detailedReading, advice, caution);
}

export function resolveFreeOmikujiReading(request: ReadingRequest): RuleBasedResolution {
  const fortune = omikujiFortunes[Math.floor(Math.random() * omikujiFortunes.length)];
  const focus = omikujiFocusLabel(request.category ?? 'general');
  const summary = `${fortune.label}입니다. ${fortune.tone}입니다.`;
  const detailedReading =
    `이번 오미쿠지는 ${focus}을 중심으로 읽을 때 의미가 더 선명합니다. `
    + `질문 "${request.question ?? ''}"이 있다면, 성급하게 결과를 단정하기보다 흐름의 분위기를 먼저 읽는 것이 좋습니다.`;
  const advice = fortune.advice;
  const caution = fortune.code === 'kyo'
    ? '흉이 나와도 나쁜 결과를 확정하는 뜻은 아닙니다. 지금은 속도를 늦추고 정비하라는 신호로 받아들이면 좋습니다.'
    : '좋은 결과가 나와도 준비 없는 낙관으로 이어지지 않도록 작은 점검은 계속해 주세요.';

  const payload = {
    fortune_code: fortune.code,
    fortune_label: fortune.label,
    focus,
    category: request.category ?? 'general',
  };

  return buildResolution('omikuji_draw', payload, summary, detailedReading, advice, caution);
}

export function buildAiBaseInterpretationsFromResolution(
  request: ReadingRequest,
  freeReading: RuleBasedResolution,
) {
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

function buildResolution(
  payloadType: string,
  payload: Record<string, unknown>,
  summary: string,
  detailedReading: string,
  advice: string,
  caution: string,
): RuleBasedResolution {
  const resultJson = {
    summary,
    detailed_reading: detailedReading,
    advice,
    caution,
    source_payload: payload,
  };

  return {
    resultText: [
      summary,
      detailedReading,
      `조언: ${advice}`,
      `주의: ${caution}`,
    ].join('\n\n'),
    resultJson,
    payloads: [
      {
        payload_type: payloadType,
        payload_json: payload,
      },
    ],
  };
}

function asNonEmptyString(value: unknown): string | null {
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

function inDateRange(monthDay: string, start: string, end: string): boolean {
  if (start <= end) {
    return monthDay >= start && monthDay <= end;
  }
  return monthDay >= start || monthDay <= end;
}

function traitByCategory(trait: string, category: string): string {
  switch (category) {
    case 'career':
      return `${trait}을 일과 방향 설정에 활용할 때`;
    case 'love':
      return `${trait}이 관계와 감정 표현에 드러날 때`;
    case 'money':
      return `${trait}이 자원 관리 방식에 반영될 때`;
    default:
      return `${trait}이 현재 흐름에 자연스럽게 드러날 때`;
  }
}

function zodiacAdvice(element: string, category: string): string {
  if (category === 'love') {
    return '감정의 속도를 상대와 맞추며 표현하면 관계의 균형을 더 잘 잡을 수 있습니다.';
  }
  switch (element) {
    case 'fire':
      return '좋은 에너지가 올라올 때일수록 실행 순서를 정리해 두면 성급함을 줄일 수 있습니다.';
    case 'earth':
      return '안정적으로 쌓아가는 방식이 지금은 가장 큰 힘이 됩니다.';
    case 'air':
      return '생각과 말을 정리해 전달하면 흐름이 훨씬 부드러워집니다.';
    case 'water':
      return '직감만 따르기보다 감정의 파도와 현실 조건을 함께 살피는 것이 좋습니다.';
    default:
      return '현재 기운을 한 번에 다 쓰기보다 리듬을 조절하며 활용해 보세요.';
  }
}

function omikujiFocusLabel(category: string): string {
  switch (category) {
    case 'love':
      return '연애 흐름';
    case 'career':
      return '일과 진로';
    case 'money':
      return '금전 흐름';
    case 'relationship':
      return '인간관계';
    default:
      return '전체 운세';
  }
}

function elementLabel(value: string): string {
  switch (value) {
    case 'fire':
      return '불';
    case 'earth':
      return '흙';
    case 'air':
      return '바람';
    case 'water':
      return '물';
    default:
      return value;
  }
}

function modalityLabel(value: string): string {
  switch (value) {
    case 'cardinal':
      return '시작형';
    case 'fixed':
      return '고정형';
    case 'mutable':
      return '변화형';
    default:
      return value;
  }
}
