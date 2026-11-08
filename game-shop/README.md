# Game-Shop — บันทึกประจำกะร้านเกม

เว็บใช้งานจริง: https://game-shop-voraphon.netlify.app/ (เผยแพร่ 8 พฤศจิกายน 2569)
Production เปิดถึงหน้า Login ได้โดยไม่ต้องมีบัญชี Netlify; Deploy Previews เป็น Private. ข้อมูลกะยังต้องล็อกอิน Supabase และเป็นสมาชิก Game-Shop

Netlify project: game-shop-voraphon, ID 5e70976f-2d58-4e98-92e3-5e9517cfaa69. เชื่อม branch claude/project-thread-m1floy ของ PR #6 ซึ่งยังไม่ merge

เว็บหน้าเดียวสำหรับเปิดกะ บันทึกลูกค้า และปิดกะ รองรับเครื่อง 1–20 ค่าเกม ค่าน้ำ/ขนม เงินสด/โอน และคิดเงินทอน

## การเชื่อมต่อปัจจุบัน

- Supabase: **voraphon-apps** (`qfxqjpqpytkaymlyjuuz`), URL `https://qfxqjpqpytkaymlyjuuz.supabase.co`
- ข้อมูล Game-Shop อยู่ใน schema `game_shop`: `members`, `shifts`, `shift_entries`; helper ภายในอยู่ `game_shop_private` ซึ่งไม่ expose ผ่าน API
- ใช้โปรเจกต์ร่วมกับ Kungten แต่แยก schema; Todo ใช้อีกโปรเจกต์ (`rfmkmerdiusocpflyhoq`) และไม่ได้แก้ข้อมูล Todo
- โปรเจกต์แยก `game-shop` เดิมถูกลบแล้วตามคำขอประหยัดโควต้า ห้ามนำ URL/key ของโปรเจกต์ที่ลบกลับมาใช้
- บัญชีร้านและสมาชิกตั้งไว้บน voraphon-apps แล้ว ใช้อีเมลและรหัสผ่านเดิมของโปรเจกต์นี้
- Game-Shop ยังไม่มีฟังก์ชันอัปโหลด และไม่มี bucket/ไฟล์ที่ต้องย้าย

## การตั้งเว็บ Netlify ที่ใช้อยู่

สร้างโปรเจกต์ Netlify สำหรับ Game-Shop แล้ว ไม่แก้โปรเจกต์ของ Todo หรือ Kungten

| ช่อง | ค่า |
|---|---|
| Repository | `voraphon-r/web-app` |
| Branch | `claude/project-thread-m1floy` (PR #6 ยังไม่ merge) |
| Base directory | เว้นว่าง |
| Build command | เว้นว่าง |
| Publish directory | `game-shop/public` |

หน้าเว็บเป็น HTML แบบ static และมี publishable key สำหรับ browser อยู่แล้ว ไม่ต้องใส่ service-role key ใน Netlify หรือหน้าเว็บ

Netlify previews ที่ผูกกับ PR เดิมเป็นของ kungten-order และ voraphon-tierlist จึงใช้ยืนยันว่า Game-Shop เปิดให้ใช้งานแล้วไม่ได้ ตรวจเว็บ Game-Shop เปิดถึงหน้า Login แล้ว; ขั้นถัดไปให้เจ้าของทดสอบ login/เปิดกะ/เครื่อง20/สด/โอน/เงินทอน/ปิดกะ/ย้อนหลัง/Realtime สองหน้าต่างจริง

## ตั้ง Supabase กรณีเริ่มต้นใหม่

การตั้งบนโปรเจกต์ voraphon-apps ที่ใช้อยู่ทำแล้ว ไม่ต้องรันซ้ำสำหรับการเปิดเว็บ Netlify

1. รัน `supabase/setup.sql` ในโปรเจกต์ปลายทางที่ตรวจยืนยันแล้วเท่านั้น ไฟล์ทำงานเป็น transaction และไม่ลบข้อมูลเดิม
2. Expose `game_shop` ใน Data API โดยคง schema ของแอปอื่นทั้งหมด และไม่ expose `game_shop_private`
3. สร้างบัญชีที่ Authentication > Users และเพิ่มเฉพาะอีเมลที่เจ้าของอนุญาตใน `game_shop.members`
4. ตรวจ RLS และให้ `shifts`/`shift_entries` อยู่ใน Realtime publication

โปรเจกต์ voraphon-apps ตั้ง `pgrst.db_schemas` เป็น role override ของ authenticator ไว้: public, graphql_public, kungten_order, game_shop. หากปรับ Exposed schemas ผ่าน Dashboard ในอนาคต ต้องปรับ override ให้สอดคล้องกัน หรือ reset override หลังบันทึกค่าที่ต้องการใน Dashboard แล้ว

## ความถูกต้องของข้อมูล

- เปิดกะได้ทีละกะ และเครื่องอยู่ระหว่าง 1–20 ทั้งหน้าเว็บและฐานข้อมูล
- ตัวเลขไม่ติดลบ ทศนิยมไม่เกิน 2 ตำแหน่ง เงินรับต้องไม่น้อยกว่ายอดขาย; คำนวณสรุปด้วยหน่วยสตางค์
- กัน submit ซ้อน ส่ง UUID/ข้อมูลเดิมเมื่อผลตอบกลับหาย และเก็บรายการค้างแยกตามบัญชีเพื่อ retry
- โหลดรายการแบบแบ่งหน้า; หากโหลดไม่ครบจะปิดปุ่มทำรายการและให้ลองโหลดใหม่
- แก้/ลบได้เฉพาะกะเปิด กะปิดดูย้อนหลังได้อย่างเดียว มี trigger ป้องกันที่ฐานข้อมูล
- ปิดกะผ่าน `close_shift` ซึ่งล็อกกะร่วมกับการเขียนและตรวจยอด/จำนวนรายการอีกครั้งก่อนปิด
- ยอดสดคือรายรับกะ ไม่รวมเงินทอนตั้งต้นหรือรายจ่าย

## ผลตรวจและการทดสอบ

รายละเอียดอยู่ใน `REVIEW.md` ซึ่งมีประวัติการเปลี่ยนโปรเจกต์ ให้ยึดหัวข้อการเชื่อมต่อปัจจุบันในเอกสารนี้เป็นหลัก

ใช้ Node.js 24 และ pnpm ในโฟลเดอร์ game-shop: `pnpm install --frozen-lockfile` แล้ว `pnpm test`

ชุดทดสอบผ่าน 7/7 ครอบคลุม PostgreSQL/PGlite, RLS/constraints, กันซ้ำ, กะปิด, เงินทอน, pagination 1,201 แถว และการเชื่อมไป voraphon-apps โดยแยกจาก Todo

SQL บน voraphon-apps ทดสอบเปิดกะ/เครื่อง20/บันทึก/ปิดกะผ่านใน transaction แล้ว rollback ไม่เหลือยอดทดลอง. ยังต้องตรวจ login ของเจ้าของและ Realtime สองหน้าต่างบน URL Game-Shop จริง

ตรวจหน้าจอเพิ่มเติมด้วย Playwright 1.62.1 + Microsoft Edge: `node tests/browser.cjs` (หรือตั้ง PLAYWRIGHT_MODULE เป็นตำแหน่งโมดูล) ใช้ข้อมูลจำลอง ไม่ติดต่อฐานจริง ผลภาพอยู่ test-output/
