# งานที่จะทำต่อ (Web_App)

บันทึกไว้เมื่อ 2026-10-08 · อัปเดตล่าสุด 2026-10-10

## สิ่งที่ทำแล้ว (สรุปเมื่อ 2026-10-10)

สรุปงาน 2 วันล่าสุด ส่วนแผนเดิมของ todo-app อยู่ด้านล่าง ยังทำต่อตามเดิม

### GitHub และโฟลเดอร์งาน
- สมัคร/เชื่อม GitHub กับ Claude แล้ว เปลี่ยนชื่อบัญชีจาก `RujeeP` เป็น **`voraphon-r`** (ลิงก์ชื่อเก่ายัง redirect ให้ จนกว่าจะมีคนอื่นมาจดชื่อ RujeeP)
- ย้ายโฟลเดอร์ `C:\dev\todo-app` → **`C:\dev\Web_App`** ทำเป็น git และเอาขึ้น repo **voraphon-r/web-app** (Public)
  - `.gitignore` กันไฟล์ส่วนตัวไว้แล้ว: `.mcp.json`, `routine/`, `.claude/settings.local.json`, `Note.txt`
- ตั้ง repo ในหน้าตั้งค่าโปรเจกต์ Claude เป็น voraphon-r/web-app และเพิ่ม voraphon-r/voraphon.com
- เขียน `claude-structure.md` อธิบายโครงสร้างแอป Claude (Chat / Cowork / Code)

### เว็บส่วนตัว (personal website) www.voraphon.com
- ทำจาก Resume ใช้สีธีมเดียวกับ Resume เลือกโครงแบบ **B (หน้าเดียว)** มีส่วนหัวพร้อมรูปและปุ่มติดต่อ, เกี่ยวกับ, ประสบการณ์, ผลงาน, ทักษะ, การศึกษา, ติดต่อ
- ตัดข้อมูลส่วนตัวออก (เบอร์โทร ที่อยู่ วันเกิด เกรด ข้อมูลบุคคลอ้างอิง)
- หัวข้อ **ผลงาน** มีการ์ด To-do App ลิงก์ไป todo.voraphon.com
- เพิ่ม LinkedIn, ปุ่มดาวน์โหลด Resume PDF ฉบับสาธารณะ (ไทย/อังกฤษ), หน้าอังกฤษ `/en` พร้อมปุ่มสลับ TH/EN, favicon ตัว V สีเขียว
- ที่เก็บโค้ด: repo **voraphon-r/voraphon.com** (Private) โฟลเดอร์บนเครื่อง **`C:\dev\voraphon.com`** เป็น git clone ของ repo นี้แล้ว (ของเดิมสำรองไว้ที่ `C:\dev\voraphon.com.bak`)
- ฝากเว็บ (hosting): Netlify โปรเจกต์ `voraphon` ผูกกับ GitHub แล้ว **push ขึ้น main เมื่อไหร่ เว็บอัปเดตเอง** (voraphon.netlify.app, Public)
- โดเมน/DNS ที่ Cloudflare: `A voraphon.com → 75.2.60.5` และ `CNAME www → voraphon.netlify.app` (DNS only / เมฆสีเทา) ส่วน record `todo` ไม่ได้แตะ
- ไฟล์ต้นฉบับที่ใช้สร้างหน้าเว็บและ Resume PDF อยู่ในไฟล์โปรเจกต์ Claude (`voraphon.com/source/build.py`, `resume.py`)

### เครื่องมือบนเครื่อง
- VS Code ล็อกอิน GitHub ด้วยบัญชี voraphon-r แล้ว และติดตั้ง extension **Claude Code** (ของ Anthropic) เป็น side panel
- ลำดับการแก้งานบนเครื่อง: `git pull` → แก้ไฟล์ → `git add .` → `git commit -m "..."` → `git push`

### การตัดสินใจ
- โปรเจกต์ใหม่ที่ต้องใช้ฐานข้อมูล ให้ใช้ Supabase โปรเจกต์ที่ 2 ร่วมกัน ตั้งชื่อกลางๆ เช่น **`voraphon-apps`** แล้วแยกแต่ละแอปเป็น schema ของตัวเอง (แพ็กเกจฟรีเปิดได้ 2 โปรเจกต์) ส่วน todo-app ใช้โปรเจกต์ของตัวเองต่อ
- GitHub เก็บโค้ดและไฟล์เล็กที่เว็บใช้ ส่วนไฟล์ใหญ่และไฟล์ส่วนตัว (เช่น Resume ฉบับเต็ม) เก็บใน Google Drive
- โฟลเดอร์ Google Drive `800 Google Site\Web App` เป็นงานเก่าสมัยหัดใช้ Claude ไม่ต้องย้ายมา

## ขั้นต่อไป (อัปเดต 2026-10-10)
1. **เปลี่ยนรหัส admin และ user01 ของ todo-app** ให้ยาว ไม่ซ้ำกัน ไม่มีเบอร์โทร (ด่วน เพราะ repo web-app เป็น Public แล้ว) จากนั้นลบ `C:\dev\Note.txt`
2. **ย้าย `Resume_Voraphon_2026-rev2.pdf` ออกจาก `C:\dev\Web_App`** ไปไว้ Google Drive หรือ `C:\dev` ตรงๆ (มีเบอร์โทรและที่อยู่ ห้ามขึ้น GitHub)
3. ทดสอบล็อกอินและอัปโหลดรูปใน todo.voraphon.com ของจริง (ข้อ 1–2 ในแผนเดิม)
4. สร้างรหัสสำรอง (backup codes) ของบัญชี Google
5. ตรวจคำแปลหน้าอังกฤษของเว็บส่วนตัว โดยเฉพาะชื่อตำแหน่งและใบอนุญาต กว. ("ภาคี" แปลเป็น Associate Engineer)
6. รอ Netlify ออกใบรับรอง HTTPS ของ voraphon.com แล้วเปิดเช็กทั้ง voraphon.com และ www
7. อัปเดตข้อมูลใน LinkedIn ให้ตรงกับเว็บ
8. ลบโฟลเดอร์ที่ไม่ใช้แล้ว: `C:\dev\todo-app` (ว่าง) และ `C:\dev\voraphon.com.bak` (เมื่อแน่ใจว่าไม่ต้องใช้)
9. (ทางเลือก) ผูก todo.voraphon.com กับ GitHub แบบเดียวกับเว็บส่วนตัว จะได้ไม่ต้องลากโฟลเดอร์ `public` ไปวางเองทุกครั้ง

## สถานะตอนนี้ (ของ todo-app, บันทึก 2026-10-08)
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
