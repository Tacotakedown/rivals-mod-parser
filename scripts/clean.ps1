$ErrorActionPreference = "Stop"

if (Test-Path -Path .\bindings\c) {
    Remove-Item -Path .\bindings\c -Recurse -Force
    Write-Host "Removed C bindings directory"
}

if (Test-Path -Path .\build) {
    Remove-Item -Path .\build -Recurse -Force
    Write-Host "Removed build directory"
}

if ((Test-Path -Path .\bindings\c) -or (Test-Path -Path .\build)) {
    throw "Cleanup failed - some directories still exist"
}

Write-Host "Repository cleaned successfully!" -ForegroundColor Green