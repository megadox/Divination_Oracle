import OpenAI from 'https://esm.sh/openai@4.56.0';

import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';
import {
  ensurePlusUser,
  incrementDailyUsage,
  normalizeRequest,
  saveReading,
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

    const { divinationTypeId, spread, selected } = await selectItems(client, readingRequest);
    const { data: prompt, error: promptError } = await client
      .from('prompt_templates')
      .select('*')
      .eq('code', `plus_${readingRequest.divination_type_code}_reading`)
      .eq('language_code', readingRequest.language_code)
      .eq('is_active', true)
      .order('version', { ascending: false })
      .limit(1)
      .single();

    if (promptError) {
      throw promptError;
    }

    const selectedItems = selected.map((entry) => ({
      name: entry.item.display_name ?? entry.item.name,
      orientation: entry.orientation,
      position_code: entry.position_code,
      position: entry.position_name,
      position_description: entry.position_description,
    }));
    const baseInterpretations = selected.map((entry) => entry.interpretation);
    const userPrompt = String(prompt.user_prompt_template)
      .replace('{{language_code}}', readingRequest.language_code ?? 'ko')
      .replace('{{question}}', readingRequest.question ?? '')
      .replace('{{category}}', readingRequest.category ?? 'general')
      .replace('{{spread_code}}', readingRequest.spread_code ?? 'single')
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
      divinationTypeId,
      spread,
      selected,
      'plus_ai',
      resultText,
      resultJson,
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
