# ENGREMIAT_PROMPTER · WORKER HANDOFF SIMULATION · PHASE 110G

MODO:
Simulación local de handoff. No ejecutar worker real.

OBJETIVO:
Preparar un paquete local para que un worker revise la financiación a la inversa de productos digitales dentro de Engremiat.

CONTEXTO:
ENGREMIAT_PROMPTER should structure tasks before external or local workers execute anything.

REGLAS:
- No ejecutar codigo del worker.
- No llamar IA real ni Ollama dentro de este test.
- No llamar APIs externas.
- No usar navegador, CDP, clipboard, Gmail ni Google Sheets.
- No ejecutar operador ni worker real.
- No integrar cambios sin gate humano.
- Mantener integration_allowed_now=false.
- Mantener worker_real_execution_allowed=false.
- Devolver contrato de salida verificable.
- Crear evidencia local parseable.

CONTRATO:
return_contract_path=
C:\Users\sacan\Desktop\ENGREMIAT_MASTER\tools\engremiat-control\automation-tests\phase-109g-prompter-package-builder-dry-run\package\return_contract_109g.json

ESTADO:
- delegation_allowed_now=False
- integration_allowed_now=False
- human_review_required=True

INSTRUCCIÓN:
Preparar solo una entrada simulada para worker. No ejecutar IA, Ollama, operador ni acciones externas.
