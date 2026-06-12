'use strict';
const { runQueueWorker } = require('./human-operation-queue-worker');
const { runReviewWorker } = require('./human-operation-review-worker');
const { executeConfigUpdate } = require('./human-operation-config-update-executor');
const { createRealBindingAdapters } = require('./human-operation-real-binding-adapters');
const { createOperationCommandEngine } = require('./human-operation-command-engine');
function createThreeActionBinding(options) {
  const input = options || {};
  const queueAdapter = input.queueAdapter;
  const reviewAdapter = input.reviewAdapter;
  const configContext = input.configContext || {};
  const queue = async function (operation) { return runQueueWorker({ payload: operation.payload, adapter: queueAdapter }); };
  const review = async function (operation) { return runReviewWorker({ payload: operation.payload, adapter: reviewAdapter }); };
  const config = async function (operation) { return executeConfigUpdate(configContext.sheets, configContext.spreadsheetId, configContext.sheetName, operation.payload); };
  const workers = createRealBindingAdapters({ queue: queue, review: review, config: config });
  const engine = createOperationCommandEngine(workers);
  return Object.freeze({ engine: engine, bindings: Object.freeze({ QUEUE: 'runQueueWorker', REVIEW: 'runReviewWorker', CONFIG: 'executeConfigUpdate' }) });
}
module.exports = { createThreeActionBinding };
