'use strict';
const READY_ACTIONS = new Set(['QUEUE', 'REVIEW', 'CONFIG']);
async function planThreeActionOperation(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw new Error('THREE_ACTION_INPUT_REQUIRED');
  if (input.dryRun !== true) throw new Error('DRY_RUN_REQUIRED');
  const action = String(input.action || '').trim().toUpperCase();
  if (!READY_ACTIONS.has(action)) throw new Error('THREE_ACTION_INVALID_' + action);
  const bindings = Object.freeze({ QUEUE: 'runQueueWorker', REVIEW: 'runReviewWorker', CONFIG: 'executeConfigUpdate' });
  return Object.freeze({ ok: true, dryRun: true, action: action, binding: bindings[action], executionPlanned: true, workerExecuted: false, googleApiCall: false, realSheetWrite: false });
}
module.exports = { READY_ACTIONS, planThreeActionOperation };
