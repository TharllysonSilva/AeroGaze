---
name: aerogaze-flutter-tasks
description: Implementar ou revisar alertas e ordens de serviço no app Flutter AeroGaze, nas stories FL-022, FL-023, FL-024. Usar para este módulo do mobile do hackathon.
---

# Alertas e ordens de serviço

Leia [as stories](../../docs/flutter/stories/08-tarefas.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Alertas e tarefas são efeitos da regra backend e chegam ao cache pela mesma inspeção; não invente tarefa automática local como integração real. Contadores derivam do cache por tenant. Execução offline gera evento imutável com versão esperada; projeção pendente é visível. Reconcile ACK/conflitos sem LWW ou apagamento do histórico.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
