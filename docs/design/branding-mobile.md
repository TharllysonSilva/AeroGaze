# Ícone e splash do AeroGaze

Arquivos fornecidos em 06/10/2026, copiados sem alteração:

- `apps/mobile/assets/branding/aerogaze-icon.svg`: ícone vetorial original, com metadados preservados no arquivo fonte.
- `apps/mobile/assets/branding/aerogaze-splash.png`: arte completa, 1080×1920. A cópia foi conferida por SHA-256.

## Abertura

O Android inicia com fundo escuro `#0A0F0C`, sem mostrar a marca isolada antes da arte. Em Android 12+, a janela inicial do sistema usa um drawable explicitamente transparente e fundo sólido, customizados pela [API de splash do Android](https://developer.android.com/develop/ui/views/launch/splash-screen). Nos anteriores, o fundo de lançamento também não contém ícone. Depois, Flutter usa o PNG como base, mantém a marca e os textos e desenha radar e barra animados sobre suas áreas. Ao concluir, faz fade de 250 ms para o Painel. O ícone do launcher permanece instalado; a animação de abertura controlada pelo launcher/sistema não é removida pelo tema do app.

A animação começa após o carregamento da imagem e dura 4,5 s. O radar faz duas voltas no sentido horário. Quando a linha cruza o ângulo de um ponto, ele acende em ciano, mostra dois anéis e retorna gradualmente ao ponto simples. A atividade dura cerca de 675 ms por passagem; uma nova volta pode acioná-lo novamente.

A barra começa vazia e avança linearmente até 100%, pelo mesmo AnimationController que move o radar. Ao completar, a splash começa a desaparecer imediatamente, sem a antiga espera de 150 ms. O Painel já está montado e com um primeiro frame preparado atrás da splash; a transição revela essa mesma instância, sem construir novamente as telas. Os controllers de progresso e fade são descartados ao fechar a tela.

As quatro imagens de referência são pré-carregadas durante o radar. Somente a aba inicial é construída nesse período; as demais são montadas no primeiro acesso e preservam o estado ao trocar de aba. RepaintBoundary separa a splash e o conteúdo preparado, e somente a splash recebe o fade, evitando o crossfade simultâneo das duas telas. A entrada só começa depois de 100% e da preparação do primeiro frame do Painel.

É uma animação de identidade visual, não uma leitura de sensores nem uma medição do progresso do backend. Não depende de internet. Retornar de outra aba não repete a splash; reiniciar o processo mostra a abertura novamente. A duração pode ser ajustada em `StartupScreen.displayDuration`.

`BoxFit.contain` conserva todos os textos e cantos em aparelhos com proporções diferentes. Áreas restantes recebem o fundo escuro. [Prévia renderizada em 390×844](previews/splash.png), em Flutter test, não em aparelho físico.

Estados renderizados da animação: [início](previews/radar-inicio.png), [ponto acionado](previews/radar-ativo.png), [mesmo ponto novamente normal](previews/radar-normal.png) e [barra completa](previews/radar-completo.png). O PNG original permanece inalterado: o painter cobre a varredura e a barra fixas, redesenha seus estados e restaura o ícone central da própria imagem por recorte de canvas.

## Ícone Android

- Launcher anterior ao Android 8: vector drawable com a geometria completa do SVG.
- Android 8+: ícone adaptativo com fundo e monograma em camadas, preservando margem para as máscaras do launcher.
- Android 13+: camada monocromática para ícones temáticos.
- Recursos compartilhados por dev e prod; os nomes e application IDs dos flavors continuam separados.

O Flutter logo padrão foi removido dos mipmaps. Os vetores são gerados a partir do SVG por `apps/mobile/scripts/generate_android_branding.py`, sem dependências Python externas. O conversor preserva paths, cores, stroke e opacidade dos elementos simples deste SVG. Após alterar o arquivo fonte, executar o script e reconstruir o app. A splash é um asset fornecido, não uma reconstrução dos textos em Flutter.

## Como conferir

Ajuste sem ícone intermediário verificado por análise sem problemas, nove testes aprovados e recompilação dos APKs `dev/debug` e `prod/release`. Conferência visual da nova abertura em aparelho pendente.

Pare a execução anterior e use F5 em Dev ou Prod, ou execute `flutter run --flavor dev` dentro de `apps/mobile`. Hot reload não atualiza o ícone nativo. O launcher pode manter seu ícone anterior em cache; conferir após uma nova instalação do APK.

Análise e oito testes passaram, incluindo ativação/retorno/reativação dos pontos, barra intermediária/completa, navegação após 100%, descarte de controller/timer e os controles das cinco telas. Cinco capturas dos estados da splash foram renderizadas e revisadas. A instalação e a sequência nativa em aparelho precisam de um Android conectado; nenhum foi encontrado na conferência desta etapa.

Builds verificados em 06/10/2026: `dev/debug` e `prod/release` aprovados. O APK dev foi inspecionado com aapt e usa `mipmap-anydpi-v33/ic_launcher.xml` nas densidades reportadas, confirmando a substituição do ícone padrão. A prévia da splash foi capturada após confirmar a decodificação do PNG. A assinatura release permanece a de teste descrita no README do app.

Após a correção da transição, `dart format lib test`, `flutter analyze` e os nove testes passaram. Os APKs `dev/debug` e `prod/release` foram recompilados. Os testes verificam que o Painel é montado durante a splash, permanece na mesma instância e que o fade começa sem pausa após 100%; também verificam a construção das outras abas no primeiro acesso e a preservação de estado.

O build `dev/profile` foi instalado no Android conectado. A medição da transição ficou inconclusiva porque o aparelho bloqueou durante as tentativas; a única amostra foi da retomada após desbloqueio. A pedido do usuário, a etapa foi encerrada sem nova medição. Portanto, não há confirmação de ausência de frames lentos no aparelho. Para medir depois, usar F5 com `AeroGaze Android · Dev (Profile)` e manter a tela ligada durante a abertura; `TRACE_STARTUP` registra os tempos no console e fica desativado nas configurações comuns.
