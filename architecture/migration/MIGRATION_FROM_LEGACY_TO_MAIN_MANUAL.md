# Manual de migracion · Legacy a Main

## Etapas
1. Cerrar desarrollo actual en PC antiguo.
2. Declarar freeze temporal.
3. Ejecutar preflight readonly en LEGACY_NODE.
4. Generar manifest de repo.
5. Crear paquete o decidir git clone.
6. Transferir a C:\ENGREMIAT\incoming.
7. Validar hash y estructura en MAIN_NODE.
8. Instalar en C:\ENGREMIAT\ENGREMIAT_MASTER.
9. Ejecutar smoke tests.
10. Cambiar rol: nuevo PC pasa a MAIN activo; antiguo pasa a LEGACY.

## No hacer
- No copiar a mano carpetas sueltas.
- No activar workers antes de validar.
- No migrar secretos sin inventario.
