# Recibo e prova por QR

Skill: [$aerogaze-flutter-proof](../../../skills/aerogaze-flutter-proof/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-027 - Recibo e estado de ancoragem

Como operador, quero saber quando uma evidência tem prova disponível sem interromper o trabalho.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-012; FL-019; API proof/worker.
- Status: planejada.

**Implementação**

Mostrar digest/lote/emissor/versão e pending/anchored/failed/revoked; manter recibo cacheado.

**Critérios de aceite**

Synced não significa anchored; chain indisponível mantém inspeção/tarefa; estado revogado/erro é visível; dado sensível não vai para a blockchain pelo mobile.

**Verificação/evidência**

API com ancoragem lenta, falha e revogação; operação local continua.

## FL-028 - QR e verificador público

Como auditor, quero abrir a verificação da evidência por QR.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-027; URL/verificador HTTPS implantados.
- Status: planejada.

**Implementação**

QR do endereço permitido; ação de abrir verificador; explicar integridade do histórico versus autenticidade física.

**Critérios de aceite**

URL corresponde ao lote; sem recibo real não mostrar prova válida; verificador detecta adulteração e informa revogação; indisponível não vira aprovado.

**Verificação/evidência**

Escanear QR em segundo aparelho, adulteração de cópia e falha/revogação; criptografia validada no verificador.
