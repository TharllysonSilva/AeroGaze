---
name: aerogaze-flutter-offline
description: Implementar ou revisar persistência offline no app Flutter AeroGaze, nas stories FL-007, FL-008, FL-009. Usar para este módulo do mobile do hackathon.
---

# Persistência offline

Leia [as stories](../../docs/flutter/stories/03-offline.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Drift/SQLite é a fonte persistente. Inspeção, inferência disponível e evento/outbox fazem commit na mesma transação. Mídia vai para diretório privado antes do commit; arquivo e banco não são atômicos, então trate órfãos/falta de espaço. UUID/chave/envelope são estáveis. Validar persistência reabrindo banco em arquivo/processo, não apenas memória.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
