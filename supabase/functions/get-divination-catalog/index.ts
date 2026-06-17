import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { getDivinationCatalog } from '../_shared/divination_catalog.ts';
import { createServiceClient } from '../_shared/supabase.ts';

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const client = createServiceClient();
    const catalog = await getDivinationCatalog(client);
    return jsonResponse(catalog);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
