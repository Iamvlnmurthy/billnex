-- BillNex — Row-Level Security policies.
-- Every tenant table is readable/writable only by members of that business.
-- (PRD §8.1 multi-tenant isolation, §16 least privilege.)

-- businesses: a user sees only businesses they belong to.
alter table businesses enable row level security;
create policy biz_member_read on businesses
  for select using (id in (select auth_business_ids()));
create policy biz_member_write on businesses
  for update using (id in (select auth_business_ids()));

alter table memberships enable row level security;
create policy mem_self on memberships
  for select using (user_id = auth.uid() or business_id in (select auth_business_ids()));

-- Generic per-tenant policy applied to every business_id table.
do $$
declare t text;
begin
  foreach t in array array[
    'customers','suppliers','products','sales','ledger_entries','purchases',
    'payables','stock_movements','appointments','audit_events','sync_events'
  ] loop
    execute format('alter table %I enable row level security;', t);
    execute format($f$
      create policy %1$s_tenant_all on %1$I
        using (business_id in (select auth_business_ids()))
        with check (business_id in (select auth_business_ids()));
    $f$, t);
  end loop;
end $$;

-- sale_lines inherits its parent's tenant.
alter table sale_lines enable row level security;
create policy sale_lines_tenant on sale_lines
  using (sale_id in (select id from sales))
  with check (sale_id in (select id from sales));

-- Cost/margin masking for cashiers is enforced in the API layer / views
-- (BNX-0277); RLS gives the hard tenant boundary.
