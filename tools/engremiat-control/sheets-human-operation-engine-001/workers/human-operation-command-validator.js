'use strict';
const ALLOWED_ACTIONS = new Set(['QUEUE', 'REVIEW', 'CONFIG']);
function validateOperationCommand(command) {
  if (!command || typeof command !== 'object' || Array.isArray(command)) throw new Error('OPERATION_COMMAND_REQUIRED');
  const action = String(command.action || '').trim().toUpperCase();
  if (!ALLOWED_ACTIONS.has(action)) throw new Error('OPERATION_ACTION_INVALID');
  if (!command.payload || typeof command.payload !== 'object' || Array.isArray(command.payload)) throw new Error('OPERATION_PAYLOAD_REQUIRED');
  return { ok: true, action: action, payload: command.payload };
}
module.exports = { ALLOWED_ACTIONS, validateOperationCommand };
