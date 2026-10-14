-- 1. The table
create table public.votes (
  id uuid primary key default gen_random_uuid(),
  product_id bigint not null,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint votes_user_product_unique unique (user_id, product_id)
);

-- 2. Index for counting votes per product
create index votes_product_id_idx on public.votes (product_id);

-- 3. Turn on Row Level Security
alter table public.votes enable row level security;

-- 4. Table-level permissions
grant select on public.votes to anon, authenticated;
grant insert, delete on public.votes to authenticated;

-- 5. Row-level policies
create policy "Anyone can read votes"
  on public.votes for select
  using (true);

create policy "Users can insert their own votes"
  on public.votes for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can delete their own votes"
  on public.votes for delete
  to authenticated
  using (auth.uid() = user_id);