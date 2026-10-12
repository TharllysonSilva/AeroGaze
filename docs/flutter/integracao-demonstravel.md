# Integração demonstrável — 12/10/2026

O recorte é inspeção manual: Flutter → API → tarefa no Comando web → lote EVM → verificação pública. Não usa câmera, localização, modelo TFLite ou dados reais de animais.

## Evidência publicada

Cliente HTTP Flutter com banco SQLite em arquivo, reabertura e mesma identidade de evento foi executado contra a API publicada. O dispositivo inicialmente recebeu 403 por falta de cadastro. Foi cadastrado apenas para a conta/fazenda de integração; o mesmo UUID e envelope foram reenviados, sem ampliar permissões globais.

- Evento: `5895a412-4ccb-4823-b51e-e5982c0b6e56`.
- Tarefa: `a80c4ad7-8af8-4d4d-942e-3f3a89de6269` — Revisão humana de inspeção.
- Lote: `85281cde-c9b5-4664-bdfe-ed7f5465a2db`.
- Rede: Base Sepolia, chainId 84532.
- Transação: [BaseScan](https://sepolia.basescan.org/tx/0x27c5a1594cc2d7d5988c2cb6646bef930a9b0b5a6480dcb94ecc22013ec4b4d1).
- [Verificação pública](https://aerogaze-api.onrender.com/v1/verify/85281cde-c9b5-4664-bdfe-ed7f5465a2db): valid=true, checked=true, matches=true, revoked=false.

Login no Comando web local em http://localhost:3001/comando respondeu 200 e seu HTML continha a tarefa e o mesmo UUID de origem. A web usa a API publicada. Não foi publicada externamente nesta etapa.

## Ensaio final do celular contra a nuvem

AeroGaze Dev atualizado por instalação -r, sem apagar dados, usando a API publicada. O usuário entrou com a conta real, cadastrou o aparelho no Scout e confirmou o envio manual. API, Comando web compilado e página pública foram conferidos para o mesmo evento.

- Aparelho: `flutter-79a98c33-412d-46a0-90a6-169aaaa175ed`.
- Evento Android: `3ddecea2-9690-4404-a9a9-ab4b76d30404`.
- Tarefa única: `16f7b385-ac66-4407-9432-132e5d16e604`.
- Lote Base Sepolia: `8a765b62-f0d6-4b32-872e-feded8d27885`.
- [Transação](https://sepolia.basescan.org/tx/0x43cc723c0c8dd9124ce83b1a777dae0f849c716edb995d82960be3aa231f8633).
- [Verificação pública](https://aerogaze-api.onrender.com/v1/verify/8a765b62-f0d6-4b32-872e-feded8d27885): valid=true; checked=true; matches=true; revoked=false; modo evm; chainId 84532.

A página pública da web para esse lote respondeu 200 e mostrou “Íntegro e conferido na rede”. O ensaio de nuvem foi manual; o teste nativo automatizado abaixo usa backend descartável e mock. A configuração original de repouso da tela (0) foi restaurada e conferida pelo serviço de energia do Android.

## Android

Ensaio no aparelho conectado, em aplicativo QA separado, passou: login HTTP real no backend local descartável, salvamento sem envio, desmontagem/reabertura da árvore do app com reconexão ao SQLite e armazenamento seguro, ACK accepted, uma única tarefa, lote e verificação pública mock. Repetir sincronização não duplicou a tarefa. Esse ensaio não é prova de ancoragem EVM no celular e não substitui teste de matar o processo durante envio.

Ensaio repetido no Android após restaurar as cinco abas passou, identificando o UUID da inspeção atual para não confundir ACKs de registros antigos.

As cinco abas retornaram à entrada real: Painel com contadores/alertas, Mapa cadastral dos polígonos da API, Scout com observação/outbox/prova, Rebanho explicitamente ilustrativo, Tarefas reais. Cache de listas é separado por API/organização/usuário/fazenda e informa horário; não implementa cursor ou projeções transacionais de tarefas.

## Verificação técnica

- Flutter: 33 testes passaram após a navegação, cadastro explícito e ações online de tarefa; análise sem problemas. Cobrem persistência em arquivo, rollback, migração v1→v2, perda de ACK, isolamento, lease, 401/403/500 e Retry-After.
- API: 64 testes passaram, incluindo Postgres/PostGIS real em banco exclusivamente de teste. Um teste adicional de HTTP RPC real em loopback passou: conexão sem resposta encerrou em 15,2 segundos e a leitura recuperou sem transação; timeout e recuperação preservam fila; consulta pública com RPC indisponível permanece pendente.
- Web: 7 testes de estado da prova e TypeScript aprovados. Mock, RPC indisponível e ausência de confirmação de revogação não aparecem como prova EVM conferida.
- Contrato: 10 testes Linux/Node 22 via Docker passaram. O script não monta .env ou keystores.

## Limites e próximos passos

Câmera, GPS, mídia privada, TFLite, execução de tarefas offline, background garantido e recuperação de senha/biometria/SMS reais não estão implementados. Rebanho não tem endpoint no backend. Referências visuais antigas permanecem demonstrações identificadas.

Revisão Hardhat: versões atuais compatíveis foram mantidas; npm audit ainda aponta 21 advisories (11 low, 2 moderate, 8 high) no conjunto de desenvolvimento. A correção total proposta exige migração major de Hardhat/plugins; não aplicada com --force. A web também tem avisos transitivos de dependências; não declarar dependências saneadas.

Credenciais existem somente no arquivo local ignorado da API. Nenhuma senha, JWT, URI de banco ou chave de carteira foi incluída nesta evidência.

## Ações online de tarefas — 12/10/2026

Após publicar a API `6abdc37` e instalar o AeroGaze Dev atualizado, o usuário confirmou o ensaio Iniciar → Concluir no celular. A consulta à API publicada confirmou `concluida` para a tarefa `16f7b385-ac66-4407-9432-132e5d16e604`, preservando o evento de origem `3ddecea2-9690-4404-a9a9-ab4b76d30404`. O Comando web local respondeu 200, mostrou o evento e o histórico de tarefas concluídas. A prova pública do lote `8a765b62-f0d6-4b32-872e-feded8d27885` continuou válida, conferida na Base Sepolia (84532), sem revogação e com a mesma transação registrada acima; a página web de verificação também respondeu 200 com “Íntegro e conferido na rede”.

O Android QA iniciou e concluiu a tarefa criada pela inspeção do próprio ensaio, consultando o status real na API local após cada ação. A prova pública mock permaneceu válida com a mesma raiz depois da alteração de tarefa. O ensaio passou sem abrir uma segunda instância do banco para consultar o UUID: o teste acompanha a identidade mostrada na fila.

Mobile exige ACK com o mesmo ID/status; falha mantém a lista anterior e pede atualização antes de repetir. API bloqueia auditor, isola organizações e registra status/auditoria na mesma transação com lock da tarefa. Requisições repetidas do mesmo status não geram novo histórico. Web permite consultar tarefas concluídas e não oferece edição ao auditor.

O evento de inspeção e sua prova são preservados; isso não é prova blockchain da execução física do serviço. Execução offline de tarefas e controle de versão concorrente permanecem fora do recorte. Solana não foi integrada e foi adiada a pedido do usuário até receber mais requisitos.

## Ampliação autorizada do cenário simulado

Após a validação principal, o usuário solicitou a simulação operacional compartilhada e a integração Solana. App 0.2.0 consulta `/v1/demo/farms/:farmId`, com cache separado pela mesma identidade de API/organização/usuário/fazenda. Painel oferece falha/reparo/início/parada de irrigação, ocorrência de pragas, drone, estoque e apoio. Mapa mostra polígonos cadastrados e ativos fictícios com zoom e seleção textual. Rebanho consulta 12 animais do cenário e oferece atendimento, vacinação e transferência; ações exigem conexão e confirmação da API.

Ensaio Android QA `integration_test/scenario_test.dart` passou no aparelho RMX3710: executou os botões falha → reparo → irrigação, consultou os três estados no backend local descartável e conferiu histórico, UUID de evento e 14 marcadores de telemetria simulada. É evidência de interface nativa + API local; não substitui o ensaio dessas operações na API publicada.

APK release prod 0.2.0+2 gerado com URL da API publicada, sem senha ou chave no binário. Assinado com chave de desenvolvimento para instalação direta no hackathon; não é entrega de Play Store. SHA-256: `717403968B34FD23665D7003E906C54846DAE7777D201AED8F2E710DDB17E1B3`. Web recebe `/download` público com o mesmo APK.

API passou em 74 testes, incluindo cenário persistente, isolamento, idempotência, reparo que resolve tarefa, bloqueio de assinatura sem saldo e recibo Solana que preserva os bytes assinados após resposta perdida. As imagens completas API/web passaram no Docker Node 22 Alpine. Solana usa Memo e hash SHA-256 do evento; Base conserva a ancoragem de lotes.

## Publicação e provas do cenário

- [Web pública](https://aerogaze-web.onrender.com/login): login 200; Comando, Telemetria, Frota, Análise e Logística 200, usando o cenário da API publicada.
- [Download Android](https://aerogaze-web.onrender.com/download): página pública 200; APK sem autenticação 200, com 61.800.282 bytes e SHA-256 indicado acima.
- Irrigação falha/reparo/início confirmada na API publicada. [Lote Base Sepolia](https://aerogaze-web.onrender.com/verificar/98df82dc-9225-4d8b-b2b4-cbab3afbce16) conferido: valid/checked/matches=true, revoked=false.
- Operação simulada `drone.dispatch`, evento `c47b7ad6-9f75-4207-896b-987ef7eb40ed`: [recibo público Solana](https://aerogaze-web.onrender.com/solana/c47b7ad6-9f75-4207-896b-987ef7eb40ed) respondeu 200 com “Recibo confirmado e conferido na rede”, aviso de simulação e assinatura real `3gNNiPg5gzB97exawzVqtAfWKKztew4WKxReur7DVeaopBcaAckG6m4rMq14SJNZVmQdppm9mbwf4V5Pu2hGqcBn`. API retornou checked/valid=true, cluster Devnet e emissor `3sNKJaqzzRpZjwbMxxgJERUTstsLFQMPQqs9MxyqR3A9`.
- AeroGaze Dev 0.2.0 instalado por -r no aparelho, mantendo dados e sessão; aberto após instalação. Repouso USB restaurado e conferido como 0. O ensaio nativo da nova irrigação foi contra backend local; o ciclo de nuvem registrado acima foi executado pelo cliente HTTP da equipe. Ensaio manual adicional do usuário no app atualizado fica separado destas evidências.

As referências antigas de hardware, satélite, SMS e biometria continuam simulações. Dados do cenário são identificados como fictícios e não representam sensores físicos ou inferência de IA. Stories originais de GPS, câmera, TFLite e rebanho real não são concluídas por este recorte.
