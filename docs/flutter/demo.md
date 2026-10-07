# Ensaio e evidências

## Scaffold atual

Iniciar `apps/mobile`, conferir tema, fazenda ilustrativa e cinco destinos. O banner identifica dados fictícios. As telas dos módulos descrevem o próximo fluxo e não oferecem botões que simulem envio ou diagnóstico real.

## Ensaio de conclusão do MVP

1. Autenticar online, provisionar dispositivo e carregar a fazenda única de teste. Registrar versões do app/modelo e identificar quaisquer dados simulados.
2. Ativar modo avião no Android. Capturar folha, obter resultado TFLite real ou inconclusivo, registrar localização disponível e salvar evidência.
3. Forçar encerramento do processo, reabrir offline e mostrar foto, evento e fila preservados. Reiniciar o aparelho quando disponível.
4. Restaurar rede, provocar perda de ACK após commit e repetir envio. Mostrar um recibo/evento e um único efeito no backend.
5. Abrir alerta e tarefa gerados pela regra da mesma inspeção; receber no app e no Centro de Comando. Não contabilizar fixtures como efeitos reais.
6. Simular indisponibilidade de blockchain: tarefa continua acessível e prova aparece pendente. Recuperar worker, abrir QR e verificar prova ancorada.
7. Adulterar uma cópia de teste no verificador e demonstrar falha de integridade. Não modificar a evidência original da apresentação.

## Registro mínimo de resultados

| Critério | Evidência exigida | Estado nesta etapa |
| --- | --- | --- |
| Fundação | análise estática, teste de navegação e build Android | análise, 2 testes e APK debug aprovados; aparelho pendente |
| Offline | vídeo de encerramento/reabertura + IDs e hash | pendente |
| Idempotência | duas tentativas, um recibo e um efeito | pendente backend/mobile |
| IA | modelo, licença, métricas e latência no Android | pendente modelo/mobile |
| Tenant e papéis | API recusa acesso de outra fazenda | pendente backend/sessão |
| GPS/geofence | casos de borda e baixa precisão sem falso alerta | pendente backend/GPS |
| Conflito | original e compensação preservados | pendente integração |
| Prova | ancoragem e adulteração detectada | pendente worker/verificador |

Gravar uma execução completa para contingência e exibir como gravação. Registrar deviceId, eventId e correlationId sem dados secretos. Logs operacionais não devem conter imagem, token, chave, URL assinada ou coordenadas detalhadas sem necessidade. Medir latência de inferência, tempo de commit local e atraso até ACK; não inventar métricas de desempenho.
