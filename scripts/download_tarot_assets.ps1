param(
  [string]$OutputDir = "app/flutter_app/assets/tarot/rws_major",
  [int]$DelaySeconds = 3
)

$ErrorActionPreference = "Stop"

$cards = @(
  @{ Code = "fool"; File = "RWS_Tarot_00_Fool.jpg" },
  @{ Code = "magician"; File = "RWS_Tarot_01_Magician.jpg" },
  @{ Code = "high_priestess"; File = "RWS_Tarot_02_High_Priestess.jpg" },
  @{ Code = "empress"; File = "RWS_Tarot_03_Empress.jpg" },
  @{ Code = "emperor"; File = "RWS_Tarot_04_Emperor.jpg" },
  @{ Code = "hierophant"; File = "RWS_Tarot_05_Hierophant.jpg" },
  @{ Code = "lovers"; File = "RWS_Tarot_06_Lovers.jpg" },
  @{ Code = "chariot"; File = "RWS_Tarot_07_Chariot.jpg" },
  @{ Code = "strength"; File = "RWS_Tarot_08_Strength.jpg" },
  @{ Code = "hermit"; File = "RWS_Tarot_09_Hermit.jpg" },
  @{ Code = "wheel_of_fortune"; File = "RWS_Tarot_10_Wheel_of_Fortune.jpg" },
  @{ Code = "justice"; File = "RWS_Tarot_11_Justice.jpg" },
  @{ Code = "hanged_man"; File = "RWS_Tarot_12_Hanged_Man.jpg" },
  @{ Code = "death"; File = "RWS_Tarot_13_Death.jpg" },
  @{ Code = "temperance"; File = "RWS_Tarot_14_Temperance.jpg" },
  @{ Code = "devil"; File = "RWS_Tarot_15_Devil.jpg" },
  @{ Code = "tower"; File = "RWS_Tarot_16_Tower.jpg" },
  @{ Code = "star"; File = "RWS_Tarot_17_Star.jpg" },
  @{ Code = "moon"; File = "RWS_Tarot_18_Moon.jpg" },
  @{ Code = "sun"; File = "RWS_Tarot_19_Sun.jpg" },
  @{ Code = "judgement"; File = "RWS_Tarot_20_Judgement.jpg" },
  @{ Code = "world"; File = "RWS_Tarot_21_World.jpg" }
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
  Invoke-WebRequest `
    -Uri $url `
    -OutFile $target `
    -Headers @{ "User-Agent" = "DivinationAppAssetDownloader/0.1" }

  Start-Sleep -Seconds $DelaySeconds
}

Write-Host "Downloaded $($cards.Count) tarot card assets to $OutputDir"
