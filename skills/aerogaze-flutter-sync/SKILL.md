---
name: aerogaze-flutter-sync
description: Implementar ou revisar sincronização e contratos no app Flutter AeroGaze, nas stories FL-016, FL-017, FL-018, FL-019. Usar para este módulo do mobile do hackathon.
---

# Sincronização e contratos

Leia [as stories](../../docs/flutter/stories/06-sync.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Leia contratos.md: é proposta, não API existente. connectivity_plus é gatilho e não prova internet. Worker usa lease e retry durável; trata timeout/429/5xx, expiração e rejeições. ACK válido/durável por ID, com mídia válida, é o único encerramento. Reenvio mantém UUID/chave/payload. Não transformar 409 em sucesso sem recibo. Conflitos/correções operacionais são append-only.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
