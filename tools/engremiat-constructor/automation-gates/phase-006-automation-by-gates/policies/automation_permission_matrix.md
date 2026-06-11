# Automation Permission Matrix

- local_read | allowed_now=True | requires_human=False | risk=low
- local_report_write | allowed_now=True | requires_human=False | risk=low
- local_queue_write | allowed_now=True | requires_human=False | risk=low
- local_simulation | allowed_now=True | requires_human=False | risk=low
- real_control_write | allowed_now=False | requires_human=True | risk=medium
- real_prompter_execution | allowed_now=False | requires_human=True | risk=medium
- external_ai_call | allowed_now=False | requires_human=True | risk=high
- external_api_call | allowed_now=False | requires_human=True | risk=high
- worker_real_execution | allowed_now=False | requires_human=True | risk=high
- remote_repo_creation | allowed_now=False | requires_human=True | risk=high
- customer_contact | allowed_now=False | requires_human=True | risk=high
- browser | allowed_now=False | requires_human=True | risk=high
- clipboard | allowed_now=False | requires_human=True | risk=high
