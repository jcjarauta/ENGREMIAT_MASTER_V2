# Contrato de proyecto · ENGREMIAT_CONSTRUCTOR

## Funcion

El contrato de proyecto define como nace un proyecto creado por ENGREMIAT_CONSTRUCTOR desde una necesidad normalizada.

## Relacion principal

need.schema.json -> project.schema.json -> bootstrap local -> validacion -> reporte para Control.

## Decisiones permitidas

- BUILD_NEW_PROJECT
- ADAPT_EXISTING_PROJECT
- CREATE_PROPOSAL_ONLY
- CREATE_DEMO_ONLY
- ADD_TO_BACKLOG
- DISCARD
- HUMAN_REVIEW_REQUIRED

## Estados iniciales

- DRAFT
- BOOTSTRAPPED
- PHASE_001_READY
- IN_DEVELOPMENT
- DEMO_READY
- PROPOSAL_READY
- VALIDATED
- COMMERCIALIZABLE
- ARCHIVED

## Archivos

- Schema: C:\Users\sacan\Desktop\ENGREMIAT_MASTER\tools\engremiat-constructor\schemas\project.schema.json
- Ejemplo: C:\Users\sacan\Desktop\ENGREMIAT_MASTER\tools\engremiat-constructor\examples\project-example-001.json
