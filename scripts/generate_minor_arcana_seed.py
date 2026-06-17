#!/usr/bin/env python3
"""Generate Minor Arcana seed and asset path migrations."""

from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

RANKS = [
    ("ace", "01", "Ace", "에이스"),
    ("two", "02", "Two", "2"),
    ("three", "03", "Three", "3"),
    ("four", "04", "Four", "4"),
    ("five", "05", "Five", "5"),
    ("six", "06", "Six", "6"),
    ("seven", "07", "Seven", "7"),
    ("eight", "08", "Eight", "8"),
    ("nine", "09", "Nine", "9"),
    ("ten", "10", "Ten", "10"),
    ("page", "11", "Page", "시종"),
    ("knight", "12", "Knight", "기사"),
    ("queen", "13", "Queen", "여왕"),
    ("king", "14", "King", "왕"),
]

SUITS = [
    {
        "code": "wands",
        "en": "Wands",
        "ko": "지팡이",
        "prefix": "Wands",
        "start": 22,
        "themes": [
            "새로운 시작과 영감", "계획과 미래 설계", "확장과 기회", "안정과 축하", "경쟁과 긴장",
            "승리와 인정", "방어와 인내", "빠른 전개와 움직임", "끈기와 경계", "부담과 책임",
            "호기심과 탐색", "열정과 돌진", "따뜻한 카리스마", "비전과 리더십",
        ],
        "keywords": [
            ("시작", "영감", "열정"), ("계획", "미래", "설계"), ("확장", "기회", "성장"),
            ("안정", "축하", "기반"), ("경쟁", "긴장", "도전"), ("승리", "인정", "자신감"),
            ("방어", "인내", "끈기"), ("속도", "전개", "움직임"), ("경계", "끈기", "준비"),
            ("부담", "책임", "압박"), ("호기심", "탐색", "메시지"), ("열정", "돌진", "행동"),
            ("카리스마", "따뜻함", "매력"), ("리더십", "비전", "통솔"),
        ],
    },
    {
        "code": "cups",
        "en": "Cups",
        "ko": "컵",
        "prefix": "Cups",
        "start": 36,
        "themes": [
            "감정의 시작과 사랑", "연결과 파트너십", "기쁨과 교류", "정서적 공허", "상실과 아픔",
            "추억과 순수함", "선택과 환상", "떠남과 새로운 가능성", "만족과 소망 성취", "가족과 감정적 완성",
            "직관과 감수성", "로맨스와 이상", "공감과 돌봄", "감정적 균형과 성숙",
        ],
        "keywords": [
            ("사랑", "감정", "시작"), ("연결", "파트너십", "조화"), ("기쁨", "교류", "친교"),
            ("공허", "정서", "멈춤"), ("상실", "아픔", "후회"), ("추억", "순수", "그리움"),
            ("선택", "환상", "가능성"), ("떠남", "전환", "새출발"), ("만족", "소망", "성취"),
            ("가족", "완성", "행복"), ("직관", "감수성", "메시지"), ("로맨스", "이상", "제안"),
            ("공감", "돌봄", "치유"), ("균형", "성숙", "지혜"),
        ],
    },
    {
        "code": "swords",
        "en": "Swords",
        "ko": "검",
        "prefix": "Swords",
        "start": 50,
        "themes": [
            "명확한 통찰과 진실", "딜레마와 균형", "슬픔과 분리", "휴식과 회복", "갈등과 패배감",
            "전환과 이동", "전략과 교묘함", "제약과 불안", "걱정과 악몽", "종료와 새로운 시작",
            "호기심과 아이디어", "결단과 직설", "명료함과 독립", "이성과 공정한 판단",
        ],
        "keywords": [
            ("통찰", "진실", "명료"), ("딜레마", "균형", "선택"), ("슬픔", "분리", "상처"),
            ("휴식", "회복", "재충전"), ("갈등", "패배", "긴장"), ("전환", "이동", "변화"),
            ("전략", "교묘", "계획"), ("제약", "불안", "속박"), ("걱정", "압박", "두려움"),
            ("종료", "새시작", "해방"), ("아이디어", "호기심", "학습"), ("결단", "직설", "행동"),
            ("독립", "명료", "경계"), ("이성", "공정", "판단"),
        ],
    },
    {
        "code": "pentacles",
        "en": "Pentacles",
        "ko": "펜타클",
        "prefix": "Pents",
        "start": 64,
        "themes": [
            "새로운 기회와 번영", "균형과 다재다능", "숙련과 협업", "안정과 보수", "어려움과 불안정",
            "나눔과 지원", "인내와 장기 투자", "기술과 성실", "성취와 자급자족", "부와 유산",
            "학습과 실용성", "근면과 신중한 전진", "실용과 풍요", "성공과 안정된 경영",
        ],
        "keywords": [
            ("기회", "번영", "시작"), ("균형", "다재다능", "조율"), ("숙련", "협업", "성장"),
            ("안정", "보수", "저축"), ("어려움", "불안정", "시련"), ("나눔", "지원", "베풂"),
            ("인내", "투자", "기다림"), ("기술", "성실", "노력"), ("성취", "자급자족", "풍요"),
            ("부", "유산", "완성"), ("학습", "실용", "탐구"), ("근면", "신중", "전진"),
            ("실용", "풍요", "돌봄"), ("성공", "경영", "안정"),
        ],
    },
]


def esc(value: str) -> str:
    return value.replace("'", "''")


def build_cards():
    cards = []
    for suit in SUITS:
        for index, (rank_code, rank_num, rank_en, rank_ko) in enumerate(RANKS):
            cards.append(
                {
                    "code": f"{suit['code']}_{rank_code}",
                    "name": f"{rank_en} of {suit['en']}",
                    "display_name": f"{suit['ko']} {rank_ko}",
                    "theme": suit["themes"][index],
                    "keywords": suit["keywords"][index],
                    "order_no": suit["start"] + index,
                    "suit": suit["code"],
                    "rank": rank_code,
                    "wiki_file": f"{suit['prefix']}{rank_num}.jpg",
                }
            )
    return cards


def item_values(cards):
    lines = []
    for card in cards:
        keywords = ", ".join(f"'{esc(keyword)}'" for keyword in card["keywords"])
        lines.append(
            "      ("
            f"'{esc(card['code'])}', '{esc(card['name'])}', '{esc(card['display_name'])}', "
            f"'{esc(card['theme'])}', array[{keywords}], {card['order_no']}, "
            f"'{card['suit']}', '{card['rank']}')"
        )
    return ",\n".join(lines)


def interp_values(cards):
    lines = []
    for card in cards:
        lines.append(
            "      ("
            f"'{esc(card['code'])}', '{esc(card['display_name'])}', '{esc(card['theme'])}')"
        )
    return ",\n".join(lines)


def asset_values(cards):
    lines = []
    for card in cards:
        lines.append(
            f"      ('{esc(card['code'])}', 'asset://tarot/rws_minor/{card['code']}.jpg')"
        )
    return ",\n".join(lines)


def download_script_lines(cards):
    lines = []
    for index, card in enumerate(cards):
        suffix = "," if index < len(cards) - 1 else ""
        lines.append(
            f'  @{{ Code = "{card["code"]}"; File = "{card["wiki_file"]}" }}{suffix}'
        )
    return "\n".join(lines)


def main():
    cards = build_cards()

    seed_sql = f"""-- Minor Arcana tarot seed (56 cards). Full deck: 22 major + 56 minor = 78 cards.

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
{item_values(cards)}
  ) as card(code, name, display_name, theme, keywords, order_no, suit, rank)
)
insert into public.divination_items (
  divination_type_id,
  code,
  name,
  display_name,
  description,
  keywords,
  metadata,
  order_no,
  is_active
)
select
  tarot_type.id,
  seed_cards.code,
  seed_cards.name,
  seed_cards.display_name,
  seed_cards.theme || '을 상징하는 마이너 아르카나 카드',
  seed_cards.keywords,
  jsonb_build_object(
    'arcana', 'minor',
    'suit', seed_cards.suit,
    'rank', seed_cards.rank,
    'theme', seed_cards.theme
  ),
  seed_cards.order_no,
  true
from tarot_type
cross join seed_cards
on conflict (divination_type_id, code) do update
set
  name = excluded.name,
  display_name = excluded.display_name,
  description = excluded.description,
  keywords = excluded.keywords,
  metadata = excluded.metadata,
  order_no = excluded.order_no,
  is_active = excluded.is_active,
  updated_at = now();

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
seed_cards as (
  select *
  from (
    values
{interp_values(cards)}
  ) as card(code, display_name, theme)
),
orientations as (
  select *
  from (
    values
      ('upright', '정방향', '이 카드의 에너지가 비교적 자연스럽게 드러납니다.', '지금 보이는 가능성을 현실적인 행동으로 옮겨 보세요.', '확신이 지나쳐 주변 신호를 놓치지 않도록 주의하세요.'),
      ('reversed', '역방향', '이 카드의 에너지가 지연되거나 내면에서 흔들릴 수 있습니다.', '잠시 멈추고 같은 주제를 다른 각도에서 살펴보세요.', '불안이나 조급함 때문에 성급히 결론 내리지 마세요.')
  ) as orientation(code, label, flow, advice, warning)
),
categories as (
  select *
  from (
    values
      ('general', '일반', '상황 전체의 흐름을 넓게 바라볼 필요가 있습니다.'),
      ('love', '연애', '감정의 속도와 서로의 기대를 함께 살피는 것이 좋습니다.'),
      ('career', '직업', '기회와 책임, 준비 상태를 현실적으로 점검해야 합니다.'),
      ('money', '금전', '수익보다 리스크와 지출 흐름을 먼저 확인하세요.'),
      ('health', '건강', '결과는 참고용이며 생활 리듬과 휴식을 우선하세요.'),
      ('relationship', '관계', '말보다 신뢰, 경계, 거리감을 함께 살피세요.')
  ) as category(code, label, detail)
),
card_items as (
  select item.id, item.code
  from public.divination_items item
  join tarot_type on tarot_type.id = item.divination_type_id
  where item.metadata->>'arcana' = 'minor'
)
insert into public.interpretations (
  item_id,
  orientation,
  category,
  summary,
  detail,
  advice,
  warning,
  keywords,
  language_code,
  is_active
)
select
  card_items.id,
  orientations.code,
  categories.code,
  seed_cards.display_name || ' 카드는 ' || categories.label || ' 영역에서 ' ||
    seed_cards.theme || '의 메시지를 보여줍니다.',
  seed_cards.theme || '. ' || orientations.flow || ' ' || categories.detail,
  orientations.advice,
  orientations.warning,
  array[seed_cards.theme, categories.label, orientations.label],
  'ko',
  true
from card_items
join seed_cards on seed_cards.code = card_items.code
cross join orientations
cross join categories
on conflict (item_id, orientation, category, language_code) do update
set
  summary = excluded.summary,
  detail = excluded.detail,
  advice = excluded.advice,
  warning = excluded.warning,
  keywords = excluded.keywords,
  is_active = excluded.is_active,
  updated_at = now();
"""

    asset_sql = f"""-- Local asset paths for Minor Arcana (56 cards).

with tarot_type as (
  select id
  from public.divination_types
  where code = 'tarot'
),
asset_paths as (
  select *
  from (
    values
{asset_values(cards)}
  ) as asset_path(code, path)
)
update public.divination_items item
set
  image_url = asset_paths.path,
  metadata = item.metadata || jsonb_build_object(
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
"""

    download_ps1 = f"""param(
  [string]$OutputDir = "app/flutter_app/assets/tarot/rws_minor",
  [int]$DelaySeconds = 2
)

$ErrorActionPreference = "Stop"

$cards = @(
{download_script_lines(cards)}
)

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

foreach ($card in $cards) {{
  $target = Join-Path $OutputDir "$($card.Code).jpg"
  $url = "https://commons.wikimedia.org/wiki/Special:FilePath/$($card.File)"

  if ((Test-Path -LiteralPath $target) -and ((Get-Item -LiteralPath $target).Length -gt 0)) {{
    Write-Host "Skipping $($card.Code); file already exists."
    continue
  }}

  Write-Host "Downloading $($card.Code) -> $target"
  try {{
    Invoke-WebRequest `
      -Uri $url `
      -OutFile $target `
      -Headers @{{ "User-Agent" = "DivinationAppAssetDownloader/0.1" }}
  }} catch {{
    Write-Warning "Failed to download $($card.Code): $_"
  }}

  Start-Sleep -Seconds $DelaySeconds
}}

Write-Host "Minor arcana download finished. Target: $OutputDir"
"""

    (ROOT / "supabase/migrations/20260608000001_seed_minor_arcana.sql").write_text(
        seed_sql, encoding="utf-8"
    )
    (ROOT / "supabase/migrations/20260608000002_add_minor_arcana_asset_paths.sql").write_text(
        asset_sql, encoding="utf-8"
    )
    (ROOT / "scripts/download_tarot_minor_assets.ps1").write_text(
        download_ps1, encoding="utf-8"
    )
    print(f"Generated {len(cards)} minor arcana cards")


if __name__ == "__main__":
    main()
