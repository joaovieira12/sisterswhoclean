-- ============================================================
-- SISTERS WHO CLEAN — Schema do banco de dados (Supabase / Postgres)
-- ============================================================
-- Como usar:
-- 1. Acesse seu projeto em supabase.com
-- 2. Vá no menu lateral em "SQL Editor"
-- 3. Cole todo este arquivo e clique em "Run"
-- ============================================================

-- Tabela de profissionais cadastrados
create table profissionais (
  id uuid primary key default gen_random_uuid(),
  nome_completo text not null,
  cpf_cnpj text not null,
  whatsapp text not null,
  email text not null,
  cidade text not null,
  bairro text not null,
  servicos_oferecidos text[] not null default '{}',
  experiencia text,
  disponibilidade text,
  sobre text,
  documento_url text,
  status text not null default 'pendente', -- pendente | aprovado | bloqueado
  criado_em timestamp with time zone default now()
);

-- Tabela de pedidos de serviço (vindos do formulário de orçamento do site)
create table pedidos_servico (
  id uuid primary key default gen_random_uuid(),
  nome_cliente text not null,
  whatsapp_cliente text not null,
  tipo_servico text not null,
  perfil text, -- "Cliente" ou outro
  cidade text,
  bairro text,
  descricao text,
  foto_local_url text,
  status text not null default 'aberto', -- aberto | em_andamento | concluido
  profissional_id uuid references profissionais(id),
  criado_em timestamp with time zone default now()
);

-- ============================================================
-- SEGURANÇA (Row Level Security)
-- Por padrão o Supabase bloqueia tudo. Estas regras liberam:
-- - Qualquer pessoa pode SE CADASTRAR (insert) como profissional
-- - Qualquer pessoa pode CRIAR um pedido de serviço
-- - Leitura de profissionais/pedidos fica restrita (só você vê
--   pelo painel do Supabase, com sua conta de admin)
-- ============================================================

alter table profissionais enable row level security;
alter table pedidos_servico enable row level security;

create policy "Qualquer um pode se cadastrar como profissional"
  on profissionais for insert
  with check (true);

create policy "Qualquer um pode criar um pedido de servico"
  on pedidos_servico for insert
  with check (true);

-- Caso queira no futuro permitir que profissionais logados vejam
-- os pedidos abertos da própria região, será necessário configurar
-- autenticação (Supabase Auth) e ajustar estas políticas.
