import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.3';

export function createServiceClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error('Missing Supabase service configuration.');
  }

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

export async function getUserId(request: Request): Promise<string> {
  const client = createServiceClient();
  const token = request.headers.get('Authorization')?.replace('Bearer ', '');

  if (!token) {
    throw new Error('Missing authorization token.');
  }

  const { data, error } = await client.auth.getUser(token);
  if (error || !data.user) {
    throw new Error('Invalid authorization token.');
  }

  return data.user.id;
}
