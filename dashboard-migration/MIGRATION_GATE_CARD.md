# ENGREMIAT · Migration Gate Card

## Estado
- readiness: 100
- gate: READY_WAITING_FOR_OLD_PC_DEVELOPMENT_CLOSE
- NEW_PC: MAIN_NODE preparado
- OLD_PC: SOURCE_NODE hasta freeze
- BACKUP_NODE: planificado con contrato

## Kit listo
- ZIP: C:\ENGREMIAT\packages\migration\ENGREMIAT_LEGACY_HANDOFF_KIT_20260611-181452.zip
- SHA256: 01F013F6887E3937E86CA782017F2F5503434E54F88E21E7840F235B4196EB8D
- Carpeta: C:\ENGREMIAT\packages\migration\ENGREMIAT_LEGACY_HANDOFF_KIT_20260611-181452

## Cuando cierres el desarrollo en el PC antiguo
1. Copiar el ZIP al PC antiguo.
2. Descomprimirlo en C:\Users\sacan\Desktop\ENGREMIAT_HANDOFF_KIT.
3. Ejecutar launchers\01_RUN_PREFLIGHT_READONLY_ON_OLD_PC.cmd.
4. Pegar STATUS_FINAL_PARA_PEGAR en ChatGPT.

## Bloqueado hasta revisar preflight
- No ejecutar package 002.
- No copiar repositorio a mano.
- No migrar secretos.
- No activar workers.
