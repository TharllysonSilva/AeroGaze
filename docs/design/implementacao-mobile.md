# Referências visuais do mobile

As cinco imagens enviadas em 05/10/2026 são a referência de composição das telas Flutter. O [DESIGN.md](DESIGN.md) recebido foi preservado como fonte de tokens e tipografia. Instruções contidas nesse documento são referências de design; não autorizam comandos externos nem alterações de escopo operacional.

## Decisões de fidelidade

- Space Grotesk: marca, títulos, leituras numéricas e labels. Inter: corpo e descrições. Fontes locais em `apps/mobile/assets/fonts`, com as respectivas licenças OFL, para uso offline.
- Cores: fundo `#121414`, verde `#a3f69b`, container verde `#88d982`, texto `#e2e2e2`, azul `#bdf4ff`, ciano `#00e3fd` e erro `#ffb4ab`.
- Cards de 12px, superfícies tonais e indicadores laterais; cabeçalho AEROGAZE COMMAND e navegação inferior compacta.
- As imagens têm pills e pequenos contornos que divergem da regra geral do documento. Para esses componentes concretos, a composição das imagens prevalece.
- As referências têm larguras diferentes (390, 706, 320, 595 e 688px). A comparação usa largura equivalente de 390px; no aparelho, os layouts continuam roláveis e adaptam as quebras de texto.

## Implementação

Todos os textos, cards, botões, indicador circular, gráfico, pesquisa e filtros são widgets/painters Flutter. Os PNGs fornecidos ficam em `apps/mobile/assets/reference` para rastrear a origem. Somente regiões fotográficas são desenhadas por `ReferencePhoto`; as telas não são screenshots usadas como interface. Os pequenos rostos dos avatares do painel são desenhados em canvas para não depender do emoji do sistema.

A exportação recebida não contém HTML nem imagens originais separadas. Fundos de lavoura/folha, satélite, céu e miniaturas usam regiões disponíveis nos PNGs. Os fundos são, portanto, aproximações compostas; não há como reconstruir pixels escondidos pelos cards sem os assets originais. Ao recebê-los, substituir as regiões por esses arquivos, mantendo os widgets e tokens.

## Estados e dados

A marca de demonstração é discreta no cabeçalho (DEMO), com explicação acessível ao tocar em SISTEMA ATIVO. Ela substitui o banner largo anterior para preservar a composição visual. Os números apresentados nas referências são fixtures, não medições. O mesmo vale para SISTEMA ATIVO, LIVE FEED, SINCRONIZADO: AGORA e a classificação de scouting.

Navegação, busca de tarefas, seleção/filtro de animais e controles de camada/zoom funcionam localmente. Ações operacionais exibem detalhes de demonstração; não enviam comandos a equipamentos, não executam IA nem persistem registros operacionais. Os flavors dev/prod permanecem separados no Android; a marca dentro da tela é igual em ambos para seguir a referência, e o ambiente aparece no detalhe do indicador de status.

## Fontes

[Space Grotesk](https://github.com/google/fonts/tree/main/ofl/spacegrotesk) e [Inter](https://github.com/google/fonts/tree/main/ofl/inter), distribuídas pelo repositório Google Fonts sob OFL. Os arquivos foram incorporados com suas licenças; não há download de fontes durante a execução do app.

## Verificação

Comparar capturas com fontes reais, nas proporções das referências; conferir também aparelho Android e texto ampliado. Registrar resultado da análise, testes e build no README do app. Isso comprova apresentação e interações locais, sem encerrar as stories de captura/persistência/IA/sincronização.

Capturas renderizadas pelo Flutter em testes, com fontes reais e largura lógica de 390px (não capturas de aparelho):

| Tela | Prévia implementada | Referência recebida |
| --- | --- | --- |
| Painel | [PNG](previews/painel.png) | [PNG original](../../apps/mobile/assets/reference/aerogaze_dashboard_pt.png) |
| Mapa | [PNG](previews/mapa.png) | [PNG original](../../apps/mobile/assets/reference/aerogaze_mapa_pt.png) |
| Scout | [PNG](previews/scout.png) | [PNG original](../../apps/mobile/assets/reference/aerogaze_scouting_pt.png) |
| Rebanho | [PNG](previews/rebanho.png) | [PNG original](../../apps/mobile/assets/reference/aerogaze_rebanho_pt.png) |
| Tarefas | [PNG](previews/tarefas.png) | [PNG original](../../apps/mobile/assets/reference/aerogaze_tarefas_pt_padronizado.png) |
