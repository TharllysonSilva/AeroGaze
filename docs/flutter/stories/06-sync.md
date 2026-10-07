# Sincronização e contratos

Skill: [$aerogaze-flutter-sync](../../../skills/aerogaze-flutter-sync/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-016 - Alinhar transporte e ACK

Como operador, quero envio autenticado com confirmação inequívoca.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-004/005/008/009; contrato API acordado.
- Status: planejada.

**Implementação**

Converter proposta de contratos.md em DTOs versionados; upload/hash; Idempotency-Key; ACK por ID; timeout e códigos.

**Critérios de aceite**

Só marcar synced para ID confirmado duravelmente; duplicata retorna mesmo recibo; mídia só é referenciada após upload válido; 409 genérico não é sucesso.

**Verificação/evidência**

Servidor de teste/integração com ACK certo, parcial, inválido e mídia rejeitada.

## FL-017 - Worker durável com retry

Como operador, quero que o app tente sincronizar sem perder nem duplicar evidências.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-016.
- Status: planejada.

**Implementação**

Worker com lease/exclusão mútua, backoff/jitter persistidos, recuperação de sending; disparos manual, sinal connectivity e retomada app.

**Critérios de aceite**

Timeout/429/5xx preservam envelope; conexão sem internet não marca synced; lease expirado recupera evento; worker concorrente não muda chave; ACK perdido reenvia sem efeito duplicado no backend.

**Verificação/evidência**

Falha após commit servidor, encerramento durante envio, duas tentativas concorrentes e reabertura com retry. Não prometer execução background garantida pelo Android.

## FL-018 - Fila, conflito e rejeição visíveis

Como operador, quero saber quais registros exigem minha atenção.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-012; FL-017.
- Status: planejada.

**Implementação**

Exibir pending/sending/retry/synced/conflict/rejected, contagem por tenant, motivos e retry manual; compensação para correção.

**Critérios de aceite**

Nenhuma falha temporária remove evento; 401 pausa sem limpar; 403/rejeição não fazem retry infinito; correção preserva original e autoria.

**Verificação/evidência**

Cenários de expiração, revogação, rejeição e conflito de dois dispositivos.

## FL-019 - Receber alterações e cache operacional

Como operador, quero receber alertas e tarefas do mesmo fluxo enviado.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-016/017; API changes/cursor.
- Status: planejada.

**Implementação**

Pull paginado com cursor; upsert de cache e cursor atômicos; manter versões/autoria e evento de conclusão separado.

**Critérios de aceite**

Repetir página não duplica; falha antes do commit não avança cursor; alertas/tarefas são da fazenda ativa e da mesma inspeção; dados antigos continuam disponíveis offline.

**Verificação/evidência**

Paginação, repetição, interrupção e acesso entre tenants; validar origem do alerta/tarefa no backend.
