param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = "",
  [string]$SpreadCode = "single_question"
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
  throw "Supabase anon key is required. Pass -SupabaseAnonKey or set SUPABASE_ANON_KEY."
}

$authHeaders = @{
  "apikey" = $SupabaseAnonKey
  "Authorization" = "Bearer $SupabaseAnonKey"
  "Content-Type" = "application/json"
}

$signupBody = @{
  data = @{}
} | ConvertTo-Json

try {
  $signupResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "$SupabaseUrl/auth/v1/signup" `
    -Headers $authHeaders `
    -Body $signupBody
} catch {
  $errorBody = $_.ErrorDetails.Message
  if ($errorBody -like "*anonymous_provider_disabled*") {
    throw "Anonymous sign-ins are disabled. Enable Supabase Dashboard > Authentication > Sign In / Providers > Anonymous sign-ins, then rerun this script."
  }
  throw
}

$accessToken = $signupResponse.access_token

if ([string]::IsNullOrWhiteSpace($accessToken)) {
  throw "Anonymous signup did not return an access token. Check whether anonymous sign-ins are enabled in Supabase Auth."
}

$profileHeaders = @{
  "apikey" = $SupabaseAnonKey
  "Authorization" = "Bearer $accessToken"
  "Content-Type" = "application/json"
}

$profileBody = @{
  id = $signupResponse.user.id
  email = $signupResponse.user.email
  is_anonymous = $true
} | ConvertTo-Json

Invoke-RestMethod `
  -Method Post `
  -Uri "$SupabaseUrl/rest/v1/profiles" `
  -Headers ($profileHeaders + @{ "Prefer" = "resolution=merge-duplicates" }) `
  -Body $profileBody | Out-Null

$functionBody = @{
  divination_type_code = "tarot"
  category = "general"
  question = "테스트 질문"
  spread_code = $SpreadCode
  language_code = "ko"
} | ConvertTo-Json

$reading = Invoke-RestMethod `
  -Method Post `
  -Uri "$SupabaseUrl/functions/v1/create-free-reading" `
  -Headers $profileHeaders `
  -Body $functionBody

$reading | ConvertTo-Json -Depth 10
