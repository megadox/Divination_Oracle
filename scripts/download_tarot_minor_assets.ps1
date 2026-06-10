param(
  [string]$OutputDir = "app/flutter_app/assets/tarot/rws_minor",
  [int]$DelaySeconds = 2
)

$ErrorActionPreference = "Stop"

$cards = @(
  @{ Code = "wands_ace"; File = "Wands01.jpg" },
  @{ Code = "wands_two"; File = "Wands02.jpg" },
  @{ Code = "wands_three"; File = "Wands03.jpg" },
  @{ Code = "wands_four"; File = "Wands04.jpg" },
  @{ Code = "wands_five"; File = "Wands05.jpg" },
  @{ Code = "wands_six"; File = "Wands06.jpg" },
  @{ Code = "wands_seven"; File = "Wands07.jpg" },
  @{ Code = "wands_eight"; File = "Wands08.jpg" },
  @{ Code = "wands_nine"; File = "Wands09.jpg" },
  @{ Code = "wands_ten"; File = "Wands10.jpg" },
  @{ Code = "wands_page"; File = "Wands11.jpg" },
  @{ Code = "wands_knight"; File = "Wands12.jpg" },
  @{ Code = "wands_queen"; File = "Wands13.jpg" },
  @{ Code = "wands_king"; File = "Wands14.jpg" },
  @{ Code = "cups_ace"; File = "Cups01.jpg" },
  @{ Code = "cups_two"; File = "Cups02.jpg" },
  @{ Code = "cups_three"; File = "Cups03.jpg" },
  @{ Code = "cups_four"; File = "Cups04.jpg" },
  @{ Code = "cups_five"; File = "Cups05.jpg" },
  @{ Code = "cups_six"; File = "Cups06.jpg" },
  @{ Code = "cups_seven"; File = "Cups07.jpg" },
  @{ Code = "cups_eight"; File = "Cups08.jpg" },
  @{ Code = "cups_nine"; File = "Cups09.jpg" },
  @{ Code = "cups_ten"; File = "Cups10.jpg" },
  @{ Code = "cups_page"; File = "Cups11.jpg" },
  @{ Code = "cups_knight"; File = "Cups12.jpg" },
  @{ Code = "cups_queen"; File = "Cups13.jpg" },
  @{ Code = "cups_king"; File = "Cups14.jpg" },
  @{ Code = "swords_ace"; File = "Swords01.jpg" },
  @{ Code = "swords_two"; File = "Swords02.jpg" },
  @{ Code = "swords_three"; File = "Swords03.jpg" },
  @{ Code = "swords_four"; File = "Swords04.jpg" },
  @{ Code = "swords_five"; File = "Swords05.jpg" },
  @{ Code = "swords_six"; File = "Swords06.jpg" },
  @{ Code = "swords_seven"; File = "Swords07.jpg" },
  @{ Code = "swords_eight"; File = "Swords08.jpg" },
  @{ Code = "swords_nine"; File = "Swords09.jpg" },
  @{ Code = "swords_ten"; File = "Swords10.jpg" },
  @{ Code = "swords_page"; File = "Swords11.jpg" },
  @{ Code = "swords_knight"; File = "Swords12.jpg" },
  @{ Code = "swords_queen"; File = "Swords13.jpg" },
  @{ Code = "swords_king"; File = "Swords14.jpg" },
  @{ Code = "pentacles_ace"; File = "Pents01.jpg" },
  @{ Code = "pentacles_two"; File = "Pents02.jpg" },
  @{ Code = "pentacles_three"; File = "Pents03.jpg" },
  @{ Code = "pentacles_four"; File = "Pents04.jpg" },
  @{ Code = "pentacles_five"; File = "Pents05.jpg" },
  @{ Code = "pentacles_six"; File = "Pents06.jpg" },
  @{ Code = "pentacles_seven"; File = "Pents07.jpg" },
  @{ Code = "pentacles_eight"; File = "Pents08.jpg" },
  @{ Code = "pentacles_nine"; File = "Pents09.jpg" },
  @{ Code = "pentacles_ten"; File = "Pents10.jpg" },
  @{ Code = "pentacles_page"; File = "Pents11.jpg" },
  @{ Code = "pentacles_knight"; File = "Pents12.jpg" },
  @{ Code = "pentacles_queen"; File = "Pents13.jpg" },
  @{ Code = "pentacles_king"; File = "Pents14.jpg" }
)

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

foreach ($card in $cards) {
  $target = Join-Path $OutputDir "$($card.Code).jpg"
  $url = "https://commons.wikimedia.org/wiki/Special:FilePath/$($card.File)"

  if ((Test-Path -LiteralPath $target) -and ((Get-Item -LiteralPath $target).Length -gt 0)) {
    Write-Host "Skipping $($card.Code); file already exists."
    continue
  }

  Write-Host "Downloading $($card.Code) -> $target"
  try {
    Invoke-WebRequest `
      -Uri $url `
      -OutFile $target `
      -Headers @{ "User-Agent" = "DivinationAppAssetDownloader/0.1" }
  } catch {
    Write-Warning "Failed to download $($card.Code): $_"
  }

  Start-Sleep -Seconds $DelaySeconds
}

Write-Host "Minor arcana download finished. Target: $OutputDir"
