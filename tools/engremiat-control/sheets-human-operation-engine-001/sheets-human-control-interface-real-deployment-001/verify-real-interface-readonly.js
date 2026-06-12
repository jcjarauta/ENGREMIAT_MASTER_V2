'use strict';
const fs = require('fs');
const { google } = require('googleapis');
function fail(code, message, details) { const error = new Error(message); error.code = code; error.details = details || {}; throw error; }
async function getAuth(credentialPath) {
  const raw = JSON.parse(fs.readFileSync(credentialPath, 'utf8').replace(/^\uFEFF/, ''));
  const client = google.auth.fromJSON(raw);
  if (raw.type === 'service_account') { client.scopes = ['https://www.googleapis.com/auth/spreadsheets.readonly']; }
  return client;
}
function validationValues(cell) {
  if (!cell || !cell.dataValidation || !cell.dataValidation.condition) { return []; }
  return (cell.dataValidation.condition.values || []).map(function(item) { return item.userEnteredValue; });
}
async function main() {
  const config = JSON.parse(fs.readFileSync(process.argv[2], 'utf8').replace(/^\uFEFF/, ''));
  const auth = await getAuth(config.credentialPath);
  const sheets = google.sheets({ version: 'v4', auth: auth });
  const metadata = await sheets.spreadsheets.get({ spreadsheetId: config.spreadsheetId, includeGridData: false, fields: 'sheets(properties(sheetId,title)),namedRanges(namedRangeId,name,range),sheets(protectedRanges(protectedRangeId,description,warningOnly,range))' });
  const titles = (metadata.data.sheets || []).map(function(sheet) { return sheet.properties.title; });
  const differences = [];
  config.contract.sources.forEach(function(source) { if (!titles.includes(source)) { differences.push('SOURCE_MISSING:' + source); } });
  config.contract.targets.forEach(function(target) {
    if (!titles.includes(target.tab)) { differences.push('TARGET_MISSING:' + target.tab); }
    const namedCount = (metadata.data.namedRanges || []).filter(function(item) { return item.name === target.named_range; }).length;
    if (namedCount !== 1) { differences.push('NAMED_RANGE_COUNT:' + target.named_range + ':' + namedCount); }
    const sheet = (metadata.data.sheets || []).find(function(item) { return item.properties.title === target.tab; });
    const protectionCount = sheet ? (sheet.protectedRanges || []).filter(function(item) { return item.description === target.protection && item.warningOnly === true; }).length : 0;
    if (protectionCount !== 1) { differences.push('PROTECTION_COUNT:' + target.tab + ':' + protectionCount); }
  });
  const validations = await sheets.spreadsheets.get({ spreadsheetId: config.spreadsheetId, includeGridData: true, ranges: config.contract.validation_cells, fields: 'sheets(properties(title),data(startRow,startColumn,rowData(values(dataValidation))))' });
  const decisionSheet = (validations.data.sheets || []).find(function(sheet) { return sheet.properties.title === 'ENG_DECISION_CENTER'; });
  const rules = [];
  if (decisionSheet) {
    (decisionSheet.data || []).forEach(function(grid) {
      (grid.rowData || []).forEach(function(row) {
        (row.values || []).forEach(function(cell) { if (cell.dataValidation) { rules.push(cell); } });
      });
    });
  }
  const ruleValues = rules.map(validationValues);
  const decisionRuleOk = ruleValues.some(function(values) { return config.contract.expected_decisions.every(function(value) { return values.includes(value); }); });
  const authorizationRuleOk = ruleValues.some(function(values) { return values.includes(config.authorizationPhrase); });
  if (!decisionRuleOk) { differences.push('DECISION_VALIDATION_MISSING'); }
  if (!authorizationRuleOk) { differences.push('AUTHORIZATION_VALIDATION_MISSING'); }
  const result = { schema: 'engremiat.sheets-human-control-interface.real-readback-result.v1', ok: differences.length === 0, semantic_differences: differences, semantic_differences_count: differences.length, target_tabs_verified: config.contract.targets.length, source_tabs_verified: config.contract.sources.length, named_ranges_verified: config.contract.targets.length, protections_verified: config.contract.targets.length, validations_verified: 2, idempotent_second_pass: differences.length === 0, google_api_mode: 'READONLY', real_sheet_read: true, real_sheet_write: false, source_tabs_write: false, real_task_execution: false };
  fs.writeFileSync(config.resultPath, JSON.stringify(result, null, 2));
  if (differences.length) { fail('IDEMPOTENCY_DIFFERENCES_FOUND', 'Real interface differs from expected state', { differences: differences }); }
  process.stdout.write(JSON.stringify({ ok: true, semantic_differences_count: 0, idempotent_second_pass: true }));
}
main().catch(function(error) { process.stderr.write(JSON.stringify({ ok: false, code: error.code || 'BLOCK_007_READONLY_ERROR', message: error.message, details: error.details || {} })); process.exit(1); });
