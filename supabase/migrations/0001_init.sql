-- Inventário — Dispensa, Frigorífico & Congelador
-- Esquema inicial: casas partilhadas, inventário, produtos, lista de compras,
-- histórico de eventos e subscrições de notificações push.
--
-- Como aplicar: cola este ficheiro completo no SQL Editor do projeto Supabase
-- (Dashboard → SQL Editor → New query) e corre. Também é compatível com
-- `supabase db push` se vieres a usar a CLI mais tarde.

-- ============================================================
-- Casas (households) e membros
-- ============================================================

create table households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique default substr(md5(random()::text), 1, 8),
  created_at timestamptz not null default now()
);

create table household_members (
  household_id uuid not null references households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (household_id, user_id)
);

-- Ao criar uma casa, o criador torna-se automaticamente membro.
create or replace function handle_new_household()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into household_members (household_id, user_id)
  values (new.id, auth.uid());
  return new;
end;
$$;

create trigger on_household_created
  after insert on households
  for each row execute function handle_new_household();

-- Entrar numa casa a partir do código de convite (RPC — necessário porque um
-- utilizador sem ser ainda membro não pode "ver" a linha da casa diretamente).
create or replace function join_household_by_invite_code(code text)
returns uuid
language plpgsql
security definer
as $$
declare
  hh_id uuid;
begin
  select id into hh_id from households where invite_code = code;
  if hh_id is null then
    raise exception 'Código de convite inválido';
  end if;
  insert into household_members (household_id, user_id)
  values (hh_id, auth.uid())
  on conflict do nothing;
  return hh_id;
end;
$$;

-- Helper usado nas políticas RLS abaixo.
create or replace function is_household_member(hh_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from household_members
    where household_id = hh_id and user_id = auth.uid()
  );
$$;

-- ============================================================
-- Produtos (cache partilhada entre casas, indexada pelo código de barras)
-- ============================================================

create table products (
  barcode text primary key,
  name text not null,
  generic_name text,
  image_url text,
  category_tags text[] not null default '{}',
  quantity_text text,
  source text not null default 'manual' check (source in ('openfoodfacts', 'manual')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- Itens de inventário
-- ============================================================

create type inventory_location as enum ('dispensa', 'frigorifico', 'congelador');

create table inventory_items (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  barcode text references products(barcode),
  name text not null,
  category text,
  loc inventory_location not null,
  -- Foto tirada pelo utilizador (ex. tupperware no congelador) — distinta da
  -- imagem do produto na Open Food Facts, guardada no Supabase Storage.
  photo_url text,
  qty integer not null default 1 check (qty >= 0),
  expiry_date date,
  low_stock integer,
  added_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger inventory_items_set_updated_at
  before update on inventory_items
  for each row execute function set_updated_at();

-- ============================================================
-- Histórico de eventos (base para futuras sugestões de compras/receitas)
-- ============================================================

create table inventory_events (
  id uuid primary key default gen_random_uuid(),
  inventory_item_id uuid references inventory_items(id) on delete set null,
  household_id uuid not null references households(id) on delete cascade,
  user_id uuid references auth.users(id),
  event_type text not null check (event_type in ('added', 'removed', 'adjusted', 'deleted')),
  delta integer,
  created_at timestamptz not null default now()
);

-- ============================================================
-- Lista de compras
-- ============================================================

create table shopping_list_items (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  name text not null,
  barcode text references products(barcode),
  qty_wanted integer default 1,
  checked boolean not null default false,
  added_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- Subscrições de notificações push (por utilizador/dispositivo)
-- ============================================================

create table push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  endpoint text not null unique,
  p256dh text not null,
  auth_key text not null,
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table households enable row level security;
alter table household_members enable row level security;
alter table products enable row level security;
alter table inventory_items enable row level security;
alter table inventory_events enable row level security;
alter table shopping_list_items enable row level security;
alter table push_subscriptions enable row level security;

-- households
create policy "members can view their household"
  on households for select
  using (is_household_member(id));

create policy "authenticated users can create a household"
  on households for insert
  with check (auth.uid() is not null);

-- household_members
create policy "members can view household membership"
  on household_members for select
  using (is_household_member(household_id));

-- products (cache partilhada: qualquer utilizador autenticado lê/escreve)
create policy "authenticated users can read products"
  on products for select
  using (auth.uid() is not null);

create policy "authenticated users can add products"
  on products for insert
  with check (auth.uid() is not null);

create policy "authenticated users can update products"
  on products for update
  using (auth.uid() is not null);

-- inventory_items
create policy "members can view inventory"
  on inventory_items for all
  using (is_household_member(household_id))
  with check (is_household_member(household_id));

-- inventory_events
create policy "members can view and log events"
  on inventory_events for all
  using (is_household_member(household_id))
  with check (is_household_member(household_id));

-- shopping_list_items
create policy "members can manage shopping list"
  on shopping_list_items for all
  using (is_household_member(household_id))
  with check (is_household_member(household_id));

-- push_subscriptions (estritamente do próprio utilizador)
create policy "users manage their own push subscriptions"
  on push_subscriptions for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
