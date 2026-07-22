-- Client DB schema — חנות דמה (demo-shop-e2e)
-- DEMO/TEST project only — created for the Stage 3 end-to-end test, not a real client.
-- Hosted in a dedicated Supabase project under the owner's organization (not the client's),
-- per CLAUDE.md's DB architecture: this is "DB #2", isolated from the main business DB.

create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price numeric not null,
  image_url text,
  created_at timestamptz default now()
);

create table customers (
  id uuid primary key default gen_random_uuid(),
  name text,
  email text,
  phone text,
  created_at timestamptz default now()
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete set null,
  product_id uuid references products(id) on delete set null,
  quantity integer not null default 1,
  total numeric not null,
  status text not null default 'pending',
  created_at timestamptz default now()
);

-- RLS: enabled on every table by default (see client-onboarding.md iron rule).
-- products is publicly readable (needed to display the catalog); customers and
-- orders have RLS on with no policies — default-deny for anon, service_role only.
alter table products enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;

create policy "public_read_products" on products for select using (true);
