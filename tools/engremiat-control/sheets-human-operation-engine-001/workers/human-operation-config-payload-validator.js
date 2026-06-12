const fs = require('fs');
function extractRows(payload) {
  if (Array.isArray(payload)) return payload;
  if (payload && Array.isArray(payload.rows)) return payload.rows;
  if (payload && Array.isArray(payload.values)) return payload.values;
  throw new Error('CONFIG_ROWS_NOT_FOUND');
}
function validateConfigPayload(payload) {
  const rows = extractRows(payload);
  if (rows.length !== 8) throw new Error('CONFIG_ROWS_EXPECTED_8_FOUND_' + rows.length);
  const keys = rows.map(function (row, index) {
    if (Array.isArray(row)) {
      if (row.length < 2) throw new Error('CONFIG_ROW_' + (index + 1) + '_REQUIRES_KEY_AND_VALUE');
      return String(row[0] == null ? '' : row[0]).trim();
    }
    if (!row || typeof row !== 'object') throw new Error('CONFIG_ROW_' + (index + 1) + '_INVALID');
    const key = row.config_key != null ? row.config_key : row.key != null ? row.key : row.name;
    if (key == null) throw new Error('CONFIG_ROW_' + (index + 1) + '_KEY_MISSING');
    return String(key).trim();
  });
  if (keys.some(function (key) { return key.length === 0; })) throw new Error('CONFIG_KEY_EMPTY');
  if (new Set(keys).size !== keys.length) throw new Error('CONFIG_KEYS_DUPLICATED');
  return { ok: true, rowsCount: rows.length, uniqueKeys: keys.length };
}
if (require.main === module) {
  const inputPath = process.argv[2];
  if (!inputPath) throw new Error('CONFIG_PAYLOAD_PATH_REQUIRED');
  const payload = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
  process.stdout.write(JSON.stringify(validateConfigPayload(payload)));
}
module.exports = { extractRows, validateConfigPayload };
