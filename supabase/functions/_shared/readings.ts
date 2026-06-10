import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.3';

export type ReadingRequest = {
  divination_type_code: string;
  spread_code?: string;
  category?: string;
  question?: string;
  language_code?: string;
};

export type SpreadDefinition = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  card_count: number;
  allow_reversed: boolean;
};

export type SpreadPosition = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  position_order: number;
};

export type SelectedItem = {
  item: Record<string, unknown>;
  orientation: 'upright' | 'reversed' | 'none';
  spread_position_id: string | null;
  position_code: string;
  position_name: string;
  position_description: string | null;
  position_order: number;
  interpretation: Record<string, unknown>;
};

export type SelectionResult = {
  divinationTypeId: string;
  spread: SpreadDefinition;
  positions: SpreadPosition[];
  selected: SelectedItem[];
};

export function normalizeRequest(body: Partial<ReadingRequest>): ReadingRequest {
  return {
    divination_type_code: body.divination_type_code ?? 'tarot',
    spread_code: normalizeSpreadCode(body.spread_code),
    category: body.category ?? 'general',
    question: body.question ?? '',
    language_code: body.language_code ?? 'ko',
  };
}

function normalizeSpreadCode(spreadCode?: string): string {
  if (spreadCode === 'single') {
    return 'single_question';
  }
  if (spreadCode === 'three_card') {
    return 'three_card_timeline';
  }
  return spreadCode ?? 'single_question';
}

export async function incrementDailyUsage(
  client: SupabaseClient,
  userId: string,
  field: 'free_reading_count' | 'ai_reading_count',
  limit: number,
) {
  const enforceLimit = shouldEnforceUsageLimit(field);
  const today = new Date().toISOString().slice(0, 10);
  const { data: current, error: fetchError } = await client
    .from('daily_usage')
    .select('*')
    .eq('user_id', userId)
    .eq('usage_date', today)
    .maybeSingle();

  if (fetchError) {
    throw fetchError;
  }

  const currentCount = current?.[field] ?? 0;
  if (enforceLimit && currentCount >= limit) {
    throw new Error('Daily usage limit reached.');
  }

  const payload = {
    user_id: userId,
    usage_date: today,
    free_reading_count: current?.free_reading_count ?? 0,
    ai_reading_count: current?.ai_reading_count ?? 0,
    integrated_ai_count: current?.integrated_ai_count ?? 0,
    [field]: currentCount + 1,
  };

  const { error } = await client
    .from('daily_usage')
    .upsert(payload, { onConflict: 'user_id,usage_date' });

  if (error) {
    throw error;
  }
}

function shouldEnforceUsageLimit(
  field: 'free_reading_count' | 'ai_reading_count',
): boolean {
  if (field !== 'free_reading_count') {
    return true;
  }

  return Deno.env.get('DISABLE_FREE_READING_LIMIT') !== 'true';
}

export async function ensurePlusUser(client: SupabaseClient, userId: string) {
  const { data, error } = await client
    .from('subscriptions')
    .select('id,status,current_period_end')
    .eq('user_id', userId)
    .in('status', ['active', 'trial'])
    .gt('current_period_end', new Date().toISOString())
    .maybeSingle();

  if (error) {
    throw error;
  }
  if (!data) {
    throw new Error('Plus subscription is required.');
  }
}

export async function selectItems(
  client: SupabaseClient,
  request: ReadingRequest,
): Promise<SelectionResult> {
  const { data: divinationType, error: typeError } = await client
    .from('divination_types')
    .select('id,code')
    .eq('code', request.divination_type_code)
    .eq('is_active', true)
    .single();

  if (typeError) {
    throw typeError;
  }

  const { data: spread, error: spreadError } = await client
    .from('spreads')
    .select('id,code,name,description,card_count,allow_reversed')
    .eq('divination_type_id', divinationType.id)
    .eq('code', request.spread_code)
    .eq('is_active', true)
    .single();

  if (spreadError) {
    throw spreadError;
  }

  const { data: positions, error: positionsError } = await client
    .from('spread_positions')
    .select('id,code,name,description,position_order')
    .eq('spread_id', spread.id)
    .eq('is_active', true)
    .order('position_order');

  if (positionsError) {
    throw positionsError;
  }
  if (!positions?.length) {
    throw new Error('No active spread positions found.');
  }

  const { data: items, error: itemsError } = await client
    .from('divination_items')
    .select('*')
    .eq('divination_type_id', divinationType.id)
    .eq('is_active', true);

  if (itemsError) {
    throw itemsError;
  }
  if (!items?.length) {
    throw new Error('No active divination items found.');
  }
  if (items.length < positions.length) {
    throw new Error(
      `Not enough active divination items for spread ${spread.code}. ` +
      `Need ${positions.length}, found ${items.length}.`,
    );
  }

  const shuffled = [...items].sort(() => Math.random() - 0.5).slice(0, positions.length);
  const selected: SelectedItem[] = [];

  for (let index = 0; index < shuffled.length; index += 1) {
    const item = shuffled[index];
    const position = positions[index];
    const orientation = request.divination_type_code === 'tarot' && spread.allow_reversed
      ? (Math.random() > 0.5 ? 'upright' : 'reversed')
      : 'none';

    const { data: interpretation, error: interpretationError } = await client
      .from('interpretations')
      .select('*')
      .eq('item_id', item.id)
      .eq('orientation', orientation)
      .eq('category', request.category)
      .eq('language_code', request.language_code)
      .eq('is_active', true)
      .maybeSingle();

    if (interpretationError) {
      throw interpretationError;
    }

    selected.push({
      item,
      orientation,
      spread_position_id: position.id,
      position_code: position.code,
      position_name: position.name,
      position_description: position.description,
      position_order: index,
      interpretation: interpretation ?? {
        summary: '등록된 기본 해석을 준비 중입니다.',
        detail: '콘텐츠 관리자에서 해석 데이터를 추가해야 합니다.',
        advice: '결과는 오락과 자기 성찰을 위한 참고로 사용하세요.',
        warning: null,
      },
    });
  }

  return {
    divinationTypeId: divinationType.id,
    spread: spread as SpreadDefinition,
    positions: positions as SpreadPosition[],
    selected,
  };
}

export function composeFreeText(selected: SelectedItem[]): string {
  return selected
    .map((entry) => {
      const itemName = entry.item.display_name ?? entry.item.name;
      const interpretation = entry.interpretation;
      return [
        `[${entry.position_name}] ${itemName} (${entry.orientation})`,
        entry.position_description,
        interpretation.summary,
        interpretation.detail,
        interpretation.advice ? `조언: ${interpretation.advice}` : null,
        interpretation.warning ? `주의: ${interpretation.warning}` : null,
      ].filter(Boolean).join('\n');
    })
    .join('\n\n');
}

export async function saveReading(
  client: SupabaseClient,
  userId: string,
  request: ReadingRequest,
  divinationTypeId: string,
  spread: SpreadDefinition,
  selected: SelectedItem[],
  resultType: 'free' | 'plus_ai',
  resultText: string,
  resultJson: Record<string, unknown> = {},
) {
  const { data: reading, error: readingError } = await client
    .from('readings')
    .insert({
      user_id: userId,
      divination_type_id: divinationTypeId,
      spread_id: spread.id,
      spread_code: request.spread_code,
      question: request.question,
      category: request.category,
      result_type: resultType,
      result_text: resultText,
      result_json: resultJson,
      is_ai_generated: resultType === 'plus_ai',
      language_code: request.language_code,
    })
    .select()
    .single();

  if (readingError) {
    throw readingError;
  }

  const readingItems = selected.map((entry) => ({
    reading_id: reading.id,
    item_id: entry.item.id,
    spread_position_id: entry.spread_position_id,
    orientation: entry.orientation,
    position_name: entry.position_name,
    position_order: entry.position_order,
  }));

  const { error: itemsError } = await client.from('reading_items').insert(readingItems);
  if (itemsError) {
    throw itemsError;
  }

  return reading;
}
