# OLD_TO_NEW_PC_HANDOFF_PROTOCOL

## Estados
- OLD_PC: SOURCE_NODE activo hasta freeze.
- NEW_PC: MAIN_NODE preparado.
- BACKUP_NODE: planificado.

## Handoff correcto
1. OLD_PC genera manifest.
2. OLD_PC genera paquete.
3. Humano transfiere paquete.
4. NEW_PC valida paquete.
5. NEW_PC instala solo si pasa.
6. OLD_PC pasa a LEGACY_NODE.

## Handoff incorrecto
- Copiar carpetas sueltas.
- Saltar hashes.
- Saltar manifest.
- Mezclar versiones.
- Activar workers antes de smoke tests.
