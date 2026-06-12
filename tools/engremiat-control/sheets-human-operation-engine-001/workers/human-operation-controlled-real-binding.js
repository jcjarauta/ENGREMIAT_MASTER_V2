'use strict';
const { createRealBindingAdapters } = require('./human-operation-real-binding-adapters');
const { createOperationCommandEngine } = require('./human-operation-command-engine');
const configModule = require(
"C:/ENGREMIAT_REPO_CLEAN/ENGREMIAT_MASTER_V2/tools/engremiat-control/sheets-human-operation-engine-001/workers/human-operation-config-update-executor.js"
);
function createControlledRealBinding(options) {
  const input = options || {};
  const configExportName = input.configExportName || 
"executeConfigUpdate"
;
  const configWorker = configModule[configExportName];
  if (typeof configWorker !== 'function') throw new Error('CONFIG_REAL_EXPORT_NOT_FUNCTION_' + configExportName);
  const workers = createRealBindingAdapters({ queueCandidate: input.queueCandidate || 'UNBOUND_QUEUE', reviewCandidate: input.reviewCandidate || 'UNBOUND_REVIEW', config: configWorker });
  const engine = createOperationCommandEngine(workers);
  return Object.freeze({ engine: engine, bindings: Object.freeze({ QUEUE: 'DEFERRED_FAIL_CLOSED', REVIEW: 'DEFERRED_FAIL_CLOSED', CONFIG: configExportName }) });
}
module.exports = { createControlledRealBinding };
