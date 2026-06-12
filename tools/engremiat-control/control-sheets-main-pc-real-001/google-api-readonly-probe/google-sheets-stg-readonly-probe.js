'use strict';
const fs = require('fs');
const path = require('path');
const ROOT = 'C:/ENGREMIAT_REPO_CLEAN/ENGREMIAT_MASTER_V2';
const AUTH = 'SI, AUTORIZO READONLY PROBE GOOGLE SHEETS CONTROL_SHEETS_MAIN_PC_REAL_001 SIN WRITE SIN FINAL TABS SIN PUSH';
const bindingPath = path.join(ROOT, 'tools/engremiat-control/config/control-sheets-binding.local.json');
const outPath = path.join(ROOT, 'tools/engremiat-control/control-sheets-main-pc-real-001/google-api-readonly-probe/google-sheets-stg-readonly-probe-run-report.v1.json');
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const realReadonly = args.includes('--real-readonly');
const authArgIndex = args.indexOf('--authorization');
const authValue = authArgIndex >= 0 ? String(args[authArgIndex + 1] || '') : '';
function writeReport(obj) { fs.mkdirSync(path.dirname(outPath), { recursive: true }); fs.writeFileSync(outPath, JSON.stringify(obj, null, 2), 'utf8'); }
function readBindingSafe() {
  try {
    if (!fs.existsSync(bindingPath)) return { ok:false, error:'MISSING_BINDING' };
    const raw = fs.readFileSync(bindingPath, 'utf8').replace(/^\uFEFF/, '');
    const b = JSON.parse(raw);
    const spreadsheetId = String(b.spreadsheet_id || b.spreadsheetId || b.sheet_id || b.sheetId || '');
    const spreadsheetName = String(b.spreadsheet_name || b.spreadsheetName || '');
    let credentialPath = String(b.credentials_path || b.google_credentials_path || b.service_account_key_path || b.serviceAccountKeyPath || b.key_file || b.keyFile || b.GOOGLE_APPLICATION_CREDENTIALS || process.env.GOOGLE_APPLICATION_CREDENTIALS || '');
    if (credentialPath && !path.isAbsolute(credentialPath)) credentialPath = path.join(ROOT, credentialPath);
    return { ok: spreadsheetId.length > 0, spreadsheetId, spreadsheetName, credentialPath, credentialPathPresent: credentialPath ? fs.existsSync(credentialPath) : false, error: spreadsheetId.length > 0 ? '' : 'MISSING_SPREADSHEET_ID' };
  } catch (err) { return { ok:false, error:String(err && err.message ? err.message : err) }; }
}
function masked(id) { return id && id.length > 12 ? id.slice(0,6) + '...' + id.slice(-6) : 'MASKED_OR_EMPTY'; }
async function main() {
  const binding = readBindingSafe();
  if (dryRun || !realReadonly) {
    writeReport({ ok:true, decision:'GOOGLE_API_READONLY_PROBE_006B_DRY_RUN_OK_NO_API_CALL', mode:'DRY_RUN_ONLY', binding_ok:binding.ok, binding_error:binding.error || '', spreadsheet_id_masked:masked(binding.spreadsheetId), credential_path_present:!!binding.credentialPathPresent, real_sheet_read:false, real_sheet_write:false, google_api_call:false, apps_script_execution:false, final_tabs_allowed:false, push:false });
    console.log('CONTROL_SHEETS_MAIN_PC_REAL_001_READONLY_PROBE_006B_DRY_RUN_BEGIN');
    console.log('ok=True');
    console.log('decision=GOOGLE_API_READONLY_PROBE_006B_DRY_RUN_OK_NO_API_CALL');
    console.log('binding_ok=' + String(binding.ok));
    console.log('credential_path_present=' + String(!!binding.credentialPathPresent));
    console.log('real_sheet_read=False');
    console.log('real_sheet_write=False');
    console.log('google_api_call=False');
    console.log('CONTROL_SHEETS_MAIN_PC_REAL_001_READONLY_PROBE_006B_DRY_RUN_END');
    return;
  }
  if (authValue !== AUTH) { writeReport({ ok:false, decision:'READONLY_PROBE_BLOCKED_AUTHORIZATION_MISMATCH', real_sheet_read:false, real_sheet_write:false, google_api_call:false, final_tabs_allowed:false, push:false }); process.exit(1); }
  if (!binding.ok) { writeReport({ ok:false, decision:'READONLY_PROBE_BLOCKED_BINDING_NOT_READY', binding_error:binding.error, real_sheet_read:false, real_sheet_write:false, google_api_call:false, final_tabs_allowed:false, push:false }); process.exit(1); }
  if (!binding.credentialPathPresent) { writeReport({ ok:false, decision:'READONLY_PROBE_BLOCKED_CREDENTIAL_PATH_NOT_PRESENT', spreadsheet_id_masked:masked(binding.spreadsheetId), real_sheet_read:false, real_sheet_write:false, google_api_call:false, final_tabs_allowed:false, push:false }); process.exit(1); }
  let googleapis;
  try { googleapis = require('googleapis'); } catch (err) { writeReport({ ok:false, decision:'READONLY_PROBE_BLOCKED_GOOGLEAPIS_MISSING', error:String(err.message || err), real_sheet_read:false, real_sheet_write:false, google_api_call:false, final_tabs_allowed:false, push:false }); process.exit(1); }
  const auth = new googleapis.google.auth.GoogleAuth({ keyFile: binding.credentialPath, scopes: ['https://www.googleapis.com/auth/spreadsheets.readonly'] });
  const sheets = googleapis.google.sheets({ version: 'v4', auth });
  const res = await sheets.spreadsheets.get({ spreadsheetId: binding.spreadsheetId, includeGridData: false });
  const tabs = (res.data.sheets || []).map(s => s.properties && s.properties.title).filter(Boolean);
  const stgTabs = tabs.filter(t => /^STG_/.test(t));
  writeReport({ ok:true, decision:'AUTHORIZED_READONLY_PROBE_REAL_READ_OK_NO_WRITE', spreadsheet_id_masked:masked(binding.spreadsheetId), tabs_count:tabs.length, stg_tabs_count:stgTabs.length, stg_tabs:stgTabs, real_sheet_read:true, real_sheet_write:false, google_api_call:true, apps_script_execution:false, final_tabs_allowed:false, push:false, recommended_next:'STEP_007_BUILD_STG_WRITE_ADAPTER_AFTER_READONLY_PROBE_OK' });
  console.log('CONTROL_SHEETS_MAIN_PC_REAL_001_AUTHORIZED_READONLY_PROBE_REAL_BEGIN');
  console.log('ok=True');
  console.log('decision=AUTHORIZED_READONLY_PROBE_REAL_READ_OK_NO_WRITE');
  console.log('tabs_count=' + tabs.length);
  console.log('stg_tabs_count=' + stgTabs.length);
  console.log('real_sheet_read=True');
  console.log('real_sheet_write=False');
  console.log('google_api_call=True');
  console.log('CONTROL_SHEETS_MAIN_PC_REAL_001_AUTHORIZED_READONLY_PROBE_REAL_END');
}
main().catch((err) => { writeReport({ ok:false, decision:'READONLY_PROBE_FAILED_SAFE', error:String(err && err.message ? err.message : err), real_sheet_read:false, real_sheet_write:false, google_api_call:false, final_tabs_allowed:false, push:false }); process.exit(1); });
