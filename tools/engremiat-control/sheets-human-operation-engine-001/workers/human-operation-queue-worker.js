'use strict';
function validateQueueInput(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw new Error('QUEUE_WORKER_INPUT_REQUIRED');
  const payload = input.payload;
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) throw new Error('QUEUE_PAYLOAD_REQUIRED');
  const taskId = String(payload.taskId || payload.task_id || '').trim();
  if (!taskId) throw new Error('QUEUE_TASK_ID_REQUIRED');
  const adapter = input.adapter;
  if (!adapter || typeof adapter.findByTaskId !== 'function' || typeof adapter.append !== 'function') throw new Error('QUEUE_ADAPTER_REQUIRED');
  return { taskId: taskId, payload: payload, adapter: adapter };
}
async function runQueueWorker(input) {
  const valid = validateQueueInput(input);
  const existing = await valid.adapter.findByTaskId(valid.taskId);
  if (existing) {
    const error = new Error('QUEUE_DUPLICATE_BLOCKED');
    error.code = 'QUEUE_DUPLICATE_BLOCKED';
    error.taskId = valid.taskId;
    throw error;
  }
  const row = await valid.adapter.append(valid.payload);
  return Object.freeze({ ok: true, action: 'QUEUE', taskId: valid.taskId, duplicatePolicy: 'BLOCK', appended: true, row: row || null });
}
module.exports = { validateQueueInput, runQueueWorker };
