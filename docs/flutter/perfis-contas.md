# Contas e permissões do protótipo

Em 13/10/2026, seis contas tiveram login HTTP 200 conferido na API publicada. As cinco contas iniciais receberam novas senhas a pedido do responsável; a senha da integração foi preservada. Senhas ficam somente no arquivo local ignorado `.env.accounts.local` do repositório da API.

| Conta | Perfil |
| --- | --- |
| operador@demo.aerogaze | Operador de campo |
| vet@demo.aerogaze | Veterinário |
| gerente@demo.aerogaze | Gerente |
| auditor@demo.aerogaze | Auditor |
| admin@demo.aerogaze | Administrador |
| gerente.integracao@demo.aerogaze | Gerente de integração |

Operador, veterinário e gerente ficam vinculados à fazenda de demonstração. Administrador e auditor têm escopo da organização. Auditor consulta e verifica provas, sem alterar tarefas ou cenário. Cadastro de aparelhos e talhões exige gerente/administrador. Consulta de eventos exige veterinário/gerente/auditor/administrador; o operador acompanha seus próprios ACKs e recibos pelo Scout.

As ações do cenário e mudanças de status de tarefa são permitidas a operador/veterinário/gerente/administrador; essa é a granularidade atual, não uma política completa de administração de uma empresa. A API confere organização/fazenda mesmo quando o cliente esconde botões. Não há CRUD completo de usuários no app.

As cinco abas preservam a mesma identidade visual. Permissões determinam ações e escopo de dados, não substituem o desenho das telas.
