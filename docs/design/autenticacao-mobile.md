# Autenticação mobile

Entrega em 12/10/2026 no Flutter Android existente. As referências recebidas guiam o grid escuro, verde/ciano, cartões, cantos táticos e hierarquia. A marca própria AeroGaze substitui os símbolos do login e da recuperação; Space Grotesk e Inter continuam locais. Layouts e controles são widgets, sem usar screenshots como formulário.

## Comportamento

- Splash abre o login real da API. Credenciais inválidas são recusadas; token vai ao armazenamento seguro e a senha não é persistida. A saída preserva evidências SQLite. O login livre é restrito à configuração de teste visual.
- Recuperação por e-mail valida formato e confirma apenas a simulação.
- SMS/satélite valida matrícula, telefone e terminal quando selecionado. Simular envio libera seis campos de código. 123456 valida somente a simulação; não abre a sessão real. Código diferente é recusado. Colar seis dígitos funciona; troca de canal limpa o código.
- Apoio oferece três urgências, três canais e descrição opcional. A confirmação informa a seleção e que nenhum chamado foi enviado ou salvo.
- Biometria, telefone de plantão, satélite, LoRa e recuperação real estão em construção. O botão do login não contorna a autenticação. Na sessão real, o Scout salva inspeções em SQLite e mantém outbox com UUID estável.

## Prévias renderizadas

[Login](previews/auth-login.png), [recuperar chave](previews/auth-recuperar-chave.png), [SMS/satélite](previews/auth-sms-satelite.png), [apoio ao comando](previews/auth-apoio-comando.png).

## Verificação

Formatação e análise estática aprovadas. 16 testes aprovados, incluindo sete novos testes de login/saída, recuperação, OTP, troca de canal, apoio e layout a 320/600px com fonte ampliada em 1,5x. Quatro capturas com fontes reais renderizadas e revisadas. APK dev/debug compilado. Não havia Android conectado; teclado, leitor de tela e ergonomia ainda precisam de avaliação em aparelho. A interface demo não conclui os critérios de autenticação real da FL-004.

## Integração posterior em 12/10/2026

Entrada real, armazenamento seguro, cinco abas operacionais e fila durável foram integrados. Recuperação e apoio continuam simulados. Evidências atuais e limites estão em [integração demonstrável](../flutter/integracao-demonstravel.md); a verificação histórica acima corresponde à interface de demonstração inicial.
