# ENGREMIAT · Arquitectura 3 nodos v1

## Objetivo
Construir la primera arquitectura descentralizada replicable de ENGREMIAT.

## Nodos

### 1. MAIN_NODE · Nuevo PC
- Rol: coordinacion, desarrollo principal, workers, IA local, dashboards.
- Estado: preparado, sin repositorio migrado.
- Raiz: C:\ENGREMIAT
- Repo futuro: C:\ENGREMIAT\ENGREMIAT_MASTER

### 2. LEGACY_NODE · PC antiguo
- Rol: fuente actual hasta cerrar la ultima fase de desarrollo.
- Repo actual esperado: C:\Users\sacan\Desktop\ENGREMIAT_MASTER
- Despues de migrar: nodo secundario, historico o respaldo operativo.

### 3. BACKUP_NODE · Raspberry / disco 4TB
- Rol: backup frio, paquetes, evidencias y recuperacion.
- No ejecuta desarrollo principal.

## Principio replicable
Cada nueva maquina debe incorporarse con contrato, manifiesto, manual, carpeta raiz y politica de sincronizacion.
