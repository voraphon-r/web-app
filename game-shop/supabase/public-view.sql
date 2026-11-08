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
