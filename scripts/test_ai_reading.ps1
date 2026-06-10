param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = "",
  [string]$SupabaseServiceRoleKey = "",
  [switch]$SkipPlusAiCall
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

    if ($name -eq "SUPABASE_SERVICE_ROLE_KEY" -and [string]::IsNullOrWhiteSpace($SupabaseServiceRoleKey)) {
      $SupabaseServiceRoleKey = $value
    }
  }
}

if ([string]::IsNullOrWhiteSpace($SupabaseUrl)) {
  throw "SupabaseUrl is required."
}

if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey)) {
  throw "Supabase anon key is required. Pass -SupabaseAnonKey or set SUPABASE_ANON_KEY in .env."
}

function Get-FunctionErrorMessage {
  param($ErrorRecord)

  $body = $ErrorRecord.ErrorDetails.Message
  if ([string]::IsNullOrWhiteSpace($body)) {
    $webResponse = $ErrorRecord.Exception.Response
    if ($null -ne $webResponse -and $webResponse.GetType().Name -eq "HttpWebResponse") {
      $reader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
      $body = $reader.ReadToEnd()
      $reader.Close()
    }
  }

  if ([string]::IsNullOrWhiteSpace($body)) {
    return $ErrorRecord.Exception.Message
  }

  try {
    $parsed = $body | ConvertFrom-Json
    if ($parsed.error) {
      return [string]$parsed.error
    }
  } catch {
    return $body
  }

  return $body
}

function New-AnonymousTestUser {
  param(
    [string]$Url,
    [string]$AnonKey
  )

  $authHeaders = @{
    apikey = $AnonKey
    Authorization = "Bearer $AnonKey"
    "Content-Type" = "application/json"
  }

  try {
    $signupResponse = Invoke-RestMethod `
      -Method Post `
      -Uri "$Url/auth/v1/signup" `
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
    apikey = $AnonKey
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
  }

  Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/rest/v1/profiles" `
    -Headers ($userHeaders + @{ Prefer = "resolution=merge-duplicates" }) `
    -Body (@{
      id = $userId
      email = $signupResponse.user.email
      is_anonymous = $true
    } | ConvertTo-Json) | Out-Null

  return @{
    UserId = $userId
    UserHeaders = $userHeaders
  }
}

function Invoke-AiReading {
  param(
    [string]$Url,
    [hashtable]$Headers,
    [string]$Question = "Plus AI reading verification test"
  )

  $body = @{
    divination_type_code = "tarot"
    category = "general"
    question = $Question
    spread_code = "single_question"
    language_code = "ko"
  } | ConvertTo-Json

  return Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/functions/v1/create-ai-reading" `
    -Headers $Headers `
    -Body $body
}

function Grant-TestPlusSubscription {
  param(
    [string]$Url,
    [string]$ServiceRoleKey,
    [string]$UserId
  )

  $adminHeaders = @{
    apikey = $ServiceRoleKey
    Authorization = "Bearer $ServiceRoleKey"
    "Content-Type" = "application/json"
    Prefer = "resolution=merge-duplicates"
  }

  $now = (Get-Date).ToUniversalTime().ToString("o")
  $periodEnd = (Get-Date).AddDays(30).ToUniversalTime().ToString("o")

  $subscriptionBody = @{
    user_id = $UserId
    provider = "revenuecat"
    entitlement_id = "plus"
    status = "active"
    product_id = "test_plus_monthly"
    revenuecat_app_user_id = $UserId
    current_period_start = $now
    current_period_end = $periodEnd
    raw_payload = @{ source = "test_ai_reading.ps1" }
  } | ConvertTo-Json -Depth 5

  Invoke-RestMethod `
    -Method Post `
    -Uri "$Url/rest/v1/subscriptions" `
    -Headers $adminHeaders `
    -Body $subscriptionBody | Out-Null
}

Write-Host "Plus/AI verification"
Write-Host ""

Write-Host "1. Edge Function secrets checklist"
Write-Host "   Supabase Dashboard > Project Settings > Edge Functions > Secrets"
Write-Host "   Required for create-ai-reading:"
Write-Host "   - SUPABASE_URL"
Write-Host "   - SUPABASE_SERVICE_ROLE_KEY"
Write-Host "   - OPENAI_API_KEY"
Write-Host "   - OPENAI_MODEL (optional, default gpt-4o-mini)"
Write-Host "   Required for sync-revenuecat-subscription:"
Write-Host "   - REVENUECAT_WEBHOOK_SECRET"
Write-Host ""

Write-Host "2. Non-Plus user must be blocked"
$anonymousUser = New-AnonymousTestUser -Url $SupabaseUrl -AnonKey $SupabaseAnonKey
Write-Host "   user_id: $($anonymousUser.UserId)"

try {
  Invoke-AiReading -Url $SupabaseUrl -Headers $anonymousUser.UserHeaders | Out-Null
  throw "Expected create-ai-reading to fail for non-Plus user, but it succeeded."
} catch {
  $message = Get-FunctionErrorMessage -ErrorRecord $_
  if ($message -ne "Plus subscription is required.") {
    throw "Unexpected error for non-Plus user: $message"
  }
  Write-Host "   PASS: $message"
}

if ($SkipPlusAiCall) {
  Write-Host ""
  Write-Host "3. Skipped Plus AI call (-SkipPlusAiCall)."
  Write-Host "Done."
  exit 0
}

if ([string]::IsNullOrWhiteSpace($SupabaseServiceRoleKey)) {
  Write-Host ""
  Write-Host "3. Skipped Plus AI success test."
  Write-Host "   Set SUPABASE_SERVICE_ROLE_KEY in .env or pass -SupabaseServiceRoleKey to insert a test subscription and call OpenAI."
  Write-Host "Done."
  exit 0
}

Write-Host ""
Write-Host "3. Plus test subscription upsert"
Grant-TestPlusSubscription `
  -Url $SupabaseUrl `
  -ServiceRoleKey $SupabaseServiceRoleKey `
  -UserId $anonymousUser.UserId
Write-Host "   PASS: subscriptions row upserted for entitlement plus"

Write-Host ""
Write-Host "4. Plus user create-ai-reading"
try {
  $reading = Invoke-AiReading -Url $SupabaseUrl -Headers $anonymousUser.UserHeaders
} catch {
  $message = Get-FunctionErrorMessage -ErrorRecord $_
  if ($message -like "*OpenAI*" -or $message -like "*API key*" -or $message -like "*401*") {
    throw "Plus check passed, but OpenAI call failed. Verify OPENAI_API_KEY and OPENAI_MODEL secrets. Details: $message"
  }
  throw "Plus AI reading failed: $message"
}

if ($reading.result_type -ne "plus_ai") {
  throw "Expected result_type plus_ai, got $($reading.result_type)"
}

if ([string]::IsNullOrWhiteSpace($reading.result_text)) {
  throw "AI reading returned empty result_text."
}

Write-Host "   reading_id: $($reading.id)"
Write-Host "   result_type: $($reading.result_type)"
Write-Host "   PASS: AI reading created"
Write-Host ""
Write-Host "All requested Plus/AI checks passed."
