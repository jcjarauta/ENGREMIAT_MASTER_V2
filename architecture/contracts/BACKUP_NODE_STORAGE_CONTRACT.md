# BACKUP_NODE_STORAGE_CONTRACT

## Rol
BACKUP_NODE guarda paquetes verificados, evidencias, hashes y snapshots recuperables.

## Estado actual
- status: PLANNED
- backup_execution_now: False
- real_backup_root: pendiente de confirmar

## Permitido
- Guardar paquetes verificados.
- Guardar manifest y SHA256.
- Guardar evidencias de migracion.
- Guardar snapshots de releases.
- Restaurar solo a carpeta temporal y con autorizacion.

## Bloqueado
- No desarrollo principal.
- No workers reales.
- No Telegram real.
- No secretos sin inventario/cifrado.
- No sobrescribir paquetes verificados sin nueva version.
- No mutar repositorio.

## Gate de activacion
READONLY_PREFLIGHT_REQUIRED
