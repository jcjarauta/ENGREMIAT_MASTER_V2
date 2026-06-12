'use strict';
const ALLOWED_DECISIONS = new Set(['APPROVE', 'REJECT', 'REQUEST_MORE']);
function validateReviewInput(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw new Error('REVIEW_WORKER_INPUT_REQUIRED');
  const payload = input.payload;
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) throw new Error('REVIEW_PAYLOAD_REQUIRED');
  const taskId = String(payload.taskId || payload.task_id || '').trim();
  if (!taskId) throw new Error('REVIEW_TASK_ID_REQUIRED');
  const decision = String(payload.decision || '').trim().toUpperCase();
  if (!ALLOWED_DECISIONS.has(decision)) throw new Error('REVIEW_DECISION_INVALID');
  const adapter = input.adapter;
  if (!adapter || typeof adapter.updateQueue !== 'function' || typeof adapter.appendHistory !== 'function') throw new Error('REVIEW_ADAPTER_REQUIRED');
  return { taskId: taskId, decision: decision, payload: payload, adapter: adapter };
}
async function runReviewWorker(input) {
  const valid = validateReviewInput(input);
  const queueResult = await valid.adapter.updateQueue(valid.taskId, valid.decision, valid.payload);
  const historyResult = await valid.adapter.appendHistory(valid.taskId, valid.decision, valid.payload);
  return Object.freeze({ ok: true, action: 'REVIEW', taskId: valid.taskId, decision: valid.decision, queueUpdated: true, historyAppended: true, queue: queueResult || null, history: historyResult || null });
}
module.exports = { ALLOWED_DECISIONS, validateReviewInput, runReviewWorker };
