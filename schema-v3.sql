-- ============================================================
-- SISTERS WHO CLEAN — Schema v3 — Rode no SQL Editor do Supabase
-- Adiciona aprovação de orçamento pela administração + comissão
-- ============================================================

-- 1. Novas colunas em pedidos_servico
alter table pedidos_servico
  add column if not exists valor_servico numeric(10,2),
  add column if not exists comissao_percentual numeric(5,2),
  add column if not exists comissao_valor numeric(10,2),
  add column if not exists aprovado_em timestamp with time zone;

-- 2. A partir de agora, todo pedido novo nasce "aguardando_aprovacao"
--    (antes nascia direto como "aberto"). O admin.html já envia esse
--    valor explicitamente, mas isso garante o mesmo default no banco.
alter table pedidos_servico
  alter column status set default 'aguardando_aprovacao';

-- Observação: as policies de select/update de pedidos_servico já
-- foram liberadas no schema-v2.sql (using (true)), então não é
-- necessário mexer em RLS para este passo.
