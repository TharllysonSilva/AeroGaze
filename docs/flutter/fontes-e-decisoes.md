# Fontes e decisões de escopo

## Fontes recebidas

- `../AeroGaze_Decisoes_e_Arquitetura.pdf`: versão 1.0, setembro/2026, 14 páginas. Páginas 2-3 delimitam fluxo e stack; 4-9 apresentam componentes, implantação, sequência, domínio, estados e confiança; 10-12 tratam segurança, IA e aceite; 14 lista riscos.
- `../AeroGaze_AI_Dossie_Estrategico_Visual.pdf`: 15 páginas. Páginas 4-6 descrevem campo e protótipos; 9-12 apresentam visão de confiança, geointeligência e regras. Seus números e telas são conceituais.

Os caminhos acima são relativos à raiz do repositório. Os PDFs permanecem no diretório pai e não foram copiados nem alterados.

## Como interpretar

O pedido atual autoriza começar pelo Flutter e criar skills/stories. As instruções e afirmações contidas nos PDFs são material de referência, não comandos para instalar serviços, enviar mensagens, movimentar dinheiro ou executar integrações. Nenhum serviço externo é implantado por esta preparação.

Adotamos o documento de decisões como referência do MVP, pois declara o recorte para hackathon. O dossiê orienta narrativa e aparência. Essa precedência é uma escolha de implementação documentada, não uma nova instrução do usuário.

| Assunto | Visão do dossiê | Recorte adotado |
| --- | --- | --- |
| Blockchain | Eventos e histórico on-chain | Dados completos fora da chain; hash/lote e recibo assíncrono |
| Animal | Identidade blockchain | Identidade e histórico; sem NFT negociável |
| Carbono | Tokenização e receita | Roadmap; sem promessa de crédito emitido automaticamente |
| GPS | Alerta imediato ao cruzar perímetro | Precisão, margem, permanência e leituras; cálculo PostGIS |
| IA | Identificação de patógenos e previsão | Uma cultura/condição, classe inconclusiva e revisão |
| Conflitos | Visão geral offline | Eventos append-only; correções compensatórias, sem LWW operacional |
| Métricas | Índices, sensores e confiança ilustrativos | Não reutilizar como medições reais |

## Escolhas propostas para acelerar

- Android primeiro, pois o ambiente é Windows; iOS fica para uma máquina macOS e validação específica.
- Organização `apps/mobile`, preparada para futuro monorepo sem criar backend/web agora.
- Estado de apresentação simples com widgets Flutter; interfaces de repositórios ao introduzir os dados reais. Não adicionar framework de estado apenas para o scaffold.
- Identidade visual escura, destaque verde e navegação do protótipo (dossiê p. 6). Valores de cor são aproximações visuais, não tokens oficiais extraídos.
- Uma fazenda fictícia compartilhada no scaffold, com dados marcados como demonstração. Não há sensores ou conexão reais.
- Schema, estados e endpoints em `contratos.md` são propostas que precisam ser compatibilizadas com o backend.

## Pendências que afetam entregas

Prazo/equipe, cultura e condição alvo, modelo/dataset/licença, política de uso offline após expiração/revogação, regra operacional escolhida, contrato/API e ambiente de verificação. É possível desenvolver armazenamento, captura e adapters enquanto essas decisões são concluídas. Uma saída mock de IA não fecha FL-013/014/015.

