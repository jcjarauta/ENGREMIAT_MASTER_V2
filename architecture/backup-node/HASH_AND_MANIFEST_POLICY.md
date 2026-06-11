# HASH_AND_MANIFEST_POLICY

## Cada paquete debe tener
- PACKAGE_MANIFEST.json
- PACKAGE_MANIFEST.md
- SHA256SUMS.txt
- SOURCE_NODE.txt
- RESTORE_INSTRUCTIONS.md

## Politica SHA256
Todo paquete replicable debe tener hash antes de copiarse al BACKUP_NODE.

## Versionado
No se sobrescribe un paquete estable: se crea nueva carpeta con fecha o version.
