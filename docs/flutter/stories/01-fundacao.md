# Fundação e interface

Skill: [$aerogaze-flutter-foundation](../../../skills/aerogaze-flutter-foundation/SKILL.md).

Status inicial: backlog; FL-001/002/003 têm scaffold entregue, mas os critérios de aparelho/acessibilidade ainda precisam de evidência. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-001 - Inicializar app Android

Como desenvolvedor, quero um app executável para iniciar as entregas de campo.

- Prioridade: P0. Tamanho: P.
- Dependências: Nenhuma.
- Status: parcial. Scaffold, resolução de pacotes, análise, testes e APK debug entregues; execução em aparelho pendente.

**Implementação**

Criar apps/mobile, lint, bootstrap e documentação de execução. Manter lockfile e configurações de plataforma.

Configuração adicional solicitada: flavors Android dev/prod, dev padrão, IDs e nomes separados, ambiente Dart derivado do flavor nativo e atalhos no VS Code. Validar os dois APKs e preservar aviso de demonstração em prod.

Branding solicitado em 06/10/2026: SVG do ícone convertido em recursos nativos/adaptativos e PNG da splash preservada como asset. Abertura nativa escura e transição Flutter implementadas. Análise e sete testes aprovados; execução em aparelho continua pendente. Detalhes em `docs/design/branding-mobile.md`.

Atualização da splash: radar com duas varreduras, ativação e retorno gradual dos quatro pontos, barra animada de 0 a 100% e entrada no Painel condicionada ao preenchimento. A duração padrão é 4,5 s; marca e textos da arte original permanecem. Os testes cobrem cruzamento/reativação dos pontos, barra intermediária/completa, ordem da navegação e descarte da animação.

Correção da passagem para o Painel: removida a espera fixa de 150 ms; imagens pré-carregadas e aba inicial construída durante a splash. Demais abas são montadas sob demanda, preservando estado. Nove testes aprovados, incluindo montagem antecipada, fade imediato e preservação dos filtros. Diagnóstico opt-in `TRACE_STARTUP=true` permite medir frames em aparelho via a configuração F5 Dev (Profile).

Verificação desta correção: formatação e análise aprovadas; APKs dev/debug e prod/release recompilados; dev/profile instalado no Android conectado. A medição ficou inconclusiva com o bloqueio da tela e foi encerrada sem nova tentativa a pedido do usuário. A fluidez da transição e a revisão de ergonomia no aparelho permanecem sem aceite.

Ajuste solicitado da abertura: retirado o ícone central dos launch backgrounds anteriores ao Android 12 e definido drawable transparente na splash do sistema Android 12+, em modo claro/escuro e ambos os flavors. O ícone instalado no launcher e a arte Flutter permanecem. Formatação sem alterações, análise sem problemas e nove testes aprovados; conferência visual desta abertura no aparelho pendente.

Evidência dos flavors em 05/10/2026: análise sem problemas, quatro testes aprovados e APKs dev/debug e prod/release gerados, com nomes/IDs conferidos. Execução em aparelho pendente; release ainda assinado com chave debug do scaffold.

**Critérios de aceite**

flutter pub get, flutter analyze e flutter test passam; app inicializa no Android quando disponível.

**Verificação/evidência**

Análise, teste de bootstrap e execução Android. A execução física ainda deve ser registrada.

## FL-002 - Tema e navegação de campo

Como operador, quero navegar com uma mão entre as funções de campo.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-001.
- Status: parcial. Tema, cinco destinos e layout 360px/fonte 1.5 verificados; ergonomia/revisão em Android pendentes.

Atualização visual em 05/10/2026: cinco telas nativas compostas conforme os PNGs e DESIGN.md novos; Space Grotesk/Inter locais, anel de saúde, gráfico, cards, cabeçalho e navegação personalizados. Busca de tarefas, filtro/seleção de animais, camada/zoom e transições locais implementados. Capturas Flutter revisadas; fotos originais ausentes, então fundos usam regiões disponíveis dos PNGs. Isso não entrega câmera, IA, persistência ou sincronização reais.

**Implementação**

Tema escuro e verde, navegação Painel/Mapa/Scout/Rebanho/Tarefas, componentes legíveis e estados vazios.

**Critérios de aceite**

Cinco destinos abrem em português, área segura respeitada, sem overflow a 360px e fonte ampliada; captura tem alvo de toque acessível.

**Verificação/evidência**

Teste de navegação/layout e revisão visual Android; acessibilidade e ergonomia em aparelho.

## FL-003 - Fonte única para a demonstração

Como apresentador, quero dados coerentes para explicar um fluxo da mesma fazenda.

- Prioridade: P0. Tamanho: P.
- Dependências: FL-001.
- Status: concluída. Fixture compartilhada e identificação de demonstração verificadas no teste de navegação.

**Implementação**

Uma fixture compartilhada com fazenda, talhões e totais; banner de demonstração. Não inventar predição ou telemetria.

**Critérios de aceite**

Nome e totais vêm da mesma fixture; todo dado fictício é identificado; nenhum status simulado se apresenta como leitura real.

**Verificação/evidência**

Comparar painel e destinos. Fixture substituível por repositórios na integração.
