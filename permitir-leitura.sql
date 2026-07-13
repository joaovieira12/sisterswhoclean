-- ============================================================
-- Rode este script no SQL Editor do Supabase
-- (necessário para a página admin.html conseguir LER os cadastros)
-- ============================================================

create policy "Leitura publica de profissionais (para o painel admin)"
  on profissionais for select
  using (true);

create policy "Leitura publica de pedidos (para o painel admin)"
  on pedidos_servico for select
  using (true);

create policy "Permitir remover profissionais (para o painel admin)"
  on profissionais for delete
  using (true);

create policy "Permitir atualizar status de profissionais (para o painel admin)"
  on profissionais for update
  using (true);

-- ⚠️ IMPORTANTE: isso deixa os dados legíveis por qualquer pessoa que
-- souber o link da página admin.html, já que ela usa a mesma chave
-- pública do site. A página tem uma senha simples de tela (definida
-- no próprio código) para evitar acesso casual, mas não é uma
-- segurança real de banco de dados.
--
-- Se no futuro quiser uma proteção de verdade (login com senha
-- validado pelo próprio Supabase), me avise que eu configuro o
-- Supabase Auth — é mais trabalho, mas fica seguro de verdade.
