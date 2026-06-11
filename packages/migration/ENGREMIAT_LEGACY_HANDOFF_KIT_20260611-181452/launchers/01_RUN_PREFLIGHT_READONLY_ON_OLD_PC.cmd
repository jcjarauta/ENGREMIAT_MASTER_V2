@echo off
cd /d "%~dp0\.."
echo ENGREMIAT LEGACY PREFLIGHT READONLY
echo.
echo Este comando NO crea paquete, NO copia repo y NO hace push.
echo Solo audita el estado del repo antiguo.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1"
echo.
echo Copia STATUS_FINAL_PARA_PEGAR y pegalo en ChatGPT.
pause
