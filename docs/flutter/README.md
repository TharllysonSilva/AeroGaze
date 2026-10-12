# Flutter para o hackathon

Objetivo: demonstrar uma inspeção capturada sem internet, com inferência local e persistência no dispositivo, sincronizada uma única vez para gerar alerta/tarefa e receber uma prova verificável.

## Entregue nesta etapa

- Base Android em `apps/mobile`, tema escuro inspirado no dossiê e navegação em português: Painel, Mapa, Scout, Rebanho e Tarefas.
- Ampliação 0.2.0: cenário operacional simulado compartilhado pela API, com irrigação, pragas, drone, rebanho, estoque, mapa de ativos e histórico. Ensaio Android de falha/reparo/irrigação passou; publicação e recibo Solana real têm suas evidências e pendências em [integração demonstrável](integracao-demonstravel.md).
- Cinco telas visuais em Flutter com dados ilustrativos e identificação de demonstração; entrada real e navegação operacional adicionadas em 12/10/2026; referências visuais antigas preservadas como demonstração. A adaptação às imagens e ao DESIGN.md está em [implementação mobile](../design/implementacao-mobile.md).
- Stories detalhadas e skills locais por módulo. O app registra inspeções manuais, persiste SQLite e sincroniza com ACK da API. Câmera/GPS/inferência e mídia permanecem pendentes.

## Índice de execução

| Parte | Stories | Skill local |
| --- | --- | --- |
| Fundação e interface | [FL-001 a FL-003](stories/01-fundacao.md) | [aerogaze-flutter-foundation](../../skills/aerogaze-flutter-foundation/SKILL.md) |
| Sessão, fazenda e dispositivo | [FL-004 a FL-006](stories/02-sessao.md) | [aerogaze-flutter-session](../../skills/aerogaze-flutter-session/SKILL.md) |
| Persistência offline | [FL-007 a FL-009](stories/03-offline.md) | [aerogaze-flutter-offline](../../skills/aerogaze-flutter-offline/SKILL.md) |
| Captura e scouting | [FL-010 a FL-012](stories/04-scouting.md) | [aerogaze-flutter-scouting](../../skills/aerogaze-flutter-scouting/SKILL.md) |
| Inferência no dispositivo | [FL-013 a FL-015](stories/05-ia.md) | [aerogaze-flutter-inference](../../skills/aerogaze-flutter-inference/SKILL.md) |
| Sincronização e contratos | [FL-016 a FL-019](stories/06-sync.md) | [aerogaze-flutter-sync](../../skills/aerogaze-flutter-sync/SKILL.md) |
| Mapa e localização | [FL-020 a FL-021](stories/07-mapa.md) | [aerogaze-flutter-map](../../skills/aerogaze-flutter-map/SKILL.md) |
| Alertas e ordens de serviço | [FL-022 a FL-024](stories/08-tarefas.md) | [aerogaze-flutter-tasks](../../skills/aerogaze-flutter-tasks/SKILL.md) |
| Rebanho e histórico | [FL-025 a FL-026](stories/09-rebanho.md) | [aerogaze-flutter-herd](../../skills/aerogaze-flutter-herd/SKILL.md) |
| Recibo e prova por QR | [FL-027 a FL-028](stories/10-prova.md) | [aerogaze-flutter-proof](../../skills/aerogaze-flutter-proof/SKILL.md) |
| QA, observabilidade e ensaio | [FL-029 a FL-031](stories/11-demonstracao.md) | [aerogaze-flutter-demo](../../skills/aerogaze-flutter-demo/SKILL.md) |

## Ordem sugerida

1. Fundação, banco e captura: FL-001/002/003 -> FL-007/008/009 -> FL-010/011/012. Usar contexto de demonstração explícito enquanto a sessão real não existe.
2. Em seguida, IA local (FL-013/014/015) e identidade/autenticação (FL-004/005/006).
3. Integração: FL-016/017/018/019, com contrato acordado com backend; FL-020 para contexto espacial e FL-022/023/024 para operação.
4. Prova: FL-027/028 com a API/verificador. Ensaio e critérios FL-029/030/031 ao longo da implementação.
5. FL-021 (mapa interativo), FL-025/026 (rebanho) são P1 e só entram após o fluxo principal funcionar.

P0 significa necessário para o fluxo real da demonstração. P1 significa complemento que pode ser cortado. Não há prazo do hackathon ou quantidade de pessoas informados; estimativas nas stories são relativas (P/M/G), não compromissos de horas. Faça um primeiro ensaio antes de ampliar o escopo.

## Dependências externas ainda não entregues

A API NestJS publicada já fornece identidade, ACK por UUID, regras, tarefas e verificador. Permanecem fora do recorte manual: validação PostGIS; upload S3; regras que geram alerta/tarefa; modelo `.tflite`, labels e especificação de pré-processamento; verificador público e worker de ancoragem. Os contratos locais são propostas, não endpoints já existentes.

## Como continuar

Exemplo de pedido: `Use a skill em skills/aerogaze-flutter-offline/SKILL.md e implemente FL-007 e FL-008, conforme docs/flutter/stories/03-offline.md.`

O recorte manual está descrito com evidências em [integração demonstrável](integracao-demonstravel.md). Próximas etapas incluem captura com mídia/GPS, inferência local, execução offline de tarefas e testes de encerramento do processo Android durante envio.

