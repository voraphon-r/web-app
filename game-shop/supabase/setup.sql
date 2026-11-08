-- Game-Shop: บันทึกรายรับรายจ่ายร้านเกม
-- รันไฟล์นี้ใน Supabase SQL Editor ของโปรเจกต์ที่ใช้ร่วมกัน (voraphon-apps)
-- ทุกอย่างของแอปนี้อยู่ใน schema "game_shop" แยกจากแอปอื่น
-- รันซ้ำได้ ไม่ลบข้อมูลที่บันทึกไว้ (หมวดหมู่ตั้งต้นจะใส่เฉพาะตอนตารางยังว่าง)

create schema if not exists game_shop;

-- สมาชิก: อีเมลที่อนุญาตให้ใช้แอปนี้ (ต้องมีบัญชีใน Authentication > Users ด้วย)
create table if not exists game_shop.members (
  email        text primary key check (email = lower(email)),
  display_name text not null check (char_length(btrim(display_name)) between 1 and 40),
  created_at   timestamptz not null default now()
);

-- หมวดหมู่ของรายรับ/รายจ่าย (แก้ชื่อ เพิ่ม หรือซ่อนได้ใน Table Editor)
create table if not exists game_shop.categories (
  id         bigint generated always as identity primary key,
  kind       text    not null check (kind in ('income', 'expense')),
  name       text    not null check (char_length(btrim(name)) between 1 and 40),
  sort_order integer not null default 0,
  active     boolean not null default true,
  unique (kind, name)
);

-- รายการ: 1 แถว = รายรับหรือรายจ่าย 1 รายการ
create table if not exists game_shop.entries (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  entry_date     date    not null default (now() at time zone 'Asia/Bangkok')::date,
  kind           text    not null check (kind in ('income', 'expense')),
  category       text    not null check (char_length(btrim(category)) between 1 and 40),
  amount         numeric(12,2) not null check (amount > 0),
  payment_method text    not null default 'เงินสด' check (payment_method in ('เงินสด', 'โอน', 'บัตร', 'อื่นๆ')),
  note           text    check (note is null or char_length(note) <= 200),
  created_by     text    not null default lower(auth.jwt() ->> 'email'),
  updated_by     text
);
create index if not exists entries_entry_date_idx on game_shop.entries (entry_date);

-- ใครแก้ล่าสุด และเวลาแก้
create or replace function game_shop.touch_entry() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  new.updated_by := lower(auth.jwt() ->> 'email');
  new.created_by := old.created_by;
  return new;
end $$;
drop trigger if exists entries_touch on game_shop.entries;
create trigger entries_touch before update on game_shop.entries
  for each row execute function game_shop.touch_entry();

-- เช็กว่าคนที่ล็อกอินอยู่เป็นสมาชิกของแอปนี้หรือไม่
create or replace function game_shop.is_member() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from game_shop.members m
    where m.email = lower(auth.jwt() ->> 'email')
  )
$$;

-- สิทธิ์: ต้องล็อกอิน และอีเมลต้องอยู่ในตาราง members (ไม่ให้ anon เข้าถึงเลย)
revoke all on all tables in schema game_shop from anon;
grant usage on schema game_shop to authenticated;
grant execute on function game_shop.is_member() to authenticated;
grant select on game_shop.members to authenticated;
grant select on game_shop.categories to authenticated;
grant select, insert, update, delete on game_shop.entries to authenticated;

alter table game_shop.members    enable row level security;
alter table game_shop.categories enable row level security;
alter table game_shop.entries    enable row level security;

drop policy if exists "members see members" on game_shop.members;
create policy "members see members" on game_shop.members
  for select to authenticated using (game_shop.is_member());

drop policy if exists "members read categories" on game_shop.categories;
create policy "members read categories" on game_shop.categories
  for select to authenticated using (game_shop.is_member());

drop policy if exists "members read entries"   on game_shop.entries;
drop policy if exists "members add entries"    on game_shop.entries;
drop policy if exists "members change entries" on game_shop.entries;
drop policy if exists "members delete entries" on game_shop.entries;
create policy "members read entries"   on game_shop.entries for select to authenticated using (game_shop.is_member());
create policy "members add entries"    on game_shop.entries for insert to authenticated with check (game_shop.is_member());
create policy "members change entries" on game_shop.entries for update to authenticated using (game_shop.is_member()) with check (game_shop.is_member());
create policy "members delete entries" on game_shop.entries for delete to authenticated using (game_shop.is_member());

-- Realtime: ทุกเครื่องเห็นรายการใหม่ทันที
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'game_shop' and tablename = 'entries'
  ) then
    alter publication supabase_realtime add table game_shop.entries;
  end if;
end $$;

-- หมวดหมู่ตั้งต้น (ใส่เฉพาะครั้งแรก)
insert into game_shop.categories (kind, name, sort_order)
select v.kind, v.name, v.sort_order
from (values
  ('income',  'ค่าเล่นเกม (รายชั่วโมง)', 10),
  ('income',  'ขายขนม/เครื่องดื่ม',       20),
  ('income',  'ขายบัตรเติมเงิน/ไอเท็ม',   30),
  ('income',  'รายรับอื่นๆ',              90),
  ('expense', 'ค่าเช่าร้าน',              10),
  ('expense', 'ค่าไฟ',                    20),
  ('expense', 'ค่าน้ำ',                    25),
  ('expense', 'ค่าอินเทอร์เน็ต',          30),
  ('expense', 'ซื้อสินค้าเข้าร้าน',        40),
  ('expense', 'ค่าจ้างพนักงาน',           50),
  ('expense', 'ซ่อม/อุปกรณ์คอม',          60),
  ('expense', 'รายจ่ายอื่นๆ',             90)
) as v(kind, name, sort_order)
where not exists (select 1 from game_shop.categories);

-- ===== เพิ่มคนที่ใช้แอปได้ (แก้อีเมลแล้วรันเฉพาะบรรทัดนี้) =====
-- insert into game_shop.members (email, display_name) values ('someone@example.com', 'ชื่อเล่น');
