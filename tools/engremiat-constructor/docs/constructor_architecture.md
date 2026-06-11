# Arquitectura inicial de ENGREMIAT_CONSTRUCTOR

## Rol dentro de Engremiat

CONTROL detecta y decide.
PROMPTER disena y redacta.
CONSTRUCTOR crea y estructura.
MASTER OPERATOR ejecuta y valida.
WORKERS producen cuando esten autorizados.
CONTROL vuelve a observar, priorizar y comercializar.

## Responsabilidad del Constructor

Convertir una necesidad validada en un proyecto local trazable:

- estructura de carpetas
- contrato de proyecto
- documentacion minima
- ficha comercial
- ficha de financiacion
- estado para Control
- prompts para Prompter/workers
- reportes de evidencia

## Decisiones futuras

- BUILD_NEW_PROJECT
- ADAPT_EXISTING_PROJECT
- CREATE_PROPOSAL_ONLY
- CREATE_DEMO_ONLY
- ADD_TO_BACKLOG
- DISCARD
- HUMAN_REVIEW_REQUIRED

## Estados futuros del proyecto

- DETECTED
- NORMALIZED
- SCORED
- WAITING_HUMAN_DECISION
- APPROVED_FOR_BUILD
- PROJECT_CREATED
- BOOTSTRAPPED
- PHASE_001_READY
- IN_DEVELOPMENT
- DEMO_READY
- PROPOSAL_READY
- VALIDATED
- COMMERCIALIZABLE
- ARCHIVED
