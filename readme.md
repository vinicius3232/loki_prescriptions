# 💊 LOKI_PRESCRIPTIONS v2.0 (Modernized & Hardened)

Sistema avançado e imersivo de receitas médicas, controle farmacológico e farmácias para FiveM, totalmente reformulado para alta performance (0.00ms resmon), segurança à prova de exploits e integração viva com o ecossistema de saúde e necessidades ([`vp_needs`](../vp_needs)).

---

## 🌟 O que há de Novo na Versão 2.0

### 1. 🛡️ Blindagem de Segurança & Anti-Exploit
- **Validação de Autoridade Server-Side:** O servidor sanitiza todos os medicamentos contra a whitelist do `Config.Medicine`, bloqueando qualquer tentativa de injeção de itens forjados ou quantidades abusivas.
- **Identidade Médica Canônica:** O nome civil e o registro do médico emissor são extraídos pelo servidor via framework, impedindo falsificação de assinatura por parte do cliente.
- **Validação de Distância Física no Resgate:** O servidor valida a proximidade do jogador com o balcão da farmácia (`<= 4.0m`). Tentativas de resgate via executor remoto são sumariamente rejeitadas.
- **Trava de Concorrência (Anti-Dupe):** Mutex atômico por jogador impede que múltiplos pacotes simultâneos causem duplicação de itens.
- **Fail-Closed de Inventário:** Verificação prévia de capacidade de peso e slots (`CanCarryItem`). A transação só ocorre se o jogador puder carregar todos os itens com segurança.
- **Consumo Preciso por Slot:** No `ox_inventory`, a receita é consumida amarrada ao slot exato do item, evitando queimar itens errados na mochila.

### 2. 🧪 Farmacologia Ativa Integrada com `vp_needs`
Os medicamentos agora possuem **efeitos farmacológicos reais e imediatos**:
- **`clearairin` (Broncodilatador):** Interrompe crises agudas de tosse e engasgo/asfixia do módulo `consumption_choking.lua` do `vp_needs`.
- **`gutguard` (Protetor Gástrico):** Alivia instantaneamente náuseas e vômitos causados por comida estragada ou excesso de álcool.
- **`painaway` / `ibrofenix` (Analgésicos/Anti-inflamatórios):** Suprimem a dor física e concedem alívio maciço de estresse (`-50` de estresse).
- **`vironix` / `zithromed` (Antivirais/Antibióticos):** Aceleram a recuperação clínica e aceleram altas médicas na clínica Parsons.
- **`dayrelief` / `loprexin`:** Estabilizam a estamina e o ritmo cardíaco após esforços intensos.
- **Mecânica de Overdose:** Ingestão de 3 ou mais comprimidos em menos de 60 segundos induz intoxicação medicamentosa (visão turva, perda de equilíbrio e náuseas).

### 3. 📋 Ciclo de Vida Médico (Uso Contínuo & Retenção)
- **Validade Temporal:** As receitas agora expiram após um prazo configurável (padrão de 3 dias reais). A farmácia recusa receitas vencidas.
- **Receitas de Uso Contínuo (Recargas):** Medicamentos comuns permitem até 3 retiradas. A farmácia carimba a retirada e devolve a receita até esgotar as vias.
- **Receitas de Retenção Obrigatória:** Antibióticos e analgésicos opioides (tarja preta) são retidos na primeira retirada.
- **Prescrição Direta no Paciente:** Médicos podem mirar diretamente no paciente próximo via `ox_target` para emitir a receita diretamente no bolso dele.

### 4. ⚡ Otimização com `ox_lib` (0.00ms Idle)
- Substituição de threads manuais de polling por **`lib.points`**. Quando o jogador está fora das farmácias, o script opera com **0.00ms de resmon**.
- Animações imersivas com barra de progresso visual (`lib.progressBar`) ao retirar remédios no balcão.

### 5. 🏥 Economia Hospitalar & Localização
- **Faturamento Hospitalar:** O dinheiro arrecadado nas farmácias é depositado diretamente na conta institucional do hospital (`Renewed-Banking` / `society_ambulance`).
- **Localização pt-BR:** Suporte nativo ao Português do Brasil em todas as mensagens e notificações.

---

## 📦 Itens e Configuração de Inventário

Consulte o arquivo [`ITEM_SETUP/items_ox.lua`](./ITEM_SETUP/items_ox.lua) para as definições completas dos itens prontas para copiar e colar no seu `ox_inventory/data/items.lua`.