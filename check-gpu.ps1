$ErrorActionPreference = 'Continue'
$lines = New-Object System.Collections.Generic.List[string]
function Add-Line([string]$text = '') {
  $lines.Add($text)
  Write-Host $text
}

Add-Line '=============================================='
Add-Line ' Binhe Digital Twin / GPU health report'
Add-Line (' Time: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Add-Line '=============================================='

$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
Add-Line ('Model : ' + $cs.Manufacturer + ' ' + $cs.Model)
Add-Line ('BIOS  : ' + $bios.SMBIOSBIOSVersion + '  (' + $bios.ReleaseDate.ToString('yyyy-MM-dd') + ')')
Add-Line ''

Add-Line '--- Display adapters ---'
Get-PnpDevice -Class Display | ForEach-Object {
  Add-Line ('  ' + $_.FriendlyName + ' | Status=' + $_.Status + ' | Problem=' + $_.Problem)
}
Add-Line ''

Add-Line '--- NVIDIA SMI ---'
$smi = Join-Path $env:WINDIR 'System32\nvidia-smi.exe'
if (Test-Path $smi) {
  $out = & $smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>&1
  $out | ForEach-Object { Add-Line ('  ' + $_) }
  Add-Line ('  exit=' + $LASTEXITCODE)
} else {
  Add-Line '  nvidia-smi not found'
}
Add-Line ''

Add-Line '--- Vulkan devices ---'
$vulkan = Join-Path $env:WINDIR 'System32\vulkaninfo.exe'
if (Test-Path $vulkan) {
  $vout = & $vulkan --summary 2>&1
  $vout | Select-String -Pattern 'GPU[0-9]+:|deviceName|deviceType|vendorID|driverVersion' | ForEach-Object {
    Add-Line ('  ' + $_.Line.Trim())
  }
} else {
  Add-Line '  vulkaninfo not found'
}
Add-Line ''

Add-Line '--- Windows per-app GPU preference ---'
$pref = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
$apps = @(
  (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'),
  (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'),
  (Join-Path $env:LOCALAPPDATA 'Programs\DeepSeek Harness\DeepSeek Harness.exe')
)
foreach ($app in $apps) {
  $value = (Get-ItemProperty -Path $pref -Name $app -ErrorAction SilentlyContinue).$app
  Add-Line ('  ' + $app + ' => ' + $(if ($value) { $value } else { '<not set>' }))
}
Add-Line ''

Add-Line '--- Running browser GPU processes ---'
$browsers = Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe' OR Name = 'msedge.exe'" |
  Where-Object { $_.CommandLine -match '--type=gpu-process' }
if (-not $browsers) {
  Add-Line '  no browser GPU process found'
} else {
  foreach ($b in $browsers) {
    $angle = '<default>'
    if ($b.CommandLine -match '--use-angle=([^\s"]+)') { $angle = $Matches[1] }
    $mode = 'HARDWARE (or driver default)'
    if ($b.CommandLine -match 'warp|swiftshader') { $mode = 'SOFTWARE / WARP' }
    Add-Line ('  ' + $b.Name + ' PID=' + $b.ProcessId + ' ANGLE=' + $angle + ' -> ' + $mode)
  }
}
Add-Line ''
Add-Line 'Expected after repair:'
Add-Line '  nvidia-smi lists the dedicated GPU, and Vulkan lists Intel/NVIDIA hardware.'
Add-Line '  Browser GPU process should NOT contain warp/swiftshader.'
Add-Line '  App: SCENE -> quality -> GPU row should show the hardware renderer.'
Add-Line '=============================================='

$report = Join-Path $PSScriptRoot 'gpu-report.txt'
$lines | Set-Content -LiteralPath $report -Encoding UTF8
Write-Host ''
Write-Host ('Report saved to: ' + $report)
