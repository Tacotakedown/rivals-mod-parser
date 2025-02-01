$ErrorActionPreference = "Stop"

$vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-Not (Test-Path $vswherePath)) {
    throw "vswhere.exe not found! Install Visual Studio Build Tools."
}

$vsPath = & $vswherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-Not $vsPath) {
    throw "MSVC Build Tools not found! Ensure you have 'C++ Build Tools' installed."
}

$vcvarsPath = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
if (-Not (Test-Path $vcvarsPath)) {
    throw "vcvars64.bat not found! Ensure you have installed MSVC toolchain."
}

Write-Host "Setting up MSVC Build Tools environment..." -ForegroundColor Cyan
cmd /c """$vcvarsPath"" && set" | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
    }
}

Write-Host "MSVC Build Tools are now configured!" -ForegroundColor Green

New-Item -ItemType Directory -Path .\build -Force | Out-Null

Write-Host "Building Go library..." -ForegroundColor Yellow

$env:CC = "cl"
$env:CXX = "cl"
$env:AR = "lib"
$env:CGO_CFLAGS = "-nologo"

go build -buildmode=c-archive -o .\build\mod_parser.lib .\main.go

if (-not (Test-Path .\build\mod_parser.lib)) {
    throw "Go build failed: missing .lib file"
}
if (-not (Test-Path .\build\mod_parser.h)) {
    throw "Go build failed: missing .h file"
}

Write-Host "Go library built successfully! Generating C library" -ForegroundColor Green

New-Item -ItemType Directory -Path .\bindings\c\bin -Force | Out-Null
New-Item -ItemType Directory -Path .\bindings\c\include\modParser -Force | Out-Null

Copy-Item -Path .\build\mod_parser.lib -Destination .\bindings\c\bin\ -Force
Copy-Item -Path .\build\mod_parser.h -Destination .\bindings\c\include\modParser -Force

if (-not (Test-Path .\bindings\c\bin\mod_parser.lib)) {
    throw "Failed to copy library to C bindings bin directory"
}
if (-not (Test-Path .\bindings\c\include\modParser\mod_parser.h)) {
    throw "Failed to copy header to C bindings include directory"
}

Write-Host "Build artifacts copied to C bindings directory successfully!" -ForegroundColor Green
