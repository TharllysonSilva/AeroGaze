---
name: aerogaze-flutter-session
description: Implementar ou revisar sessão, fazenda e dispositivo no app Flutter AeroGaze, nas stories FL-004, FL-005, FL-006. Usar para este módulo do mobile do hackathon.
---

# Sessão, fazenda e dispositivo

Leia [as stories](../../docs/flutter/stories/02-sessao.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Escopo organizationId/farmId acompanha banco, filas, cache e requisições. Token/chave ficam em armazenamento seguro. Logout e troca de conta não podem perder evidências nem expor filas anteriores. Política offline após expiração e revogação deve ser acordada, não inferida de conectividade. A API aplica autorização, além da UI.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
