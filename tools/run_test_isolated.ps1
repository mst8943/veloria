param(
	[Parameter(Mandatory = $true)][string]$Script,
	[string[]]$GameArgs = @(),
	[switch]$Window
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
$repo = Split-Path -Parent $PSScriptRoot
$godot = "C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
$profile = Join-Path $env:TEMP ("Veloria_M1_Test_" + [guid]::NewGuid().ToString("N"))
$oldAppData = $env:APPDATA
New-Item -ItemType Directory -Path $profile | Out-Null
try {
	$env:APPDATA = $profile
	Push-Location $repo
	try {
		if ($Script -eq "@project") {
			if ($Window) { & $godot --path . @GameArgs }
			else { & $godot --headless --path . @GameArgs }
		} else {
			$resource = if ($Script.StartsWith("res://", [StringComparison]::OrdinalIgnoreCase)) { $Script } else { "res://tests/" + $Script }
			if ($Window) { & $godot --path . --script $resource @GameArgs }
			else { & $godot --headless --path . --script $resource @GameArgs }
		}
		$code = $LASTEXITCODE
	} finally {
		Pop-Location
	}
} finally {
	$env:APPDATA = $oldAppData
	$resolvedProfile = (Resolve-Path -LiteralPath $profile).Path
	$tempRoot = (Resolve-Path -LiteralPath $env:TEMP).Path
	if (-not $resolvedProfile.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) { throw "Temporary profile path escaped TEMP" }
	Remove-Item -LiteralPath $resolvedProfile -Recurse -Force
}
exit $code
