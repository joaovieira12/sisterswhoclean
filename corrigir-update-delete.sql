-- ============================================================
-- Rode este script no SQL Editor do Supabase.
-- Ele apaga e recria as políticas de update/delete para garantir
-- que existam corretamente, mesmo que você já tenha tentado antes.
-- ============================================================

drop policy if exists "Permitir remover profissionais (para o painel admin)" on profissionais;
drop policy if exists "Permitir atualizar status de profissionais (para o painel admin)" on profissionais;

create policy "Permitir remover profissionais (para o painel admin)"
  on profissionais for delete
  using (true);

create policy "Permitir atualizar status de profissionais (para o painel admin)"
  on profissionais for update
  using (true)
  with check (true);

-- Para conferir se funcionou, rode esta consulta depois:
-- select * from pg_policies where tablename = 'profissionais';
-- Deve aparecer pelo menos 4 linhas (select, insert, update, delete)
