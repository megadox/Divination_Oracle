-- Public-domain Rider-Waite-Smith Major Arcana image URLs from Wikimedia Commons.
-- Image.network follows the Special:FilePath redirect to the current file.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
image_urls as (
  select *
  from (
    values
      ('fool', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_00_Fool.jpg'),
      ('magician', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_01_Magician.jpg'),
      ('high_priestess', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_02_High_Priestess.jpg'),
      ('empress', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_03_Empress.jpg'),
      ('emperor', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_04_Emperor.jpg'),
      ('hierophant', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_05_Hierophant.jpg'),
      ('lovers', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_06_Lovers.jpg'),
      ('chariot', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_07_Chariot.jpg'),
      ('strength', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_08_Strength.jpg'),
      ('hermit', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_09_Hermit.jpg'),
      ('wheel_of_fortune', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_10_Wheel_of_Fortune.jpg'),
      ('justice', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_11_Justice.jpg'),
      ('hanged_man', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_12_Hanged_Man.jpg'),
      ('death', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_13_Death.jpg'),
      ('temperance', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_14_Temperance.jpg'),
      ('devil', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_15_Devil.jpg'),
      ('tower', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_16_Tower.jpg'),
      ('star', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_17_Star.jpg'),
      ('moon', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_18_Moon.jpg'),
      ('sun', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_19_Sun.jpg'),
      ('judgement', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_20_Judgement.jpg'),
      ('world', 'https://commons.wikimedia.org/wiki/Special:FilePath/RWS_Tarot_21_World.jpg')
  ) as image_url(code, url)
)
update public.divination_items item
set
  image_url = image_urls.url,
  metadata = item.metadata || jsonb_build_object(
    'image_source', 'Wikimedia Commons',
    'image_license', 'Public domain',
    'deck', 'Rider-Waite-Smith'
  ),
  updated_at = now()
from tarot_type
join image_urls on true
where item.divination_type_id = tarot_type.id
  and item.code = image_urls.code;
