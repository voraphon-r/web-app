begin;
-- Game-Shop: บันทึกประจำกะ ร้านเกม
-- รันไฟล์นี้ใน Supabase SQL Editor ของโปรเจกต์ voraphon-apps
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
  machine       integer not null check (machine between 1 and 20),
  game_amount   numeric(10,2) not null default 0 check (game_amount >= 0),
  drink_amount  numeric(10,2) not null default 0 check (drink_amount >= 0),
  pay_method    text not null check (pay_method in ('cash', 'transfer')),
  cash_received numeric(10,2) check (cash_received is null or cash_received >= 0),  -- เงินที่ลูกค้าให้มา (ไว้คิดเงินทอน)
  note          text check (note is null or char_length(note) <= 120),
  check (game_amount + drink_amount > 0)
);
create index if not exists shift_entries_shift_idx on game_shop.shift_entries (shift_id, created_at);

-- Private membership helper: only authenticated sessions may call it.
create schema if not exists game_shop_private;
revoke all on schema game_shop_private from public, anon;
grant usage on schema game_shop_private to authenticated;
create or replace function game_shop_private.is_member() returns boolean
language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null and exists (
    select 1 from game_shop.members m where m.email = lower(auth.jwt() ->> 'email')
  )
$$;
revoke all on function game_shop_private.is_member() from public, anon;
grant execute on function game_shop_private.is_member() to authenticated;

-- สิทธิ์: ต้องล็อกอิน และอีเมลต้องอยู่ในตาราง members (ไม่ให้ anon เข้าถึงเลย)
revoke all on all tables in schema game_shop from public, anon;
grant usage on schema game_shop to authenticated;

grant select on game_shop.members to authenticated;
revoke all on game_shop.shifts from authenticated;
grant select on game_shop.shifts to authenticated;
grant insert (staff_name) on game_shop.shifts to authenticated;
grant update (closed_at) on game_shop.shifts to authenticated;
grant select, insert, update, delete on game_shop.shift_entries to authenticated;

alter table game_shop.members       enable row level security;
alter table game_shop.shifts        enable row level security;
alter table game_shop.shift_entries enable row level security;

drop policy if exists "members see members" on game_shop.members;
create policy "members see members" on game_shop.members
  for select to authenticated using (game_shop_private.is_member());

do $$
declare t text;
begin
  foreach t in array array['shifts', 'shift_entries'] loop
    execute format('drop policy if exists "members read"   on game_shop.%I', t);
    execute format('drop policy if exists "members add"    on game_shop.%I', t);
    execute format('drop policy if exists "members change" on game_shop.%I', t);
    execute format('drop policy if exists "members delete" on game_shop.%I', t);
    execute format('create policy "members read"   on game_shop.%I for select to authenticated using (game_shop_private.is_member())', t);
    execute format('create policy "members add"    on game_shop.%I for insert to authenticated with check (game_shop_private.is_member())', t);
    execute format('create policy "members change" on game_shop.%I for update to authenticated using (game_shop_private.is_member()) with check (game_shop_private.is_member())', t);
    execute format('create policy "members delete" on game_shop.%I for delete to authenticated using (game_shop_private.is_member())', t);

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

-- Upgrade the original setup without discarding any entries. Invalid legacy rows
-- deliberately stop the transaction so the owner can review them first.
alter table game_shop.shift_entries drop constraint if exists shift_entries_machine_check;
alter table game_shop.shift_entries add constraint shift_entries_machine_check check (machine between 1 and 20);
alter table game_shop.shift_entries drop constraint if exists valid_cash_received;
alter table game_shop.shift_entries add constraint valid_cash_received check (
  (pay_method = 'transfer' and cash_received is null) or
  (pay_method = 'cash' and (cash_received is null or cash_received >= game_amount + drink_amount))
);

alter table game_shop.shift_entries drop constraint if exists finite_amounts;
alter table game_shop.shift_entries add constraint finite_amounts check (
  game_amount between 0 and 99999999.99 and drink_amount between 0 and 99999999.99
  and (cash_received is null or cash_received between 0 and 99999999.99)
);

create or replace function game_shop_private.guard_entry() returns trigger
language plpgsql security invoker set search_path = '' as $$
declare target uuid; closed timestamptz;
begin
  if TG_OP = 'UPDATE' and (new.id <> old.id or new.shift_id <> old.shift_id or new.created_at <> old.created_at) then
    raise exception 'Entry identity and timestamp cannot change';
  end if;
  if TG_OP = 'DELETE' then target := old.shift_id; else target := new.shift_id; end if;
  -- Same row lock as close_shift: serialize writes against closing a shift.
  select closed_at into closed from game_shop.shifts where id = target for update;
  if not found or closed is not null then raise exception 'Shift is closed or unavailable'; end if;
  if TG_OP = 'DELETE' then return old; end if;
  if TG_OP = 'INSERT' then new.created_at := clock_timestamp(); end if;
  return new;
end $$;
revoke all on function game_shop_private.guard_entry() from public, anon, authenticated;
drop trigger if exists guard_entry on game_shop.shift_entries;
create trigger guard_entry before insert or update or delete on game_shop.shift_entries
for each row execute function game_shop_private.guard_entry();

create or replace function game_shop_private.guard_shift() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  if TG_OP = 'UPDATE' then
    if old.closed_at is not null or new.closed_at is null or new.id <> old.id or new.opened_at <> old.opened_at or new.staff_name <> old.staff_name then
      raise exception 'Closed shifts and shift identity cannot change';
    end if;
    new.closed_at := clock_timestamp();
  end if;
  return new;
end $$;
revoke all on function game_shop_private.guard_shift() from public, anon, authenticated;
drop trigger if exists guard_shift on game_shop.shifts;
create trigger guard_shift before update on game_shop.shifts
for each row execute function game_shop_private.guard_shift();

create or replace function game_shop.close_shift(p_id uuid, p_count bigint, p_cash numeric, p_transfer numeric)
returns void language plpgsql security invoker set search_path = '' as $$
declare closed timestamptz; n bigint; cash numeric; transfer numeric;
begin
  select closed_at into closed from game_shop.shifts where id = p_id for update;
  if not found or closed is not null then raise exception 'Shift is closed or unavailable'; end if;
  select count(*), coalesce(sum(game_amount + drink_amount) filter (where pay_method = 'cash'), 0),
    coalesce(sum(game_amount + drink_amount) filter (where pay_method = 'transfer'), 0)
    into n, cash, transfer from game_shop.shift_entries where shift_id = p_id;
  if p_count is distinct from n or p_cash is distinct from cash or p_transfer is distinct from transfer then
    raise exception 'Shift totals changed. Refresh and recount before closing';
  end if;
  update game_shop.shifts set closed_at = clock_timestamp() where id = p_id;
end $$;
revoke all on function game_shop.close_shift(uuid,bigint,numeric,numeric) from public, anon;
grant execute on function game_shop.close_shift(uuid,bigint,numeric,numeric) to authenticated;

-- Remove the previous public SECURITY DEFINER helper after replacing policies.
drop function if exists game_shop.is_member();
-- Intentionally public, read-only projection requested by the shop owner.
-- No parameters: callers cannot select closed shifts, other apps, or account data.
create or replace function game_shop.current_shift_public()
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'shift', jsonb_build_object('staff_name',s.staff_name,'opened_at',s.opened_at),
    'entries',coalesce((
      select jsonb_agg(jsonb_build_object(
        'created_at',e.created_at,'machine',e.machine,
        'game_amount',e.game_amount,'drink_amount',e.drink_amount,
        'pay_method',e.pay_method,'cash_received',e.cash_received
      ) order by e.created_at,e.id)
      from game_shop.shift_entries e where e.shift_id=s.id
    ),'[]'::jsonb)
  ) from game_shop.shifts s where s.closed_at is null
$$;
revoke all on function game_shop.current_shift_public() from public;
grant usage on schema game_shop to anon;
grant execute on function game_shop.current_shift_public() to anon,authenticated;

commit;
