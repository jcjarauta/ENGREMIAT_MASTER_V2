# NEXT ACTION WHEN OLD PC DEVELOPMENT CLOSES

## Condicion de entrada
La ultima fase de desarrollo en el PC antiguo esta cerrada.

## Accion 1 · Transferir kit
Copiar al PC antiguo:

`	ext
C:\ENGREMIAT\packages\migration\ENGREMIAT_LEGACY_HANDOFF_KIT_20260611-181452.zip
`",
",

Ubicarlo por ejemplo en:

`	ext
C:\Users\sacan\Desktop\ENGREMIAT_HANDOFF_KIT
`",
",


`powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1
`",
",

Pegar STATUS_FINAL_PARA_PEGAR en ChatGPT.

## No hacer todavia
- No ejecutar package 002 sin revision.
- No copiar repo a mano.
- No migrar secretos.
- No activar workers.
