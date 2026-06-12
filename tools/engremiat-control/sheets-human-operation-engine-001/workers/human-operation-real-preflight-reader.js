'use strict';
const EXPECTED = Object.freeze({
  ENG_QUEUE: Object.freeze(['task_id','created_at','status','priority','title','description','project_id','requested_by','assigned_to','source','metadata_json']),
  ENG_REVIEWS: Object.freeze(['review_id','task_id','reviewed_at','reviewed_by','decision','comment','previous_status','new_status','source','metadata_json']),
  ENG_HISTORY: Object.freeze(['history_id','entity_type','entity_id','event_at','event_type','previous_status','new_status','actor','source','details_json','correlation_id']),
  CONFIG: Object.freeze(['config_key','config_value'])
});
const LAST_COLUMN = Object.freeze({ ENG_QUEUE: 'K', ENG_REVIEWS: 'J', ENG_HISTORY: 'K', CONFIG: 'B' });
function normalize(value) { return String(value == null ? '' : value).trim().toLowerCase(); }
function quoteSheetName(name) { return "'" + String(name).replace(/'/g, "''") + "'"; }
function compareHeaders(actual, expected) {
  const normalizedActual = actual.map(normalize);
  const normalizedExpected = expected.map(normalize);
  return Object.freeze({ match: normalizedActual.length === normalizedExpected.length && normalizedActual.every(function (value, index) { return value === normalizedExpected[index]; }), actual: actual, expected: expected, actualCount: actual.length, expectedCount: expected.length });
}
async function runRealPreflightReader(options) {
  const input = options || {};
  const sheets = input.sheets;
  const spreadsheetId = String(input.spreadsheetId || '').trim();
  if (!sheets || !sheets.spreadsheets || typeof sheets.spreadsheets.get !== 'function') throw new Error('PREFLIGHT_SPREADSHEETS_GET_REQUIRED');
  if (!sheets.spreadsheets.values || typeof sheets.spreadsheets.values.batchGet !== 'function') throw new Error('PREFLIGHT_VALUES_BATCHGET_REQUIRED');
  if (!spreadsheetId) throw new Error('PREFLIGHT_SPREADSHEET_ID_REQUIRED');
  const metadataResponse = await sheets.spreadsheets.get({ spreadsheetId: spreadsheetId, includeGridData: false, fields: 'properties.title,sheets.properties.title' });
  const metadataSheets = metadataResponse && metadataResponse.data && Array.isArray(metadataResponse.data.sheets) ? metadataResponse.data.sheets : [];
  const tabs = metadataSheets.map(function (item) { return String(item && item.properties && item.properties.title || '').trim(); }).filter(Boolean);
  const existingExpectedTabs = Object.keys(EXPECTED).filter(function (name) { return tabs.indexOf(name) >= 0; });
  const ranges = existingExpectedTabs.map(function (name) { return quoteSheetName(name) + '!A1:' + LAST_COLUMN[name] + '1'; });
  let valueRanges = [];
  if (ranges.length > 0) {
    const headerResponse = await sheets.spreadsheets.values.batchGet({ spreadsheetId: spreadsheetId, ranges: ranges, majorDimension: 'ROWS' });
    valueRanges = headerResponse && headerResponse.data && Array.isArray(headerResponse.data.valueRanges) ? headerResponse.data.valueRanges : [];
  }
  const headersByTab = {};
  existingExpectedTabs.forEach(function (name, index) {
    const values = valueRanges[index] && Array.isArray(valueRanges[index].values) && Array.isArray(valueRanges[index].values[0]) ? valueRanges[index].values[0] : [];
    headersByTab[name] = values;
  });
  const checks = {};
  Object.keys(EXPECTED).forEach(function (name) {
    const tabExists = tabs.indexOf(name) >= 0;
    const actual = tabExists && Array.isArray(headersByTab[name]) ? headersByTab[name] : [];
    checks[name] = Object.freeze({ tabExists: tabExists, headerReadAttempted: tabExists, headers: compareHeaders(actual, EXPECTED[name]) });
  });
  const allTabsExist = Object.keys(checks).every(function (name) { return checks[name].tabExists; });
  const allHeadersMatch = Object.keys(checks).every(function (name) { return checks[name].headers.match; });
  return Object.freeze({ ok: true, spreadsheetTitle: String(metadataResponse && metadataResponse.data && metadataResponse.data.properties && metadataResponse.data.properties.title || ''), tabs: tabs, expectedTabsFound: existingExpectedTabs, rangesRead: ranges, checks: Object.freeze(checks), allTabsExist: allTabsExist, allHeadersMatch: allHeadersMatch, realWrite: false });
}
module.exports = { EXPECTED, LAST_COLUMN, compareHeaders, runRealPreflightReader };
