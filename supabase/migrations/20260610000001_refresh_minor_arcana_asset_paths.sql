-- Refresh Minor Arcana asset paths for environments where the earlier
-- migration was already applied before local asset path changes were finalized.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
asset_paths as (
  select *
  from (
    values
      ('wands_ace', 'asset://tarot/rws_minor/wands_ace.jpg'),
      ('wands_two', 'asset://tarot/rws_minor/wands_two.jpg'),
      ('wands_three', 'asset://tarot/rws_minor/wands_three.jpg'),
      ('wands_four', 'asset://tarot/rws_minor/wands_four.jpg'),
      ('wands_five', 'asset://tarot/rws_minor/wands_five.jpg'),
      ('wands_six', 'asset://tarot/rws_minor/wands_six.jpg'),
      ('wands_seven', 'asset://tarot/rws_minor/wands_seven.jpg'),
      ('wands_eight', 'asset://tarot/rws_minor/wands_eight.jpg'),
      ('wands_nine', 'asset://tarot/rws_minor/wands_nine.jpg'),
      ('wands_ten', 'asset://tarot/rws_minor/wands_ten.jpg'),
      ('wands_page', 'asset://tarot/rws_minor/wands_page.jpg'),
      ('wands_knight', 'asset://tarot/rws_minor/wands_knight.jpg'),
      ('wands_queen', 'asset://tarot/rws_minor/wands_queen.jpg'),
      ('wands_king', 'asset://tarot/rws_minor/wands_king.jpg'),
      ('cups_ace', 'asset://tarot/rws_minor/cups_ace.jpg'),
      ('cups_two', 'asset://tarot/rws_minor/cups_two.jpg'),
      ('cups_three', 'asset://tarot/rws_minor/cups_three.jpg'),
      ('cups_four', 'asset://tarot/rws_minor/cups_four.jpg'),
      ('cups_five', 'asset://tarot/rws_minor/cups_five.jpg'),
      ('cups_six', 'asset://tarot/rws_minor/cups_six.jpg'),
      ('cups_seven', 'asset://tarot/rws_minor/cups_seven.jpg'),
      ('cups_eight', 'asset://tarot/rws_minor/cups_eight.jpg'),
      ('cups_nine', 'asset://tarot/rws_minor/cups_nine.jpg'),
      ('cups_ten', 'asset://tarot/rws_minor/cups_ten.jpg'),
      ('cups_page', 'asset://tarot/rws_minor/cups_page.jpg'),
      ('cups_knight', 'asset://tarot/rws_minor/cups_knight.jpg'),
      ('cups_queen', 'asset://tarot/rws_minor/cups_queen.jpg'),
      ('cups_king', 'asset://tarot/rws_minor/cups_king.jpg'),
      ('swords_ace', 'asset://tarot/rws_minor/swords_ace.jpg'),
      ('swords_two', 'asset://tarot/rws_minor/swords_two.jpg'),
      ('swords_three', 'asset://tarot/rws_minor/swords_three.jpg'),
      ('swords_four', 'asset://tarot/rws_minor/swords_four.jpg'),
      ('swords_five', 'asset://tarot/rws_minor/swords_five.jpg'),
      ('swords_six', 'asset://tarot/rws_minor/swords_six.jpg'),
      ('swords_seven', 'asset://tarot/rws_minor/swords_seven.jpg'),
      ('swords_eight', 'asset://tarot/rws_minor/swords_eight.jpg'),
      ('swords_nine', 'asset://tarot/rws_minor/swords_nine.jpg'),
      ('swords_ten', 'asset://tarot/rws_minor/swords_ten.jpg'),
      ('swords_page', 'asset://tarot/rws_minor/swords_page.jpg'),
      ('swords_knight', 'asset://tarot/rws_minor/swords_knight.jpg'),
      ('swords_queen', 'asset://tarot/rws_minor/swords_queen.jpg'),
      ('swords_king', 'asset://tarot/rws_minor/swords_king.jpg'),
      ('pentacles_ace', 'asset://tarot/rws_minor/pentacles_ace.jpg'),
      ('pentacles_two', 'asset://tarot/rws_minor/pentacles_two.jpg'),
      ('pentacles_three', 'asset://tarot/rws_minor/pentacles_three.jpg'),
      ('pentacles_four', 'asset://tarot/rws_minor/pentacles_four.jpg'),
      ('pentacles_five', 'asset://tarot/rws_minor/pentacles_five.jpg'),
      ('pentacles_six', 'asset://tarot/rws_minor/pentacles_six.jpg'),
      ('pentacles_seven', 'asset://tarot/rws_minor/pentacles_seven.jpg'),
      ('pentacles_eight', 'asset://tarot/rws_minor/pentacles_eight.jpg'),
      ('pentacles_nine', 'asset://tarot/rws_minor/pentacles_nine.jpg'),
      ('pentacles_ten', 'asset://tarot/rws_minor/pentacles_ten.jpg'),
      ('pentacles_page', 'asset://tarot/rws_minor/pentacles_page.jpg'),
      ('pentacles_knight', 'asset://tarot/rws_minor/pentacles_knight.jpg'),
      ('pentacles_queen', 'asset://tarot/rws_minor/pentacles_queen.jpg'),
      ('pentacles_king', 'asset://tarot/rws_minor/pentacles_king.jpg')
  ) as asset_path(code, path)
)
update public.divination_items item
set
  image_url = asset_paths.path,
  metadata = coalesce(item.metadata, '{}'::jsonb) || jsonb_build_object(
    'image_storage', 'flutter_asset',
    'image_asset_root', 'assets/tarot/rws_minor',
    'image_source', 'local app asset',
    'deck', 'Rider-Waite-Smith'
  ),
  updated_at = now()
from tarot_type
join asset_paths on true
where item.divination_type_id = tarot_type.id
  and item.code = asset_paths.code;
