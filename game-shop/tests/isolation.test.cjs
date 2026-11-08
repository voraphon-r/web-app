const {test}=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');
test('Game-Shop shares voraphon-apps with Kungten, keeps game_shop schema, and stays separate from Todo',()=>{
const root=path.resolve(__dirname,'../..');const shop=fs.readFileSync(path.join(root,'game-shop/public/index.html'),'utf8');const todo=fs.readFileSync(path.join(root,'public/index.html'),'utf8');const kungten=fs.readFileSync(path.join(root,'kungten-order/public/index.html'),'utf8');
const ref=s=>s.match(/const SUPABASE_URL = 'https:\/\/([a-z]+)\.supabase\.co'/)[1];
assert.equal(ref(shop),'qfxqjpqpytkaymlyjuuz');assert.notEqual(ref(shop),ref(todo));assert.equal(ref(shop),ref(kungten));assert.match(shop,/schema: 'game_shop'/);assert.match(kungten,/schema: 'kungten_order'/);assert.match(shop,/const SUPABASE_KEY = 'sb_publishable_/);assert.doesNotMatch(shop,/sb_secret_|service_role/);
});
