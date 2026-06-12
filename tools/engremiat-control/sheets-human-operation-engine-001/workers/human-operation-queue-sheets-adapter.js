'use strict';
function createQueueSheetsAdapter(options) {
  const input = options || {};
  const sheets = input.sheets;
  const spreadsheetId = String(input.spreadsheetId || '').trim();
  const readRange = input.readRange || 'ENG_QUEUE!A2:K';
  const appendRange = input.appendRange || 'ENG_QUEUE!A:K';
  if (!sheets || !sheets.spreadsheets || !sheets.spreadsheets.values) throw new Error('QUEUE_SHEETS_CLIENT_REQUIRED');
  if (typeof sheets.spreadsheets.values.get !== 'function' || typeof sheets.spreadsheets.values.append !== 'function') throw new Error('QUEUE_SHEETS_METHODS_REQUIRED');
  if (!spreadsheetId) throw new Error('QUEUE_SPREADSHEET_ID_REQUIRED');
  return Object.freeze({
    findByTaskId: async function (taskId) {
      const id = String(taskId || '').trim();
      if (!id) throw new Error('QUEUE_LOOKUP_TASK_ID_REQUIRED');
      const response = await sheets.spreadsheets.values.get({ spreadsheetId: spreadsheetId, range: readRange });
      const rows = response && response.data && Array.isArray(response.data.values) ? response.data.values : [];
      const index = rows.findIndex(function (row) { return String((row || [])[0] || '').trim() === id; });
      return index < 0 ? null : { taskId: id, rowNumber: index + 2, values: rows[index] };
    },
    append: async function (payload) {
      const p = payload || {};
      const row = [p.taskId || p.task_id || '',p.createdAt || p.created_at || '',p.status || 'PENDING',p.priority || '',p.title || '',p.description || '',p.projectId || p.project_id || '',p.requestedBy || p.requested_by || '',p.assignedTo || p.assigned_to || '',p.source || '',typeof p.metadataJson === 'string' ? p.metadataJson : JSON.stringify(p.metadata || {})];
      if (row.length !== 11) throw new Error('QUEUE_ROW_COLUMN_COUNT_INVALID');
      const response = await sheets.spreadsheets.values.append({ spreadsheetId: spreadsheetId, range: appendRange, valueInputOption: 'RAW', insertDataOption: 'INSERT_ROWS', requestBody: { values: [row] } });
      const updates = response && response.data && response.data.updates ? response.data.updates : {};
      return { updatedRange: updates.updatedRange || appendRange, updatedRows: Number(updates.updatedRows || 0), updatedCells: Number(updates.updatedCells || 0), values: row };
    }
  });
}
module.exports = { createQueueSheetsAdapter };
