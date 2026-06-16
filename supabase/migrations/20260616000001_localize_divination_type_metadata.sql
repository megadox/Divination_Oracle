-- Normalize divination metadata to Korean-facing copy so the app shows
-- consistent messaging across home, catalog, and intro screens.

update public.divination_types
set
  description = case code
    when 'tarot' then '카드 상징을 통해 현재 흐름과 조언을 읽는 점술'
    when 'rune' then '룬 상징을 통해 현재 에너지와 방향성을 읽는 점술'
    when 'omikuji' then '제비를 뽑아 오늘의 길흉과 메시지를 확인하는 점술'
    when 'saju' then '생년월일시를 바탕으로 기질과 인생 흐름을 해석하는 동아시아 명리 점술'
    when 'zodiac' then '생년월일을 바탕으로 별자리 성향과 흐름을 읽는 입문형 점성술'
    else description
  end,
  short_description = case code
    when 'tarot' then '카드로 현재 흐름과 조언을 살펴봅니다.'
    when 'rune' then '룬 상징으로 현재 에너지와 방향을 읽습니다.'
    when 'omikuji' then '제비를 뽑아 오늘의 길흉과 메시지를 확인합니다.'
    when 'saju' then '생년월일시를 기반으로 기질과 흐름을 봅니다.'
    when 'zodiac' then '생년월일을 기반으로 별자리 성향과 흐름을 봅니다.'
    else short_description
  end,
  origin_region = case code
    when 'tarot' then '서유럽'
    when 'rune' then '북유럽'
    when 'omikuji' then '일본'
    when 'saju' then '한국 · 동아시아'
    when 'zodiac' then '전 세계'
    else origin_region
  end,
  updated_at = now()
where code in ('tarot', 'rune', 'omikuji', 'saju', 'zodiac');
