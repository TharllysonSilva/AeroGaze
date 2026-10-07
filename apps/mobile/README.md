# AeroGaze Mobile

Aplicativo Flutter Android para o hackathon. As cinco telas (Painel, Mapa, Scout, Rebanho e Tarefas) seguem as novas referências, com Space Grotesk e Inter incorporadas para uso offline. Captura, Drift, IA, sincronização, tarefas reais e QR ainda são stories pendentes.

[Referências e decisões visuais](../../docs/design/implementacao-mobile.md). Os layouts e controles são widgets Flutter; os fundos fotográficos usam regiões dos PNGs recebidos enquanto as fotos originais não estiverem disponíveis. Os dados são ilustrativos, identificados por DEMO no cabeçalho; toque em SISTEMA ATIVO para detalhes.

Ícone próprio e splash fornecida estão integrados nos dois flavors. [Branding, prévia e comportamento de abertura](../../docs/design/branding-mobile.md). Para atualizar o ícone, pare o app e execute pelo F5 novamente; hot reload não altera recursos nativos.

A abertura nativa usa apenas fundo escuro antes da splash art, sem uma tela intermediária com o ícone central. Esse ajuste exige reconstruir/reinstalar o app pelo F5; hot reload não atualiza os temas Android.

A splash tem radar animado: a varredura acende os quatro pontos, que mostram anéis e voltam ao estado normal. A barra preenche de 0 a 100% durante aproximadamente 4,5 segundos e, somente ao completar, abre o Painel com fade. Reinicie a execução pelo F5 para ver o ciclo desde o início.

A passagem foi otimizada: imagens pré-carregadas, Painel montado durante a splash, outras abas construídas no primeiro acesso e remoção da pausa fixa ao completar a barra. Para avaliar a fluidez em aparelho, há também a opção F5 `AeroGaze Android · Dev (Profile)`, com diagnóstico de frames da transição no console. O [Flutter recomenda profile em aparelho físico](https://docs.flutter.dev/perf/ui-performance); debug pode apresentar pausas de compilação JIT.

Verificação em 06/10/2026 após otimizar a transição: formatação concluída, análise sem problemas, nove testes aprovados e APKs dev/debug e prod/release gerados. Ícone nativo conferido no APK dev e estados ativo, normal e completo da splash revisados. Dev/profile instalado no Android conectado; medição de fluidez inconclusiva devido ao bloqueio da tela, encerrada sem nova tentativa a pedido do usuário.

## Executar

Usar Flutter compatível com Dart 3.12.2 ou superior (base criada com Flutter 3.44.8), Android SDK e aparelho/emulador configurado. O app atualmente suporta Android.

```powershell
cd apps/mobile
flutter pub get
flutter devices
flutter run --flavor dev
```

Antes de executar, abra um emulador pelo Device Manager do Android Studio ou conecte um celular com depuração USB habilitada e autorize o computador. Se houver vários dispositivos, use `flutter run --flavor dev -d ID_DO_ANDROID`, substituindo o ID pelo mostrado em `flutter devices`.

Sem dispositivo Android, liste os emuladores com `flutter emulators` e inicie um com `flutter emulators --launch ID_DO_EMULADOR`. Em seguida, execute `flutter devices` novamente. Chrome/Windows não são destinos configurados neste projeto.

## Flavors dev e prod

| Flavor | Nome instalado | Application ID | Comando |
| --- | --- | --- | --- |
| dev | AeroGaze AI Dev | com.aerogaze.aerogaze_mobile.dev | `flutter run --flavor dev` |
| prod | AeroGaze AI | com.aerogaze.aerogaze_mobile | `flutter run --flavor prod` |

Os dois apps podem coexistir no aparelho e têm armazenamento Android separado. `dev` é o padrão no pubspec: `flutter run` equivale a selecionar dev. O Dart lê o flavor nativo com `appFlavor`, sem exigir um segundo parâmetro de ambiente ou entrypoint separado. O nome instalado distingue Dev; o ambiente também aparece ao tocar em SISTEMA ATIVO. A marca interna é AEROGAZE COMMAND em ambos, conforme a referência visual.

Flavor escolhe o ambiente; debug/release escolhe o modo de compilação. `flutter run --flavor prod` ainda usa debug. Para executar prod em release no aparelho: `flutter run --flavor prod --release`. Os dois flavors ainda mostram os dados fictícios da demonstração; não há endpoints de API configurados.

No VS Code, abra a raiz do repositório, instale as extensões Flutter/Dart, selecione um dispositivo Android e use F5 com `AeroGaze Android · Dev` ou `AeroGaze Android · Prod`. As configurações ficam em [launch.json](../../.vscode/launch.json).

## Gerar APK

```powershell
flutter build apk --flavor dev --debug
flutter build apk --flavor prod --debug
flutter build apk --flavor prod --release
```

Saídas em `build/app/outputs/flutter-apk/`: `app-dev-debug.apk`, `app-prod-debug.apk` e `app-prod-release.apk`, respectivamente. Para instalar sem abrir o código, copie o APK para o aparelho e abra o arquivo, permitindo a instalação pelo aplicativo usado para abri-lo.

O release usa a assinatura debug herdada do scaffold, adequada para teste local/hackathon. Publicação em loja requer configurar o keystore de release; selecionar prod não configura essa assinatura.

## Verificar

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --flavor dev --debug
```

O build APK exige toolchain Android e dependências Gradle. O scaffold não pede câmera/GPS nem contém credenciais: esses módulos entram em suas stories com testes em aparelho.

Verificação inicial em 05/10/2026: pacotes resolvidos, análise estática, navegação/layout e build Android debug aprovados. A configuração de flavors substitui o comando de APK sem flavor anterior. Isso não substitui execução em aparelho nem valida o fluxo offline futuro.

Verificação dos flavors em 05/10/2026: análise sem problemas, quatro testes passando e builds `dev/debug` e `prod/release` concluídos. Os nomes e IDs foram conferidos nos APKs. A execução em aparelho permanece pendente.

Configuração baseada na [documentação oficial de flavors Android do Flutter](https://docs.flutter.dev/deployment/flavors).

## Planejamento

[Índice Flutter](../../docs/flutter/README.md), [arquitetura](../../docs/flutter/arquitetura.md), [contratos propostos](../../docs/flutter/contratos.md) e [roteiro de demonstração](../../docs/flutter/demo.md).

Skills estão em `../../skills`, com roteamento pelo `AGENTS.md` da raiz. Próximo bloco: FL-007/008/009, persistência Drift e outbox.
