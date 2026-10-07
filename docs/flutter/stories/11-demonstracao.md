# QA, observabilidade e ensaio

Skill: [$aerogaze-flutter-demo](../../../skills/aerogaze-flutter-demo/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-029 - Diagnóstico de falhas sem segredos

Como equipe, quero rastrear um evento do aparelho até seu recibo.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-008; FL-017.
- Status: planejada.

**Implementação**

Logs estruturados com correlationId/eventId/deviceId e estágio; medidas de commit/inferência/ACK; sanitização e integração com traces backend.

**Critérios de aceite**

Timeout e rejeição são rastreáveis; token/chave/imagem/URL assinada não entram em log; métricas identificam aparelho/versão e não são fictícias.

**Verificação/evidência**

Provocar erro e cruzar ID nos logs backend; revisar conteúdo e redaction.

## FL-030 - Cenários críticos integrados

Como avaliador, quero evidência de offline, integridade, isolamento e resiliência.

- Prioridade: P0. Tamanho: G.
- Dependências: FL-011/014/018/019/024/028; ambiente integrado.
- Status: planejada.

**Implementação**

Executar matriz de demo.md: reinício offline, ACK perdido, conflito, tenant, geofence/GPS e chain indisponível; guardar resultados.

**Critérios de aceite**

Critérios do documento de decisões p. 12 têm evidência ou pendência declarada; análise e testes passam; não confundir teste de widget com validação física/backend.

**Verificação/evidência**

Vídeo Android, resultados API, prova adulterada e matriz preenchida.

## FL-031 - APK e ensaio de apresentação

Como apresentador, quero uma demonstração reprodutível e contingência clara.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-030; prazo e ambiente do hackathon.
- Status: planejada.

**Implementação**

Build APK, configuração sem segredos, seed único, roteiro offline -> IA -> sync -> tarefa -> QR e gravação de contingência.

**Critérios de aceite**

APK instala no aparelho escolhido; todas as telas usam mesma fazenda/linha temporal; mocks aparecem como simulados; gravação é apresentada como gravação; limites conhecidos registrados.

**Verificação/evidência**

Instalação limpa e ensaio integral cronometrado; registrar versão/build/aparelho.
