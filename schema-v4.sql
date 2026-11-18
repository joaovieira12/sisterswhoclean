-- ============================================================
-- SISTERS WHO CLEAN — Schema v4 — Rode no SQL Editor do Supabase
-- Corrige erro ao remover profissional que já tem pedidos
-- ============================================================

-- O vínculo pedidos_servico.profissional_id não tinha uma regra de
-- "o que fazer" quando a profissional é apagada, então o Postgres
-- bloqueava a exclusão (erro de foreign key).
--
-- A correção abaixo troca a regra para "ON DELETE SET NULL":
-- o pedido continua existindo (histórico e comissão preservados),
-- só o vínculo com a profissional removida fica em branco.

alter table pedidos_servico
  drop constraint if exists pedidos_servico_profissional_id_fkey;

alter table pedidos_servico
  add constraint pedidos_servico_profissional_id_fkey
  foreign key (profissional_id) references profissionais(id)
  on delete set null;
