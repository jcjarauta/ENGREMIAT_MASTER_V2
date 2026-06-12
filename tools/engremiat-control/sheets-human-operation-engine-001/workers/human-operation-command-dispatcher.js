'use strict';
const { validateOperationCommand } = require('./human-operation-command-validator');
async function dispatchOperationCommand(registry, command, context) {
  if (!registry || typeof registry !== 'object') throw new Error('COMMAND_REGISTRY_REQUIRED');
  const validated = validateOperationCommand(command);
  const handler = registry[validated.action];
  if (typeof handler !== 'function') throw new Error('COMMAND_HANDLER_NOT_FOUND_' + validated.action);
  return handler(validated.payload, context || {});
}
module.exports = { dispatchOperationCommand };
