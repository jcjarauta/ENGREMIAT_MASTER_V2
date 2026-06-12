'use strict';
const { validateConfigPayload } = require('./human-operation-config-payload-validator');
const { executeConfigUpdate } = require('./human-operation-config-update-executor');
async function runConfigUpdateWorker(input) {
  if (!input || typeof input !== 'object') throw new Error('WORKER_INPUT_REQUIRED');
  const validation = validateConfigPayload(input.payload);
  const result = await executeConfigUpdate(input.sheets, input.spreadsheetId, input.sheetName, input.payload);
  return { ok: true, validation: validation, update: result };
}
module.exports = { runConfigUpdateWorker };
