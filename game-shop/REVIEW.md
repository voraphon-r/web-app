# ผลตรวจ PR #6 — Game-Shop

วันที่ตรวจ: 8 พฤศจิกายน 2569 (เวลาไทย)
ต้นทาง: voraphon-r/web-app PR #6, branch `claude/project-thread-m1floy`, commit `b68d3781bf358c806b3798aef4895ed23de7fb48`

## สิ่งที่ตรวจพบ

- อ่าน diff ทั้ง 3 ไฟล์ต้นฉบับ และตรวจ comments/review threads/checks แล้ว ไม่มี review thread จากคน มีแต่ข้อความ Netlify bot
- checks เดิมเป็น Netlify preview ของ kungten-order และ voraphon-tierlist ไม่ใช่ Game-Shop; ไม่มี GitHub Actions workflow run สำหรับ PR commit นี้
- ตรวจ Supabase `voraphon-apps` แบบอ่านอย่างเดียว: ไม่พบตารางหรือ policies ใน schema game_shop จึงยังไม่มีข้อมูลร้านเกมให้ตรวจหรือใช้ทดสอบจริง
- ตรวจ project logs และ security advisors: คำเตือนที่มีเป็นของแอปอื่นใน public schema ไม่ได้เปลี่ยนแปลงสิ่งเหล่านั้น

## สิ่งที่แก้

- กันกดบันทึกซ้อนระหว่างส่ง และส่ง UUID/ข้อมูลเดิมเมื่อผลตอบกลับหาย พร้อมตรวจรายการที่มีอยู่แล้ว เก็บรายการค้างแยกตามบัญชีไว้ในเครื่องเพื่อกลับมาตรวจต่อ
- ตรวจเงินผิดรูปแบบ ติดลบ ทศนิยมเกินสองตำแหน่ง เงินรับไม่พอ และเครื่องนอกช่วง 1–20
- คำนวณยอดรวมด้วยหน่วยสตางค์ และแบ่งหน้าโหลดรายการ ป้องกันยอดขาดเมื่อ API จำกัดจำนวนแถว
- โหลดข้อมูลผิดพลาดจะไม่แสดงเสมือนบันทึกสำเร็จ และปิดการทำรายการจนโหลดครบ มีปุ่มลองใหม่
- กะปิดดูย้อนหลังได้อย่างเดียว ป้องกันการแก้/ลบ/เพิ่มทั้งหน้าเว็บและฐานข้อมูล ห้ามเปิดกะที่ปิดแล้วกลับมาใหม่
- ล็อกแถวกะระหว่างเขียนรายการกับปิดกะ และตรวจยอด/จำนวนรายการในฐานข้อมูลก่อนปิด หากยอดเปลี่ยนให้ตรวจใหม่
- จำกัดสิทธิ์ตารางกะ ลดสิทธิ์ลบข้อมูลทั้งกะ ย้าย helper สมาชิกไป schema ภายใน และถอนสิทธิ์เรียกจากผู้ไม่ล็อกอิน
- setup ทำงานเป็น transaction รันซ้ำได้โดยไม่ลบข้อมูล หากข้อมูลเดิมไม่ผ่านข้อกำหนดจะหยุดทั้งชุด
- รักษาหน้าบันทึกประจำกะ เครื่อง 1–20 ค่าเกม/ค่าน้ำ สด/โอน เงินทอน ตารางและยอดสรุป

## ผลทดสอบ

`node --test game-shop/tests/*.test.cjs` ผ่าน 6/6 ชุด:

- PostgreSQL/PGlite: setup รันซ้ำทั้งฐานว่างและฐานมีข้อมูล, RLS สมาชิก/คนนอก/anon, เปิดกะซ้ำ, เครื่องผิด, จำนวนเงินผิด/NaN, เงินรับไม่พอ, UUID ซ้ำ, แก้และปิดกะ, ยอดเปลี่ยนก่อนปิด, เขียนกะปิดไม่ได้, ห้ามเปลี่ยนกะ/เวลา/ลบทั้งกะ
- ข้อมูลตัวอย่าง 5 รายการ: เงินสด 150 บาท โอน 114 บาท
- ฝั่งหน้าเว็บ: ตัวเลขผิดรูปแบบ, ความแม่นยำสตางค์, submit ซ้อน, ผลตอบกลับหายแล้ว retry ไม่เพิ่มแถว, คง payload เดิม, ส่งรายการค้างหลังอีกเครื่องปิดกะ
- โหลด 1,201 รายการได้ครบ และปิดปุ่มเขียนเมื่อโหลดล้มเหลว
- เงินรับ 100 / ยอด 50 แสดงทอน 50 และกะปิดแก้ไม่ได้

Edge + Playwright ผ่าน: แสดงตารางตัวอย่างและยอดถูกต้อง เครื่องครบ 20 ปุ่ม คิดเงินทอน และซ่อนฟอร์มกะปิด; หน้ากว้าง 360/390/768/1280 ไม่มี horizontal overflow และไม่มี JavaScript error. ใช้ Supabase mock ในเบราว์เซอร์ ภาพผลอยู่ที่ test-output/game-shop-mobile.png (ไม่นำเข้าประวัติโค้ด)

`git diff --check` ผ่าน

## สิ่งที่ยังต้องทำก่อนเปิดร้านใช้จริง

- อนุมัติการนำ setup ไปใช้กับ Supabase จริง เพิ่ม exposed schema และสมาชิกที่เจ้าของร้านเลือก แล้วทดสอบ login/REST/Realtime ด้วยบัญชีร้านจริง
- ทดสอบเปิดพร้อมกันและบันทึกแข่งกับปิดกะบนสองเครื่องที่เชื่อมฐานจริง การทดสอบในเครื่องครั้งนี้ยืนยัน constraints/logic แต่ไม่ได้ทดสอบการเชื่อมต่อ Supabase จริงหรือการแข่งขันบนสอง connection จริง
- ตั้ง Netlify ให้ชี้ game-shop/public โดยเฉพาะ checks ของแอปอื่นใช้รับรอง Game-Shop ไม่ได้
- การ push branch เดิมกระตุ้น Netlify deploy preview อัตโนมัติ จึงเก็บการแก้ไขเป็น local commit ก่อนตามข้อห้าม deploy

ยังไม่ได้ push, merge, deploy หรือเปลี่ยนฐานข้อมูลจริง จึงยังไม่รับรองว่าระบบพร้อมเปิดใช้งานจริงจนกว่าผ่านขั้นตอนข้างต้น

## อัปเดตหลังอนุมัติ

- ผู้ใช้อนุมัติ push และตั้งฐานข้อมูล พร้อมเพิ่มเครื่องจาก 12 เป็น 20
- ทดสอบซ้ำผ่าน 6/6; Edge เลือกเครื่อง 20 ได้และตรวจ responsive ทั้ง 4 ขนาดผ่าน
- ใช้ migration game_shop_shift_log_twenty_machines และ expose_game_shop_api_preserve_existing_schemas กับ Supabase จริงสำเร็จ
- ตาราง members/shifts/shift_entries มี RLS ครบ; Realtime publication ครบ; constraint เครื่อง 1–20 ถูกต้อง
- เพิ่มสมาชิกตามอีเมลผู้ใช้ระบุแล้ว แต่ยังไม่มี Auth user ของอีเมลนั้น ต้องให้เจ้าของสร้างบัญชี/ตั้งรหัสผ่านเองก่อนตรวจ login จริง
- ทดสอบฐานจริงด้วย authenticated role + JWT claims จำลองภายใน transaction แล้ว rollback: เครื่อง 20 ผ่าน, 21 ไม่ผ่าน, UUID ซ้ำไม่ผ่าน, close_shift ผ่าน และแก้หลังปิดไม่ได้; non-member เขียนไม่ได้
- ไม่เหลือข้อมูลกะ/รายการจากการทดสอบ ข้อมูลสมาชิกที่ผู้ใช้อนุญาตยังอยู่
- REST ยืนยันว่า game_shop expose แล้วและคง public/graphql_public/kungten_order ครบ; anon ถูกปฏิเสธด้วย 401/42501
- ใช้ role authenticator override pgrst.db_schemas; บันทึกข้อควรทำหากปรับ Dashboard settings ใน README
- security advisor หลังเปลี่ยนไม่มี findings เพิ่มใน game_shop; warnings เดิมของแอปอื่นไม่ถูกแก้
- Computer Use หยุดเพราะไม่สามารถยืนยัน browser URL จึงไม่มีการแก้ Dashboard ผ่าน UI; ใช้ Supabase connector ที่ได้รับอนุมัติตั้ง API แทน
- รายงานก่อนหน้านี้เป็นสถานะก่อนอนุมัติ ให้ยึดอัปเดตส่วนนี้เป็นสถานะปัจจุบัน; ยังไม่ merge หรือเปิด Netlify production ของ Game-Shop

## แยก Database/Auth/Storage หลังผู้ใช้อนุมัติองค์กร

สร้างโปรเจกต์ game-shop เฉพาะในองค์กร voraphon.r@gmail.com ref ncbjaeitjcpoayvkadwn และเปลี่ยนการเชื่อมต่อหน้าเว็บเฉพาะ Game-Shop; Todo และ Kungten ไม่เปลี่ยนแปลง

คัดลอกสมาชิกและเฉพาะบัญชี Auth/identity ของ Game-Shop พร้อม password hash เดิม (ตรวจเทียบตรงกัน) ไม่ย้าย session หรือ token. ไม่มีกะ/รายการ/Storage ของ Game-Shop ต้นทางให้คัดลอก. เก็บต้นทางไว้ทั้งหมด

ทดสอบ Auth login จริงด้วยบัญชีทดสอบใหม่, REST non-member read/insert, anon access ผ่าน. ทดสอบ SQL กะ/เครื่อง20/กันซ้ำ/ปิดกะ ผ่านและ rollback. Cleanup บัญชีทดสอบแล้ว เหลือ Auth1/member1/shift0/entry0/bucket0/object0

เพิ่ม regression test ป้องกันกลับไปใช้ Supabase ของ Todo หรือ Kungten. รหัสผ่านบัญชีร้านยังใช้เดิม ต้องเข้าสู่ระบบใหม่; ไม่ได้ทดสอบรหัสผ่านจริงของเจ้าของเพราะไม่ขอรับรหัสผ่าน

## สถานะล่าสุด: กลับใช้ voraphon-apps เพื่อประหยัดโควต้า

ผู้ใช้ยกเลิกการใช้โปรเจกต์แยก game-shop. หน้าเว็บกลับไปใช้ qfxqjpqpytkaymlyjuuz และ schema game_shop ร่วมโปรเจกต์ voraphon-apps กับ Kungten (schema kungten_order) แต่ยังแยกจาก Todo ที่ rfmkmerdiusocpflyhoq

ตรวจเทียบก่อนเปลี่ยน: ทั้งสองโปรเจกต์มีสมาชิก/บัญชีร้านคนเดิม ต้นทางแยกยังไม่มีกะ รายการขาย bucket หรือ object ใหม่ จึงไม่มีข้อมูลที่ต้องคัดลอกกลับ. ไม่แก้บัญชีหรือข้อมูล Todo/Kungten

ทดสอบ 7/7 ผ่าน และ SQL บน voraphon-apps ตรวจสมาชิก เปิดกะ บันทึกเครื่อง20 และปิดกะผ่านใน transaction แล้ว rollback ไม่เหลือยอดทดลอง. ใช้อีเมลและรหัสผ่านเดิมของ voraphon-apps

การลบโปรเจกต์แยกและการเปิด Todo ที่ pause ให้ตรวจสถานะจริงจาก Supabase; บันทึกการแยกโปรเจกต์ก่อนหน้านี้เป็นประวัติ ไม่ใช่การเชื่อมต่อปัจจุบัน

## ยืนยันยกเลิกโปรเจกต์แยกสำเร็จ

ผู้ใช้ยืนยันลบถาวร ณ ขั้นตอนจริงแล้ว และลบ ncbjaeitjcpoayvkadwn สำเร็จ ตรวจรายชื่อ Supabase เหลือ voraphon-apps และ voraphon.r@gmail.com's Project ทั้งคู่ ACTIVE_HEALTHY. Todo กลับมาเปิดแล้วโดยไม่แก้ข้อมูล

Game-Shop ปัจจุบันใช้ qfxqjpqpytkaymlyjuuz/schema game_shop ตาม commit 2f180ce. README ปรับให้เป็นสถานะปัจจุบันและลบขั้นตอนที่ชวนให้เชื่อมไปโปรเจกต์ที่ถูกลบแล้ว เหลือตั้ง Netlify เฉพาะ Game-Shop และทดสอบเจ้าของ login บน URL จริง

## เปิดเว็บ Netlify จริงแล้ว

เผยแพร่ https://game-shop-voraphon.netlify.app/ ผ่าน Netlify project 5e70976f-2d58-4e98-92e3-5e9517cfaa69 จาก branch PR เดิม publish game-shop/public โดยไม่ merge. ผู้ใช้ยืนยันเปลี่ยน Production visibility เป็น Public และ Deploy Preview visibility เป็น Private แล้ว บันทึกสำเร็จ ตรวจเปิดหน้า Login จริงผ่าน Chrome โดยไม่ผ่าน Netlify team login. ยังไม่ได้ใช้รหัสผ่านเจ้าของเข้าสู่ระบบจริงหลังเผยแพร่ ต้องให้เจ้าของทำเองและตรวจ Realtime สองเครื่องต่อ
