# Game-Shop (บัญชีร้านเกม)

เว็บหน้าเดียวสำหรับบันทึกรายรับและรายจ่ายของร้านเกม ต้องเข้าสู่ระบบ (อีเมล + รหัสผ่าน) และอีเมลต้องอยู่ในรายชื่อสมาชิกของแอป
ทุกเครื่องเห็นรายการใหม่ทันที (Supabase Realtime)

- หน้าเว็บ: `public/index.html` (ไฟล์เดียว)
- ฐานข้อมูล: `supabase/setup.sql` สร้าง schema `game_shop` (ตาราง `members`, `categories`, `entries`)
- ใช้ Supabase โปรเจกต์ที่ใช้ร่วมกันหลายแอป (`voraphon-apps`) แต่ละแอปอยู่คนละ schema

## ทำอะไรได้

- บันทึกรายรับ/รายจ่าย: จำนวนเงิน หมวดหมู่ วันที่ ช่องทาง (เงินสด/โอน/บัตร/อื่นๆ) หมายเหตุ
- สรุปรายเดือน: รายรับ รายจ่าย คงเหลือ, รายการแยกตามวัน, แยกตามหมวดหมู่
- แตะรายการเพื่อแก้หรือลบ, เก็บว่าใครบันทึก/แก้ล่าสุด
- ดาวน์โหลดรายการของเดือนเป็น CSV (เปิดใน Excel ได้ ภาษาไทยไม่เพี้ยน)

## ตั้งค่าครั้งแรก

1. Supabase (โปรเจกต์ voraphon-apps) > SQL Editor > วางเนื้อหา `supabase/setup.sql` > Run
2. Integrations > Data API > Settings > Exposed schemas > เพิ่ม `game_shop` > Save
3. Authentication > Users > Add user > Create new user: ใส่อีเมล + รหัสผ่านของคนที่จะใช้ (ติ๊ก Auto Confirm User)
4. SQL Editor: เพิ่มอีเมลนั้นเป็นสมาชิก
   ```sql
   insert into game_shop.members (email, display_name) values ('อีเมล@ตัวพิมพ์เล็ก', 'ชื่อเล่น');
   ```
5. Deploy: Netlify > Add new project > Import from GitHub > `voraphon-r/web-app`, Publish directory = `game-shop/public`
   แล้วตั้งโดเมน เช่น `game.voraphon.com` (Cloudflare CNAME `game` -> `<ชื่อโปรเจกต์>.netlify.app`, DNS only)

## หมายเหตุ

- หน้าเว็บไม่มีปุ่มสมัครสมาชิก เพิ่มคนใช้งานได้ทางข้อ 3-4 เท่านั้น คนที่ล็อกอินได้แต่ไม่อยู่ใน `members` จะดูข้อมูลไม่ได้ (คุมด้วย RLS)
- แก้/เพิ่มหมวดหมู่: ตาราง `game_shop.categories` ใน Table Editor (ซ่อนด้วย `active = false`)
- `setup.sql` รันซ้ำได้ ไม่ลบรายการที่บันทึกไว้
