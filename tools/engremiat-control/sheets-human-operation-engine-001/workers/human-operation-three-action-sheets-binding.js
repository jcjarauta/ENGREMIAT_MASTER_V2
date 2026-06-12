'use strict';
const { createQueueSheetsAdapter } = require('./human-operation-queue-sheets-adapter');
const { createReviewSheetsAdapter } = require('./human-operation-review-sheets-adapter');
const { createThreeActionBinding } = require('./human-operation-three-action-binding');
const { planThreeActionOperation } = require('./human-operation-three-action-launcher');
function createThreeActionSheetsBinding(options) {
  const input = options || {};
  if (input.dryRun !== true) throw new Error('DRY_RUN_REQUIRED');
  const sheets = input.sheets;
  const spreadsheetId = String(input.spreadsheetId || '').trim();
  if (!spreadsheetId) throw new Error('THREE_ACTION_SPREADSHEET_ID_REQUIRED');
  const queueAdapter = createQueueSheetsAdapter({ sheets: sheets, spreadsheetId: spreadsheetId });
  const reviewAdapter = createReviewSheetsAdapter({ sheets: sheets, spreadsheetId: spreadsheetId });
  const bound = createThreeActionBinding({ queueAdapter: queueAdapter, reviewAdapter: reviewAdapter, configContext: { sheets: sheets, spreadsheetId: spreadsheetId, sheetName: input.configSheetName || 'CONFIG' } });
  return Object.freeze({ engine: bound.engine, bindings: bound.bindings, dryRun: true, realExecutionAllowed: false, plan: async function (action) { return planThreeActionOperation({ dryRun: true, action: action }); } });
}
module.exports = { createThreeActionSheetsBinding };
