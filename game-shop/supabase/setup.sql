-- Game-Shop: บันทึกประจำกะ ร้านเกม
-- รันไฟล์นี้ใน Supabase SQL Editor ของโปรเจกต์ที่ใช้ร่วมกัน (voraphon-apps)
-- ทุกอย่างของแอปนี้อยู่ใน schema "game_shop" แยกจากแอปอื่น
-- รันซ้ำได้ ไม่ลบข้อมูลที่บันทึกไว้

create schema if not exists game_shop;

-- สมาชิก: อีเมลที่อนุญาตให้ใช้แอปนี้ (ต้องมีบัญชีใน Authentication > Users ด้วย)
-- แนะนำ: ทำบัญชีร้าน 1 บัญชี ล็อกอินค้างไว้ที่เครื่องในร้าน
create table if not exists game_shop.members (
  email        text primary key check (email = lower(email)),
  display_name text not null check (char_length(btrim(display_name)) between 1 and 40),
  created_at   timestamptz not null default now()
);

-- กะ: 1 แถว = 1 กะ (เปิดกะ ... ปิดกะ)
create table if not exists game_shop.shifts (
  id          uuid primary key default gen_random_uuid(),
  opened_at   timestamptz not null default now(),
  closed_at   timestamptz,
  staff_name  text not null check (char_length(btrim(staff_name)) between 1 and 40),
  note        text check (note is null or char_length(note) <= 200)
);
-- เปิดได้ทีละ 1 กะ
create unique index if not exists shifts_one_open_idx on game_shop.shifts ((true)) where closed_at is null;
create index if not exists shifts_opened_at_idx on game_shop.shifts (opened_at desc);

-- รายการในกะ: 1 แถว = ลูกค้า 1 ราย (เหมือน 1 บรรทัดในสมุด)
create table if not exists game_shop.shift_entries (
  id            uuid primary key default gen_random_uuid(),
  shift_id      uuid not null references game_shop.shifts(id) on delete cascade,
  created_at    timestamptz not null default now(),
  machine       integer not null check (machine between 1 and 99),
  game_amount   numeric(10,2) not null default 0 check (game_amount >= 0),
  drink_amount  numeric(10,2) not null default 0 check (drink_amount >= 0),
  pay_method    text not null check (pay_method in ('cash', 'transfer')),
  cash_received numeric(10,2) check (cash_received is null or cash_received >= 0),  -- เงินที่ลูกค้าให้มา (ไว้คิดเงินทอน)
  note          text check (note is null or char_length(note) <= 120),
  check (game_amount + drink_amount > 0)
);
create index if not exists shift_entries_shift_idx on game_shop.shift_entries (shift_id, created_at);

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
grant select, insert, update, delete on game_shop.shifts        to authenticated;
grant select, insert, update, delete on game_shop.shift_entries to authenticated;

alter table game_shop.members       enable row level security;
alter table game_shop.shifts        enable row level security;
alter table game_shop.shift_entries enable row level security;

drop policy if exists "members see members" on game_shop.members;
create policy "members see members" on game_shop.members
  for select to authenticated using (game_shop.is_member());

do $$
declare t text;
begin
  foreach t in array array['shifts', 'shift_entries'] loop
    execute format('drop policy if exists "members read"   on game_shop.%I', t);
    execute format('drop policy if exists "members add"    on game_shop.%I', t);
    execute format('drop policy if exists "members change" on game_shop.%I', t);
    execute format('drop policy if exists "members delete" on game_shop.%I', t);
    execute format('create policy "members read"   on game_shop.%I for select to authenticated using (game_shop.is_member())', t);
    execute format('create policy "members add"    on game_shop.%I for insert to authenticated with check (game_shop.is_member())', t);
    execute format('create policy "members change" on game_shop.%I for update to authenticated using (game_shop.is_member()) with check (game_shop.is_member())', t);
    execute format('create policy "members delete" on game_shop.%I for delete to authenticated using (game_shop.is_member())', t);

    -- Realtime: ทุกเครื่องเห็นรายการใหม่ทันที
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'game_shop' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table game_shop.%I', t);
    end if;
  end loop;
end $$;

-- ===== เพิ่มคนที่ใช้แอปได้ (แก้อีเมลแล้วรันเฉพาะบรรทัดนี้) =====
-- insert into game_shop.members (email, display_name) values ('someone@example.com', 'ร้านเกม');
