'use strict';
const { createOperationHandlers } = require('./human-operation-command-handlers');
const { createCommandRegistry } = require('./human-operation-command-registry');
const { dispatchOperationCommand } = require('./human-operation-command-dispatcher');
function createOperationCommandEngine(workers) {
  const handlers = createOperationHandlers(workers);
  const registry = createCommandRegistry(handlers);
  return Object.freeze({ dispatch: async function (command, context) { return dispatchOperationCommand(registry, command, context); } });
}
module.exports = { createOperationCommandEngine };
