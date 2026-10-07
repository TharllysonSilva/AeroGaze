---
name: aerogaze-flutter-map
description: Implementar ou revisar mapa e localização no app Flutter AeroGaze, nas stories FL-020, FL-021. Usar para este módulo do mobile do hackathon.
---

# Mapa e localização

Leia [as stories](../../docs/flutter/stories/07-mapa.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Salve latitude/longitude/precisão/instante; trate permissão, GPS desligado e posição stale. Não use 0,0 como ausência. Seleção local de talhão não substitui PostGIS. Geofence oficial considera margem, permanência e leituras na API. Falha de tiles ou chave não bloqueia scouting; fallback textual suficiente para o fluxo P0.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
