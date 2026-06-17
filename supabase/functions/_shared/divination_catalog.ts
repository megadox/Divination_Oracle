import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.3';

export async function getDivinationCatalog(client: SupabaseClient) {
  const { data, error } = await client
    .from('divination_types')
    .select(`
      id,
      code,
      name,
      display_name,
      description,
      short_description,
      origin_region,
      icon_key,
      banner_image_url,
      input_mode,
      resolver_type,
      interpretation_mode,
      is_plus_only,
      is_active,
      sort_order
    `)
    .eq('is_active', true)
    .order('sort_order');

  if (error) {
    throw error;
  }

  return data ?? [];
}

export async function getDivinationDetail(
  client: SupabaseClient,
  code: string,
) {
  const { data: divinationType, error: typeError } = await client
    .from('divination_types')
    .select(`
      id,
      code,
      name,
      display_name,
      description,
      short_description,
      origin_region,
      icon_key,
      banner_image_url,
      input_mode,
      resolver_type,
      interpretation_mode,
      is_plus_only,
      is_active,
      sort_order
    `)
    .eq('code', code)
    .eq('is_active', true)
    .single();

  if (typeError) {
    throw typeError;
  }

  const { data: inputDefinitions, error: inputError } = await client
    .from('divination_input_definitions')
    .select(`
      field_key,
      field_label,
      field_type,
      is_required,
      options_json,
      placeholder,
      help_text,
      validation_json,
      sort_order
    `)
    .eq('divination_type_id', divinationType.id)
    .eq('is_active', true)
    .order('sort_order');

  if (inputError) {
    throw inputError;
  }

  const detail: Record<string, unknown> = {
    ...divinationType,
    input_definitions: inputDefinitions ?? [],
  };

  if (divinationType.code === 'tarot') {
    const { data: spreads, error: spreadError } = await client
      .from('spreads')
      .select(`
        code,
        name,
        description,
        card_count,
        is_plus_only,
        allow_reversed,
        sort_order
      `)
      .eq('divination_type_id', divinationType.id)
      .eq('is_active', true)
      .order('sort_order');

    if (spreadError) {
      throw spreadError;
    }

    detail.spreads = spreads ?? [];
  }

  return detail;
}
