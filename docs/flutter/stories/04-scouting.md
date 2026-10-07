# Captura e scouting

Skill: [$aerogaze-flutter-scouting](../../../skills/aerogaze-flutter-scouting/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-010 - Câmera e permissões

Como operador, quero fotografar a folha sem precisar de internet.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-002; FL-009.
- Status: planejada.

**Implementação**

Preview, captura/repetição, ciclo de vida e liberação de câmera; permissões Android solicitadas no contexto.

**Critérios de aceite**

Em modo avião captura funciona; permissão negada oferece recuperação; retorno do background não trava; nenhuma chamada remota é necessária.

**Verificação/evidência**

Android real: negar permissão, capturar, repetir e alternar background.

## FL-011 - Revisar e salvar observação

Como operador, quero revisar foto, posição e observação antes de salvar.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-008; FL-010; FL-020.
- Status: planejada.

**Implementação**

Tela de revisão com talhão informado, nota, precisão GPS e resultado IA quando disponível; prevenção de duplo toque.

**Critérios de aceite**

Salvar cria um evento local; duplo toque não duplica; GPS ausente não inventa posição; erro de modelo não descarta foto; regra de captura incompleta é explícita.

**Verificação/evidência**

Fluxo offline com/sem GPS e com erro de inferência; validar inspeção/outbox após reinício.

## FL-012 - Histórico e detalhe da inspeção

Como operador, quero consultar evidências e entender se chegaram ao servidor.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-008; FL-009.
- Status: planejada.

**Implementação**

Lista reativa por fazenda, detalhe com foto/hash, autoria, modelo, estado sync e motivo de rejeição; correção como novo evento.

**Critérios de aceite**

Inspeção salva aparece offline após reinício; detalhe mantém original; correção liga ao original; pendente e sincronizado não são confundidos com ancorado.

**Verificação/evidência**

Reabrir app, filtrar tenant e rastrear cadeia original/correção.
