# ENGREMIAT Apps Script Bridge Option

Este directorio contiene una opcion futura para operar desde Google Sheets sin usar Google API local desde el PC.

La independencia se mantiene porque:

- ENGREMIAT sigue usando paquetes locales, inbox, outbox, receipts y ledger.
- Apps Script es solo una capa opcional de interfaz dentro del propio Sheet.
- No se llama Google API desde Node/PowerShell local.
- No se tocan tabs finales: solo STG_*.

Archivo principal:

- drafts/engremiat_stg_bridge_menu.draft.gs

Estado:

- Draft only.
- No ejecutado.
- Requiere instalacion humana manual si se decide probarlo.
