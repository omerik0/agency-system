-- afik-gozland — Supabase project: aykdajxqkxlflqruhebv (org-level, separate from the business DB)
-- Client type: ecommerce (template: sites/_template-ecommerce/), Stripe cart checkout

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references categories(id) on delete set null,
  name text not null,
  description text,
  price numeric(10,2) not null check (price >= 0),
  image_url text,
  stock int check (stock >= 0),      -- null = not tracked
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table customers (
  id uuid primary key default gen_random_uuid(),
  full_name text,
  email text,
  phone text,
  address text,
  created_at timestamptz not null default now()
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete set null,
  status text not null default 'pending', -- pending | paid | shipped | cancelled
  total numeric(10,2) not null check (total >= 0),
  currency text not null default 'ILS',
  stripe_session_id text unique,
  created_at timestamptz not null default now()
);

create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  quantity int not null check (quantity > 0),
  unit_price numeric(10,2) not null check (unit_price >= 0), -- price at time of order
  created_at timestamptz not null default now()
);

alter table categories enable row level security;
alter table products enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

-- Public catalog read access; writes are service_role only (no public policy for insert/update/delete)
create policy "public_read_categories" on categories
  for select
  using (true);

create policy "public_read_products" on products
  for select
  using (active);

-- customers / orders / order_items: no policies — service_role only
