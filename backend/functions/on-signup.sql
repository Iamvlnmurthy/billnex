-- Auto-provision a business + owner membership on first sign-up.
-- Run once in the Supabase SQL editor. (Alternative to an Edge Function.)

create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare new_biz uuid;
begin
  insert into businesses (legal_name, edition)
  values (coalesce(new.raw_user_meta_data->>'business_name', 'My Business'), 'Retail Standard')
  returning id into new_biz;

  insert into memberships (business_id, user_id, role)
  values (new_biz, new.id, 'owner');

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
