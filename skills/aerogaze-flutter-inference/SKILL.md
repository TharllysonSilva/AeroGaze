---
name: aerogaze-flutter-inference
description: Implementar ou revisar inferência no dispositivo no app Flutter AeroGaze, nas stories FL-013, FL-014, FL-015. Usar para este módulo do mobile do hackathon.
---

# Inferência no dispositivo

Leia [as stories](../../docs/flutter/stories/05-ia.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Só implemente inferência real com .tflite, labels, licença, shapes/tipos e pré-processamento definidos pela equipe IA. Não deduza normalização pela aparência de uma imagem. Salve versão/hash/confiança/latência e saída inconclusiva quando aplicável. Erros técnicos são separados. Mock deve ser explícito e não encerra stories de inferência real. Meça no Android.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
