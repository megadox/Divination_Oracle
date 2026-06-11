import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { getDivinationDetail } from '../_shared/divination_catalog.ts';
import { createServiceClient } from '../_shared/supabase.ts';

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const url = new URL(request.url);
    const code = url.searchParams.get('code');

    if (!code) {
      throw new Error('Missing divination code.');
    }

    const client = createServiceClient();
    const detail = await getDivinationDetail(client, code);
    return jsonResponse(detail);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
