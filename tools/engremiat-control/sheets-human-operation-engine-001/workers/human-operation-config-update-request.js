'use strict';
function buildConfigUpdateRequest(spreadsheetId, sheetName, payload) {
  if (!spreadsheetId || typeof spreadsheetId !== 'string') throw new Error('SPREADSHEET_ID_REQUIRED');
  if (!sheetName || typeof sheetName !== 'string') throw new Error('CONFIG_SHEET_NAME_REQUIRED');
  const rows = Array.isArray(payload) ? payload : payload && Array.isArray(payload.rows) ? payload.rows : payload && Array.isArray(payload.values) ? payload.values : null;
  if (!rows) throw new Error('CONFIG_ROWS_NOT_FOUND');
  if (rows.length !== 8) throw new Error('CONFIG_ROWS_EXPECTED_8_FOUND_' + rows.length);
  return { spreadsheetId: spreadsheetId, range: sheetName + '!A2:B9', valueInputOption: 'RAW', requestBody: { values: rows } };
}
module.exports = { buildConfigUpdateRequest };
