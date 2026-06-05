import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';
import {
  composeFreeText,
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

    await incrementDailyUsage(client, userId, 'free_reading_count', 5);
    const { divinationTypeId, spread, selected } = await selectItems(client, readingRequest);
    const resultText = composeFreeText(selected);
    const reading = await saveReading(
      client,
      userId,
      readingRequest,
      divinationTypeId,
      spread,
      selected,
      'free',
      resultText,
    );

    return jsonResponse(reading);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
