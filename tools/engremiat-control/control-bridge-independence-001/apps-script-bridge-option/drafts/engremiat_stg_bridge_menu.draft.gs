/**
 * ENGREMIAT STG BRIDGE MENU · DRAFT ONLY
 * Purpose: operate only STG_* tabs from inside Google Sheets.
 * Safety: no final tabs, no external API, no local Google API dependency.
 * Install manually only after human authorization.
 */

const ENGREMIAT_BRIDGE_CONFIG = {
  version: "1.0.0",
  mode: "STG_ONLY_APPS_SCRIPT_BRIDGE",
  finalTabsAllowed: false,
  allowedPrefix: "STG_",
  logTab: "STG_ENG_BRIDGE_LOG",
  signalsTab: "STG_ENG_SIGNALS",
  gatesTab: "STG_ENG_GATES",
  tasksTab: "STG_ENG_TASKS"
};

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu("ENGREMIAT")
    .addItem("Validar tabs STG", "engremiatValidateStgTabs")
    .addItem("Crear señal humana", "engremiatCreateHumanSignal")
    .addItem("Generar receipt STG", "engremiatGenerateReceipt")
    .addToUi();
}

function engremiatAssertStgOnly_(sheetName) {
  if (!sheetName || sheetName.indexOf(ENGREMIAT_BRIDGE_CONFIG.allowedPrefix) !== 0) {
    throw new Error("ENGREMIAT_BLOCKED_NON_STG_TAB: " + sheetName);
  }
  return true;
}

function engremiatGetOrCreateStgSheet_(name, headers) {
  engremiatAssertStgOnly_(name);
  const ss = SpreadsheetApp.getActive();
  let sh = ss.getSheetByName(name);
  if (!sh) {
    sh = ss.insertSheet(name);
  }
  if (headers && headers.length > 0 && sh.getLastRow() === 0) {
    sh.appendRow(headers);
  }
  return sh;
}

function engremiatLog_(event, ok, note) {
  const sh = engremiatGetOrCreateStgSheet_(
    ENGREMIAT_BRIDGE_CONFIG.logTab,
    ["at", "event", "ok", "note"]
  );
  sh.appendRow([new Date().toISOString(), event, ok, note || ""]);
}

function engremiatValidateStgTabs() {
  const ss = SpreadsheetApp.getActive();
  const sheets = ss.getSheets();
  const result = [];
  let blocked = 0;
  for (let i = 0; i < sheets.length; i++) {
    const name = sheets[i].getName();
    const isStg = name.indexOf(ENGREMIAT_BRIDGE_CONFIG.allowedPrefix) === 0;
    result.push([new Date().toISOString(), name, isStg ? "STG_OK" : "NON_STG_IGNORED"]);
    if (!isStg) blocked++;
  }
  const audit = engremiatGetOrCreateStgSheet_("STG_ENG_BRIDGE_AUDIT", ["at", "sheet", "status"]);
  if (result.length > 0) {
    audit.getRange(audit.getLastRow() + 1, 1, result.length, 3).setValues(result);
  }
  engremiatLog_("VALIDATE_STG_TABS", true, "non_stg_ignored=" + blocked);
  SpreadsheetApp.getUi().alert("ENGREMIAT STG validation complete. NON_STG ignored: " + blocked);
}

function engremiatCreateHumanSignal() {
  const ui = SpreadsheetApp.getUi();
  const key = ui.prompt("ENGREMIAT signal key", "Ejemplo: next_objective", ui.ButtonSet.OK_CANCEL);
  if (key.getSelectedButton() !== ui.Button.OK) return;
  const value = ui.prompt("ENGREMIAT signal value", "Ejemplo: manual_stg_import_validated", ui.ButtonSet.OK_CANCEL);
  if (value.getSelectedButton() !== ui.Button.OK) return;
  const sh = engremiatGetOrCreateStgSheet_(
    ENGREMIAT_BRIDGE_CONFIG.signalsTab,
    ["signal_id", "signal_type", "source_tab", "target_module", "key", "value", "status", "human_note", "created_at"]
  );
  const id = "SIG-" + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyyMMdd-HHmmss");
  sh.appendRow([id, "HUMAN_DECISION", "STG_ENG_SIGNALS", "engremiat-control", key.getResponseText(), value.getResponseText(), "READY", "Created from Apps Script bridge menu", new Date().toISOString()]);
  engremiatLog_("CREATE_HUMAN_SIGNAL", true, id);
}

function engremiatGenerateReceipt() {
  const sh = engremiatGetOrCreateStgSheet_(
    "STG_ENG_RECEIPTS",
    ["receipt_id", "packet_id", "received_by", "ok", "final_tabs_touched", "notes", "created_at"]
  );
  const id = "RECEIPT-" + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyyMMdd-HHmmss");
  sh.appendRow([id, "MANUAL_OR_BRIDGE_PACKET", "ENGREMIAT_CONTROL_SHEETS_STG", true, false, "Receipt generated inside Sheet STG-only bridge", new Date().toISOString()]);
  engremiatLog_("GENERATE_RECEIPT", true, id);
  SpreadsheetApp.getUi().alert("Receipt generated: " + id);
}
