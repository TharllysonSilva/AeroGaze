# Mapa e localização

Skill: [$aerogaze-flutter-map](../../../skills/aerogaze-flutter-map/SKILL.md).

Status inicial: backlog. P/M/G indicam tamanho relativo. Confira dependências antes de iniciar.

## FL-020 - Posição e talhão da evidência

Como operador, quero informar onde a observação foi feita e conhecer a precisão.

- Prioridade: P0. Tamanho: M.
- Dependências: FL-001; talhões cacheados/fixture explícita.
- Status: planejada.

**Implementação**

Capturar latitude/longitude/accuracy/timestamp com geolocator; tratar GPS negado, stale e impreciso; mostrar contexto textual offline.

**Critérios de aceite**

Sem mapas remotos a captura permanece possível; posição stale não vira posição nova; talhão selecionado é informado pelo operador até validação PostGIS; sem GPS não usar 0,0.

**Verificação/evidência**

Android com permissão negada, GPS desligado, baixa precisão e dados antigos; validar payload recebido no PostGIS.

## FL-021 - Mapa interativo com fallback

Como operador, quero visualizar talhões e evidências quando o mapa estiver disponível.

- Prioridade: P1. Tamanho: M.
- Dependências: FL-020; configuração Maps e polígonos API.
- Status: planejada.

**Implementação**

Polígonos/markers e escopo por fazenda; fallback textual/local; credencial de plataforma restrita e sem segredo de servidor.

**Critérios de aceite**

Falha de tile/chave/rede não bloqueia Scout; nenhuma violação oficial é decidida só pelo desenho; área/totais coincidem com a fonte de dados.

**Verificação/evidência**

Mapa online e queda de rede; casos de borda/precisão dependem do motor PostGIS.
