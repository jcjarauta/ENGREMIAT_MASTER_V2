'use strict';
const fs=require('fs'),path=require('path');
const {google}=require('googleapis');
const root=process.cwd();
const base=path.join(root,'tools','engremiat-control');
const worker=path.join(base,'sheets-oauth-worker');
const reports=path.join(worker,'reports');
const config=path.join(base,'config');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const save=(p,v)=>fs.writeFileSync(p,JSON.stringify(v,null,2),'utf8');
const binding=read(path.join(config,'control-sheets-binding.local.json'));
const credentials=read(path.join(config,'credentials.json'));
const token=read(path.join(config,'token.json'));
const payloadFile=path.join(reports,'real-core-header-payload.v1.txt');
const authFile=path.join(reports,'real-core-header-write-authorization.v1.txt');
const resultFile=path.join(reports,'real-core-header-write-result.v1.json');
if(!fs.existsSync(payloadFile))throw new Error('HEADER_PAYLOAD_NOT_FOUND');
if(!fs.existsSync(authFile))throw new Error('HEADER_AUTHORIZATION_NOT_FOUND');
const payload=fs.readFileSync(payloadFile,'utf8').replace(/^\uFEFF/,'').split(/\r?\n/);
const authorization=fs.readFileSync(authFile,'utf8').replace(/^\uFEFF/,'');
if(!authorization.includes('authorization_recorded=True'))throw new Error('HEADER_WRITE_NOT_AUTHORIZED');
const spreadsheetId=binding.spreadsheet_id||binding.spreadsheetId||binding.sheet_id||binding.sheetId;
const client=credentials.installed||credentials.web;
if(!spreadsheetId)throw new Error('SPREADSHEET_ID_NOT_FOUND');
if(!client)throw new Error('OAUTH_CLIENT_NOT_FOUND');
const redirect=(client.redirect_uris&&client.redirect_uris[0])||'http://localhost';
const oauth=new google.auth.OAuth2(client.client_id,client.client_secret,redirect);
oauth.setCredentials(token);
const sheets=google.sheets({version:'v4',auth:oauth});
const headers={};
for(const line of payload){const i=line.indexOf('=');if(i>0){const k=line.slice(0,i);const v=line.slice(i+1);if(['ENG_HUMAN_QUEUE','ENG_HUMAN_REVIEW','ENG_HUMAN_HISTORY','ENG_HUMAN_CONFIG'].includes(k))headers[k]=v.split('|');}}
if(Object.keys(headers).length!==4)throw new Error('HEADER_PAYLOAD_ROLES_INVALID');
const targets=['ENG_HUMAN_QUEUE','ENG_HUMAN_REVIEW','ENG_HUMAN_HISTORY','ENG_HUMAN_CONFIG'];

if(targets.length!==4)throw new Error('CORE_TARGET_COUNT_INVALID');
const roleOf=t=>{const u=t.toUpperCase();if(u.includes('QUEUE'))return'ENG_HUMAN_QUEUE';if(u.includes('REVIEW'))return'ENG_HUMAN_REVIEW';if(u.includes('HISTORY'))return'ENG_HUMAN_HISTORY';if(u.includes('CONFIG'))return'ENG_HUMAN_CONFIG';return'';};
const rows=targets.map(title=>({title,role:roleOf(title)}));
if(rows.some(x=>!x.role))throw new Error('CORE_ROLE_MAPPING_FAILED');
(async()=>{
const q=t=>t+'!1:1';
const ranges=rows.map(x=>q(x.title));
const before=await sheets.spreadsheets.values.batchGet({spreadsheetId,ranges});
const values=before.data.valueRanges||[];
const occupied=values.filter(x=>Array.isArray(x.values)&&x.values.some(r=>Array.isArray(r)&&r.some(v=>String(v).trim()!==''))).length;
if(occupied!==0)throw new Error('NO_GO_ONE_OR_MORE_HEADER_ROWS_NOT_EMPTY');
const data=rows.map(x=>({range:q(x.title),majorDimension:'ROWS',values:[headers[x.role]]}));
if(data.length!==4)throw new Error('HEADER_WRITE_DATA_COUNT_INVALID');
const write=await sheets.spreadsheets.values.batchUpdate({spreadsheetId,requestBody:{valueInputOption:'RAW',data}});
const updated=Number(write.data.totalUpdatedRows||0);
const after=await sheets.spreadsheets.values.batchGet({spreadsheetId,ranges});
const afterValues=after.data.valueRanges||[];
let verified=0;
for(let i=0;i<rows.length;i++){const actual=afterValues[i]&&afterValues[i].values&&afterValues[i].values[0]?afterValues[i].values[0].map(String):[];const expected=headers[rows[i].role].map(String);if(actual.length===expected.length&&actual.every((v,j)=>v===expected[j]))verified++;}
const ok=updated===4&&verified===4;
save(resultFile,{schema:'engremiat.core-header-write-result.v1',ok,objective:'SHEETS_CORE_OPERATIONAL_STRUCTURE_001',mode:'CONTROLLED_CORE_HEADER_WRITE',authorized_tabs_count:4,authorized_row:1,header_rows_before_empty:true,header_rows_written:updated,header_rows_verified:verified,delete_allowed:false,rename_allowed:false,other_tabs_write_allowed:false,data_rows_write_allowed:false,formatting_write:false,google_api_call:true,google_api_read:true,google_api_write:true,real_sheet_write:ok,decision:ok?'FOUR_CORE_HEADERS_WRITTEN_AND_VERIFIED':'CORE_HEADER_WRITE_NOT_FULLY_VERIFIED',readiness:ok?98:90,gate:ok?'OPEN_READY_FOR_BLOCK_007_REAL_STRUCTURE_AUDIT':'STOP_REVIEW_CORE_HEADER_WRITE',recommended_next:ok?'SHEETS_CORE_OPERATIONAL_STRUCTURE_001_BLOCK_007':'REVIEW_CORE_HEADER_WRITE_RESULT',commit:false,push:false});
if(!ok)process.exitCode=20;
})().catch(e=>{const m=String(e&&e.message?e.message:e);save(resultFile,{schema:'engremiat.core-header-write-result.v1',ok:false,objective:'SHEETS_CORE_OPERATIONAL_STRUCTURE_001',mode:'CONTROLLED_CORE_HEADER_WRITE',header_rows_written:0,header_rows_verified:0,google_api_call:true,google_api_write:false,real_sheet_write:false,decision:m.includes('NO_GO_')?m:'CORE_HEADER_WRITE_EXECUTION_FAILED',gate:'STOP_REVIEW_CORE_HEADER_WRITE_ERROR',error_message:m,commit:false,push:false});process.exitCode=21;});

