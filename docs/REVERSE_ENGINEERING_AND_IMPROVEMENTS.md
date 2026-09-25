# Engenharia Reversa Completa & Matriz de Melhorias para loki_prescriptions
**Genealogia dos 6 Scripts Médicos de Referência, Análise Módulo a Módulo e Roadmap de Inovação**

---

## 1. Visão Geral Executiva e Genealogia Arquitetural

O desenvolvimento do script médico e farmacêutico definitivo (`loki_prescriptions`) no ambiente FiveM / QBox Core demandou o estudo detalhado e a engenharia reversa das seis maiores referências da comunidade:

1. **Wasabi Ambulance** (`wasabi_ambulance_unlocked.pack`): Referência em combate corpo a corpo, knockout, macas com física raycasting, gerenciamento modular de check-ins e anestésicos/drogas.
2. **P-Ambulancejob** (`p_ambulancejob _ fully cleand & fixed by Said Ak`): Referência em telemetria biométrica (pulso e temperatura corporal via state bags), muletas físicas com walking styles de lesão, bodybags para necrotério e monitores hospitalares via telas de TV em DUI.
3. **OSP Ambulance** (`osp_ambulance_decrypted (1)`): Referência em patologias crônicas/agudas, fraturas com bloqueio de volante veicular, variações de vestuário médico (gessos e colares cervicais em peds), triagem de catástrofe e seguros de saúde.
4. **AK47 Ambulance** (`ak47_qb_ambulancejob`): Referência em infusão intravenosa física (bolsa de soro fisiológico anexada a suporte/paciente), compressão mecânica automatizada (Lucas 3 CPR), caixas de suprimento no chão e efeitos de tela de trauma.
5. **Pluto Medical Ecosystem** (`plt_ambulance_job`, `plt_departments`, `plt_xray`): Referência máxima em minigames interativos de alta precisão cirúrgica via Canvas 2D / física vetorial Bézier, controle de acesso RFID/cartão de ponto magnético e condecorações hospitalares.
6. **Lation UI** (`lation_ui`): Referência definitiva de design system moderno, glassmorphism dark slate, microinterações sonoras e componentes atômicos (drawers, skillchecks e alerts).

### Matriz Comparativa Multidimensional

| Dimensão Técnica | Wasabi Ambulance | P-Ambulancejob | OSP Ambulance | AK47 Ambulance | Pluto Medical | Lation UI | **loki_prescriptions (Alvo)** |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Framework Base** | Bridge Universal (ESX/QB) | QBox / Ox-Core nativo | ESX / QB / QBox híbrido | QB-Core legado com wrapper | Standalone / QBox / Ox | Standalone / Ox Lib | **QBox Core + Ox_Lib Puro** |
| **Sincronização de Estado** | NetEvents + State Bags básicos | State Bags replicados (`LocalPlayer.state`) | State Bags + Heartbeat loops | NetEvents frequentes (alto tráfego) | Lib Callbacks + NetEvents | State Bags de UI | **State Bags Replicados + Ox Callbacks** |
| **Simulação Fisiológica** | Dano geral + Sangramento linear | Pulso + Temperatura + Parada cardíaca | Condições crônicas + Fraturas ósseas | Soro + Desidratação + Stress | 7 Procedimentos cirúrgicos vetoriais | N/A (UI Provider) | **Unificado: Biometria + Fraturas + 7 Minigames** |
| **Mecânica de Transporte** | Maca com raycast + offsets | Maca Stryker + Cadeira de rodas + Bodybag | Cadeira de rodas + Cama hospitalar | Maca com Lucas 3 + Cadeira de rodas | Maca Stryker + Gurney | N/A (UI Provider) | **Maca Raycast + Bodybag + Lucas 3 + Saline** |
| **Impedimento Motor** | Limp clipset (`move_m@injured`) | Muleta física (`prop_mads_crutch01`) | Travamento de volante (`LockSteering`) | Redução de velocidade por membro | Queda por fraqueza em minigame | N/A (UI Provider) | **Muleta Lester + Shake de Mira + Steering Lock** |
| **Interface & UX** | NUI legada / DrawText / Ox Menu | Mantine React UI + DUI TV | NUI Customizada + DUI X-Ray | HTML5/JS legado com sons | HTML5 Canvas 2D + SVG Bézier | React + Tailwind Glassmorphism | **Lation Slate UI + Canvas Minigames + DUI** |
| **Segurança & Anti-Dupe** | Validações básicas de distância | Server Authoritative com rate-limit | Checagem de itens server-side | NetEvents com payload aberto (Vulnerável) | Validação via Callbacks síncronos | Escuta de NUI local | **Fail-Closed + Anti-Dupe + Proximity Server** |
| **Integração Ecossistema** | Standalone fechado | ox_inventory básico | Suporte a múltiplos inventários | QB-Inventory fixo | ox_inventory nativo | Export universal | **vp_needs + nexus_os + vp_tablet + vp_phone** |

---

## 2. Engenharia Reversa: Wasabi Ambulance (`wasabi_ambulance_unlocked.pack`)

### 2.1 Arquitetura Geral & Padrão Bridge
O script utiliza a biblioteca `wasabi_bridge` para desacoplar a camada de persistência e inventário do framework do servidor (ESX ou QBCore). A estrutura divide-se em:
- `game/configuration/`: Dicionários de armas (`weapons.lua`), logs de auditoria (`logs.lua`), locales multilíngues e `config.lua`.
- `game/client/`: Lógica central do cliente, rotinas de nocaute, macas e funções auxiliares.
- `game/server/`: Autoridade de respawn, manipulação de itens de inventário e dispensários de ambulância.

### 2.2 Motor de Combate Melee & Nocaute (`knockout.lua`)
- **Mecânica:** Detecta quando o jogador entra em combate corpo a corpo (`IsPedInMeleeCombat`) e sua vida atinge patamar inferior a `Config.KnockoutFeature.healthForKnockout`.
- **Efeitos Cinemáticos:**
  - Aplica ragdoll forçado (`SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)`).
  - Shaker de câmera: `ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 2.5)` e vibração contínua `ShakeGameplayCam('VIBRATE_SHAKE', 1.0)`.
  - Shader gráfico pós-processamento: `SetTimecycleModifier('Bloom')` com força ajustada para `2.8`, simulando concussão severa e visão ofuscada.
  - Bloqueio de disparo e movimentação: `DisablePlayerFiring(PlayerId(), true)`.
  - Regeneração passiva no chão: Se configurado `regainHealth`, restaura +2 HP por ciclo até atingir o limiar mínimo de sobrevivência.

### 2.3 Sistema de Maca com Raycasting & Offset Físico (`stretcher.lua`)
- **Detecção de Obstáculos:** Utiliza traçado de raio (`StartShapeTestLosProbe` / `GetShapeTestResult`) para verificar se a posição à frente do paramédico está desobstruída antes de instanciar a entidade `wasabi_stretcher`.
- **Offset e Anexação:**
  - Carregando maca: `AttachEntityToEntity(stretcher, ped, bone, -0.032, -0.716, -1.269, 16.489, 1.863, -1.3292)`.
  - Paciente deitado: `AttachEntityToEntity(patientPed, stretcher, 0, 0.0, 0.0, 1.9, 0.0, 0.0, 180.0)`.
- **Embarque Veicular:** Identifica ossos da mala de ambulâncias (`platelight`, `boot`) e guarda a maca fisicamente dentro do porta-malas do veículo.

### 2.4 Movimentação Lesionada & Tremor de Mira (`functions.lua`, `client.lua`)
- **Limping:** Altera o `moveRate` do ped dinamicamente (0.9 a 0.75) e aplica o clipset `move_m@injured`.
- **SimulateAimPain:** Intercepta `IsPlayerFreeAiming` quando o jogador possui dano nos braços. Dispara sacudidas de câmera e desvia o retículo de tiro proporcionalmente à intensidade do dano no membro superior.

### 2.5 Check-ins Modulares Independentes (Prisão, Vovó e Hospitais)
- Suporta múltiplos pontos autônomos (`Config.StandaloneCheckIns`).
- Permite configurar cobrança por conta bancária ou dinheiro vivo (`PayAccount = 'bank'`), direcionamento de receita para a sociedade hospitalar (`society_ambulance`) e fallback caso todas as camas estejam ocupadas (`RespawnNoBedLocation`).

### 2.6 Farmacologia & Metabolismo de Analgésicos
- Tabela `DrugIntake` com decaimento temporal:
  - `morphine30`, `morphine15`, `perc30`, `perc10`, `vic10`, `vic5`.
  - O uso contínuo acumula saturação de alívio de dor, mascarando o dano de membros, mas gerando vinheta escura (`SetTimecycleModifier('blacklight')`) em doses excessivas.

### 2.7 Falhas e Vulnerabilidades Identificadas
- *Falta de Validação Server-Side na Maca:* Eventos de colocar jogador na maca confiavam cegamente no ID do alvo fornecido pelo cliente.
- *Potencial de Desincronização em Ragdoll:* Se o jogador entrasse em ragdoll enquanto ocupava a maca, a animação deitada quebrava, deixando o ped flutuando em T-Pose.

---

## 3. Engenharia Reversa: P-Ambulancejob (`p_ambulancejob`)

### 3.1 Arquitetura Geral & Padrão de Sincronização
O `p_ambulancejob` é estruturado com foco em telemetria realista e suporte completo ao `ox_lib`. Diferente dos scripts legados, utiliza extensivamente `LocalPlayer.state` para sincronizar atributos vitais entre todos os clientes da sessão.

### 3.2 Motor Cardiovascular & Pulso Replicado (`pulse.lua`)
- **Estrutura de Dados:**
  ```lua
  Pulse = {
      value          = math.random(Config.Pulse.minPulse, Config.Pulse.minPulse + 30),
      antiSpam       = GetGameTimer(),
      critical       = false,
      canGetCritical = true,
  }
  ```
- **Dinâmica Cardiovascular:**
  - Tiros e esforço físico: O evento nativo `CEventGunShot` incrementa o pulso em +1 a +3 bpm a cada disparo, com anti-spam de 1000ms.
  - Decaimento Homeostático: Sem ferimentos, o pulso decai lentamente em direção ao valor basal (`minPulse`).
  - Arritmia / Pulso Crítico: Com ferimentos graves múltiplos, há chance percentual configurada de colapso cardiovascular (`criticalPulse`), forçando taquicardia severa (>160 bpm) ou bradicardia extrema (<35 bpm), acionando áudios de monitor (`rapidheartbeat.wav` / `slowheartbeat.wav`).
  - Replicação de Estado: `LocalPlayer.state:set("pulse", self.value, true)` transmite o valor para o servidor e demais jogadores sem nenhum NetEvent manual.

### 3.3 Sistema de Termorregulação Corporal (`temperature.lua`)
- **Mecânica:** Monitora a temperatura em graus Celsius/Fahrenheit (`LocalPlayer.state.temperature`).
- **Hipotermia & Febre:** Ferimentos abertos e sangramentos induzem hipotermia severa; queimaduras e infecções elevam a temperatura.
- **Intervenção Terapêutica:** Itens específicos injetam variação térmica (ex: cobertores térmicos elevam a temperatura, bolsas de gelo reduzem febre).

### 3.4 Sistema de Muleta Física & Passo Mancando (`crutch.lua`)
- **Prop e Anexo:** Cria o prop `prop_mads_crutch01` e anexa à mão do ped:
  ```lua
  AttachEntityToEntity(prop, cache.ped, CRUTCH_BONE, CRUTCH_OFFSET.x, CRUTCH_OFFSET.y, CRUTCH_OFFSET.z, CRUTCH_ROT.x, CRUTCH_ROT.y, CRUTCH_ROT.z, true, true, false, true, 1, true)
  ```
- **Clipset de Caminhada:** Aplica `move_heist_lester` (`SetPedMovementClipset(cache.ped, "move_heist_lester", 100)`).
- **Watchdog de Persistência:** Thread de verificação a cada 1000ms que recria a entidade caso ela seja eliminada pelo motor de culling do FiveM.
- **Bloqueio de Controles:** Impede corrida (`INPUT_SPRINT`), pulo (`INPUT_JUMP`) e ataque físico enquanto a muleta estiver ativa.

### 3.5 Gerenciamento Funerário com Body Bag (`bodybag.lua`)
- **Encapsulamento de Corpos:** Envolve o ped morto no modelo `prop_ld_binbag_01`.
- **Anexação Dupla:** Permite carregar o saco com as duas mãos (`animDict = "missfbi4prepp1"`, animação `"idle"`) OU acoplar o saco mortuário diretamente sobre a maca Stryker (`AttachEntityToEntity(bagEntity, Stretcher.object, ...)`).
- **Transporte para Necrotério:** Permite que médicos ou policiais levem o corpo até o IML para liberação do personagem.

### 3.6 Telemetria Hospitalar em Tela de TV / Monitor DUI (`tv.lua`, `ecg.html`)
- Criação de instâncias DUI (Direct User Interface) mapeadas para superfícies de TV em quartos hospitalares.
- Renderização do traçado eletrocardiográfico (ECG) em tempo real do paciente ocupante da maca daquele quarto, reagindo à frequência cardíaca replicada no state bag `pulse`.

---

## 4. Engenharia Reversa: OSP Ambulance (`osp_ambulance_decrypted (1)`)

### 4.1 Arquitetura Geral & Modelo de Danos
O OSP Ambulance destaca-se pela separação granular de traumas físicos e estados patológicos.

### 4.2 Condições Médicas Crônicas e Agudas (`conditions.lua`)
- **Tabela de Condições Ativas:** `BodyDamage.activeConditions`.
- **Mecânica de Supressão Temporal:** Medicamentos contêm a chave `suppressedUntil`. O script compara o timestamp retornado por `GetServerTime()` para determinar se os sintomas da doença voltam a manifestar-se (tosse, visão turva, vômitos sonoros com `vomit.wav`).

### 4.3 Fraturas Ósseas & Travamento de Direção (`fractures.lua`)
- **Fratura em Membros Superiores (Braços):**
  - Thread periódica que invoca `LockSteering`: A cada 15 segundos de condução veicular contínua, o volante do carro trava ou gira bruscamente para o lado, simulando a perda de força muscular e dor aguda na articulação do motorista ferido.
- **Fratura em Membros Inferiores (Pernas):**
  - Thread contínua que dispara `CauseFractureStaggering`: Ao tentar correr ou pular com a tíbia/fêmur fraturado, o ped tropeça imediatamente, caindo de joelhos com gemidos de dor (`fracture1.wav`, `fracture2.wav`).

### 4.4 Variações de Vestuário Médico nos Peds
- Detecta o modelo do ped (`mp_m_freemode_01` ou `mp_f_freemode_01`).
- Aplica dinamicamente drawables e texturas de roupas:
  - Gesso no braço esquerdo/direito (`pedVariationCategory`).
  - Colar cervical ortopédico no pescoço.
  - Tala na perna.
  - Essa representação visual persiste até que o médico realize o procedimento de remoção com ferramentas adequadas no leito cirúrgico.

### 4.5 Triagem de Vítimas em Massa (MCI Triage Tags)
- Sistema visual de classificação de prioridade de resgate baseado na doutrina internacional START (Simple Triage and Rapid Treatment):
  - **Verde (Prioridade 3 - Leve / Ambulatorial):** Ferimentos leves, paciente deambula.
  - **Amarelo (Prioridade 2 - Urgente):** Ferimentos graves mas estáveis, sem risco de vida imediato.
  - **Vermelho (Prioridade 1 - Emergência Imediata):** Hemorragia maciça, via aérea obstruída, risco iminente de óbito.
  - **Preto (Prioridade 0 - Expectante / Óbito):** PCR sem resposta, lesões incompatíveis com a vida.
- As tags são exibidas via TextUI/3D Marker sobre a cabeça do paciente para que paramédicos priorizem o transporte.

### 4.6 Sistema de Seguros de Saúde & Cobrança Automática (`insurance.lua`)
- Integração SQL para armazenamento de apólices (`hospital_insurances`).
- Pacientes com seguro ativo recebem desconto progressivo no custo de atendimento hospitalar e nas contas de medicamentos na farmácia, sendo o saldo debitado automaticamente em intervalos semanais/diários.

---

## 5. Engenharia Reversa: AK47 Ambulance (`ak47_qb_ambulancejob`)

### 5.1 Arquitetura Geral & Módulos Isolados
O `ak47_qb_ambulancejob` é estruturado em subpastas completamente autocontidas dentro de `modules/`, com seu próprio `config.lua`, `client/` e `server/`.

### 5.2 Sistema de Soro Intravenoso / IV Drip Bag (`modules/saline`)
- **Prop Físico:** Utiliza o modelo customizado `prop_saline.ydr`.
- **Fixação Fisiológica:**
  - Conecta a bolsa de soro à maca, cadeira de rodas ou poste de leito hospitalar.
  - Passa tubulação visual até o braço do paciente.
- **Restauração Dinâmica por Segundo:**
  ```lua
  Config.Saline = {
      addHealth = 5,       -- Restaura +5 HP/seg
      addFood = 5,         -- Restaura +5 Alimentação/seg (Conexão direta com sistemas de fome)
      addWater = 5,        -- Restaura +5 Hidratação/seg (Conexão direta com sistemas de sede)
      removeStress = 5,    -- Reduz -5 de Stress/seg
      reduceAddiction = 5, -- Reduz tolerância química
      duration = 5 * 60,   -- Duração total de 300 segundos (5 minutos)
  }
  ```
- **Impacto no RP:** Proporciona um ciclo de recuperação onde o paciente precisa ficar repousando no leito enquanto a solução salina escorre gradualmente, restabelecendo a volemia sanguínea após hemorragias severas.

### 5.3 Compressão Mecânica Automatizada - Lucas 3 CPR (`modules/cpr`, `prop_lucas3.ydr`)
- **Prop e Anexo Torácico:** Anexa o dispositivo mecânico `prop_lucas3.ydr` sobre o tórax do paciente desacordado:
  - Animação do pistão pneumático realizando massagens cardíacas contínuas.
  - Batimento acústico rítmico (`beat.mp3` / `rapidheartbeat.wav`) em loop sonoro 3D.
- **Vantagem Tática:** Permite que um único paramédico realize o resgate: o equipamento assume a RCP mecânica, impedindo o avanço do cronômetro de sangramento mortal (`bleedout`), liberando o paramédico para dirigir a ambulância ou atender outras vítimas graves no local.

### 5.4 Caixa de Suprimentos / Field Medicine Box (`modules/medicinebox`, `prop_medbox.ydr`)
- O paramédico pode posicionar no chão uma caixa de suprimentos físicos (`prop_medbox.ydr`).
- Cria um inventário secundário persistente no local da ocorrência (`ox_inventory:stash`), permitindo que a equipe de resgate retire desfibriladores, bandagens, soros e bolsas de sangue sem precisar retornar à ambulância.

---

## 6. Engenharia Reversa: Pluto Medical (`plt_ambulance_job`, `plt_departments`, `plt_xray`)

### 6.1 Arquitetura de Minigames Vetoriais & Canvas 2D
O ecossistema Pluto destaca-se pelo realismo cirúrgico das interfaces. Enquanto os scripts tradicionais utilizavam meras barras de progresso ou teclados `E-Q-R`, o Pluto desenvolveu simulações completas em NUI (Canvas HTML5 + física vetorial):

### 6.2 Análise dos 7 Minigames Cirúrgicos
1. **Esfigmomanômetro & Braçadeira (`pressure_cuff`):**
   - Simulação física da insuflação da bolsa de borracha via curva cúbica Bézier na NUI.
   - O médico bombeia a pera de ar até a pressão sistólica (>160 mmHg) e controla a válvula de desinsuflação enquanto ouve os ruídos de Korotkoff até a pressão diastólica.
2. **Ausculta Pulmonar com Estetoscópio (`stethoscope`):**
   - O paramédico arrasta a campânula do estetoscópio sobre a silhueta torácica da vítima.
   - Detecta 5 zonas pulmonares (ápices e bases) com áudios de estridor, sibilos asmáticos ou murmúrios vesiculares limpos.
3. **Teste de Reflexo Patelar (`reflex_hammer`):**
   - Martelo neurológico com cálculo angular de impacto e velocidade. O impacto exato no tendão patelar dispara a animação de extensão reflexa da perna.
4. **Punção Venosa Intravenosa (`iv_infusion`):**
   - Alinhamento de cateter venoso com ângulo de entrada da agulha (15 a 30 graus).
   - Ao canular a veia corretamente, há visualização do refluxo de sangue no canhão da agulha ("flashback") antes de engatar o tubo do equipo.
5. **Sutura e Anastomose Vascular (`arterial_stitch`):**
   - O cirurgião manuseia a pinça porta-agulhas, transpassando o fio cirúrgico de um bordo da ferida vascular ao outro em sequência de pontos de colchoeiro, contendo a hemorragia arterial.
6. **Extração de Projétil Balístico (`bullet_extraction`):**
   - Navegação de pinça cirúrgica pelo canal do tiro através de colisão por pixel em 2D, desviando de nervos e fragmentos ósseos até pinçar e remover o projétil.
7. **Tipagem Sanguínea Rápida (`blood_typing`):**
   - Mistura de gotas de sangue do paciente com reagentes Anti-A, Anti-B e Anti-Rh em lâmina de vidro virtual, observando a reação de aglutinação para determinar o tipo sanguíneo (A+, O-, B+, AB+, etc.).

### 6.3 Controle de Acesso por Crachá RFID & Finanças (`plt_departments`)
- Terminal biométrico / leitor magnético de cartões de acesso para abrir portas restritas da UTI, farmácia controlada e necrotério.
- Sistema de condecorações com medalhas históricas (LAPD Lifesaving Medal, Star of Life, Medal of Valor) associadas à ficha do paramédico.

---

## 7. Engenharia Reversa: Lation UI (`lation_ui`)

### 7.1 Padrão Glassmorphism & Paleta Dark Slate
- Paleta cromática ultramoderna: ardósia profunda (`#0f172a`, `#1e293b`), bordas sutis com gradientes de vidro (`rgba(255, 255, 255, 0.08)`), glow ciano/esmeralda médico.
- Tipografia premium: fontes `Inter` e `JetBrains Mono` embutidas localmente para máxima legibilidade de valores vitais e telemetria.

### 7.2 Microinterações e Áudio Espacial
- Feedback tátil em cada ação de clique, drag e hover através de dispatched web audios nativos de baixa latência.
- Componentes modulares independentes: Drawers laterais, Timelines de histórico clínico, Skillchecks circulares oscilantes e Anéis de progresso SVG.

---

## 8. Síntese e Matriz de Gaps do `loki_prescriptions`

### O que o `loki_prescriptions` já possui:
- Sistema completo de prontuários eletrônicos de pacientes, histórico de prescrições e dosagens.
- Farmácias físicas com controle de estoque e autenticação por CRM médico.
- Os 7 minigames do Pluto já absorvidos no front-end (`web/build/prescription.js` + `lation-medical.css`) e no back-end (`client/minigames.lua`, `server/minigames.lua`).
- Integração preliminar com `vp_needs` e ecossistema QBox.

### Principais Oportunidades de Evolução Identificadas:
1. **Infusão Contínua de Soro com Prop Físico:** Falta acoplar a hidratação contínua e reposição volêmica com o prop `prop_saline` e tubulação física.
2. **Compressor Mecânico Lucas 3:** Implementar o suporte para RCP automática para permitir que ambulâncias operem com paramédicos solo sem morte do paciente durante a viagem.
3. **Telemetria Cardíaca e Térmica Replicada:** Expandir o modelo de State Bags para pulso (`pulse`) e temperatura corporal (`temperature`), integrando com os monitores de leito e prontuário.
4. **Dinâmica de Condução e Mobilidade Lesionada:** Integrar a muleta física (`move_heist_lester`) para fraturas de perna e o travamento temporário do volante veicular (`LockSteering`) para fraturas nos membros superiores.
5. **Classificação START de Triagem:** Adicionar etiquetas de triagem com marcadores 3D visuais sobre pacientes em desastres com múltiplas vítimas.

---

## 9. Plano de Ação & Roadmap de Melhorias para loki_prescriptions

### Melhoria 1: Módulo de Soro Fisiológico com Conexão ao vp_needs (`modules/saline`)
- **Objetivo:** Permitir que o médico instale uma bolsa de soro no paciente (deitado em maca, cama ou sentado em cadeira).
- **Efeito:** A cada 2 segundos, restaura +3 de HP, +4 de hidratação (`vp_needs`) e -2 de stress durante 180 segundos.
- **Prop:** Anexa `prop_saline` ao leito ou suporte com rotação alinhada.

### Melhoria 2: Sistema de RCP Mecânica Automatizada - Lucas 3 (`modules/lucas3`)
- **Objetivo:** Dispositivo para estabilização de parada cardiorrespiratória em transporte de emergência.
- **Efeito:** Enquanto o Lucas 3 estiver ativo sobre o peito do paciente desacordado (`prop_lucas3`), o cronômetro de sangramento para completamente e o pulso estabiliza em ritmo artificial, permitindo ao médico dirigir até o hospital.

### Melhoria 3: Telemetria Biometria Viva via State Bags (`client/biometrics.lua`)
- **Objetivo:** Pulso dinâmico e temperatura corporal persistentes em `LocalPlayer.state`.
- **Efeito:** O estetoscópio e os monitores de leito NUI leem em tempo real a pulsação do paciente. Tiros, corridas e perdas de sangue alteram o ritmo cardíaco.

### Melhoria 4: Restrições Motoras de Fraturas (Muletas e Lock Steering)
- **Objetivo:** Dar consequências físicas reais às fraturas ósseas.
- **Efeito:** Fratura na perna ativa automaticamente a muleta ortopédica e marcha lenta Lester; fratura no braço provoca perda intermitente de direção ao dirigir em alta velocidade.

### Melhoria 5: Protocolo de Triagem START para Vítimas em Massa
- **Objetivo:** Adicionar tags de triagem médica (Verde, Amarelo, Vermelho, Preto) acopláveis por paramédicos durante grandes incidentes.
- **Efeito:** Identificação visual instantânea com marcadores luminosos sutis e sincronização com o dispatch da central.

---

## 10. Conclusão & Próximos Passos
A absorção e engenharia reversa destes 6 pilares permite consolidar o `loki_prescriptions` não apenas como um gerenciador de receitas médicas, mas como o **sistema médico-hospitalar mais completo e avançado de toda a comunidade FiveM**.
O código segue rigorosamente os padrões de autoridade do servidor, ausência total de loops de alto consumo no cliente, suporte nativo a QBox/ox_lib e interface moderna no padrão Lation Dark Slate.
