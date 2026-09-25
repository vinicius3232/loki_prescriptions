# 🎯 Gap Analysis de Gameplay (GAMEPLAY_GAP_ANALYSIS)

Mapeamento de lacunas de roleplay e imersão entre o estado atual e a visão final.

---

| Mecânica de RP | Estado Atual | Visão Alvo | Prioridade | Solução Projetada |
| :--- | :--- | :--- | :--- | :--- |
| **Triagem de Desastre (MCI)** | Inexistente | Tags START visuais 3D | **P1** | Módulo de Triage Tags com marcação rápida e visualização de equipes |
| **Consequência ao Dirigir Ferido**| Parcial (Apenas tremor mira) | Volante perde tração com braço quebrado | **P1** | LockSteering intermitente ao conduzir em alta velocidade com fratura |
| **Soro IV Físico em Campo** | Concluído na fase anterior | Bolsa de soro com hidratação e fome | **Concluído** | Módulo `client/saline.lua` integrado ao `vp_needs` |
| **Caixa de Suprimentos Portátil**| Inexistente | Stash móvel no chão para incidentes remotos | **P2** | `prop_medbox` com inventário efêmero `ox_inventory` |
| **Laudo com Histórico CID** | Parcial (Texto livre) | Diagnósticos catalogados com CID real | **P2** | Tabela de códigos CID médicos no receituário |
