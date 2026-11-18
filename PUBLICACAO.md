# Publicação da atualização

1. No SQL Editor do projeto Supabase que o site já usa, execute `schema-v3.sql`, `schema-v4.sql` e `schema-v5.sql`, nessa ordem. Se as migrações v3 e v4 já estiverem aplicadas, execute apenas a v5.
2. Publique os HTMLs e a pasta `assets` na hospedagem existente.
3. Envie um pedido de teste pelo formulário. Confira a data e o horário no painel e use **Cancelar pedido** para movê-lo ao histórico **Cancelados**.

No painel administrativo, a aba **Pedidos** tem o botão **Ativar notificações do navegador** quando o navegador oferece suporte e ainda não tem uma permissão definida. Em HTTPS, permita as notificações e mantenha o painel aberto. O painel também consulta novos pedidos a cada 15 segundos e exibe um aviso e o total de pedidos pendentes. Navegadores em segundo plano podem atrasar a consulta.
