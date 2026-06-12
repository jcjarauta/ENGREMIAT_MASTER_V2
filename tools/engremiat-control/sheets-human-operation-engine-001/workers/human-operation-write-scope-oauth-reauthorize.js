'use strict';
const fs = require('fs');
const http = require('http');
const { URL } = require('url');
const { google } = require(
"C:\\ENGREMIAT_REPO_CLEAN\\ENGREMIAT_MASTER_V2\\tools\\engremiat-control\\sheets-oauth-worker\\node_modules\\googleapis"
);
function readJson(filePath) { return JSON.parse(fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '')); }
function getClientConfig(value) { return value.installed || value.web || value; }
async function reauthorize(options) {
  const input = options || {};
  const config = getClientConfig(readJson(input.oauthClientPath));
  if (!config.client_id || !config.client_secret) throw new Error('OAUTH_CLIENT_FIELDS_REQUIRED');
  const redirectUri = 'http://127.0.0.1:53682/oauth2callback';
  const client = new google.auth.OAuth2(config.client_id, config.client_secret, redirectUri);
  const scope = 'https://www.googleapis.com/auth/spreadsheets';
  const url = client.generateAuthUrl({ access_type: 'offline', prompt: 'consent', scope: [scope] });
  return { client: client, url: url, redirectUri: redirectUri, scope: scope };
}
module.exports = { reauthorize };
