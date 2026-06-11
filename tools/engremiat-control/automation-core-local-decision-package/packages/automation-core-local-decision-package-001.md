# ENGREMIAT Automation Core · Local decision queue package

- type: ENGREMIAT_AUTOMATION_CORE_LOCAL_DECISION_QUEUE_PACKAGE_001
- phase: AUTOMATION_CORE_LOCAL_DECISION_QUEUE_PACKAGE
- ok: True
- generated_at: 2026-06-06T07:46:28.8083922Z
- package_id: automation-core-local-decision-package-001
- package_status: queued_but_not_executable
- queue_target: automation_core_local_stub
- source_contract: tools/engremiat-control/automation-core-local-decision-package/contract/automation_core_local_decision_package_contract.json
- source_control_decision: READY_FOR_NEXT_LOCAL_AUTOMATION
- intent: prepare_next_local_automation_package_for_review
- payload: {"requested_action":"prepare_local_automation_review_gate","recommended_next":"AUTOMATION_CORE_PACKAGE_REVIEW_GATE","execution_mode":"NO_EXECUTION_PACKAGE_ONLY","expected_human_gate":"review_before_any_worker_or_external_action"}
- safety: {"local_only":true,"external_actions_executed":false,"google_api_call_allowed":false,"real_worker_allowed":false,"decision_auto_execution_allowed":false,"worker_execution_allowed":false,"queued_but_not_executable":true,"human_review_required":true}
- next: CREATE_DASHBOARD_CARD_FOR_LOCAL_DECISION_PACKAGE
