const {test}=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');
test('Game-Shop uses its dedicated project and a publishable key; Todo and Kungten stay separate',()=>{
const root=path.resolve(__dirname,'../..');const shop=fs.readFileSync(path.join(root,'game-shop/public/index.html'),'utf8');const todo=fs.readFileSync(path.join(root,'public/index.html'),'utf8');const kungten=fs.readFileSync(path.join(root,'kungten-order/public/index.html'),'utf8');
const ref=s=>s.match(/const SUPABASE_URL = 'https:\/\/([a-z]+)\.supabase\.co'/)[1];
assert.equal(ref(shop),'ncbjaeitjcpoayvkadwn');assert.notEqual(ref(shop),ref(todo));assert.notEqual(ref(shop),ref(kungten));assert.match(shop,/const SUPABASE_KEY = 'sb_publishable_/);assert.doesNotMatch(shop,/sb_secret_|service_role/);
});
