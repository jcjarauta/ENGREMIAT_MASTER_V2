# ENGREMIAT LEGACY HANDOFF KIT

## Objetivo
Este kit se lleva al PC antiguo para preparar la migracion hacia el nuevo MAIN_NODE sin improvisar.

## Uso en PC antiguo
1. Copiar esta carpeta o ZIP al PC antiguo.
2. Abrir PowerShell dentro de la carpeta del kit.
3. Ejecutar primero:
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1
4. Pegar el resultado en ChatGPT.
5. Solo si el estado es correcto y el desarrollo esta cerrado, ejecutar el script 002.

## Importante
No ejecutar script 002 si hay cambios sin cerrar en Git.
No copiar carpetas a mano.
No migrar secretos sin inventario.
