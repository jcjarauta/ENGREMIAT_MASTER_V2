'use strict';
const STATUS_BY_DECISION = Object.freeze({ APPROVE: 'APPROVED', REJECT: 'REJECTED', REQUEST_MORE: 'NEEDS_MORE' });
function createReviewSheetsAdapter(options) {
  const input = options || {};
  const sheets = input.sheets;
  const spreadsheetId = String(input.spreadsheetId || '').trim();
  const queueRange = input.queueRange || 'ENG_QUEUE!A2:K';
  const historyRange = input.historyRange || 'ENG_HISTORY!A:K';
  if (!sheets || !sheets.spreadsheets || !sheets.spreadsheets.values) throw new Error('REVIEW_SHEETS_CLIENT_REQUIRED');
  const values = sheets.spreadsheets.values;
  if (typeof values.get !== 'function' || typeof values.update !== 'function' || typeof values.append !== 'function') throw new Error('REVIEW_SHEETS_METHODS_REQUIRED');
  if (!spreadsheetId) throw new Error('REVIEW_SPREADSHEET_ID_REQUIRED');
  return Object.freeze({
    updateQueue: async function (taskId, decision, payload) {
      const id = String(taskId || '').trim();
      const normalizedDecision = String(decision || '').trim().toUpperCase();
      if (!id) throw new Error('REVIEW_QUEUE_TASK_ID_REQUIRED');
      const newStatus = STATUS_BY_DECISION[normalizedDecision];
      if (!newStatus) throw new Error('REVIEW_QUEUE_DECISION_INVALID');
      const read = await values.get({ spreadsheetId: spreadsheetId, range: queueRange });
      const rows = read && read.data && Array.isArray(read.data.values) ? read.data.values : [];
      const index = rows.findIndex(function (row) { return String((row || [])[0] || '').trim() === id; });
      if (index < 0) throw new Error('REVIEW_QUEUE_TASK_NOT_FOUND');
      const rowNumber = index + 2;
      const previousStatus = String((rows[index] || [])[2] || '').trim();
      const updateRange = 'ENG_QUEUE!C' + rowNumber + ':C' + rowNumber;
      const response = await values.update({ spreadsheetId: spreadsheetId, range: updateRange, valueInputOption: 'RAW', requestBody: { values: [[newStatus]] } });
      const data = response && response.data ? response.data : {};
      return { taskId: id, rowNumber: rowNumber, previousStatus: previousStatus, newStatus: newStatus, updatedRange: data.updatedRange || updateRange, payload: payload || {} };
    },
    appendHistory: async function (taskId, decision, payload) {
      const p = payload || {};
      const normalizedDecision = String(decision || '').trim().toUpperCase();
      const newStatus = STATUS_BY_DECISION[normalizedDecision];
      if (!newStatus) throw new Error('REVIEW_HISTORY_DECISION_INVALID');
      const row = [p.historyId || p.history_id || '',p.entityType || p.entity_type || 'TASK',taskId,p.eventAt || p.event_at || '',p.eventType || p.event_type || 'REVIEW_' + normalizedDecision,p.previousStatus || p.previous_status || '',p.newStatus || p.new_status || newStatus,p.actor || p.reviewedBy || p.reviewed_by || '',p.source || '',typeof p.detailsJson === 'string' ? p.detailsJson : JSON.stringify(p.details || { decision: normalizedDecision }),p.correlationId || p.correlation_id || ''];
      if (row.length !== 11) throw new Error('REVIEW_HISTORY_COLUMN_COUNT_INVALID');
      const response = await values.append({ spreadsheetId: spreadsheetId, range: historyRange, valueInputOption: 'RAW', insertDataOption: 'INSERT_ROWS', requestBody: { values: [row] } });
      const updates = response && response.data && response.data.updates ? response.data.updates : {};
      return { updatedRange: updates.updatedRange || historyRange, updatedRows: Number(updates.updatedRows || 0), updatedCells: Number(updates.updatedCells || 0), values: row };
    }
  });
}
module.exports = { STATUS_BY_DECISION, createReviewSheetsAdapter };
