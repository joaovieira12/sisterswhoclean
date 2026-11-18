-- Execute no SQL Editor do Supabase após a v5.
begin;

create extension if not exists pg_cron;

alter table public.pedidos_servico
  add column if not exists orcamento_enviado_em timestamptz,
  add column if not exists orcamento_expira_em timestamptz,
  add column if not exists cancelado_por_prazo boolean not null default false;

create index if not exists pedidos_orcamento_expira_idx
  on public.pedidos_servico (orcamento_expira_em)
  where status = 'aguardando_cliente';

-- As permissões antigas de visitante continuam valendo para os pedidos
-- liberados, mas os visitantes não podem alterar pedidos aguardando aceite.
drop policy if exists "Visitante cria pedido sem prazo" on public.pedidos_servico;
create policy "Visitante cria pedido sem prazo"
  on public.pedidos_servico as restrictive for insert to anon
  with check (
    status <> 'aguardando_cliente' and orcamento_enviado_em is null
    and orcamento_expira_em is null and not cancelado_por_prazo
  );

drop policy if exists "Visitante aguarda confirmação da administração" on public.pedidos_servico;
create policy "Visitante aguarda confirmação da administração"
  on public.pedidos_servico as restrictive for update to anon
  using (status <> 'aguardando_cliente')
  with check (status <> 'aguardando_cliente' and not cancelado_por_prazo);

-- As funções usam as permissões do painel autenticado.
create or replace function public.registrar_envio_orcamento(
  pedido uuid, valor numeric, percentual numeric
) returns boolean
language plpgsql
set search_path = ''
as $$
declare
  enviado timestamptz := pg_catalog.clock_timestamp();
begin
  if valor is null or valor < 0.01 or valor > 99999999.99
     or percentual is null or percentual < 0 or percentual > 100 then
    raise exception 'Informe um valor válido e uma comissão de 0 a 100%%.';
  end if;

  update public.pedidos_servico
  set status = 'aguardando_cliente',
      valor_servico = round(valor, 2),
      comissao_percentual = round(percentual, 2),
      comissao_valor = round(round(valor, 2) * round(percentual, 2) / 100, 2),
      orcamento_enviado_em = enviado,
      orcamento_expira_em = enviado + interval '168 hours'
  where id = pedido and status = 'aguardando_aprovacao';

  return found;
end;
$$;

create or replace function public.registrar_aceite_orcamento(pedido uuid)
returns boolean
language plpgsql
set search_path = ''
as $$
begin
  -- Confere o prazo depois de obter o bloqueio da linha, inclusive se
  -- houver um cancelamento concorrente ou o aceite chegar no limite.
  perform 1 from public.pedidos_servico
  where id = pedido and status = 'aguardando_cliente' for update;

  update public.pedidos_servico
  set status = 'aberto', aprovado_em = pg_catalog.clock_timestamp()
  where id = pedido and status = 'aguardando_cliente'
    and orcamento_expira_em > pg_catalog.clock_timestamp();

  return found;
end;
$$;

revoke all on function public.registrar_envio_orcamento(uuid, numeric, numeric) from public, anon;
revoke all on function public.registrar_aceite_orcamento(uuid) from public, anon;
grant execute on function public.registrar_envio_orcamento(uuid, numeric, numeric) to authenticated;
grant execute on function public.registrar_aceite_orcamento(uuid) to authenticated;

select cron.schedule(
  'sisters-who-clean-expirar-orcamentos',
  '* * * * *',
  $cron$
    update public.pedidos_servico
    set status = 'cancelado', cancelado_em = statement_timestamp(),
        cancelado_por_prazo = true
    where status = 'aguardando_cliente'
      and orcamento_expira_em <= statement_timestamp();
  $cron$
);

commit;
