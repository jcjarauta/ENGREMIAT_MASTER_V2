# Manual BACKUP_NODE · ENGREMIAT

## Objetivo
Convertir Raspberry/disco 4TB en nodo de respaldo y recuperacion replicable.

## Flujo seguro
1. Confirmar ruta real del backup.
2. Ejecutar preflight readonly.
3. Crear estructura de carpetas.
4. Copiar solo paquetes verificados.
5. Crear SHA256SUMS.txt.
6. Validar restauracion en temporal.
7. Registrar paquete en inventario.

## Reglas
- Primero manifest, luego copia.
- Primero hash, luego confianza.
- Restaurar siempre a temp antes de tocar MAIN_NODE.
- No guardar secretos sin politica especifica.

## Carpetas recomendadas
- packages
- manifests
- hashes
- evidence
- releases
- restore-tests
- incoming
- quarantine
