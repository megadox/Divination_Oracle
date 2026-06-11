import OpenAI from 'https://esm.sh/openai@4.56.0';

import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import {
  buildAiBaseInterpretationsFromResolution,
  resolveFreeOmikujiReading,
  resolveFreeRuneReading,
  resolveFreeZodiacReading,
} from '../_shared/extended_divinations.ts';
import { buildSajuAiBaseInterpretations } from '../_shared/saju.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';
import {
  ensurePlusUser,
  getDivinationType,
  incrementDailyUsage,
  normalizeRequest,
  saveReading,
  type SelectedItem,
  type SpreadDefinition,
  selectItems,
} from '../_shared/readings.ts';

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const userId = await getUserId(request);
    const client = createServiceClient();
    const body = await request.json();
    const readingRequest = normalizeRequest(body);

    await ensurePlusUser(client, userId);
    await incrementDailyUsage(client, userId, 'ai_reading_count', 30);

    const divinationType = await getDivinationType(client, readingRequest.divination_type_code);
    const promptCodes = [
      `plus_${readingRequest.divination_type_code}_reading_${readingRequest.language_code}_v1`,
      `plus_${readingRequest.divination_type_code}_reading`,
    ];
    const { data: prompt, error: promptError } = await client
      .from('prompt_templates')
      .select('*')
      .in('code', promptCodes)
      .eq('language_code', readingRequest.language_code)
      .eq('is_active', true)
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (promptError) {
      throw promptError;
    }
    if (!prompt) {
      throw new Error(`No active prompt template found for ${readingRequest.divination_type_code}.`);
    }

    let selectedItems: Array<Record<string, unknown>> = [];
    let baseInterpretations: unknown;
    let spreadCode = readingRequest.spread_code ?? 'single';
    let spread: SpreadDefinition | null = null;
    let selected: SelectedItem[] = [];
    let payloads: Array<{
      payload_type: string;
      payload_json: Record<string, unknown>;
    }> = [];

    if (divinationType.code === 'saju') {
      const sajuData = buildSajuAiBaseInterpretations(readingRequest);
      selectedItems = [
        {
          type: 'birth_data',
          birth_date: readingRequest.inputs?.birth_date ?? null,
          birth_time: readingRequest.inputs?.birth_time ?? null,
          calendar_type: readingRequest.inputs?.calendar_type ?? null,
          gender: readingRequest.inputs?.gender ?? null,
        },
      ];
      baseInterpretations = sajuData.baseInterpretations;
      payloads = sajuData.freeReading.payloads;
      spreadCode = readingRequest.spread_code ?? 'saju_basic';
    } else if (divinationType.code === 'zodiac') {
      const zodiacData = buildAiBaseInterpretationsFromResolution(
        readingRequest,
        resolveFreeZodiacReading(readingRequest),
      );
      selectedItems = [
        {
          type: 'birth_date',
          birth_date: readingRequest.inputs?.birth_date ?? null,
        },
      ];
      baseInterpretations = zodiacData.baseInterpretations;
      payloads = zodiacData.freeReading.payloads;
      spreadCode = readingRequest.spread_code ?? 'zodiac_basic';
    } else if (divinationType.code === 'rune') {
      const runeData = buildAiBaseInterpretationsFromResolution(
        readingRequest,
        resolveFreeRuneReading(readingRequest),
      );
      const runePayload = runeData.freeReading.payloads[0]?.payload_json;
      selectedItems = runePayload && Array.isArray(runePayload.selected_runes)
        ? runePayload.selected_runes as Array<Record<string, unknown>>
        : [];
      baseInterpretations = runeData.baseInterpretations;
      payloads = runeData.freeReading.payloads;
      spreadCode = readingRequest.spread_code ?? 'rune_basic';
    } else if (divinationType.code === 'omikuji') {
      const omikujiData = buildAiBaseInterpretationsFromResolution(
        readingRequest,
        resolveFreeOmikujiReading(readingRequest),
      );
      selectedItems = [
        omikujiData.freeReading.payloads[0]?.payload_json ?? {},
      ];
      baseInterpretations = omikujiData.baseInterpretations;
      payloads = omikujiData.freeReading.payloads;
      spreadCode = readingRequest.spread_code ?? 'omikuji_basic';
    } else {
      const selection = await selectItems(client, readingRequest);
      spread = selection.spread;
      selected = selection.selected;
      selectedItems = selection.selected.map((entry) => ({
        name: entry.item.display_name ?? entry.item.name,
        orientation: entry.orientation,
        position_code: entry.position_code,
        position: entry.position_name,
        position_description: entry.position_description,
      }));
      baseInterpretations = selection.selected.map((entry) => entry.interpretation);
      spreadCode = selection.spread.code;
    }

    const userPrompt = String(prompt.user_prompt_template)
      .replace('{{language_code}}', readingRequest.language_code ?? 'ko')
      .replace('{{question}}', readingRequest.question ?? '')
      .replace('{{category}}', readingRequest.category ?? 'general')
      .replace('{{spread_code}}', spreadCode)
      .replace('{{selected_items}}', JSON.stringify(selectedItems))
      .replace('{{base_interpretations}}', JSON.stringify(baseInterpretations));

    const openai = new OpenAI({ apiKey: Deno.env.get('OPENAI_API_KEY') });
    const model = Deno.env.get('OPENAI_MODEL') ?? 'gpt-4o-mini';
    const completion = await openai.chat.completions.create({
      model,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: prompt.system_prompt },
        { role: 'user', content: userPrompt },
      ],
    });

    const content = completion.choices[0]?.message?.content ?? '{}';
    const resultJson = JSON.parse(content) as Record<string, unknown>;
    const resultText = [
      resultJson.summary,
      resultJson.detailed_reading,
      resultJson.advice ? `조언: ${resultJson.advice}` : null,
      resultJson.caution ? `주의: ${resultJson.caution}` : null,
    ].filter(Boolean).join('\n\n');

    const reading = await saveReading(
      client,
      userId,
      readingRequest,
      divinationType.id,
      spread,
      selected,
      'plus_ai',
      resultText,
      resultJson,
      payloads,
    );

    const { error: aiError } = await client.from('ai_results').insert({
      reading_id: reading.id,
      prompt_template_id: prompt.id,
      model_name: model,
      prompt_tokens: completion.usage?.prompt_tokens ?? 0,
      completion_tokens: completion.usage?.completion_tokens ?? 0,
      total_tokens: completion.usage?.total_tokens ?? 0,
      prompt_text: userPrompt,
      result_json: resultJson,
      status: 'succeeded',
    });

    if (aiError) {
      throw aiError;
    }

    return jsonResponse(reading);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
