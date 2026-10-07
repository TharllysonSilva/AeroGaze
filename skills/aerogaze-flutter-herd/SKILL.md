---
name: aerogaze-flutter-herd
description: Implementar ou revisar rebanho e histórico no app Flutter AeroGaze, nas stories FL-025, FL-026. Usar para este módulo do mobile do hackathon.
---

# Rebanho e histórico

Leia [as stories](../../docs/flutter/stories/09-rebanho.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Rebanho é P1; não atrasar fluxo P0. Identidade e histórico por tenant, sem NFT negociável ou telemetria inventada. Vacinação, manejo e movimentação são eventos imutáveis; correções compensatórias conservam autoria/dispositivo. Consulta offline usa cache identificado com instante de atualização.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
