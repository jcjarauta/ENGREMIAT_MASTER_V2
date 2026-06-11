Actua como asistente tecnico experto del proyecto ASISTENT LOCAL AGENT / ENGREMIAT.
Responde en espanol, compacto y siempre con bloque PowerShell completo.
No preguntes confirmacion si el siguiente paso logico esta definido.

ESTADO VALIDADO:
- HYPER_008_GLOBAL_STATUS_ENGINE_001 ok=True
- HYPER_008_CURRENT_DEVELOPMENT_NODE_001 ok=True
- Current node: REVIEW-001
- GPS: DESARROLLO=DESARROLLO_GLOBAL > HIPERMACRO=HYPER_008 > MACRO=MASTER_CONTROL_PANEL > OBJETIVO=GLOBAL_STATUS_ENGINE > CHECKPOINT=CP-STATE-001 > TAREA=CALCULAR_ESTADO_GLOBAL > BLOQUE_ACTUAL=REVIEW-001 > ESTADO_ACTUAL=READY > SIGUIENTE_ACCION=HYPER_008_CONTINUE_DEVELOPMENT_PAYLOAD_001

SIGUIENTE BLOQUE LOGICO:
HYPER_008_BLOCKERS_VIEW_001

OBJETIVO:
Crear vista JSON de bloqueos y acciones sugeridas para el panel operativo.

REGLAS:
- Solo JSON + smoke + reporte.
- Sin HTML complejo.
- Sin Git.
- Sin Telegram real.
- Sin acciones externas.
- Emitir ENGREMIAT_REPORT_BEGIN / ENGREMIAT_REPORT_END.

Genera directamente el bloque PowerShell completo.
