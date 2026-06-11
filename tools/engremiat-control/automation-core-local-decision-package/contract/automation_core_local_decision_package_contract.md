# ENGREMIAT CONTROL · Automation Core local decision package contract

- type: ENGREMIAT_CONTROL_AUTOMATION_CORE_LOCAL_DECISION_PACKAGE_CONTRACT_001
- phase: AUTOMATION_CORE_LOCAL_DECISION_QUEUE_PACKAGE
- ok: True
- generated_at: 2026-06-06T07:46:19.9596837Z
- mode: LOCAL_ONLY_QUEUE_PACKAGE_CONTRACT_NO_EXECUTION
- package_contract_ready: True
- package_id: automation-core-local-decision-package-001
- source_decision_final: tools/engremiat-control/reports/control_decision_layer_reevaluation_after_bridge_final.json
- source_decision_engine: tools/engremiat-control/decision-layer/reevaluation-after-bridge/engine-v2/control_decision_layer_reevaluation_engine_v2_output.json
- control_decision: READY_FOR_NEXT_LOCAL_AUTOMATION
- recommended_next: AUTOMATION_CORE_LOCAL_DECISION_QUEUE_PACKAGE
- intent: prepare_next_local_automation_package_for_review
- queue_state: queued_but_not_executable
- execution_allowed: False
- human_review_required: True
- gates: {"local_only":true,"external_actions_executed":false,"google_api_call_allowed":false,"real_worker_allowed":false,"decision_auto_execution_allowed":false,"worker_execution_allowed":false,"browser_used":false,"cdp_used":false,"clipboard_used":false,"webapp_execution_allowed":false}
- recommended_package_review_gate: AUTOMATION_CORE_PACKAGE_REVIEW_GATE
- next: CREATE_AUTOMATION_CORE_LOCAL_DECISION_QUEUE_PACKAGE
