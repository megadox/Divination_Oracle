-- Store Flutter local asset references instead of external image URLs.
-- The app resolves asset://tarot/rws_major/<card_code>.jpg to
-- app/flutter_app/assets/tarot/rws_major/<card_code>.jpg.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
asset_paths as (
  select *
  from (
    values
      ('fool', 'asset://tarot/rws_major/fool.jpg'),
      ('magician', 'asset://tarot/rws_major/magician.jpg'),
      ('high_priestess', 'asset://tarot/rws_major/high_priestess.jpg'),
      ('empress', 'asset://tarot/rws_major/empress.jpg'),
      ('emperor', 'asset://tarot/rws_major/emperor.jpg'),
      ('hierophant', 'asset://tarot/rws_major/hierophant.jpg'),
      ('lovers', 'asset://tarot/rws_major/lovers.jpg'),
      ('chariot', 'asset://tarot/rws_major/chariot.jpg'),
      ('strength', 'asset://tarot/rws_major/strength.jpg'),
      ('hermit', 'asset://tarot/rws_major/hermit.jpg'),
      ('wheel_of_fortune', 'asset://tarot/rws_major/wheel_of_fortune.jpg'),
      ('justice', 'asset://tarot/rws_major/justice.jpg'),
      ('hanged_man', 'asset://tarot/rws_major/hanged_man.jpg'),
      ('death', 'asset://tarot/rws_major/death.jpg'),
      ('temperance', 'asset://tarot/rws_major/temperance.jpg'),
      ('devil', 'asset://tarot/rws_major/devil.jpg'),
      ('tower', 'asset://tarot/rws_major/tower.jpg'),
      ('star', 'asset://tarot/rws_major/star.jpg'),
      ('moon', 'asset://tarot/rws_major/moon.jpg'),
      ('sun', 'asset://tarot/rws_major/sun.jpg'),
      ('judgement', 'asset://tarot/rws_major/judgement.jpg'),
      ('world', 'asset://tarot/rws_major/world.jpg')
  ) as asset_path(code, path)
)
update public.divination_items item
set
  image_url = asset_paths.path,
  metadata = item.metadata || jsonb_build_object(
    'image_storage', 'flutter_asset',
    'image_asset_root', 'assets/tarot/rws_major',
    'image_source', 'local app asset',
    'deck', 'Rider-Waite-Smith'
  ),
  updated_at = now()
from tarot_type
join asset_paths on true
where item.divination_type_id = tarot_type.id
  and item.code = asset_paths.code;
