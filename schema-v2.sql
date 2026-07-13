-- ============================================================
-- SISTERS WHO CLEAN — Schema v2 — Rode no SQL Editor do Supabase
-- ============================================================

-- 1. Adiciona colunas novas na tabela profissionais
alter table profissionais
  add column if not exists avaliacao_media numeric(2,1) default null,
  add column if not exists total_avaliacoes integer default 0;

-- 2. Adiciona profissional escolhido e flag de avaliado no pedido
alter table pedidos_servico
  add column if not exists profissional_id uuid references profissionais(id),
  add column if not exists avaliado boolean default false;

-- 3. Tabela de credenciais (login criado só pelo admin)
create table if not exists credenciais_profissionais (
  id uuid primary key default gen_random_uuid(),
  profissional_id uuid references profissionais(id) on delete cascade unique not null,
  username text unique not null,
  senha text not null,
  criado_em timestamp with time zone default now()
);

-- 4. Tabela de avaliações
create table if not exists avaliacoes (
  id uuid primary key default gen_random_uuid(),
  profissional_id uuid references profissionais(id) on delete cascade not null,
  pedido_id uuid references pedidos_servico(id) on delete set null,
  nome_cliente text not null,
  estrelas integer not null check (estrelas between 1 and 5),
  comentario text,
  criado_em timestamp with time zone default now()
);

-- 5. Policies
alter table credenciais_profissionais enable row level security;
alter table avaliacoes enable row level security;

create policy "Admin pode gerenciar credenciais"
  on credenciais_profissionais for all using (true) with check (true);

create policy "Qualquer um pode criar avaliacao"
  on avaliacoes for insert with check (true);

create policy "Qualquer um pode ler avaliacoes"
  on avaliacoes for select using (true);

-- Policies para pedidos (se ainda não existirem)
drop policy if exists "Qualquer um pode criar um pedido de servico" on pedidos_servico;
drop policy if exists "Qualquer um pode ler pedidos" on pedidos_servico;
drop policy if exists "Profissional pode atualizar pedido" on pedidos_servico;

create policy "Qualquer um pode criar pedido" on pedidos_servico for insert with check (true);
create policy "Qualquer um pode ler pedidos" on pedidos_servico for select using (true);
create policy "Qualquer um pode atualizar pedido" on pedidos_servico for update using (true);

-- 6. Função que recalcula média automaticamente após avaliação
create or replace function atualizar_media_profissional()
returns trigger as $$
begin
  update profissionais set
    avaliacao_media = (select round(avg(estrelas)::numeric,1) from avaliacoes where profissional_id = new.profissional_id),
    total_avaliacoes = (select count(*) from avaliacoes where profissional_id = new.profissional_id)
  where id = new.profissional_id;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trigger_media on avaliacoes;
create trigger trigger_media
  after insert on avaliacoes
  for each row execute function atualizar_media_profissional();
