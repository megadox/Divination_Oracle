import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';

type HistoryRequest = {
  divination_code?: string;
  result_type?: string;
  limit?: number;
};

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const body = await parseBody(request);
    const userId = await getUserId(request);
    const client = createServiceClient();

    let query = client
      .from('readings')
      .select(`
        id,
        question,
        category,
        spread_code,
        result_type,
        result_text,
        result_json,
        created_at,
        divination_types(code, display_name, name)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(normalizeLimit(body.limit));

    if (body.result_type) {
      query = query.eq('result_type', body.result_type);
    }

    if (body.divination_code) {
      const { data: divinationType, error: divinationTypeError } = await client
        .from('divination_types')
        .select('id')
        .eq('code', body.divination_code)
        .eq('is_active', true)
        .maybeSingle();

      if (divinationTypeError) {
        throw divinationTypeError;
      }

      if (!divinationType) {
        return jsonResponse([]);
      }

      query = query.eq('divination_type_id', divinationType.id);
    }

    const { data, error } = await query;
    if (error) {
      throw error;
    }

    return jsonResponse(data ?? []);
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

async function parseBody(request: Request): Promise<HistoryRequest> {
  if (request.method === 'GET') {
    const url = new URL(request.url);
    return {
      divination_code: url.searchParams.get('divination_code') ?? undefined,
      result_type: url.searchParams.get('result_type') ?? undefined,
      limit: parseOptionalInt(url.searchParams.get('limit')),
    };
  }

  try {
    const json = await request.json();
    return typeof json === 'object' && json !== null
      ? json as HistoryRequest
      : {};
  } catch (_) {
    return {};
  }
}

function normalizeLimit(value?: number): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return 30;
  }

  return Math.min(Math.max(Math.trunc(value), 1), 100);
}

function parseOptionalInt(value: string | null): number | undefined {
  if (value == null || value.length == 0) {
    return undefined;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isNaN(parsed) ? undefined : parsed;
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
