# Manual · Freeze y exportacion desde PC antiguo

## Fase 1 · Cierre
Terminar la ultima fase de desarrollo en el PC antiguo y dejar un estado estable.

## Fase 2 · Preflight readonly
Ejecutar RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1 en el PC antiguo.

## Fase 3 · Freeze
Si el preflight es correcto, declarar freeze: desde ese momento no se hacen cambios nuevos sin log.

## Fase 4 · Paquete
Ejecutar RUN_ON_LEGACY_PC_002_CREATE_EXPORT_PACKAGE_AFTER_FREEZE.ps1 para crear paquete con manifest y hash.

## Fase 5 · Recepcion
Copiar el paquete a C:\ENGREMIAT\incoming en el nuevo PC.

## Fase 6 · Validacion
Ejecutar RUN_ON_MAIN_NODE_003_RECEIVE_AND_VALIDATE_LEGACY_PACKAGE.ps1.

## Regla de oro
No mover el repositorio real a MAIN_NODE hasta que el paquete pase hash, manifest y estructura.
