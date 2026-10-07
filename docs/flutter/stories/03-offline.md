# Persistência offline

Skill: [$aerogaze-flutter-offline](../../../skills/aerogaze-flutter-offline/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-007 - Banco Drift e migrações

Como operador, quero recuperar meus dados mesmo depois de fechar o app.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-001.
- Status: planejada.

**Implementação**

Drift/SQLite com inspeções, mídia, eventos/outbox, contexto, tarefas/cache e cursores; índices e migração inicial.

**Critérios de aceite**

Dados são escopados por organização/fazenda; abrir/fechar processo preserva registros; migração mantém dados e não recria banco destrutivamente.

**Verificação/evidência**

Teste com banco em arquivo reaberto e migração com dados; memória não prova persistência.

## FL-008 - Inspeção e outbox atômicas

Como operador, quero salvar uma inspeção sem perder sua futura sincronização.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-007; contexto real ou demo explícito.
- Status: planejada.

**Implementação**

UUID local; envelope imutável; inspeção, resultado e outbox na mesma transação; timestamps UTC e versão.

**Critérios de aceite**

Commit gera exatamente um evento enfileirado; falha intermediária não deixa inspeção sem outbox; sucesso UI só após commit; reabertura mantém IDs.

**Verificação/evidência**

Injetar falha na transação, salvar offline, encerrar e reabrir processo.

## FL-009 - Arquivos privados e integridade de mídia

Como operador, quero que a foto da inspeção continue disponível e íntegra.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-007.
- Status: planejada.

**Implementação**

Copiar câmera para diretório privado, hash SHA-256, metadados no banco, reconciliação de órfãos e estado de falta de espaço.

**Critérios de aceite**

Cache temporário removido não perde foto salva; mídia faltante/corrompida impede ACK local; erro de disco mantém rascunho recuperável e feedback.

**Verificação/evidência**

Reabertura de arquivo, hash conhecido, disco sem espaço e janela de falha arquivo/banco.
