import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import {
  resolveFreeOmikujiReading,
  resolveFreeRuneReading,
  resolveFreeZodiacReading,
} from '../_shared/extended_divinations.ts';
import { resolveFreeSajuReading } from '../_shared/saju.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';
import {
  composeFreeText,
  getDivinationType,
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

    await incrementDailyUsage(client, userId, 'free_reading_count', 10);
    const divinationType = await getDivinationType(client, readingRequest.divination_type_code);
    let reading;

    if (divinationType.code === 'saju') {
      const sajuResult = resolveFreeSajuReading(readingRequest);
      reading = await saveReading(
        client,
        userId,
        readingRequest,
        divinationType.id,
        null,
        [],
        'free',
        sajuResult.resultText,
        sajuResult.resultJson,
        sajuResult.payloads,
      );
    } else if (divinationType.code === 'zodiac') {
      const zodiacResult = resolveFreeZodiacReading(readingRequest);
      reading = await saveReading(
        client,
        userId,
        readingRequest,
        divinationType.id,
        null,
        [],
        'free',
        zodiacResult.resultText,
        zodiacResult.resultJson,
        zodiacResult.payloads,
      );
    } else if (divinationType.code === 'rune') {
      const runeResult = resolveFreeRuneReading(readingRequest);
      reading = await saveReading(
        client,
        userId,
        readingRequest,
        divinationType.id,
        null,
        [],
        'free',
        runeResult.resultText,
        runeResult.resultJson,
        runeResult.payloads,
      );
    } else if (divinationType.code === 'omikuji') {
      const omikujiResult = resolveFreeOmikujiReading(readingRequest);
      reading = await saveReading(
        client,
        userId,
        readingRequest,
        divinationType.id,
        null,
        [],
        'free',
        omikujiResult.resultText,
        omikujiResult.resultJson,
        omikujiResult.payloads,
      );
    } else {
      const { divinationTypeId, spread, selected } = await selectItems(client, readingRequest);
      const resultText = composeFreeText(selected);
      reading = await saveReading(
        client,
        userId,
        readingRequest,
        divinationTypeId,
        spread,
        selected,
        'free',
        resultText,
      );
    }

    return jsonResponse(reading);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
