-- ════════════════════════════════════════════════════════════════
--  SHIONIX CUSTOMER WEBSITE — SUPABASE SETUP
--  Supabase → SQL Editor → New Query → Paste → Run
-- ════════════════════════════════════════════════════════════════

-- ── 1. PROFILES ──────────────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text unique not null,
  full_name   text,
  phone       text,
  avatar_url  text,
  role        text not null default 'customer' check (role in ('admin','customer')),
  status      text not null default 'active'   check (status in ('active','blocked')),
  city        text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Auto-create profile when user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, phone)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── 2. CATEGORIES ────────────────────────────────────────────────
create table if not exists public.categories (
  id          bigint primary key generated always as identity,
  name        text not null unique,
  slug        text not null unique,
  description text,
  image_url   text,
  emoji       text default '📦',
  status      text default 'active' check (status in ('active','inactive')),
  sort_order  int  default 0,
  product_count int default 0,
  created_at  timestamptz default now()
);

-- Seed categories
insert into public.categories (name, slug, emoji, sort_order) values
  ('Headphones',   'headphones',  '🎧', 1),
  ('Smartwatches', 'smartwatch',  '⌚', 2),
  ('Earbuds',      'earbuds',     '🎵', 3),
  ('Speakers',     'speakers',    '🔊', 4),
  ('Laptops',      'laptop',      '💻', 5),
  ('Mobiles',      'phone',       '📱', 6),
  ('Cameras',      'camera',      '📷', 7),
  ('Gaming',       'gaming',      '🎮', 8)
on conflict (slug) do nothing;

-- ── 3. PRODUCTS ──────────────────────────────────────────────────
create table if not exists public.products (
  id               bigint primary key generated always as identity,
  name             text not null,
  description      text,
  price            numeric(10,2) not null check (price >= 0),
  mrp              numeric(10,2),
  discount_percent numeric(5,2)  default 0,
  stock            int           not null default 0,
  sku              text          unique,
  category_id      bigint        references public.categories(id) on delete set null,
  emoji            text          default '📦',
  brand            text,
  colors           text[],
  sizes            text[],
  tags             text[],
  images           text[],
  video_url        text,
  status           text          default 'active' check (status in ('active','inactive')),
  featured         boolean       default false,
  best_seller      boolean       default false,
  new_arrival      boolean       default false,
  flash_sale       boolean       default false,
  rating           numeric(3,2)  default 4.5,
  review_count     int           default 0,
  created_at       timestamptz   default now(),
  updated_at       timestamptz   default now()
);

-- ── 4. ORDERS ────────────────────────────────────────────────────
create table if not exists public.orders (
  id             text primary key,
  customer_id    uuid references public.profiles(id) on delete set null,
  customer_name  text not null,
  customer_email text,
  customer_phone text,
  address        text,
  city           text,
  state          text,
  pin_code       text,
  items          jsonb default '[]',
  subtotal       numeric(10,2) default 0,
  shipping       numeric(10,2) default 0,
  discount       numeric(10,2) default 0,
  total_amount   numeric(10,2) not null,
  status         text default 'pending'
    check (status in ('pending','processing','shipped','delivered','cancelled','refunded')),
  payment_method text default 'cod',
  notes          text,
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

-- ── 5. CONTACT MESSAGES ──────────────────────────────────────────
create table if not exists public.contact_messages (
  id         bigint primary key generated always as identity,
  name       text not null,
  email      text not null,
  subject    text,
  message    text not null,
  created_at timestamptz default now()
);

-- ── 6. NEWSLETTER SUBSCRIBERS ────────────────────────────────────
create table if not exists public.newsletter_subscribers (
  id         bigint primary key generated always as identity,
  email      text not null unique,
  created_at timestamptz default now()
);

-- ── 7. COUPONS ───────────────────────────────────────────────────
create table if not exists public.coupons (
  id        bigint primary key generated always as identity,
  code      text not null unique,
  type      text not null check (type in ('percentage','flat')),
  value     numeric(10,2) not null,
  min_order numeric(10,2) default 0,
  max_uses  int default 1000,
  used      int default 0,
  expiry    date,
  active    boolean default true,
  created_at timestamptz default now()
);

insert into public.coupons (code, type, value, min_order, max_uses, expiry, active) values
  ('SHIONIX10', 'percentage', 10,  500,  1000, '2026-12-31', true),
  ('WELCOME',   'flat',       100, 999,  500,  '2026-12-31', true),
  ('SUMMER20',  'percentage', 20, 1500,  200,  '2026-08-31', true)
on conflict (code) do nothing;

-- ── 8. REVIEWS ───────────────────────────────────────────────────
create table if not exists public.reviews (
  id          bigint primary key generated always as identity,
  product_id  bigint references public.products(id) on delete cascade,
  customer_id uuid   references public.profiles(id) on delete set null,
  rating      int    not null check (rating between 1 and 5),
  comment     text,
  status      text   default 'approved' check (status in ('pending','approved','hidden')),
  created_at  timestamptz default now()
);

-- ════════════════════════════════════════════════════════════════
--  ROW LEVEL SECURITY (RLS)
-- ════════════════════════════════════════════════════════════════

alter table public.profiles            enable row level security;
alter table public.categories          enable row level security;
alter table public.products            enable row level security;
alter table public.orders              enable row level security;
alter table public.contact_messages    enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.coupons             enable row level security;
alter table public.reviews             enable row level security;

-- Helper: is admin?
create or replace function public.is_admin()
returns boolean language sql security definer as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

-- PROFILES
create policy "Users see own profile"     on public.profiles for select using (auth.uid() = id);
create policy "Users update own profile"  on public.profiles for update using (auth.uid() = id);
create policy "Admins full profiles"      on public.profiles for all    using (public.is_admin());

-- CATEGORIES — public read
create policy "Anyone reads categories"   on public.categories for select using (status = 'active' or public.is_admin());
create policy "Admins manage categories"  on public.categories for all    using (public.is_admin());

-- PRODUCTS — public read active
create policy "Anyone reads active products" on public.products for select using (status = 'active' or public.is_admin());
create policy "Admins manage products"    on public.products for all using (public.is_admin());

-- ORDERS — customers own, admin all
create policy "Customers see own orders"  on public.orders for select using (auth.uid() = customer_id or public.is_admin());
create policy "Anyone can insert order"   on public.orders for insert with check (true);
create policy "Admins manage orders"      on public.orders for all    using (public.is_admin());

-- CONTACT MESSAGES — insert only (public), read admin
create policy "Anyone can send message"   on public.contact_messages for insert with check (true);
create policy "Admins read messages"      on public.contact_messages for select using (public.is_admin());

-- NEWSLETTER — insert public, read admin
create policy "Anyone can subscribe"      on public.newsletter_subscribers for insert with check (true);
create policy "Admins read subscribers"   on public.newsletter_subscribers for select using (public.is_admin());

-- COUPONS — public read active
create policy "Anyone reads active coupons" on public.coupons for select using (active = true or public.is_admin());
create policy "Admins manage coupons"     on public.coupons for all using (public.is_admin());

-- REVIEWS — public read approved
create policy "Anyone reads approved reviews" on public.reviews for select using (status = 'approved' or public.is_admin());
create policy "Users insert reviews"      on public.reviews for insert with check (auth.uid() = customer_id);
create policy "Admins manage reviews"     on public.reviews for all using (public.is_admin());

-- ════════════════════════════════════════════════════════════════
--  INDEXES
-- ════════════════════════════════════════════════════════════════
create index if not exists idx_products_category  on public.products(category_id);
create index if not exists idx_products_status    on public.products(status);
create index if not exists idx_products_featured  on public.products(featured) where featured = true;
create index if not exists idx_orders_customer    on public.orders(customer_id);
create index if not exists idx_orders_status      on public.orders(status);
create index if not exists idx_orders_created     on public.orders(created_at desc);

-- ════════════════════════════════════════════════════════════════
--  EMAIL CONFIRMATION OFF (optional — for testing)
--  Supabase Dashboard → Authentication → Email → Confirm email: OFF
-- ════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════
--  SEED SAMPLE PRODUCTS (optional — delete after real products added)
-- ════════════════════════════════════════════════════════════════
insert into public.products
  (name, description, price, mrp, stock, sku, category_id, emoji, featured, best_seller, new_arrival, rating, review_count, status)
select
  p.name, p.description, p.price, p.mrp, p.stock, p.sku,
  c.id, p.emoji, p.featured, p.best_seller, p.new_arrival, p.rating, p.review_count, 'active'
from (values
  ('Shionix Pro ANC Headphones', 'Studio-quality sound with ANC, 40-hour battery, premium comfort', 4999, 8999, 45, 'SHX-HP-001', 'headphones', '🎧', true,  true,  false, 4.8, 1240),
  ('SmartWatch X Pro',           'AMOLED display, 7-day battery, health tracking, water resistant', 2499, 4999, 32, 'SHX-SW-002', 'smartwatch', '⌚', true,  false, true,  4.7, 890),
  ('AirPods Ultra Pro',          'True wireless, 30hr total battery, ANC, crystal-clear calls',    1999, 3500, 80, 'SHX-EB-003', 'earbuds',    '🎵', true,  true,  false, 4.9, 2100),
  ('BoomBox Pro Speaker',        '360° sound, 20hr battery, IPX5 waterproof',                      3299, 5500, 60, 'SHX-SP-004', 'speakers',   '🔊', false, true,  true,  4.6, 650),
  ('Wireless Neckband Pro',      'Magnetic earbuds, 24hr battery, fast charge, IPX4',              899,  1999, 120,'SHX-EB-008', 'earbuds',    '🎼', true,  true,  false, 4.5, 3400),
  ('SmartBand Fit 3',            'Steps, sleep, heart rate, SpO2, 14-day battery',                 1299, 2500, 55, 'SHX-SW-009', 'smartwatch', '💪', false, false, true,  4.4, 1560),
  ('Budget Smartphone 5G',       '6.5" AMOLED, 5000mAh, 50MP camera, 128GB',                     12999,18000, 30, 'SHX-PH-012', 'phone',      '📱', true,  false, true,  4.5, 1800),
  ('GamePad Pro X',              'Ergonomic, 200hr battery, universal compatibility',               2799, 4500, 40, 'SHX-GM-007', 'gaming',     '🎮', false, true,  false, 4.6, 780)
) as p(name, description, price, mrp, stock, sku, cat_slug, emoji, featured, best_seller, new_arrival, rating, review_count)
join public.categories c on c.slug = p.cat_slug
on conflict (sku) do nothing;
