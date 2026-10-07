# Rebanho e histórico

Skill: [$aerogaze-flutter-herd](../../../skills/aerogaze-flutter-herd/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-025 - Lista e detalhe do animal

Como veterinário, quero consultar identidade e histórico do rebanho da fazenda.

- Prioridade: P1. Tamanho: M.
- Dependências: FL-004; FL-007; API animais.
- Status: planejada.

**Implementação**

Cache de animal/identificador/piquete; lista/detalhe e contadores; fixtures explícitas até API. Sem NFT negociável.

**Critérios de aceite**

Animal pertence ao tenant; totais coerentes; telemetria ausente aparece ausente, não com números inventados; histórico pode ser consultado offline.

**Verificação/evidência**

Troca de fazenda e consulta offline; sem endpoint manter story pendente.

## FL-026 - Eventos sanitários e de manejo

Como veterinário, quero registrar vacinação, manejo e movimentação com autoria preservada.

- Prioridade: P1. Tamanho: G.
- Dependências: FL-008; FL-006; FL-017; FL-025.
- Status: planejada.

**Implementação**

Eventos append-only, correção compensatória, ordem temporal e identificação de autor/dispositivo; sem LWW.

**Critérios de aceite**

Correção não modifica vacinação original; dois dispositivos conservam eventos ou conflito explícito; registro persiste offline e deduplica na API.

**Verificação/evidência**

Original/correção, concorrência, autorização e retry. Eventos não representam pagamentos nem certificados automáticos.
