-- Execute no SQL Editor do Supabase antes de publicar os novos HTMLs.
alter table public.pedidos_servico
  add column if not exists data_preferida date,
  add column if not exists hora_preferida time without time zone,
  add column if not exists cancelado_em timestamp with time zone;

-- O site permite criar e atualizar pedidos como visitante. Reserve o
-- cancelamento para o painel autenticado e proteja o histórico de alterações anônimas.
drop policy if exists "Visitante cria apenas pedidos sem cancelamento" on public.pedidos_servico;
create policy "Visitante cria apenas pedidos sem cancelamento"
  on public.pedidos_servico as restrictive for insert to anon
  with check (status <> 'cancelado' and cancelado_em is null);

drop policy if exists "Visitante atualiza apenas pedidos sem cancelamento" on public.pedidos_servico;
create policy "Visitante atualiza apenas pedidos sem cancelamento"
  on public.pedidos_servico as restrictive for update to anon
  using (status <> 'cancelado' and cancelado_em is null)
  with check (status <> 'cancelado' and cancelado_em is null);
