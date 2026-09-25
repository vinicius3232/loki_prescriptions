# 🔬 Engenharia Reversa e Absorção do Ecossistema Pluto Framework

Este documento apresenta uma análise técnica completa e exaustiva de todos os componentes, scripts e minigames contidos em `F:\Nova pasta (6)\pluto\pluto`, bem como a arquitetura de absorção e integração para o `loki_prescriptions` sob o padrão visual **Lation Medical UI** (Slate Glassmorphism, OLED Contrast, Emerald/Cyan Glow).

---

## 🏛️ 1. Mapeamento do Pacote Pluto (`F:\Nova pasta (6)\pluto\pluto`)

O pacote Pluto é composto por três recursos principais:
1. **`plt_ambulance_job`**: Sistema médico de emergência, diagnóstico corporal com câmera scriptada, inventário de mochila médica no solo, tela de coma (deathscreen) e conjunto de minigames cirúrgicos/clínicos.
2. **`plt_departments`**: Suíte de ferramentas policiais e forenses, incluindo etilômetro/bafômetro sincronizado via WebSocket/NUI, minigame de passagem de cartão magnético, estação forense de balística estilo Windows 98, ALPR e radar.
3. **`plt_xray`**: Sistema de fluoroscopia e raio-X 3D NUI integrado a leitos e macas hospitalares.

---

## 🎮 2. Análise Detalhada dos Mini-Games e Mecânicas Interativas

### 🩺 2.1. Esfigmomanômetro & Aferição de Pressão Arterial (`startBPMinigame`)
- **Arquitetura Visual**:
  - Renderiza o braço do paciente em alta resolução (`img/arm.png`) e uma zona de destino com rotação anatômica (`#bp-target-zone`).
  - O médico arrasta a braçadeira de pressão (`img/bp-cuff.png`).
  - **Física de Tubo 3D SVG**: Uma curva de Bézier cúbica em SVG (`#bp-tube-svg`) conecta a base do monitor de sinais vitais (`img/bp.png`) à braçadeira em tempo real durante o arrasto do mouse (`M x1 y1 C cp1x cp1y, cp2x cp2y, x2 y2`).
- **Mecânica de Jogo**:
  - Encaixe magnético (snap) quando a braçadeira atinge o raio de tolerância do braço.
  - O aparelho infla e calcula dinamicamente a Pressão Sistólica, Pressão Diastólica e Frequência Cardíaca (BPM).
- **Absorção no Loki**: Integrado ao sistema de sinais vitais, ao `client/pulse.lua` e ao nível de estresse do `vp_needs`. Export público `exports.loki_prescriptions:StartBPMinigame(targetId, bone)`.

---

### 🩸 2.2. Hemostasia & Anastomose Vascular (`startClampMinigame`)
- **Arquitetura Visual**:
  - Canvas HTML5 renderizando leito tecidual profundo com gradientes radiais anatômicos (`#3d0606` a `#0e0101`).
  - Vasos rompidos interativos: Artérias (vermelho vivo `#c0392b`) e Veias (azul `#2980b9`), com lúmen circular escuro e borda de corte umedecida.
  - **Pulsação Arterial em Tempo Real**: Jatos de sangue pulsando sincronizados com a taxa cardíaca (`sin(ms * 0.015)`).
- **Mecânica de Jogo**:
  - O médico arrasta a extremidade do vaso seccionado esquerdo até alinhá-la com o coto vascular direito.
  - Ao encaixar, o jorro arterial cessa e surgem 3 pontos de sutura vascular na junção.
  - O cirurgião deve guiar a agulha de sutura (`suture-needle`) através dos orifícios de entrada e saída para fechar cada ponto.
- **Absorção no Loki**: Acionado automaticamente ao tratar hemorragias ativas e fraturas vasculares no Body Diagnostic ou via `/clampminigame`.

---

### 🎯 2.3. Extração Cirúrgica de Projétil (`startBulletMinigame`)
- **Arquitetura Visual**:
  - Canal tecidual/arterial sinuoso delimitado por paredes musculares em gradiente radial escuro e lúmen seguro em vermelho cirúrgico (`#e11d48`).
  - Projétil balístico renderizado com sombreamento e rotação anatômica (`img/bullet.png`).
  - Zona de saída circular pulsante (`#extraction-target`).
- **Mecânica de Jogo**:
  - O cirurgião clica no projétil com fórceps e o conduz pelo interior do canal.
  - **Detecção de Colisão por Pixel**: `ctx.getImageData(cx, cy, 1, 1)` analisa o canal em tempo real. Se o médico tocar a parede muscular arterial (limiar de cor vermelha < 115), a pinça escorrega, a ferida sofre hemorragia e o projétil retorna ao início do trajeto.
  - Ao conduzir o projétil até a zona de saída com sucesso, a bala é extraída e adicionada como evidência pericial no inventário.
- **Absorção no Loki**: Integrado ao tratamento de lesões balísticas no Body Diagnostic ou via `/bulletminigame`.

---

### 🪡 2.4. Sutura Cutânea Contínua (`startSutureMinigame`)
- **Arquitetura Visual**:
  - Incisão tecidual em Canvas com equimose perilesional e bordas laceradas.
  - **Cicatrização Progressiva Dinâmica**: Conforme os pontos são realizados da esquerda para a direita, a incisão se fecha por gradiente suave, revelando a cicatriz pós-sutura.
- **Mecânica de Jogo**:
  - O cirurgião deve guiar a agulha cirúrgica do orifício de entrada (superior) ao orifício de saída (inferior) ao longo de 8 pontos cirúrgicos consecutivos.
  - Fio cirúrgico de seda branca (`#f8fafc`) com nós anatômicos desenhados a cada fechamento.
- **Absorção no Loki**: Integrado ao uso de kits de sutura estéril (`suturekit`), tratamento de lacerações ou via `/sutureminigame`.

---

### 🩹 2.5. Curativo de Trauma em 3 Etapas (`startBandageMinigame`)
- **Arquitetura Visual**:
  - Membro anatômico em canvas de alta resolução com escoriação e contaminação bacteriana (`dirtOpacity`).
  - Bandeja cirúrgica lateral com ferramentas: Swab de Algodão (`img/cotton.png`), Gaze Estéril e Fita Micropore/Esparadrapo.
- **Mecânica de Jogo**:
  - **Etapa 1 (Assepsia)**: O médico esfrega o algodão embebido em antisséptico sobre a ferida, gerando espuma bioativa e partículas esterilizadoras até atingir 100% de assepsia.
  - **Etapa 2 (Aplicação de Gaze)**: A compressa de gaze estéril é centralizada sobre o leito higienizado.
  - **Etapa 3 (Fixação Cirúrgica)**: O médico aplica 4 tiras de fita cirúrgica nas quatro bordas (superior, inferior, esquerda e direita) com alinhamento e rotação exata.
- **Absorção no Loki**: Integrado ao curativo de queimaduras e ferimentos ou via `/bandageminigame`.

---

### 🌬️ 2.6. Etilômetro / Bafômetro Digital NUI (`openBreathalyzer`)
- **Arquitetura Visual**:
  - Aparelho portátil realista com visor LCD digital iluminado e bocal descartável (`img/breathalyzer.png`).
  - Gauge de pressão de ar com Sweet Spot central demarcado (zona verde entre 40% e 60%).
- **Mecânica de Jogo**:
  - **Sopro Controlado**: O condutor/paciente clica na boquilha e deve manter pressionada a tecla `[E]` para calibrar o fluxo de ar, equilibrando o indicador na zona verde durante o tempo de amostragem.
  - **Sincronização em Tempo Real**: Os dados de sopro e progresso são sincronizados a cada 100ms entre o policial/médico e o paciente.
  - **Leitura de Alcoolemia**: Calcula o BAC (Blood Alcohol Content) com alerta sonoro e visual de limite legal (> 0.08% = Over Legal Limit). Integrado à toxicologia do `vp_needs`!
- **Absorção no Loki**: Export `StartBreathalyzerTest(targetId)` e comando `/bafometro [id]`.

---

### 💳 2.7. Leitor de Cartão Magnético Hospitalar (`startSwipeMinigame`)
- **Arquitetura Visual**:
  - Leitor magnético físico (`img/card-reader.png`) com slot de passagem e crachá de identificação médica (`img/card.png`).
- **Mecânica de Jogo**:
  - O profissional segura o cartão e o arrasta pelo leitor.
  - Validação de velocidade e distância: se deslizar muito rápido, muito devagar ou soltar antes do final da fita magnética, a leitura é rejeitada com feedback sonoro e visual.
- **Absorção no Loki**: Para destrancar armários de medicamentos controlados, portas de UTI e necrotério ou via `/swipeminigame`.

---

## 🔒 3. Protocolos de Segurança & Autoridade do Servidor

Todo o código absorvido segue as diretrizes mandatadas de segurança FiveM:
1. **Server Authority**: O cliente apenas solicita o início do minigame e envia a conclusão; o servidor valida a distância física 3D + Z (`#(coordsA - coordsB) <= 4.0`), autorização profissional e posse de itens.
2. **Concurrency & Rate Limit**: Mutex por paciente (`minigameLocks[targetId]`) evitando abusos ou curas simultâneas por múltiplos médicos, e rate limit de 1.2s por médico.
3. **Limpeza em `playerDropped`**: Liberação automática de todas as travas caso qualquer um dos jogadores desconecte.
4. **Zero Erros de Sintaxe**: Compilação 100% verificada via `luac.exe -p` com código de retorno 0.
