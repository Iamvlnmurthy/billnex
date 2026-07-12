-- BillNex — Postgres schema (Supabase-ready)
-- Multi-tenant by business_id with row-level security. Run in the Supabase
-- SQL editor (or `supabase db push`). Auth is handled by Supabase Auth;
-- app users map to auth.users via the memberships table.
--
-- PRD refs: §8 (architecture), §13 (API), §14 (sync), BNX-0268 (audit).

create extension if not exists "pgcrypto";

-- ── Tenancy ────────────────────────────────────────────────────────────────
create table if not exists businesses (
  id           uuid primary key default gen_random_uuid(),
  legal_name   text not null,
  gstin        text,
  state_code   text,
  edition      text not null default 'Retail Standard',
  settings     jsonb not null default '{}',
  created_at   timestamptz not null default now()
);

create table if not exists memberships (
  business_id  uuid not null references businesses(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  role         text not null default 'owner'
                 check (role in ('owner','manager','cashier','accountant','stock','purchase','support')),
  created_at   timestamptz not null default now(),
  primary key (business_id, user_id)
);

-- Helper: businesses the current user belongs to.
create or replace function auth_business_ids() returns setof uuid
  language sql stable security definer set search_path = public as $$
  select business_id from memberships where user_id = auth.uid()
$$;

-- ── Masters ─────────────────────────────────────────────────────────────────
create table if not exists customers (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id) on delete cascade,
  name         text not null,
  mobile       text,
  gstin        text,
  credit_limit numeric(12,2) not null default 0,
  consent      boolean not null default false,
  updated_at   timestamptz not null default now()
);

create table if not exists suppliers (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id) on delete cascade,
  name         text not null,
  phone        text,
  gstin        text,
  credit_days  int not null default 0
);

create table if not exists products (
  id            uuid primary key default gen_random_uuid(),
  business_id   uuid not null references businesses(id) on delete cascade,
  sku           text not null,
  name          text not null,
  unit          text not null default 'Piece',
  price         numeric(12,2) not null default 0,
  cost          numeric(12,2) not null default 0,
  qty           numeric(12,3) not null default 0,
  reorder_level numeric(12,3) not null default 10,
  unique (business_id, sku)
);

-- ── Transactions (immutable source documents) ───────────────────────────────
create table if not exists sales (
  id            uuid primary key default gen_random_uuid(),
  business_id   uuid not null references businesses(id) on delete cascade,
  invoice_no    text not null,
  customer_id   uuid references customers(id),
  template_id   text not null default 'classic',
  payment_mode  text not null,
  subtotal      numeric(12,2) not null,
  gst           numeric(12,2) not null,
  total         numeric(12,2) not null,
  posted_at     timestamptz not null default now(),
  unique (business_id, invoice_no)
);

create table if not exists sale_lines (
  id          bigserial primary key,
  sale_id     uuid not null references sales(id) on delete cascade,
  name        text not null,
  qty         numeric(12,3) not null,
  price       numeric(12,2) not null
);

-- Customer receivable ledger (debit = owes, credit = paid).
create table if not exists ledger_entries (
  id           bigserial primary key,
  business_id  uuid not null references businesses(id) on delete cascade,
  customer_id  uuid not null references customers(id) on delete cascade,
  kind         text not null,
  ref          text not null,
  debit        numeric(12,2) not null default 0,
  credit       numeric(12,2) not null default 0,
  mode         text,
  at           timestamptz not null default now()
);

create table if not exists purchases (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id) on delete cascade,
  purchase_no  text not null,
  supplier_id  uuid not null references suppliers(id),
  supplier_ref text,
  subtotal     numeric(12,2) not null,
  gst          numeric(12,2) not null,
  total        numeric(12,2) not null,
  paid         boolean not null default false,
  at           timestamptz not null default now(),
  unique (business_id, purchase_no)
);

create table if not exists payables (
  id           bigserial primary key,
  business_id  uuid not null references businesses(id) on delete cascade,
  supplier_id  uuid not null references suppliers(id) on delete cascade,
  ref          text not null,
  debit        numeric(12,2) not null default 0,
  credit       numeric(12,2) not null default 0,
  mode         text,
  at           timestamptz not null default now()
);

create table if not exists stock_movements (
  id           bigserial primary key,
  business_id  uuid not null references businesses(id) on delete cascade,
  sku          text not null,
  kind         text not null,
  delta        numeric(12,3) not null,
  ref          text not null,
  reason       text,
  at           timestamptz not null default now()
);

create table if not exists appointments (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id) on delete cascade,
  customer     text not null,
  service      text,
  staff        text,
  slot_at      timestamptz not null,
  status       text not null default 'booked'
);

create table if not exists audit_events (
  id           bigserial primary key,
  business_id  uuid not null references businesses(id) on delete cascade,
  actor        text not null,
  action       text not null,
  ref          text,
  at           timestamptz not null default now()
);

-- ── Sync outbox (idempotent replay, PRD §14) ────────────────────────────────
create table if not exists sync_events (
  idem_key     text primary key,          -- client-generated; dedupes replays
  business_id  uuid not null references businesses(id) on delete cascade,
  kind         text not null,
  ref          text not null,
  payload      jsonb not null default '{}',
  received_at  timestamptz not null default now(),
  rev          bigserial                  -- monotonic; clients pull since rev
);

create index if not exists sync_events_biz_rev on sync_events (business_id, rev);
create index if not exists sales_biz_idx on sales (business_id, posted_at desc);
create index if not exists ledger_biz_cust_idx on ledger_entries (business_id, customer_id);

-- Load RLS policies:
\i policies.sql
