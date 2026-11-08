# Game-Shop (บันทึกประจำกะ ร้านเกม)

เว็บหน้าเดียวแทนสมุดบันทึกกะ สำหรับคนที่เข้ากะ: เปิดกะ > บันทึกลูกค้าทีละราย > ปิดกะ
ต้องเข้าสู่ระบบ (แนะนำบัญชีร้าน 1 บัญชี ล็อกอินค้างไว้ที่เครื่องในร้าน) ทุกเครื่องเห็นรายการทันที (Supabase Realtime)

- หน้าเว็บ: `public/index.html` (ไฟล์เดียว) จำนวนเครื่องตั้งที่ `MACHINE_COUNT`
- ฐานข้อมูล: `supabase/setup.sql` สร้าง schema `game_shop` (ตาราง `members`, `shifts`, `shift_entries`)
- ใช้ Supabase โปรเจกต์เฉพาะ `game-shop` (`ncbjaeitjcpoayvkadwn`) แยก Database, Auth และ Storage จาก Todo และ Kungten

## ทำอะไรได้

- เปิดกะ (ใส่ชื่อคนเข้ากะ) เปิดได้ทีละ 1 กะ
- บันทึกลูกค้า 1 ราย = เครื่องที่เล่น, ค่าเกม, ค่าน้ำ/ขนม, จ่ายสดหรือโอน (เวลาบันทึกอัตโนมัติ)
- จ่ายสด: ใส่เงินที่รับมา แล้วแสดงเงินทอนให้
- ตารางแบบสมุด: เวลา | เครื่อง | ค่าเกม | ค่าน้ำ | โอน | สด พร้อมยอดรวม จำนวนรายการ เงินสด โอน
- แตะแถวเพื่อแก้หรือลบ, ปิดกะ (แสดงยอดเงินสดให้นับลิ้นชัก), ดูกะที่ผ่านมา 10 กะล่าสุด

## ตั้งค่าครั้งแรก

1. Supabase (โปรเจกต์ game-shop) > SQL Editor > วางเนื้อหา `supabase/setup.sql` > Run
2. Integrations > Data API > Settings > Exposed schemas > เพิ่ม `game_shop` > Save
3. Authentication > Users > Add user > Create new user: ใส่อีเมล + รหัสผ่านของคนที่จะใช้ (ติ๊ก Auto Confirm User)
4. SQL Editor: เพิ่มอีเมลนั้นเป็นสมาชิก
   ```sql
   insert into game_shop.members (email, display_name) values ('อีเมล@ตัวพิมพ์เล็ก', 'ร้านเกม');
   ```
5. Deploy: Netlify > Add new project > Import from GitHub > `voraphon-r/web-app`, Publish directory = `game-shop/public`
   แล้วตั้งโดเมน เช่น `game.voraphon.com` (Cloudflare CNAME `game` -> `<ชื่อโปรเจกต์>.netlify.app`, DNS only)

## หมายเหตุ

- หน้าเว็บไม่มีปุ่มสมัครสมาชิก เพิ่มคนใช้งานได้ทางข้อ 3-4 เท่านั้น คนที่ล็อกอินได้แต่ไม่อยู่ใน `members` จะดูข้อมูลไม่ได้ (คุมด้วย RLS)
- `setup.sql` รันซ้ำได้ ไม่ลบข้อมูลที่บันทึกไว้

## ความถูกต้องของข้อมูล

- กะที่ปิดแล้วดูย้อนหลังได้อย่างเดียว แก้/ลบได้เฉพาะกะที่เปิดอยู่
- จำนวนเครื่องต้องอยู่ระหว่าง 1–20 ทั้งหน้าเว็บและฐานข้อมูล
- เงินต้องไม่ติดลบ ทศนิยมไม่เกิน 2 ตำแหน่ง เงินที่รับมาต้องไม่น้อยกว่ายอดขาย
- รายการใหม่ใช้ UUID เดิมเมื่อส่งซ้ำ เก็บรายการที่ยังยืนยันผลไม่ได้ในเครื่อง แยกตามบัญชี เมื่อเปิดหน้าใหม่จะให้ตรวจและส่งรายการเดิมก่อน
- หากโหลดข้อมูลไม่ครบ จะปิดปุ่มบันทึก/ปิดกะ และมีปุ่มลองโหลดใหม่
- โหลดรายการแบบแบ่งหน้า เพื่อไม่ให้ยอดขาดเมื่อเกินขีดจำกัดจำนวนแถวของ API
- ปิดกะผ่าน `close_shift` ซึ่งล็อกกะแข่งกับการบันทึก และตรวจจำนวนรายการ/ยอดสด/ยอดโอนในฐานข้อมูลก่อนปิด หากยอดเปลี่ยนต้องโหลดและนับใหม่
- ยอดสดคือรายรับของกะ ไม่รวมเงินทอนตั้งต้นหรือรายจ่าย
- `setup.sql` ครอบด้วย transaction: หากข้อมูลเก่าไม่ผ่านข้อกำหนดใหม่จะยกเลิกทั้งชุด ไม่ลบหรือแก้ข้อมูลเก่าอัตโนมัติ

## ทดสอบในเครื่อง

ใช้ Node.js 24 และ pnpm: `pnpm install --frozen-lockfile` แล้ว `pnpm test` ในโฟลเดอร์ `game-shop`.
ชุดทดสอบใช้ PostgreSQL ผ่าน PGlite ในเครื่อง ไม่ใช้ข้อมูล Supabase จริง รวมการรัน setup ซ้ำ, สิทธิ์ RLS, validation, กะปิด, ยอดสมุด, การส่งซ้ำ/ผลตอบกลับหาย และ pagination 1,201 รายการ

ตรวจหน้าจอเพิ่มเติม: ใช้ Playwright 1.62.1 และ Microsoft Edge รัน `node tests/browser.cjs` (หรือตั้ง `PLAYWRIGHT_MODULE` เป็นตำแหน่งโมดูลที่ติดตั้งไว้) ใช้ข้อมูลจำลองและปิดการเชื่อมบริการภายนอก ภาพอยู่ใน `test-output/`.

## สถานะล่าสุด (8 พฤศจิกายน 2569)

ผู้ใช้อนุมัติ push และตั้ง Supabase แล้ว และขอเพิ่มเป็น 20 เครื่อง

- ใช้ setup กับ Supabase voraphon-apps แล้ว: ตาราง 3 ตารางเปิด RLS และ shifts/shift_entries อยู่ใน Realtime publication
- เพิ่ม game_shop ใน Data API ผ่าน pgrst.db_schemas ของ role authenticator โดยคง public, graphql_public, kungten_order ไว้ครบ และไม่ expose game_shop_private
- ค่านี้เป็น database role override หากแก้ Exposed schemas ผ่าน Dashboard ในอนาคต ต้องปรับ override ให้สอดคล้องกัน หรือ reset override หลังบันทึกค่าที่ต้องการใน Dashboard แล้ว
- ทดสอบจริงใน transaction แล้ว rollback: เครื่อง 20 ผ่าน, เครื่อง 21 ไม่ผ่าน, UUID ซ้ำไม่ผ่าน, ปิดกะแล้วแก้ไม่ได้, non-member เขียนไม่ได้; ไม่เหลือ shifts/entries ทดสอบ
- ตรวจ REST จริง: game_shop ถูก expose แล้ว และ anon ถูกปฏิเสธด้วย 401/42501 ตามที่ควรเป็น
- เพิ่มสมาชิกตามอีเมลที่ผู้ใช้ระบุแล้ว แต่ Authentication ยังไม่มีบัญชีของอีเมลนี้ เจ้าของต้องสร้างบัญชีและกำหนดรหัสผ่านเองใน Authentication > Users ก่อนทดสอบล็อกอินจริง
- ทดสอบในเครื่องผ่าน 6/6 และ Edge ผ่านเครื่องครบ 20 ปุ่ม กับหน้าจอ 4 ขนาด

ยังไม่ merge และยังไม่ตั้ง Netlify production ของ Game-Shop. Netlify previews ที่ผูกกับ PR เป็นของแอปอื่น ไม่ใช่หลักฐานว่า Game-Shop เปิดให้ใช้แล้ว ต้องตั้ง publish directory game-shop/public โดยเฉพาะและทดสอบบัญชีร้าน/Realtime สองเครื่องจริงก่อนเปิดใช้

## แยกโปรเจกต์ Game-Shop แล้ว

สถานะปัจจุบันให้ยึดส่วนนี้แทนบันทึกเก่าด้านบน: Game-Shop ใช้โปรเจกต์ ncbjaeitjcpoayvkadwn โดยเฉพาะ URL https://ncbjaeitjcpoayvkadwn.supabase.co และ publishable key ของโปรเจกต์ใหม่นี้

- Todo คงใช้ rfmkmerdiusocpflyhoq และ Kungten คงใช้ qfxqjpqpytkaymlyjuuz ไม่แก้โค้ด/ข้อมูล/บัญชี/Storage/การตั้งค่าของแอปทั้งสอง
- Database: ย้ายสมาชิก 1 บัญชี มี RLS/constraints/Realtime ครบ; ต้นทางไม่มีรายการขายหรือกะให้คัดลอก
- Auth: คัดลอกเฉพาะบัญชีของสมาชิก Game-Shop และ email identity พร้อม password hash เดิม ไม่คัดลอก session/token เดิม ต้อง login ใหม่ด้วยอีเมลและรหัสผ่านเดิม
- Storage: ต้นทางไม่มี bucket หรือ object ของ Game-Shop และแอปยังไม่มีฟังก์ชันอัปโหลด จึงไม่สร้าง bucket ที่ไม่ใช้และไม่คัดลอกไฟล์ของแอปอื่น; Storage ต่อจากนี้เป็นบริการของโปรเจกต์ใหม่เท่านั้น
- โปรเจกต์ใหม่ expose public/graphql_public/game_shop; game_shop_private ไม่ expose
- ทดสอบ Auth password login ด้วยบัญชีชั่วคราวและ REST สิทธิ์คนนอก/anon ผ่าน; ลบบัญชีทดสอบแล้ว เหลือบัญชีร้าน 1 บัญชี
- ทดสอบ SQL เปิดกะ/เครื่อง20/UUIDซ้ำ/ปิดกะ/ห้ามแก้หลังปิดใน transaction แล้ว rollback ไม่เหลือกะ/รายการทดลอง
- เปรียบเทียบ password hash ของบัญชีร้านแล้วตรงกัน แต่ยังไม่ได้ให้เจ้าของลอง login ด้วยรหัสผ่านจริงหลังย้าย
- โปรเจกต์เก่าและข้อมูล Game-Shop เดิมเก็บไว้ครบ ไม่ลบหรือปิดเพื่อคงทางย้อนกลับ
- Security advisor: มีคำเตือนค่าเริ่มต้น Leaked Password Protection Disabled; ไม่มี findings ด้าน RLS ของ Game-Shop
