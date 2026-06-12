'use strict';
const fs = require('fs');
const { runRealPreflightReader } = require('./human-operation-real-preflight-reader');
function readJson(filePath) { return JSON.parse(fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '')); }
function loadGoogleApis(options) {
  const input = options || {};
  const explicitRoot = String(input.googleapisRoot || process.env.ENGREMIAT_GOOGLEAPIS_ROOT || '').trim();
  if (explicitRoot) return require(explicitRoot);
  try { return require('googleapis'); } catch (error) { throw new Error('GOOGLEAPIS_MODULE_REQUIRED'); }
}
async function createReadonlySheetsClient(options) {
  const input = options || {};
  const credentialPath = String(input.credentialPath || process.env.GOOGLE_APPLICATION_CREDENTIALS || '').trim();
  if (!credentialPath) throw new Error('READONLY_CREDENTIAL_PATH_REQUIRED');
  const credential = readJson(credentialPath);
  const googleapis = loadGoogleApis(input);
  const google = googleapis.google;
  const auth = google.auth.fromJSON(credential);
  if (!auth) throw new Error('GOOGLE_AUTH_FROM_JSON_FAILED');
  if (auth.scopes !== undefined) auth.scopes = ['https://www.googleapis.com/auth/spreadsheets.readonly'];
  return google.sheets({ version: 'v4', auth: auth });
}
async function runReadonlyPreflight(options) {
  const input = options || {};
  const spreadsheetId = String(input.spreadsheetId || '').trim();
  if (!spreadsheetId) throw new Error('READONLY_SPREADSHEET_ID_REQUIRED');
  const sheets = input.sheets || await createReadonlySheetsClient(input);
  return runRealPreflightReader({ sheets: sheets, spreadsheetId: spreadsheetId });
}
module.exports = { readJson, loadGoogleApis, createReadonlySheetsClient, runReadonlyPreflight };
