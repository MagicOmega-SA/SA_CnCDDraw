[CmdletBinding()]
param(
    [string]$ToolchainBin
)

$ErrorActionPreference = 'Stop'

$sourceDir = Join-Path $PSScriptRoot 'vendor\cnc-ddraw-7.1.0.0'
$distDir = Join-Path $PSScriptRoot 'dist'
$configFile = Join-Path $PSScriptRoot 'config\cnc-ddraw.ini'
if (-not $ToolchainBin) {
    $ToolchainBin = Split-Path -Parent (Get-Command i686-w64-mingw32-gcc.exe -CommandType Application).Source
}
$ToolchainBin = (Resolve-Path -LiteralPath $ToolchainBin).Path
$gcc = Join-Path $ToolchainBin 'i686-w64-mingw32-gcc.exe'
$windres = Join-Path $ToolchainBin 'windres.exe'

$buildDir = Join-Path ([IO.Path]::GetTempPath()) ('SA_CnCDDraw-' + [guid]::NewGuid().ToString('N'))
$metadataDir = Join-Path $buildDir 'inc'
$gitHeader = Join-Path $metadataDir 'git.h'
$resource = Join-Path $buildDir 'res.o'
$regularDll = Join-Path $buildDir 'regular.dll'
$noLogDll = Join-Path $buildDir 'no-log.dll'
$originalPath = $env:Path

Push-Location -LiteralPath $sourceDir
try {
    $env:Path = "$ToolchainBin;$originalPath"
    New-Item -ItemType Directory -Path $metadataDir | Out-Null
    @(
        '#define GIT_COMMIT "541b5de"'
        '#define GIT_BRANCH "v7.1.0.0"'
    ) | Set-Content -LiteralPath $gitHeader -Encoding ASCII

    & $windres -J rc -I $buildDir -i res.rc -o $resource
    if ($LASTEXITCODE -ne 0) {
        throw "windres failed with exit code $LASTEXITCODE."
    }

    $sources = Get-ChildItem -LiteralPath src -File -Filter '*.c' -Recurse |
        Sort-Object FullName |
        ForEach-Object { $_.FullName.Substring($sourceDir.Length + 1) }
    $options = @('-O2', '-Wall', '-std=c99', '-Iinc', "-I$metadataDir",
        '-Wl,--enable-stdcall-fixup', '-s', '-static', '-shared')
    $libraries = @('-lgdi32', '-lwinmm', '-lole32', '-lmsimg32', '-lavifil32', '-luuid')

    # The upstream mini diagnostic configuration uses _DEBUG without _DEBUG_X.
    & $gcc @options -D_DEBUG -o $regularDll @sources $resource exports.def @libraries
    if ($LASTEXITCODE -ne 0) {
        throw "Regular build failed with exit code $LASTEXITCODE."
    }
    & $gcc @options -o $noLogDll @sources $resource exports.def @libraries
    if ($LASTEXITCODE -ne 0) {
        throw "No-log build failed with exit code $LASTEXITCODE."
    }

    foreach ($variant in @('regular', 'no-log')) {
        $packageDir = Join-Path $distDir $variant
        $resources = Join-Path $packageDir 'Resources'
        New-Item -ItemType Directory -Path $resources -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $buildDir "$variant.dll") -Destination (Join-Path $resources 'cnc-ddraw.dll') -Force
        Copy-Item -LiteralPath $configFile -Destination $resources -Force
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LICENSE'), (Join-Path $PSScriptRoot 'THIRD-PARTY-NOTICES.txt') -Destination $packageDir -Force
    }
}
finally {
    $env:Path = $originalPath
    Pop-Location
    # These files belong to this invocation and have no use after packaging.
    foreach ($item in @($regularDll, $noLogDll, $resource, $gitHeader, $metadataDir, $buildDir)) {
        if (Test-Path -LiteralPath $item) {
            Remove-Item -LiteralPath $item
        }
    }
}
