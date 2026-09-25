# ⚙️ Gap Analysis Técnico (TECHNICAL_GAP_ANALYSIS)

Classificação por criticidade técnica de todos os subsistemas pendentes de refinamento.

---

### P0 — Crítico / Obrigatório
* **[RESOLVIDO] Validação Sintática 100%:** Todos os 79 arquivos Lua compilam com saída 0 em `luac.exe -p`.
* **[RESOLVIDO] Autoridade Server-Side:** Remoção de eventos com client authority no consumo de remédios.

### P1 — Importante / Core Gameplay
* **Módulo de Fraturas Ósseas Integrado:** Ligar a fratura de membros ao travamento de volante (`LockSteering`) e tropeço de perna (`CauseFractureStaggering`).
* **MCI START Triage Tags:** Sistema de identificação visual rápida de prioridade de transporte.
* **Caixa de Suprimentos Portátil (`prop_medbox`):** Stash temporário em campo para atendimento em massa.

### P2 — Melhoria Relevante
* **Conexão Dinâmica dos Minigames com State Bags:** Ajustar a frequência cardíaca audível no estetoscópio para bater no ritmo exato do `LocalPlayer.state.pulse`.
