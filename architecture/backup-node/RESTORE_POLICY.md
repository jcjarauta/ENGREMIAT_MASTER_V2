# RESTORE_POLICY

## Regla
Ningun paquete se restaura directamente sobre el repositorio principal.

## Pasos
1. Validar SHA256.
2. Descomprimir en restore-tests.
3. Comprobar manifest.
4. Ejecutar smoke readonly si aplica.
5. Pedir gate humano.
6. Solo entonces preparar restauracion real.

## Bloqueado
- Overwrite directo.
- Restaurar paquetes sin hash.
- Restaurar paquetes sin manifest.
- Restaurar secretos no inventariados.
