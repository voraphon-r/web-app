# งานที่จะทำต่อ (todo-app)

บันทึกไว้เมื่อ 2026-10-08

## สถานะตอนนี้
- **ออนไลน์แล้ว:** https://todo.voraphon.com (Netlify, 2026-10-08)
  - ชื่อเดิม https://spiffy-semolina-c84975.netlify.app ยังใช้ได้
  - โดเมน voraphon.com ซื้อที่ Cloudflare Registrar (ต่ออายุอัตโนมัติ หมดอายุ 8 ต.ค. 2027)
  - DNS ที่ Cloudflare: CNAME `todo` → `spiffy-semolina-c84975.netlify.app` (ต้องเป็น DNS only / เมฆสีเทา)
    และ TXT `subdomain-owner-verification` สำหรับยืนยันกับ Netlify (ห้ามลบ)
  อัปเดตเว็บ: ลากโฟลเดอร์ `public` ไปวางในหน้า Deploys ของเว็บนี้ใน Netlify
- ตัวแอปอยู่ที่ `public/index.html` ไฟล์เดียว ต้องล็อกอินก่อนใช้งาน
- **เอาขึ้นเว็บเฉพาะโฟลเดอร์ `public/` เท่านั้น** ห้ามอัปโหลดทั้งโฟลเดอร์ (มี `.mcp.json`, `routine/` ที่เป็นข้อมูลส่วนตัว)
- **ค้างไว้ก่อนแชร์ให้คนอื่น:**
  - เปลี่ยนรหัส admin และ user01 ให้ต่างกัน และไม่มีเบอร์โทรอยู่ในรหัส (ใช้ SQL `update auth.users set encrypted_password = extensions.crypt('...', extensions.gen_salt('bf')) where email = '...';`)
  - สร้างรหัสสำรอง (backup codes) ของบัญชี Google เพราะ Cloudflare ล็อกอินผ่าน Google
- ดูหน้าเว็บในเครื่อง: ใช้ config `todo-app` ใน `.claude/launch.json` (python http.server พอร์ต 5500)

## แผน
1. ~~**ล็อกอินและแยกข้อมูลของแต่ละคน**~~ ทำแล้ว 2026-10-08 (รอทดสอบล็อกอินจริง)
   - ล็อกอินด้วยชื่อผู้ใช้ + รหัสผ่าน (เบื้องหลังเป็นอีเมล `ชื่อ@todo-app.example`)
   - ตาราง `profiles` เก็บ `username` และ `role` (`admin` / `user`) สร้างอัตโนมัติเมื่อเพิ่มบัญชี
   - user เห็นและแก้ได้เฉพาะงานตัวเอง admin เห็นและจัดการได้ทุกงาน
   - ปิดการสมัครเอง: เพิ่มบัญชีใหม่ได้ที่ Supabase → Authentication → Users → Add user (ติ๊ก Auto Confirm)
   - ตั้งใครเป็น admin: `update public.profiles set role = 'admin' where username = '...';`
   - SQL ที่ใช้: `supabase/migrations/20261008_add_auth_profiles_and_per_user_todos.sql`
   - **ก่อนแชร์ลิงก์: เปลี่ยนรหัส admin เป็นรหัสยาว**
2. ~~**แนบรูปภาพ**~~ ทำแล้ว 2026-10-08 (รอทดสอบอัปโหลดจริง)
   - bucket `todo-images` เป็น private รับเฉพาะ WebP/JPEG ไม่เกิน 2 MB ไฟล์เก็บที่ `<user_id>/<uuid>.webp`
   - SQL ที่ใช้: `supabase/migrations/20261008_add_todo_images.sql`
   - บีบอัดในเบราว์เซอร์ (ด้านยาวไม่เกิน ~1280px, WebP/JPEG คุณภาพ ~80%)
   - เก็บไฟล์ใน Supabase Storage bucket `todo-images` และเก็บชื่อไฟล์ในคอลัมน์ `image_path`
   - ตั้งกฎ Storage ให้แต่ละคนเข้าถึงได้เฉพาะรูปของตัวเอง
   - ถ้าพื้นที่ใกล้เต็มค่อยย้ายไป Cloudflare R2 (ไม่ใช้ Google Drive เพราะต้องมีเซิร์ฟเวอร์ถือสิทธิ์ และลิงก์ Drive เอาไปแสดงเป็นรูปตรงๆ ไม่ได้)
3. **เอาขึ้นเว็บ**: Netlify Drop หรือ Cloudflare Pages แล้วแชร์ลิงก์
