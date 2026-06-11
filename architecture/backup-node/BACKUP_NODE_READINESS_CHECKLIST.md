# BACKUP_NODE_READINESS_CHECKLIST

## Preparacion
- [ ] Confirmar maquina real: Raspberry/disco 4TB.
- [ ] Confirmar ruta raiz.
- [ ] Ejecutar preflight readonly.
- [ ] Crear estructura de carpetas.
- [ ] Probar escritura de marcador pequeno.
- [ ] Probar lectura.

## Primer paquete
- [ ] Elegir paquete limpio inicial.
- [ ] Copiar a incoming.
- [ ] Calcular SHA256.
- [ ] Crear manifest.
- [ ] Mover de incoming a packages.
- [ ] Probar restore en restore-tests.

## Activacion
- [ ] Registrar BACKUP_NODE como READONLY_VALIDATED.
- [ ] Activar politica de backups manuales.
- [ ] Planificar automatizacion futura.
