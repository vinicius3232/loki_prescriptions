# 🎮 Análise de Gameplay e Sistemas de Roleplay (GAMEPLAY_ANALYSIS)

Análise das dinâmicas de jogo sob a perspectiva de Game Systems Design para servidores Heavy RP.

---

## 1. Loops de Gameplay

### Loop Primário do Médico (Atendimento de Emergência)
1. **Despacho / Chamada:** O paramédico recebe o alerta de emergência pelo tablet ou dispatch.
2. **Chegada e Triagem (MCI START):** Em acidentes com múltiplas vítimas, classifica os pacientes com tags coloridas (Verde, Amarelo, Vermelho, Preto).
3. **Estabilização Pré-Hospitalar:**
   * Instalação de compressor mecânico Lucas 3 caso o paciente esteja em parada cardiorrespiratória.
   * Conexão de bolsa de soro intravenoso (Saline IV) para restabelecimento volêmico.
   * Contenção de hemorragias com sutura rápida ou torniquete.
4. **Embarque e Condução:** Carregamento em maca articulada Stryker para o compartimento traseiro da ambulância.
5. **Procedimento Cirúrgico Intra-Hospitalar:** Execução dos 7 minigames anatômicos (extração de projétil, sutura vascular profunda, raio-X de fraturas).
6. **Pós-Operatório & Prescrição:** Emissão de receituário farmacológico, colocação de muleta ortopédica e atestado médico.

### Loop Primário do Paciente (Sobrevivência & Convalescença)
1. **Trauma e Lesão:** Impactos e tiros provocam sangramentos, redução de batimentos e dor física real (tremor de mira e volante puxando).
2. **Interação com a Equipe Médica:** Resposta aos testes de reflexo, ausculta pulmonar e pressão arterial.
3. **Recuperação Farmacológica:** Compra dos remédios receitados na farmácia hospitalar, respeitando dosagens máximas para evitar overdose.
