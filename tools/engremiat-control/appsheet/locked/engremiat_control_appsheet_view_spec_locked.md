# ENGREMIAT CONTROL - AppSheet view spec locked

## Objetivo
Definir la interfaz humana minima para Google Sheets/AppSheet sin activar automatizacion real.

## Vistas
- Panel global: Ver modo operativo, automatizacion permitida y siguiente accion recomendada.
- Proyectos: Consultar proyectos activos y su siguiente paso.
- Acciones pendientes: Ver acciones no cerradas.
- Validacion humana: Revisar decisiones pendientes del humano.
- Bloqueos: Ver acciones bloqueadas y razon operacional.
- Eventos recientes: Auditoria rapida del latir inicial de engremiat_control.
- Settings: Consultar configuracion operativa inicial.

## Acciones humanas iniciales
- Crear proyecto: allowed_now=True, risk_level=low
- Crear accion: allowed_now=True, risk_level=low
- Validar decision: allowed_now=True, risk_level=medium
- Registrar evento manual: allowed_now=True, risk_level=low
- Ejecutar automatizacion real: allowed_now=False, risk_level=high

## Navegacion principal
- Panel global
- Proyectos
- Acciones pendientes
- Validacion humana
- Bloqueos
- Eventos recientes

## Seguridad
- automation_allowed=False
- real_appsheet_connection_done=False
- telegram_connection_done=False
- chatgpt_automation_done=False
- hardware_actions_done=False

## Siguiente accion recomendada
CREATE_ENGREMIAT_CONTROL_HUMAN_FLOW_TEST_LOCKED
