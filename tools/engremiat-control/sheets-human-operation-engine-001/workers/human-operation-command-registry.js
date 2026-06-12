'use strict';
const ACTIONS = Object.freeze(['QUEUE', 'REVIEW', 'CONFIG']);
function createCommandRegistry(handlers) {
  if (!handlers || typeof handlers !== 'object' || Array.isArray(handlers)) throw new Error('COMMAND_HANDLERS_REQUIRED');
  const registry = {};
  for (const action of ACTIONS) {
    const handler = handlers[action];
    if (typeof handler !== 'function') throw new Error('COMMAND_HANDLER_REQUIRED_' + action);
    registry[action] = handler;
  }
  return Object.freeze(registry);
}
module.exports = { ACTIONS, createCommandRegistry };
