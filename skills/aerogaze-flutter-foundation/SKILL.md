---
name: aerogaze-flutter-foundation
description: Implementar ou revisar fundação e interface no app Flutter AeroGaze, nas stories FL-001, FL-002, FL-003. Usar para este módulo do mobile do hackathon.
---

# Fundação e interface

Leia [as stories](../../docs/flutter/stories/01-fundacao.md) para selecionar o trabalho pedido e seus critérios. Consulte [arquitetura](../../docs/flutter/arquitetura.md) ao mudar estrutura e [contratos](../../docs/flutter/contratos.md) ao integrar dados. Os links partem deste diretório; o app está em `../../apps/mobile`.

## Decisões do módulo

Preserve apps/mobile e as cinco abas em português do dossiê p. 6. Use tema escuro com destaque verde sem importar métricas conceituais como medições. Derive contadores de uma única fonte. Introduza repositórios/serviços quando houver dados, sem criar camadas vazias. O scaffold não atende captura/persistência só por navegar.

Para apresentação, siga agora as cinco referências de `apps/mobile/assets/reference` e [as decisões de implementação](../../docs/design/implementacao-mobile.md), que atualizam o visual inicial do dossiê. Tokens e tipografia ficam em `app/design_system.dart`: Space Grotesk/Inter locais, não fontes do sistema. Reproduza composição com widgets; não substituir uma tela por sua captura. O marcador DEMO e os detalhes do status identificam fixtures.

Preserve os flavors Android `dev` e `prod`, com `dev` padrão. O ambiente Dart vem de `appFlavor`; evite duplicar a escolha em entrypoints/dart-defines que possam divergir. Dev usa sufixo `.dev` no applicationId; a marca visual interna é AEROGAZE COMMAND em ambos os ambientes. Ambos mantêm identificação de fixtures enquanto a integração real estiver pendente. Os comandos e a limitação de assinatura release estão no README do app.

## Entrega

Implemente a story autorizada e suas dependências necessárias, identificando qualquer dependência externa ausente. Preserve o recorte P0/P1 descrito no [índice](../../docs/flutter/README.md). Não amplie para backend, cadeia ou serviços externos apenas porque estão mencionados nas fontes.

Execute format/analyze e os testes pertinentes em apps/mobile; use a verificação da story para provar o comportamento, com aparelho/API quando exigidos. Atualize status com evidência e pendências reais. Não declare concluída uma integração sustentada apenas por fixtures.
