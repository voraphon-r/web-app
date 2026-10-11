# Kungten-Order (ร้านกุ้งเต้น)

เว็บหน้าเดียว ลิงก์เดียว: ด้านบนเลือก/สร้างการจอง (หัวข้องาน วันที่ รอบ ห้อง จองในนาม มัดจำ) ด้านล่างให้หลายคนสั่งอาหารเข้ารายการของงานนั้น ไม่ต้องล็อกอิน
ทุกเครื่องเห็นรายการรวมทันที (Supabase Realtime)

- หน้าเว็บ: `public/index.html` (ไฟล์เดียว)
- ฐานข้อมูล: `supabase/setup.sql` สร้าง schema `kungten_order` (ตาราง `menu_items`, `bookings`, `orders`) + ใส่เมนู
- ใช้ Supabase โปรเจกต์ที่ใช้ร่วมกันหลายแอป (`voraphon-apps`) แต่ละแอปอยู่คนละ schema

## ตั้งค่าครั้งแรก

1. Supabase: สร้างโปรเจกต์ `voraphon-apps` (ถ้ายังไม่มี)
2. SQL Editor > วางเนื้อหา `supabase/setup.sql` > Run
3. Project Settings > Data API > Exposed schemas > เพิ่ม `kungten_order` > Save
4. Project Settings > API Keys > คัดลอก Project URL และ Publishable key ไปใส่ `SUPABASE_URL` / `SUPABASE_KEY` ใน `public/index.html`
5. Deploy: ลากโฟลเดอร์ `public/` ไปวางใน Netlify (Add new project > Deploy manually)

## หมายเหตุเมนู

- เมนูที่มีหลายราคา (เช่น 95/190/380) ใช้ป้าย เล็ก/กลาง/ใหญ่ ซึ่งเดาเอา เพราะเมนูร้านเขียนแค่ตัวเลข
- เมนู "ขีดละ" จำนวนที่สั่ง = กี่ขีด ยอดรวมเป็นราคาประมาณ
- แก้เมนู/ราคา: แก้ในตาราง `kungten_order.menu_items` ผ่าน Table Editor ได้เลย (ปิดเมนูด้วย `available = false`)
- **อย่ารัน `setup.sql` ซ้ำหลังใช้งานจริง** เพราะจะล้างรายการสั่งทั้งหมด
