-- ลบงานทดสอบที่ไม่มีเจ้าของ
delete from public.todos;

-- ===== โปรไฟล์ผู้ใช้: ชื่อผู้ใช้ + บทบาท =====
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique,
  role text not null default 'user' check (role in ('admin', 'user')),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

-- สร้างโปรไฟล์อัตโนมัติเมื่อมีบัญชีใหม่ (ชื่อผู้ใช้ = ส่วนหน้า @ ของอีเมล)
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- เช็กว่าคนที่ล็อกอินอยู่เป็น admin ไหม
create function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

revoke execute on function public.is_admin() from anon, public;
grant execute on function public.is_admin() to authenticated;
revoke execute on function public.handle_new_user() from anon, authenticated, public;

-- ผู้ใช้เห็นโปรไฟล์ตัวเอง admin เห็นทุกคน (ไม่มีนโยบาย update = ไม่มีใครเปลี่ยน role ตัวเองได้)
create policy "read own profile or admin reads all"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select public.is_admin()));

-- ===== งาน: ผูกกับเจ้าของ =====
alter table public.todos
  add column user_id uuid not null default auth.uid()
  references public.profiles (id) on delete cascade;
create index todos_user_id_idx on public.todos (user_id);

drop policy "anyone can do everything" on public.todos;

create policy "owner or admin can read"
  on public.todos for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));

create policy "users add their own todos"
  on public.todos for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "owner or admin can update"
  on public.todos for update to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()))
  with check (user_id = (select auth.uid()) or (select public.is_admin()));

create policy "owner or admin can delete"
  on public.todos for delete to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));
