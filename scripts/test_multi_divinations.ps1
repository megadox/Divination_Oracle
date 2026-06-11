param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = "",
  [switch]$IncludeTarot
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $repoRoot ".env"

if (Test-Path $envPath) {
  Get-Content -LiteralPath $envPath | ForEach-Object {
    $line = $_.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#") -or -not $line.Contains("=")) {
      return
    }

    $parts = $line.Split("=", 2)
    $name = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")

    if ($name -eq "SUPABASE_URL" -and [string]::IsNullOrWhiteSpace($SupabaseUrl)) {
      $SupabaseUrl = $value
    }

    if ($name -eq "SUPABASE_ANON_KEY" -and [string]::IsNullOrWhiteSpace($SupabaseAnonKey)) {
      $SupabaseAnonKey = $value
    }
  }
}

if ([string]::IsNullOrWhiteSpace($SupabaseUrl)) {
  throw "SupabaseUrl is required."
}

if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey)) {
  throw "Supabase anon key is required."
}

function New-AnonymousSession {
  param(
    [string]$Url,
    [string]$AnonKey
  )

  $authHeaders = @{
    apikey = $AnonKey
    Authorization = "Bearer $AnonKey"
    "Content-Type" = "application/json"
  }

  $signupResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/auth/v1/signup" `
    -Headers $authHeaders `
    -Body (@{ data = @{} } | ConvertTo-Json)

  if ([string]::IsNullOrWhiteSpace($signupResponse.access_token)) {
    throw "Anonymous signup did not return an access token."
  }

  $userHeaders = @{
    apikey = $AnonKey
    Authorization = "Bearer $($signupResponse.access_token)"
    "Content-Type" = "application/json"
  }

  Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/rest/v1/profiles" `
    -Headers ($userHeaders + @{ Prefer = "resolution=merge-duplicates" }) `
    -Body (@{
      id = $signupResponse.user.id
      email = $signupResponse.user.email
      is_anonymous = $true
    } | ConvertTo-Json) | Out-Null

  return $userHeaders
}

function Invoke-FreeReading {
  param(
    [string]$Url,
    [hashtable]$Headers,
    [string]$DivinationCode,
    [string]$Question,
    [string]$Category,
    [hashtable]$Inputs = @{},
    [string]$SpreadCode = ""
  )

  $body = @{
    divination_type_code = $DivinationCode
    question = $Question
    category = $Category
    language_code = "ko"
  }

  if (-not [string]::IsNullOrWhiteSpace($SpreadCode)) {
    $body.spread_code = $SpreadCode
  }

  if ($Inputs.Count -gt 0) {
    $body.inputs = $Inputs
  }

  return Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/functions/v1/create-free-reading" `
    -Headers $Headers `
    -Body ($body | ConvertTo-Json -Depth 10)
}

$headers = New-AnonymousSession -Url $SupabaseUrl -AnonKey $SupabaseAnonKey

$cases = @(
  @{
    Code = "saju"
    Question = "올해 직업 흐름이 궁금합니다."
    Category = "career"
    Inputs = @{
      name = "테스트"
      birth_date = "1994-03-21"
      birth_time = "14:30"
      calendar_type = "solar"
      gender = "female"
      birth_time_unknown = $false
    }
  },
  @{
    Code = "zodiac"
    Question = "이번 달 연애 흐름이 궁금합니다."
    Category = "love"
    Inputs = @{
      name = "테스트"
      birth_date = "1997-08-15"
    }
  },
  @{
    Code = "rune"
    Question = "지금 방향을 바꿔도 될까요?"
    Category = "general"
    Inputs = @{
      draw_count = 3
    }
  },
  @{
    Code = "omikuji"
    Question = "오늘 중요한 결정을 해도 괜찮을까요?"
    Category = "general"
    Inputs = @{}
  }
)

if ($IncludeTarot) {
  $cases += @{
    Code = "tarot"
    Question = "타로 회귀 테스트"
    Category = "general"
    Inputs = @{}
    SpreadCode = "single_question"
  }
}

$results = @()

foreach ($case in $cases) {
  Write-Host "Testing free reading: $($case.Code)"
  $reading = Invoke-FreeReading `
    -Url $SupabaseUrl `
    -Headers $headers `
    -DivinationCode $case.Code `
    -Question $case.Question `
    -Category $case.Category `
    -Inputs $case.Inputs `
    -SpreadCode $case.SpreadCode

  if ([string]::IsNullOrWhiteSpace($reading.id)) {
    throw "Missing reading id for $($case.Code)"
  }

  if ([string]::IsNullOrWhiteSpace($reading.result_text)) {
    throw "Missing result_text for $($case.Code)"
  }

  $results += [PSCustomObject]@{
    code = $case.Code
    reading_id = $reading.id
    result_type = $reading.result_type
    spread_code = $reading.spread_code
    preview = [string]$reading.result_text
  }

  Write-Host "  PASS: $($case.Code) => $($reading.id)"
}

$results | ConvertTo-Json -Depth 10
