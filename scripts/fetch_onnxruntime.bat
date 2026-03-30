@echo off
REM onnxruntime 1.24.4 바이너리를 third_party\ 에 다운로드합니다.
setlocal

set VERSION=1.24.4
set PKG=onnxruntime-win-x64-%VERSION%
set URL=https://github.com/microsoft/onnxruntime/releases/download/v%VERSION%/%PKG%.zip
set DIR=%~dp0..\third_party

if not exist "%DIR%" mkdir "%DIR%"

if exist "%DIR%\%PKG%" (
    echo 이미 존재합니다: %DIR%\%PKG%
    exit /b 0
)

echo 다운로드 중: %URL%
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%DIR%\%PKG%.zip'"
powershell -Command "Expand-Archive -Path '%DIR%\%PKG%.zip' -DestinationPath '%DIR%'"
del "%DIR%\%PKG%.zip"
echo 완료: %DIR%\%PKG%
