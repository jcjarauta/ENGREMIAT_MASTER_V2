# RUN THIS ON OLD PC

## Paso 1 · Preflight readonly
`powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1
`",
",

Pegar STATUS_FINAL_PARA_PEGAR en ChatGPT.

## Paso 3 · Freeze
Solo si el desarrollo esta terminado y Git esta limpio o controlado.

## Paso 4 · Crear paquete
`powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\RUN_ON_LEGACY_PC_002_CREATE_EXPORT_PACKAGE_AFTER_FREEZE.ps1
`",
",

Copiar el ZIP generado al nuevo PC en:
C:\ENGREMIAT\incoming

## Paso 6 · Validar en nuevo PC
Ejecutar el script de recepcion en MAIN_NODE.
