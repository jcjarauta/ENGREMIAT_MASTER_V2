'use strict';
const { buildConfigUpdateRequest } = require('./human-operation-config-update-request');
async function executeConfigUpdate(sheets, spreadsheetId, sheetName, payload) {
  if (!sheets || !sheets.spreadsheets || !sheets.spreadsheets.values || typeof sheets.spreadsheets.values.update !== 'function') throw new Error('SHEETS_VALUES_UPDATE_CLIENT_REQUIRED');
  const request = buildConfigUpdateRequest(spreadsheetId, sheetName, payload);
  const response = await sheets.spreadsheets.values.update(request);
  const data = response && response.data ? response.data : {};
  return { ok: true, updatedRange: data.updatedRange || request.range, updatedRows: Number(data.updatedRows || 0), updatedCells: Number(data.updatedCells || 0) };
}
module.exports = { executeConfigUpdate };
