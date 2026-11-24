-- Core schema for a single-business dropshipping store.
-- Apply with Supabase migrations after creating a project.
create extension if not exists pgcrypto;

create type public.product_status as enum ('draft','published','archived');
create type public.order_status as enum ('pending_payment','paid','processing','submitted_to_supplier','supplier_confirmed','preparing_shipment','shipped','in_transit','delivered','cancelled','refunded','fulfillment_exception');
create type public.fulfillment_status as enum ('queued','submitted','confirmed','rejected','shipped','cancelled','failed','manual_action_required');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','admin','fulfillment','support','analyst')),
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null default '',
  specifications jsonb not null default '{}'::jsonb,
  status public.product_status not null default 'draft',
  retail_price numeric(12,2) not null check (retail_price >= 0),
  sale_price numeric(12,2) check (sale_price is null or sale_price >= 0),
  currency char(3) not null default 'USD',
  category_id uuid references public.product_categories(id) on delete set null,
  shipping_min_days integer check (shipping_min_days is null or shipping_min_days >= 0),
  shipping_max_days integer check (shipping_max_days is null or shipping_max_days >= shipping_min_days),
  availability text not null default 'unknown' check (availability in ('available','unavailable','unknown')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  storage_path text not null,
  alt_text text not null default '',
  sort_order integer not null default 0
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  sku text unique,
  title text not null,
  options jsonb not null default '{}'::jsonb,
  retail_price numeric(12,2) check (retail_price is null or retail_price >= 0),
  availability text not null default 'unknown' check (availability in ('available','unavailable','unknown')),
  created_at timestamptz not null default now()
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_name text,
  email text,
  phone text,
  country text not null default 'China',
  integration_type text not null default 'manual' check (integration_type in ('api','manual','mock')),
  enabled boolean not null default true,
  processing_days integer check (processing_days is null or processing_days >= 0),
  reliability_score numeric(5,2) check (reliability_score between 0 and 100),
  internal_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.supplier_products (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  supplier_id uuid not null references public.suppliers(id) on delete restrict,
  supplier_product_id text,
  supplier_product_url text,
  product_cost numeric(12,2) not null check (product_cost >= 0),
  shipping_cost numeric(12,2) not null default 0 check (shipping_cost >= 0),
  supplier_currency char(3) not null default 'USD',
  fulfillment_method text not null default 'manual' check (fulfillment_method in ('api','manual','mock')),
  supplier_available boolean not null default false,
  is_preferred boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(product_id,supplier_id,supplier_product_id)
);

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete set null,
  email text not null,
  full_name text,
  phone text,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  customer_id uuid references public.customers(id) on delete set null,
  email text not null,
  currency char(3) not null default 'USD',
  status public.order_status not null default 'pending_payment',
  subtotal numeric(12,2) not null default 0 check (subtotal >= 0),
  shipping_total numeric(12,2) not null default 0 check (shipping_total >= 0),
  tax_total numeric(12,2) not null default 0 check (tax_total >= 0),
  discount_total numeric(12,2) not null default 0 check (discount_total >= 0),
  grand_total numeric(12,2) not null default 0 check (grand_total >= 0),
  shipping_address jsonb not null,
  guest_access_token_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  variant_id uuid references public.product_variants(id) on delete set null,
  product_title_snapshot text not null,
  variant_snapshot jsonb not null default '{}'::jsonb,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  supplier_cost_snapshot numeric(12,2) check (supplier_cost_snapshot is null or supplier_cost_snapshot >= 0),
  supplier_shipping_snapshot numeric(12,2) check (supplier_shipping_snapshot is null or supplier_shipping_snapshot >= 0)
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  provider text not null,
  provider_payment_id text unique,
  amount numeric(12,2) not null check (amount >= 0),
  currency char(3) not null,
  status text not null default 'pending' check (status in ('pending','authorized','paid','failed','partially_refunded','refunded')),
  provider_fee numeric(12,2) not null default 0 check (provider_fee >= 0),
  confirmed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.supplier_fulfillment_orders (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  supplier_id uuid not null references public.suppliers(id) on delete restrict,
  status public.fulfillment_status not null default 'queued',
  supplier_order_reference text,
  submission_idempotency_key text not null unique,
  supplier_cost numeric(12,2) not null default 0 check (supplier_cost >= 0),
  supplier_currency char(3) not null default 'USD',
  last_error text,
  submitted_at timestamptz,
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.shipments (
  id uuid primary key default gen_random_uuid(),
  fulfillment_order_id uuid not null references public.supplier_fulfillment_orders(id) on delete restrict,
  carrier text,
  tracking_number text,
  tracking_url text,
  status text not null default 'pending',
  shipped_at timestamptz,
  delivered_at timestamptz,
  updated_at timestamptz not null default now()
);

create table public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  provider_event_id text not null,
  event_type text not null,
  verified boolean not null default false,
  processed_at timestamptz,
  processing_error text,
  received_at timestamptz not null default now(),
  unique(provider,provider_event_id)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index products_public_idx on public.products(status, category_id) where status = 'published';
create index products_updated_idx on public.products(updated_at desc);
create index orders_created_idx on public.orders(created_at desc);
create index orders_status_idx on public.orders(status, created_at desc);
create index orders_customer_idx on public.orders(customer_id, created_at desc);
create index fulfillment_status_idx on public.supplier_fulfillment_orders(status, created_at);
create index supplier_products_lookup_idx on public.supplier_products(product_id, is_preferred);
create index webhook_events_pending_idx on public.webhook_events(received_at) where processed_at is null;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid()) and enabled = true
  );
$$;

alter table public.profiles enable row level security;
alter table public.admin_users enable row level security;
alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_variants enable row level security;
alter table public.suppliers enable row level security;
alter table public.supplier_products enable row level security;
alter table public.customers enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.supplier_fulfillment_orders enable row level security;
alter table public.shipments enable row level security;
alter table public.webhook_events enable row level security;
alter table public.audit_logs enable row level security;

create policy "published categories are readable" on public.product_categories for select using (exists(select 1 from public.products p where p.category_id = id and p.status = 'published') or public.is_admin());
create policy "published products are readable" on public.products for select using (status = 'published' or public.is_admin());
create policy "published product images are readable" on public.product_images for select using (exists(select 1 from public.products p where p.id = product_id and p.status = 'published') or public.is_admin());
create policy "published variants are readable" on public.product_variants for select using (exists(select 1 from public.products p where p.id = product_id and p.status = 'published') or public.is_admin());

create policy "admins manage categories" on public.product_categories for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage products" on public.products for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage product images" on public.product_images for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage variants" on public.product_variants for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage suppliers" on public.suppliers for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage supplier mappings" on public.supplier_products for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage profiles" on public.profiles for all using (id = (select auth.uid()) or public.is_admin()) with check (id = (select auth.uid()) or public.is_admin());
create policy "admins read admin users" on public.admin_users for select using (user_id = (select auth.uid()) or public.is_admin());
create policy "admins manage customers" on public.customers for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage orders" on public.orders for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage order items" on public.order_items for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage payments" on public.payments for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage fulfillment" on public.supplier_fulfillment_orders for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage shipments" on public.shipments for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage webhook events" on public.webhook_events for all using (public.is_admin()) with check (public.is_admin());
create policy "admins read audit logs" on public.audit_logs for select using (public.is_admin());
create policy "admins insert audit logs" on public.audit_logs for insert with check (public.is_admin());

-- Public roles are intentionally not granted direct write access to orders, payments,
-- supplier records, fulfillment records, webhook events, or audit logs.
-- Checkout and webhook writes must use authenticated server-side code with a
-- privileged secret held only in the server environment.
