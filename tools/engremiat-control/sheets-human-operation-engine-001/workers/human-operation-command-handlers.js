'use strict';
function createOperationHandlers(workers) {
  if (!workers || typeof workers !== 'object' || Array.isArray(workers)) throw new Error('OPERATION_WORKERS_REQUIRED');
  if (typeof workers.queue !== 'function') throw new Error('QUEUE_WORKER_REQUIRED');
  if (typeof workers.review !== 'function') throw new Error('REVIEW_WORKER_REQUIRED');
  if (typeof workers.config !== 'function') throw new Error('CONFIG_WORKER_REQUIRED');
  return Object.freeze({
    QUEUE: async function (payload, context) { return workers.queue({ payload: payload, context: context || {} }); },
    REVIEW: async function (payload, context) { return workers.review({ payload: payload, context: context || {} }); },
    CONFIG: async function (payload, context) { return workers.config({ payload: payload, context: context || {} }); }
  });
}
module.exports = { createOperationHandlers };
