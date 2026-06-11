# ENGREMIAT MAIN NODE MANIFEST

phase=NEW_PC_NORMALIZATION_007_CREATE_MAIN_NODE_FOLDER_STRUCTURE_SAFE
decision=MAIN_NODE_FOLDER_STRUCTURE_CREATED_REPO_NOT_MIGRATED

## Estado
- role: MAIN_NODE
- computer: DESKTOP-PVRVE56
- main_root: C:\ENGREMIAT
- repo_dir: C:\ENGREMIAT\ENGREMIAT_MASTER
- repo_copy: False
- migration_started: False
- docker_deferred: True

## Carpetas
- C:\ENGREMIAT
- C:\ENGREMIAT\ENGREMIAT_MASTER
- C:\ENGREMIAT\data
- C:\ENGREMIAT\backups
- C:\ENGREMIAT\packages
- C:\ENGREMIAT\nodes
- C:\ENGREMIAT\logs
- C:\ENGREMIAT\temp
- C:\ENGREMIAT\incoming
- C:\ENGREMIAT\outgoing
- C:\ENGREMIAT\data\context
- C:\ENGREMIAT\data\snapshots
- C:\ENGREMIAT\data\sheets
- C:\ENGREMIAT\data\queues
- C:\ENGREMIAT\backups\legacy-pc
- C:\ENGREMIAT\packages\clean-core
- C:\ENGREMIAT\packages\exports
- C:\ENGREMIAT\nodes\main
- C:\ENGREMIAT\nodes\legacy
- C:\ENGREMIAT\nodes\backup
- C:\ENGREMIAT\nodes\ai-local
- C:\ENGREMIAT\logs\operator
- C:\ENGREMIAT\logs\migration
- C:\ENGREMIAT\logs\benchmarks

## Politica
- No copiar el repositorio hasta cerrar la etapa actual en el PC antiguo.
- No activar Telegram real ni workers reales en este PC todavia.
- No migrar secretos/tokens hasta tener inventario y backup.
- Usar C:\ENGREMIAT como raiz ordenada para evitar mezclar pruebas con repositorio real.

## Siguiente
Preparar plan readonly de exportacion/migracion desde PC antiguo.
