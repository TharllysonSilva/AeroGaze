# Contrato integrado do recorte manual — 12/10/2026

API publicada: `https://aerogaze-api.onrender.com`. Login `POST /v1/auth/login` recebe email/password e retorna accessToken/user. Fazendas: `GET /v1/farms`; áreas: `GET /v1/farms/:farmId/plots`; tarefas/alertas: GET com farmId. Autorização deriva do token no servidor.

`POST /v1/sync/events` recebe `{farmId, deviceId, events:[{id,type:"inspection.recorded",schemaVersion:1,occurredAt,payload:{notes,captureMode:"manual"}}]}`. Organização e autoria são atribuídas pela API. O `id` UUID é a chave de idempotência e permanece igual em todas as tentativas; não há cabeçalho Idempotency-Key nesse endpoint.

Resposta `{acks:[{id,status}],summary,serverTime}`. O recorte envia um evento por chamada e exige exatamente um ACK do mesmo id com status accepted ou duplicate. Rejected, resposta incompleta e 409 não são sucesso. Ingestão confirmada é distinta de lote ancorado.

`GET /v1/sync/events/:eventId/receipt` autenticado retorna eventId, ingestion, tasks e batch (null enquanto ainda não formado). `GET /v1/verify/:batchId` é público. Só apresentar confirmação EVM quando valid=true, status=ancorado, anchor.mode=evm, onChain.checked=true, matches=true e revoked=false. Mock permanece explicitamente simulado; RPC indisponível aparece como consulta pendente.

Estados locais: pending, sending com lease persistido, retry com backoff/jitter, paused para 401, rejected para 400/403/409/422 e synced após ACK. 429 respeita Retry-After numérico inclusive em reenvio manual. 403 exige revalidação explícita após correção do cadastro; envelope/UUID permanecem intactos.

`POST /v1/sync/devices` registra explicitamente um identificador Flutter para gerente/administrador na fazenda autorizada. Retorna deviceId/farmId/registered. Cadastro é idempotente e não reativa revogados ou muda propriedade. A ação do Scout reabilita somente rejeições 403 do próprio escopo, mantendo UUID/envelope.

## Propostas futuras, não implementadas

Os contratos abaixo são propostas históricas para mídia, inferência e cursor. Não representam endpoints disponíveis no recorte atual.

# Contratos mobile propostos

Não existe backend neste repositório. Nomes de campos e endpoints abaixo são propostas para alinhar mobile/backend; não são especificações confirmadas pelos PDFs. Versionar antes de integrar. Exemplos omitem credenciais.

## Envelope imutável

```json
{
  "eventId": "uuid-gerado-no-dispositivo",
  "schemaVersion": 1,
  "eventType": "inspection.created",
  "organizationId": "org-demo",
  "farmId": "farm-demo",
  "deviceId": "device-demo",
  "actorId": "operator-demo",
  "occurredAt": "2026-10-05T18:00:00Z",
  "idempotencyKey": "mesmo-uuid-em-todas-as-tentativas",
  "payload": {
    "inspectionId": "uuid-da-inspecao",
    "location": {"latitude": -12.645, "longitude": -55.823, "accuracyMeters": 12, "capturedAt": "2026-10-05T18:00:00Z"},
    "media": [{"mediaId": "uuid-da-midia", "sha256": "hash-de-64-caracteres", "mimeType": "image/jpeg"}],
    "inference": null,
    "notes": "Exemplo ilustrativo"
  }
}
```

`inference` quando disponível inclui `modelVersion`, `modelSha256`, `label`, `confidence`, `durationMs`, `preprocessingVersion` e `isSimulated`. Correção recebe novo eventId e `supersedesEventId` apontando para o original. Não alterar o envelope já enfileirado. Metadados de retry não fazem parte do payload assinado/hasheado.

Sem GPS, `location` é null com motivo separado; não inventar coordenada. A política de captura sem posição deve ser acordada: evidência permanece local e validação espacial fica pendente. Inferência inconclusiva é resultado de domínio; erro de carregamento do modelo é falha técnica registrada separadamente.

## Ingestão e mídia

Proposta: `POST /v1/media/uploads` prepara upload privado; enviar bytes e concluir upload com verificação de hash. `POST /v1/events` inclui cabeçalho `Idempotency-Key`. O backend valida organização/fazenda a partir da sessão, não confia apenas no corpo. ACK por evento inclui `eventId`, `receiptId`, `receivedAt`, `status` e versão do contrato. Resposta duplicada retorna o mesmo recibo/efeito; `409` isolado não significa sucesso.

ACK só é aceito após commit durável do evento e referência de mídia válida. Perda de resposta após commit leva ao reenvio do mesmo envelope. Sucesso parcial em lote confirma somente IDs aceitos explicitamente. Mídia não é removida pela tentativa; retenção local é política futura.

## Estados de outbox

| Estado | Saída permitida |
| --- | --- |
| draft | pending após validação e transação local |
| pending | sending quando o worker obtém lease |
| sending | synced com ACK durável; retry em falha transitória; conflict ou rejected em falha de domínio |
| retry | sending após nextAttemptAt, com backoff e jitter; tentativa manual respeita exclusão mútua |
| conflict | resolução explícita cria evento compensatório; original preservado |
| rejected | correção explícita cria evento novo; original e motivo preservados |
| synced | terminal para aquele envelope |

Após interrupção, lease expirado em `sending` permite retry com a mesma chave. Guardar attempts, nextAttemptAt, lastErrorCode, leaseExpiresAt e receiptId. Não limitar retries apagando evidência.

Timeout, rede, 429 (respeitar Retry-After) e 5xx: transitórios. 401: suspender envios, renovar sessão uma vez e aguardar autenticação se necessário, sem apagar fila. 403: acesso/revogação visível, não retry infinito. 409: interpretar tipo/recibo conforme contrato. 422: rejeição explícita. Nunca registrar bearer token ou URL assinada nos logs.

## Leitura operacional

Proposta: `GET /v1/farms/{farmId}/changes?cursor=...` entrega inspeções aceitas, alertas e tarefas. Upserts do cache e avanço do cursor na mesma transação; deduplicar IDs e escopar organização/fazenda. Paginação não pode saltar eventos. Conclusão de tarefa é novo evento, com versão esperada e evidência local, não sobrescrita silenciosa.

## Recibo de confiança

Proposta: `GET /v1/inspections/{id}/proof` retorna `batchId`, `digest`, `algorithmVersion`, `status`, `issuer`, `anchoredAt`, `verificationUrl`, e quando aplicável `chainId`, `transactionHash`, `revocationStatus`. Estados: pending, anchored, failed, revoked. URL HTTPS permitida/configurada; não aceitar esquemas arbitrários. O mobile mostra o recibo e abre o verificador; validação criptográfica completa pertence ao verificador/backend.

## Pontos a acordar

Formato canônico do evento e inclusão de assinatura; registro/chave/revogação de dispositivo; limiar e labels do modelo; timestamps/precisão GPS; protocolo de upload e confirmação; payload ACK e conflitos; cursor; papéis; origem permitida de QR. Não adotar hash de JSON arbitrário: ordem e normalização precisam de especificação comum.

