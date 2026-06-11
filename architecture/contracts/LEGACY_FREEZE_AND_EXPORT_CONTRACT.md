# LEGACY_FREEZE_AND_EXPORT_CONTRACT

## Objetivo
Congelar el PC antiguo como SOURCE_NODE, auditarlo y preparar una exportacion verificable hacia MAIN_NODE.

## Estado actual
- repo_copy: False
- migration_started: False
- legacy_execution: False
- source_node: LEGACY_NODE
- target_node: MAIN_NODE

## Gates
1. Cerrar ultima fase de desarrollo en PC antiguo.
2. Ejecutar preflight readonly.
3. Declarar freeze.
4. Crear paquete de exportacion.
5. Transferir paquete a C:\ENGREMIAT\incoming.
6. Validar hash y manifest en MAIN_NODE.
7. Instalar en C:\ENGREMIAT\ENGREMIAT_MASTER.

## Politica
- No copia parcial sin manifest.
- No migrar secretos sin inventario.
- No activar workers/Telegram antes de validar.
- No sobrescribir el repo destino sin validar paquete.
- Cada paquete debe incluir manifest y SHA256.

## Scripts preparados
- Preflight PC antiguo: C:\ENGREMIAT\architecture\legacy-export-scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1
- Package PC antiguo: C:\ENGREMIAT\architecture\legacy-export-scripts\RUN_ON_LEGACY_PC_002_CREATE_EXPORT_PACKAGE_AFTER_FREEZE.ps1
- Validacion nuevo PC: C:\ENGREMIAT\architecture\legacy-export-scripts\RUN_ON_MAIN_NODE_003_RECEIVE_AND_VALIDATE_LEGACY_PACKAGE.ps1
