param([string]$VcpkgRoot = "$env:RUNNER_TEMP/reeldeck-vcpkg")
$ErrorActionPreference = 'Stop'
$commit = 'eb2d3a3279fd019cb7733072d86900d0ad2a1aef'
if (!$env:RUNNER_TEMP -and !$PSBoundParameters.ContainsKey('VcpkgRoot')) {
  $VcpkgRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'reeldeck-vcpkg'
}
if (!(Test-Path "$VcpkgRoot/.git")) {
  git clone https://github.com/microsoft/vcpkg.git $VcpkgRoot
  if ($LASTEXITCODE) { throw 'vcpkg clone failed' }
}
git -C $VcpkgRoot checkout --detach $commit
if ($LASTEXITCODE) { throw 'vcpkg checkout failed' }
& "$VcpkgRoot/bootstrap-vcpkg.bat" -disableMetrics
if ($LASTEXITCODE) { throw 'vcpkg bootstrap failed' }
& "$VcpkgRoot/vcpkg.exe" install 'angle:arm64-windows' --overlay-triplets="$PSScriptRoot/vcpkg-triplets" --disable-metrics
if ($LASTEXITCODE) { throw 'ANGLE ARM64 build failed' }
$env:REELDECK_ANGLE_DIR = "$VcpkgRoot/installed/arm64-windows"
if ($env:GITHUB_ENV) {
  "REELDECK_ANGLE_DIR=$env:REELDECK_ANGLE_DIR" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
Write-Output "ANGLE ARM64: $env:REELDECK_ANGLE_DIR"
