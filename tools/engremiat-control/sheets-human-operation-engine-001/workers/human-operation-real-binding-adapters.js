'use strict';
function createDeferredWorker(action, candidateFile) {
  return async function () {
    const error = new Error(action + '_REAL_EXPORT_NOT_BOUND');
    error.code = action + '_REAL_EXPORT_NOT_BOUND';
    error.candidateFile = candidateFile;
    throw error;
  };
}
function createRealBindingAdapters(bindings) {
  const input = bindings || {};
  const queue = typeof input.queue === 'function' ? input.queue : createDeferredWorker('QUEUE', input.queueCandidate || 'UNKNOWN');
  const review = typeof input.review === 'function' ? input.review : createDeferredWorker('REVIEW', input.reviewCandidate || 'UNKNOWN');
  if (typeof input.config !== 'function') throw new Error('CONFIG_REAL_BINDING_REQUIRED');
  return Object.freeze({ queue: queue, review: review, config: input.config });
}
module.exports = { createDeferredWorker, createRealBindingAdapters };
