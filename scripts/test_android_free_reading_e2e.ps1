param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = ""
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
  throw "Supabase anon key is required. Pass -SupabaseAnonKey or set it in .env."
}

$spreadCases = @(
  @{
    spread_code = "single_question"
    expected_cards = 1
    category = "love"
    question = "Android E2E single_question test"
  },
  @{
    spread_code = "three_card_timeline"
    expected_cards = 3
    category = "career"
    question = "Android E2E three_card_timeline test"
  },
  @{
    spread_code = "celtic_cross"
    expected_cards = 10
    category = "money"
    question = "Android E2E celtic_cross test"
  }
)

$authHeaders = @{
  apikey = $SupabaseAnonKey
  Authorization = "Bearer $SupabaseAnonKey"
  "Content-Type" = "application/json"
}

Write-Host "1. Anonymous sign-in"
try {
  $signupResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "$SupabaseUrl/auth/v1/signup" `
    -Headers $authHeaders `
    -Body (@{ data = @{} } | ConvertTo-Json)
} catch {
  $errorBody = $_.ErrorDetails.Message
  if ($errorBody -like "*anonymous_provider_disabled*") {
    throw "Anonymous sign-ins are disabled. Enable anonymous sign-ins in Supabase Auth settings."
  }
  throw
}

$accessToken = $signupResponse.access_token
$userId = $signupResponse.user.id

if ([string]::IsNullOrWhiteSpace($accessToken)) {
  throw "Anonymous signup did not return an access token."
}

$userHeaders = @{
  apikey = $SupabaseAnonKey
  Authorization = "Bearer $accessToken"
  "Content-Type" = "application/json"
}

Invoke-RestMethod `
  -Method Post `
  -Uri "$SupabaseUrl/rest/v1/profiles" `
  -Headers ($userHeaders + @{ Prefer = "resolution=merge-duplicates" }) `
  -Body (@{
    id = $userId
    email = $signupResponse.user.email
    is_anonymous = $true
  } | ConvertTo-Json) | Out-Null

$usageQuery = "$SupabaseUrl/rest/v1/daily_usage?user_id=eq.$userId" +
  "&select=free_reading_count,usage_date&order=usage_date.desc&limit=1"
$beforeUsage = Invoke-RestMethod `
  -Method Get `
  -Uri $usageQuery `
  -Headers $userHeaders

$beforeCount = 0
if ($beforeUsage.Count -gt 0) {
  $beforeCount = [int]$beforeUsage[0].free_reading_count
}

Write-Host "   user_id: $userId"
Write-Host "   free_reading_count before: $beforeCount"

$createdReadingIds = @()
$passed = 0

foreach ($case in $spreadCases) {
  Write-Host ""
  Write-Host "2. Create free reading: $($case.spread_code)"

  $functionBody = @{
    divination_type_code = "tarot"
    category = $case.category
    question = $case.question
    spread_code = $case.spread_code
    language_code = "ko"
  } | ConvertTo-Json

  $reading = Invoke-RestMethod `
    -Method Post `
    -Uri "$SupabaseUrl/functions/v1/create-free-reading" `
    -Headers $userHeaders `
    -Body $functionBody

  $readingId = $reading.id
  $createdReadingIds += $readingId

  if ($reading.spread_code -ne $case.spread_code) {
    throw "spread_code mismatch for $($case.spread_code): got $($reading.spread_code)"
  }

  if ($reading.category -ne $case.category) {
    throw "category mismatch for $($case.spread_code): expected $($case.category), got $($reading.category)"
  }

  if ($reading.question -ne $case.question) {
    throw "question mismatch for $($case.spread_code)"
  }

  if ([string]::IsNullOrWhiteSpace($reading.result_text)) {
    throw "result_text is empty for $($case.spread_code)"
  }

  $itemsQuery = "$SupabaseUrl/rest/v1/reading_items?reading_id=eq.$readingId" +
    "&select=id,position_name,position_order,orientation&order=position_order.asc"
  $items = Invoke-RestMethod `
    -Method Get `
    -Uri $itemsQuery `
    -Headers $userHeaders

  if ($items.Count -ne $case.expected_cards) {
    throw "reading_items count mismatch for $($case.spread_code): expected $($case.expected_cards), got $($items.Count)"
  }

  Write-Host "   reading_id: $readingId"
  Write-Host "   cards: $($items.Count)"
  Write-Host "   PASS"
  $passed++
}

$afterUsage = Invoke-RestMethod `
  -Method Get `
  -Uri $usageQuery `
  -Headers $userHeaders

$afterCount = 0
if ($afterUsage.Count -gt 0) {
  $afterCount = [int]$afterUsage[0].free_reading_count
}

$expectedAfterCount = $beforeCount + $spreadCases.Count
if ($afterCount -ne $expectedAfterCount) {
  throw "daily_usage mismatch: expected $expectedAfterCount, got $afterCount"
}

Write-Host ""
Write-Host "3. daily_usage free_reading_count: $beforeCount -> $afterCount"
Write-Host ""
Write-Host "All $passed spread checks passed."
Write-Host "Created reading IDs:"
$createdReadingIds | ForEach-Object { Write-Host " - $_" }
Write-Host ""
Write-Host "Manual Android check:"
Write-Host " - Run .\scripts\run_flutter_android.ps1"
Write-Host " - Create the same spreads in the app UI"
Write-Host " - Press back on result/history/plus screens and confirm you return to home"
Write-Host " - Press back on home to exit the app"
