---
name: aerogaze-flutter-scouting
description: Implementar ou revisar captura e scouting no app Flutter AeroGaze, nas stories FL-010, FL-011, FL-012. Usar para este módulo do mobile do hackathon.
---

# Captura e scouting

Leia [as stories](../../docs/flutter/stories/04-scouting.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

A câmera funciona sem rede; trate permissões, lifecycle, recuperação e duplo toque. Copie mídia temporária para armazenamento durável antes de confirmar salvamento. GPS ausente/antigo tem estado explícito. Erro de IA não apaga foto e não é classe inconclusiva. Revisão e correção preservam o evento original.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
