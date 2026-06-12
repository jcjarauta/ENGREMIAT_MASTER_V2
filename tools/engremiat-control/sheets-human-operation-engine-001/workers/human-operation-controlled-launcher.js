'use strict';
const { createControlledRealBinding } = require('./human-operation-controlled-real-binding');
async function runControlledOperation(input) {
  if (!input || typeof input !== 'object') throw new Error('CONTROLLED_OPERATION_INPUT_REQUIRED');
  if (input.dryRun !== true) throw new Error('DRY_RUN_REQUIRED');
  const action = String(input.action || '').trim().toUpperCase();
  if (action !== 'CONFIG') throw new Error('REAL_BINDING_ACTION_NOT_READY_' + action);
  const bound = createControlledRealBinding(input.bindingOptions || {});
  return Object.freeze({ ok: true, dryRun: true, action: action, binding: bound.bindings.CONFIG, executionPlanned: true, workerExecuted: false, googleApiCall: false, realSheetWrite: false });
}
module.exports = { runControlledOperation };
