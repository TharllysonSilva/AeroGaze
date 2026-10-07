# Arquitetura Flutter

## Limites

O aplicativo coleta e armazena evidências, executa TFLite local, mantém fila durável e recebe dados operacionais. API NestJS autentica, valida, deduplica e confirma ingestão. PostGIS determina talhão/geofence. Workers ancoram provas. O aplicativo não determina uma violação oficial nem executa contratos blockchain.

Fonte persistente: Drift/SQLite, com mídia no diretório privado do aplicativo. Widgets observam repositórios e exibem estado; serviços isolam câmera, GPS, modelo e HTTP. Use casos de uso apenas para operações que coordenam múltiplas fontes, como salvar inspeção + mídia + outbox.

## Estrutura

```text
apps/mobile/lib/
  main.dart
  app/                 # bootstrap, tema e shell
  core/demo/           # fixtures identificadas do scaffold
  core/database/       # futuro Drift, migrações e DAOs
  core/session/        # futuro contexto de usuário/fazenda/dispositivo
  core/sync/           # futuro worker e transporte
  features/dashboard/  # painel
  features/scouting/   # captura e revisão
  features/inference/  # execução TFLite
  features/map/        # contexto de talhão e GPS
  features/tasks/      # alertas, tarefa e eventos
  features/herd/       # identidade e histórico P1
  features/proof/      # recibo e verificação
```

Só crie diretórios quando houver implementação. O scaffold entrega app, demo e painel; a estrutura restante orienta as stories.

## Fluxo de gravação

1. Câmera gera arquivo temporário; copiar bytes para armazenamento privado, calcular hash e validar existência.
2. Executar inferência com timeout/erro tratados. Falha do modelo mantém a captura e permite revisão; não transforma erro em diagnóstico.
3. Na mesma transação SQLite, gravar inspeção, metadados de mídia, resultado disponível e evento/outbox. Emitir sucesso visual depois do commit.
4. Se a transação falhar, manter rascunho recuperável; limpar órfãos apenas com política segura. Arquivo e banco não compartilham transação: registrar e reconciliar essa janela de falha.
5. Worker único por fila envia mídia/evento segundo contrato; UUID e chave idempotente permanecem os mesmos em todas as tentativas.
6. ACK de ingestão durável encerra sincronização. Ancoragem é outro estado; seu atraso não bloqueia tarefa.

## Dependências a introduzir por story

| Necessidade | Opção |
| --- | --- |
| Banco e código gerado | drift, drift_flutter, drift_dev, build_runner |
| Mídia e captura | camera, path_provider, crypto |
| Identificadores | uuid |
| Posição e sinal de rede | geolocator, connectivity_plus |
| HTTP e credenciais | cliente HTTP encapsulado, flutter_secure_storage |
| Modelo | tflite_flutter |
| Mapa interativo P1 | google_maps_flutter, apenas quando configurado |
| QR/verificador | qr_flutter e abertura de URL HTTPS validada |

Estas dependências não estão todas instaladas. Conferir compatibilidade do Flutter/Android e resolução do `pubspec.lock` ao adicionar cada uma; não copiar versões antigas dos PDFs.

## Verificação técnica consultada

O [guia Flutter](https://docs.flutter.dev/app-architecture/guide) separa apresentação e dados com repositórios/serviços. O [setup Drift](https://drift.simonbinder.eu/setup/) orienta configuração e geração. [connectivity_plus](https://pub.dev/packages/connectivity_plus) não garante acesso à internet: o resultado HTTP decide a tentativa. [tflite_flutter](https://pub.dev/packages/tflite_flutter) exige verificar suporte nativo e integração no dispositivo. Consulta: 05/10/2026. As escolhas aplicadas são adaptações ao MVP.

