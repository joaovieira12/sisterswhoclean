# Publicação da atualização

1. No SQL Editor do projeto Supabase que o site já usa, execute `schema-v3.sql`, `schema-v4.sql` e `schema-v5.sql`, nessa ordem. Se as migrações v3 e v4 já estiverem aplicadas, execute apenas a v5.
2. Publique os HTMLs e a pasta `assets` na hospedagem existente.
3. Envie um pedido de teste pelo formulário. Confira a data e o horário no painel e use **Cancelar pedido** para movê-lo ao histórico **Cancelados**.

No painel administrativo, a aba **Pedidos** tem o botão **Ativar notificações do navegador** quando o navegador oferece suporte e ainda não tem uma permissão definida. Em HTTPS, permita as notificações e mantenha o painel aberto. O painel também consulta novos pedidos a cada 15 segundos e exibe um aviso e o total de pedidos pendentes. Navegadores em segundo plano podem atrasar a consulta.

## Prazo de 7 dias

Execute `schema-v6.sql` depois da v5, antes de publicar o site atualizado. A migração habilita o Supabase Cron e agenda uma verificação por minuto. Em **Integrations → Cron**, o job aparece como `sisters-who-clean-expirar-orcamentos`.

No painel, informe o valor e a comissão. Clique em **Abrir orçamento no WhatsApp**, envie a mensagem e clique em **Registrar envio** para iniciar o prazo. Quando o cliente responder aceitando, clique em **Confirmar aceite e liberar**. Ao fim de 7 dias (168 horas), o aceite fica bloqueado e a próxima execução do Cron move o pedido para **Cancelados**. Pedidos anteriores só passam a ter prazo se um novo envio for registrado pelo painel.

Para testar, envie um pedido de teste e registre o envio. No Table Editor, ajuste `orcamento_expira_em` desse pedido de teste para um horário anterior ao atual. Aguarde até a próxima execução do Cron e atualize a lista. Faça um segundo teste confirmando o aceite antes do prazo e confira se o pedido aparece como liberado.
