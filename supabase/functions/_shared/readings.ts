import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.3';

export type ReadingRequest = {
  divination_type_code: string;
  spread_code?: string;
  category?: string;
  question?: string;
  language_code?: string;
};

export type SelectedItem = {
  item: Record<string, unknown>;
  orientation: 'upright' | 'reversed' | 'none';
  position_name: string;
  position_order: number;
  interpretation: Record<string, unknown>;
};

export function normalizeRequest(body: Partial<ReadingRequest>): ReadingRequest {
  return {
    divination_type_code: body.divination_type_code ?? 'tarot',
    spread_code: body.spread_code ?? 'single',
    category: body.category ?? 'general',
    question: body.question ?? '',
    language_code: body.language_code ?? 'ko',
  };
}

export function spreadCount(spreadCode: string): number {
  if (spreadCode === 'three_card') {
    return 3;
  }
  return 1;
}

export async function incrementDailyUsage(
  client: SupabaseClient,
  userId: string,
  field: 'free_reading_count' | 'ai_reading_count',
  limit: number,
) {
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
  if (currentCount >= limit) {
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
): Promise<{ divinationTypeId: string; selected: SelectedItem[] }> {
  const { data: divinationType, error: typeError } = await client
    .from('divination_types')
    .select('id,code')
    .eq('code', request.divination_type_code)
    .eq('is_active', true)
    .single();

  if (typeError) {
    throw typeError;
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

  const count = spreadCount(request.spread_code ?? 'single');
  const shuffled = [...items].sort(() => Math.random() - 0.5).slice(0, count);
  const selected: SelectedItem[] = [];

  for (let index = 0; index < shuffled.length; index += 1) {
    const item = shuffled[index];
    const orientation = request.divination_type_code === 'tarot'
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
      position_name: count === 3
        ? ['past', 'present', 'future'][index]
        : 'single',
      position_order: index,
      interpretation: interpretation ?? {
        summary: '등록된 기본 해석을 준비 중입니다.',
        detail: '콘텐츠 관리자에서 해석 데이터를 추가해야 합니다.',
        advice: '결과는 오락과 자기 성찰을 위한 참고로 사용하세요.',
        warning: null,
      },
    });
  }

  return { divinationTypeId: divinationType.id, selected };
}

export function composeFreeText(selected: SelectedItem[]): string {
  return selected
    .map((entry) => {
      const itemName = entry.item.display_name ?? entry.item.name;
      const interpretation = entry.interpretation;
      return [
        `${itemName} (${entry.orientation})`,
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
