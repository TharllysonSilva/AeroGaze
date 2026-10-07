# Sessão, fazenda e dispositivo

Skill: [$aerogaze-flutter-session](../../../skills/aerogaze-flutter-session/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-004 - Autenticação e contexto de fazenda

Como operador, quero entrar e selecionar apenas fazendas às quais tenho acesso.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-001; API de identidade.
- Status: planejada.

**Implementação**

Login, contexto organizationId/farmId/actorId e armazenamento seguro de tokens; cache particionado.

**Critérios de aceite**

Falha de login é visível; token não aparece em logs; troca de fazenda não exibe dados anteriores; API rejeita tenant alheio.

**Verificação/evidência**

Integração com duas organizações e testes de logout/troca de contexto.

## FL-005 - Identidade de dispositivo e continuidade offline

Como operador, quero continuar capturando offline com autoria rastreável.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-004; contrato de registro/revogação.
- Status: planejada.

**Implementação**

Provisionar deviceId e chave segura conforme backend; política de sessão offline/expirada; preservar fila por dono.

**Critérios de aceite**

Reabrir offline conserva identidade; revogação impede novos envios autorizados; logout não apaga evidências pendentes nem as mostra a outro usuário.

**Verificação/evidência**

Reinício, expiração e revogação; confirmar que chave não entra no SQLite/log.

## FL-006 - Papéis e ações permitidas

Como gerente, quero que ações respeitem operador, veterinário, gerente, auditor e administrador.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-004; matriz de permissões backend.
- Status: planejada.

**Implementação**

Aplicar capacidades recebidas pela API na UI e tratar 403. Não implementar autorização apenas escondendo botões.

**Critérios de aceite**

Usuário sem permissão recebe recusa da API mesmo chamando ação diretamente; auditor não edita histórico; lista offline segue escopo cacheado.

**Verificação/evidência**

Matriz mínima de leitura/execução/correção por papel e teste API negativo.
