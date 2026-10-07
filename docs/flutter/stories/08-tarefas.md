# Alertas e ordens de serviço

Skill: [$aerogaze-flutter-tasks](../../../skills/aerogaze-flutter-tasks/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-022 - Painel de alertas e pendências

Como operador, quero ver prioridades da fazenda e o estado dos meus envios.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-018; FL-019.
- Status: planejada.

**Implementação**

Substituir fixture do painel por streams locais, contadores derivados, horário de atualização e indicação offline.

**Critérios de aceite**

Contadores batem com listas do mesmo tenant; dado desatualizado é identificado; alerta novo corresponde à inspeção confirmada; UI não inventa sensores ou predição.

**Verificação/evidência**

Dados vazios, cache antigo e evento integrado; conferir totais entre painel/detalhe.

## FL-023 - Consultar tarefa vinculada ao alerta

Como operador, quero abrir a ação gerada pela inspeção.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-019; regra backend cria tarefa.
- Status: planejada.

**Implementação**

Lista/detalhe de ordem com ID, status, origem/inspeção, responsável e prioridade; cache offline.

**Critérios de aceite**

Uma inspeção reenviada mantém uma única tarefa por efeito idempotente; link abre a evidência correta; offline permite leitura do que está cacheado.

**Verificação/evidência**

Integração inspeção -> alerta -> tarefa e consulta em modo avião.

## FL-024 - Executar e concluir tarefa offline

Como operador, quero registrar uma execução sem apagar o histórico anterior.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-008; FL-017; FL-023; papéis FL-006.
- Status: planejada.

**Implementação**

Eventos de início/conclusão com notas/evidência e versão esperada; projeção local marcada pendente; conflitos explícitos.

**Critérios de aceite**

Concluir offline sobrevive reinício; duplo toque não duplica evento; dois dispositivos não sobrescrevem silenciosamente; após ACK estado reconciliado mantém histórico.

**Verificação/evidência**

Conclusão offline, ACK perdido, concorrência de dois dispositivos e recusa de papel.
