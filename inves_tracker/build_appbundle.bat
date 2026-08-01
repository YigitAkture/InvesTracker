@echo off
setlocal enabledelayedexpansion

set PUBSPEC=pubspec.yaml

:: ── 1. Validate pubspec.yaml exists ─────────────────────────────────────────
if not exist "%PUBSPEC%" (
    echo [ERROR] %PUBSPEC% not found. Run this script from your Flutter project root.
    exit /b 1
)

:: ── 2. Read current version ──────────────────────────────────────────────────
set CURRENT_VERSION=
for /f "tokens=2 delims= " %%A in ('findstr /r "^version: " %PUBSPEC%') do (
    set CURRENT_VERSION=%%A
)

if "%CURRENT_VERSION%"=="" (
    echo [ERROR] Could not find 'version:' in %PUBSPEC%.
    exit /b 1
)

:: ── 3. Build the appbundle ────────────────────────────────────────────────────
echo [BUILD] Starting Flutter build...
flutter build appbundle --obfuscate --split-debug-info=debug_info --release

echo.
echo [DONE] Build complete! Version: %CURRENT_VERSION%