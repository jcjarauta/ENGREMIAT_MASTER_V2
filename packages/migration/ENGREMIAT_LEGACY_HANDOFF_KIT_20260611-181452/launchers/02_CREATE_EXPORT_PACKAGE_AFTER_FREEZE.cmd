@echo off
cd /d "%~dp0\.."
echo ENGREMIAT CREATE EXPORT PACKAGE AFTER FREEZE
echo.
echo IMPORTANTE: ejecutar solo si ChatGPT valida el preflight y el desarrollo antiguo esta cerrado.
echo Si Git tiene cambios sin cerrar, el script debe bloquearse.
echo.
set /p CONFIRM=Escribe FREEZE para continuar: 
if NOT "%CONFIRM%"=="FREEZE" (
  echo Cancelado.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\RUN_ON_LEGACY_PC_002_CREATE_EXPORT_PACKAGE_AFTER_FREEZE.ps1"
echo.
echo Copia STATUS_FINAL_PARA_PEGAR y pegalo en ChatGPT.
pause
