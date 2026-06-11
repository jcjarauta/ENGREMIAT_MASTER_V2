# ENGREMIAT · Manual de incorporacion de nodos v1

## Objetivo
Permitir que cualquier nueva maquina se incorpore al sistema ENGREMIAT siguiendo un contrato replicable.

## Flujo
1. Crear contrato JSON desde node-contract.template.v1.json.
2. Rellenar node_id, machine_name, role y root_path.
3. Definir allowed_actions y blocked_actions.
4. Definir sync_policy, backup_policy y secrets_policy.
5. Ejecutar validate-node-contract.ps1.
6. Solo si pasa, registrar el nodo en engremiat-node-registry.v1.json.

## Regla
Un nodo sin contrato validado no ejecuta acciones reales.

## Estados
- PLANNED: definido pero no preparado.
- PREPARED: carpetas/herramientas listas.
- READONLY_VALIDATED: paso de auditoria readonly superado.
- ACTIVE: puede operar segun contrato.
- SUSPENDED: temporalmente bloqueado.
- LEGACY: historico/secundario.
