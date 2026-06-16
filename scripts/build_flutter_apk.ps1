param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY,
  [string]$DisableFreeReadingLimit = "",
  [ValidateSet("release", "debug", "profile")]
  [string]$BuildMode = "release"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $repoRoot ".env"
$flutterAppDir = Join-Path $repoRoot "app\flutter_app"
$pubspecPath = Join-Path $flutterAppDir "pubspec.yaml"

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

    if ($name -eq "DISABLE_FREE_READING_LIMIT" -and [string]::IsNullOrWhiteSpace($DisableFreeReadingLimit)) {
      $DisableFreeReadingLimit = $value
    }
  }
}

if (-not (Test-Path $pubspecPath)) {
  throw "Flutter project not found: $pubspecPath"
}

if ([string]::IsNullOrWhiteSpace($SupabaseUrl)) {
  throw "SupabaseUrl is required."
}

if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey)) {
  throw "Supabase anon key is required. Pass -SupabaseAnonKey or set SUPABASE_ANON_KEY."
}

Set-Location $flutterAppDir

flutter pub get

if ([string]::IsNullOrWhiteSpace($DisableFreeReadingLimit)) {
  $DisableFreeReadingLimit = "true"
}

$commonArgs = @(
  "--dart-define=SUPABASE_URL=$SupabaseUrl",
  "--dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey",
  "--dart-define=DISABLE_FREE_READING_LIMIT=$DisableFreeReadingLimit"
)

$buildArgs = @("build", "apk", "--$BuildMode") + $commonArgs

flutter @buildArgs

$outputName = if ($BuildMode -eq "release") { "app-release.apk" } elseif ($BuildMode -eq "debug") { "app-debug.apk" } else { "app-profile.apk" }
$outputPath = Join-Path $flutterAppDir "build\app\outputs\flutter-apk\$outputName"

if (Test-Path $outputPath) {
  Write-Host "APK built: $outputPath"
} else {
  throw "APK output not found: $outputPath"
}
