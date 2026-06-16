import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { getDivinationDetail } from '../_shared/divination_catalog.ts';
import { createServiceClient } from '../_shared/supabase.ts';

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const code = await resolveDivinationCode(request);

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

async function resolveDivinationCode(request: Request): Promise<string | null> {
  const url = new URL(request.url);
  const queryCode = normalizeCode(url.searchParams.get('code'));
  if (queryCode != null) {
    return queryCode;
  }

  if (request.method === 'GET' || request.method === 'HEAD') {
    return null;
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch (_) {
    return null;
  }

  if (body == null || typeof body !== 'object' || Array.isArray(body)) {
    return null;
  }

  return normalizeCode(
    readBodyCode(body as Record<string, unknown>, [
      'code',
      'divination_code',
      'divinationTypeCode',
      'divination_type_code',
    ]),
  );
}

function readBodyCode(
  body: Record<string, unknown>,
  keys: string[],
): string | null {
  for (const key of keys) {
    const value = body[key];
    if (typeof value === 'string' && value.trim().length > 0) {
      return value;
    }
  }
  return null;
}

function normalizeCode(value: string | null): string | null {
  if (value == null) {
    return null;
  }

  const normalized = value.trim();
  return normalized.length == 0 ? null : normalized;
}
