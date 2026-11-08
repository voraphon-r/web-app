# Game-Shop (บันทึกประจำกะ ร้านเกม)

เว็บหน้าเดียวแทนสมุดบันทึกกะ สำหรับคนที่เข้ากะ: เปิดกะ > บันทึกลูกค้าทีละราย > ปิดกะ
ต้องเข้าสู่ระบบ (แนะนำบัญชีร้าน 1 บัญชี ล็อกอินค้างไว้ที่เครื่องในร้าน) ทุกเครื่องเห็นรายการทันที (Supabase Realtime)

- หน้าเว็บ: `public/index.html` (ไฟล์เดียว) จำนวนเครื่องตั้งที่ `MACHINE_COUNT`
- ฐานข้อมูล: `supabase/setup.sql` สร้าง schema `game_shop` (ตาราง `members`, `shifts`, `shift_entries`)
- ใช้ Supabase โปรเจกต์ที่ใช้ร่วมกันหลายแอป (`voraphon-apps`) แต่ละแอปอยู่คนละ schema

## ทำอะไรได้

- เปิดกะ (ใส่ชื่อคนเข้ากะ) เปิดได้ทีละ 1 กะ
- บันทึกลูกค้า 1 ราย = เครื่องที่เล่น, ค่าเกม, ค่าน้ำ/ขนม, จ่ายสดหรือโอน (เวลาบันทึกอัตโนมัติ)
- จ่ายสด: ใส่เงินที่รับมา แล้วแสดงเงินทอนให้
- ตารางแบบสมุด: เวลา | เครื่อง | ค่าเกม | ค่าน้ำ | โอน | สด พร้อมยอดรวม จำนวนรายการ เงินสด โอน
- แตะแถวเพื่อแก้หรือลบ, ปิดกะ (แสดงยอดเงินสดให้นับลิ้นชัก), ดูกะที่ผ่านมา 10 กะล่าสุด

## ตั้งค่าครั้งแรก

1. Supabase (โปรเจกต์ voraphon-apps) > SQL Editor > วางเนื้อหา `supabase/setup.sql` > Run
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
