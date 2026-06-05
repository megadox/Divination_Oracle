import { handleOptions, jsonResponse } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';

Deno.serve(async (request) => {
  const options = handleOptions(request);
  if (options) {
    return options;
  }

  try {
    const expectedSecret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
    const token = request.headers.get('Authorization')?.replace('Bearer ', '');
    if (expectedSecret && token !== expectedSecret) {
      return jsonResponse({ error: 'Unauthorized.' }, 401);
    }

    const payload = await request.json();
    const event = payload.event ?? payload;
    const appUserId = event.app_user_id as string | undefined;

    if (!appUserId) {
      throw new Error('Missing RevenueCat app_user_id.');
    }

    const status = mapRevenueCatStatus(event.type as string | undefined);
    const client = createServiceClient();
    const { error } = await client.from('subscriptions').upsert({
      user_id: appUserId,
      provider: 'revenuecat',
      revenuecat_app_user_id: appUserId,
      product_id: event.product_id,
      entitlement_id: event.entitlement_id ?? 'plus',
      status,
      current_period_start: event.purchased_at_ms != null
        ? new Date(Number(event.purchased_at_ms)).toISOString()
        : null,
      current_period_end: event.expiration_at_ms != null
        ? new Date(Number(event.expiration_at_ms)).toISOString()
        : null,
      raw_payload: payload,
    }, { onConflict: 'user_id,provider,entitlement_id' });

    if (error) {
      throw error;
    }

    return jsonResponse({ ok: true });
  } catch (error) {
    return jsonResponse({ error: errorMessage(error) }, 400);
  }
});

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function mapRevenueCatStatus(type?: string): 'active' | 'trial' | 'expired' | 'cancelled' {
  switch (type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'UNCANCELLATION':
      return 'active';
    case 'CANCELLATION':
      return 'cancelled';
    case 'EXPIRATION':
    case 'BILLING_ISSUE':
      return 'expired';
    default:
      return 'active';
  }
}
