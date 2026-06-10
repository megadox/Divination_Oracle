param(
  [string]$SupabaseUrl = "",
  [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY,
  [ValidateSet("chrome", "edge", "web-server")]
  [string]$Device = "chrome",
  [int]$WebPort = 8080
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $repoRoot ".env"
$flutterAppDir = Join-Path $repoRoot "app\flutter_app"
$pubspecPath = Join-Path $flutterAppDir "pubspec.yaml"
$webDir = Join-Path $flutterAppDir "web"

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

if (-not (Test-Path $webDir)) {
  flutter create . --platforms web
}

flutter pub get

$commonArgs = @(
  "--dart-define=SUPABASE_URL=$SupabaseUrl",
  "--dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey"
)

if ($Device -eq "web-server") {
  flutter run -d web-server `
    --web-hostname localhost `
    --web-port $WebPort `
    @commonArgs
} else {
  flutter run -d $Device @commonArgs
}
