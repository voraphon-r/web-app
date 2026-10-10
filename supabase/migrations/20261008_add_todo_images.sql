-- ===== รูปแนบของงาน =====
-- เก็บแค่ที่อยู่ไฟล์ในตาราง ตัวไฟล์อยู่ใน Storage
alter table public.todos add column image_path text;

-- bucket แบบ private (ดูรูปได้ผ่านลิงก์ชั่วคราวเท่านั้น)
-- รับเฉพาะรูปที่บีบอัดแล้ว ไม่เกิน 2 MB
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('todo-images', 'todo-images', false, 2097152, array['image/webp', 'image/jpeg']);

-- ไฟล์เก็บเป็น <user_id>/<ชื่อไฟล์> แต่ละคนจึงมีโฟลเดอร์ของตัวเอง
create policy "users upload to their own folder"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'todo-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "owner or admin can view images"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'todo-images'
    and ((storage.foldername(name))[1] = (select auth.uid())::text or (select public.is_admin()))
  );

create policy "owner or admin can delete images"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'todo-images'
    and ((storage.foldername(name))[1] = (select auth.uid())::text or (select public.is_admin()))
  );
