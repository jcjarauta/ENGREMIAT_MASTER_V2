# HANDOFF_KIT_MANIFEST

phase=NEW_PC_DECENTRALIZED_ARCHITECTURE_005S_BUILD_LEGACY_HANDOFF_PORTABLE_KIT_STABLE
decision=LEGACY_HANDOFF_PORTABLE_KIT_READY
kit_root=C:\ENGREMIAT\packages\migration\ENGREMIAT_LEGACY_HANDOFF_KIT_20260611-181452
zip_path=C:\ENGREMIAT\packages\migration\ENGREMIAT_LEGACY_HANDOFF_KIT_20260611-181452.zip

## Contenido
- scripts: preflight, package, receive validate.
- contracts: freeze/export contract.
- docs: manuales de handoff.
- manifests: manifest del kit.

## Primer comando en PC antiguo
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\RUN_ON_LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY.ps1
