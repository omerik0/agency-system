-- Business DB schema — tracks the agency's own clients, projects and billing
-- Run this in Supabase SQL editor (or psql) once the project is created

create table clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_email text,
  contact_phone text,
  created_at timestamptz default now()
);

create table projects (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references clients(id) on delete cascade,
  site_name text not null,          -- folder name under sites/
  status text not null default 'in_progress', -- in_progress | live | needs_attention
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table invoices (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references clients(id) on delete cascade,
  project_id uuid references projects(id) on delete set null,
  type text not null,               -- build_fee | monthly_hosting
  amount numeric not null,
  currency text default 'ILS',
  status text not null default 'unpaid', -- unpaid | paid
  due_date date,
  created_at timestamptz default now()
);

create table deployments (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  url text,
  provider text,                    -- vercel | netlify | vps
  last_deployed_at timestamptz,
  created_at timestamptz default now()
);
