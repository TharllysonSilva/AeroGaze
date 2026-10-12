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

## Android

Ensaio no aparelho conectado, em aplicativo QA separado, passou: login HTTP real no backend local descartável, salvamento sem envio, desmontagem/reabertura da árvore do app com reconexão ao SQLite e armazenamento seguro, ACK accepted, uma única tarefa, lote e verificação pública mock. Repetir sincronização não duplicou a tarefa. Esse ensaio não é prova de ancoragem EVM no celular e não substitui teste de matar o processo durante envio.

Ensaio repetido no Android após restaurar as cinco abas passou, identificando o UUID da inspeção atual para não confundir ACKs de registros antigos.

As cinco abas retornaram à entrada real: Painel com contadores/alertas, Mapa cadastral dos polígonos da API, Scout com observação/outbox/prova, Rebanho explicitamente ilustrativo, Tarefas reais. Cache de listas é separado por API/organização/usuário/fazenda e informa horário; não implementa cursor ou projeções transacionais de tarefas.

## Verificação técnica

- Flutter: 31 testes passaram após a navegação e cadastro explícito; análise sem problemas. Cobrem persistência em arquivo, rollback, migração v1→v2, perda de ACK, isolamento, lease, 401/403/500 e Retry-After.
- API: 59 testes passaram, incluindo Postgres/PostGIS real em banco exclusivamente de teste. Um teste adicional de HTTP RPC real em loopback passou: conexão sem resposta encerrou em 15,2 segundos e a leitura recuperou sem transação; timeout e recuperação preservam fila; consulta pública com RPC indisponível permanece pendente.
- Web: 7 testes de estado da prova e TypeScript aprovados. Mock, RPC indisponível e ausência de confirmação de revogação não aparecem como prova EVM conferida.
- Contrato: 10 testes Linux/Node 22 via Docker passaram. O script não monta .env ou keystores.

## Limites e próximos passos

Câmera, GPS, mídia privada, TFLite, execução de tarefas offline, background garantido e recuperação de senha/biometria/SMS reais não estão implementados. Rebanho não tem endpoint no backend. Referências visuais antigas permanecem demonstrações identificadas.

Revisão Hardhat: versões atuais compatíveis foram mantidas; npm audit ainda aponta 21 advisories (11 low, 2 moderate, 8 high) no conjunto de desenvolvimento. A correção total proposta exige migração major de Hardhat/plugins; não aplicada com --force. A web também tem avisos transitivos de dependências; não declarar dependências saneadas.

Credenciais existem somente no arquivo local ignorado da API. Nenhuma senha, JWT, URI de banco ou chave de carteira foi incluída nesta evidência.
