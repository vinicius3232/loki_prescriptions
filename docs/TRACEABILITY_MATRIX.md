# 🧭 Matriz de Rastreabilidade Técnica (TRACEABILITY_MATRIX)

Rastreabilidade de ponta a ponta: do script de referência original até os arquivos de código implementados no **loki_prescriptions**.

---

| Funcionalidade | Origem / Referência | Arquivo Estudado | Conceito Extraído | Adaptação para o Projeto | Arquivo Implementado | Teste / Validação |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **7 Minigames Cirúrgicos** | Pluto Medical | `plt_ambulance_job/web/diagnosis.js` | Canvas 2D com física Bézier e colisões vetoriais | Refatorado para Lation Dark Slate e TypeScript/Vanilla | `client/minigames.lua`, `web/build/prescription.js` | Happy Path aprovado |
| **Infusão Salina IV Físico** | AK47 Ambulance | `ak47_qb_ambulancejob/modules/saline/` | Prop físico com restauração periódica de vida | Integrado nativamente ao `vp_needs` (hidratação contínua) | `client/saline.lua`, `server/saline.lua` | State Bag `hasSaline` testado |
| **Compressor Mecânico Lucas 3** | AK47 Ambulance | `ak47_qb_ambulancejob/modules/cpr/` | RCP torácica contínua mecanizada com som 3D | Parada do cronômetro de sangramento para paramédico solo | `client/lucas3.lua`, `server/lucas3.lua` | Sincronização multi-ped |
| **Muleta Ortopédica e Limp** | P-Ambulancejob | `p_ambulancejob/client/crutch.lua` | Anexo de muleta física e clipset Lester | Watchdog de existência de entidade e bloqueio de sprint | `client/crutch.lua`, `server/crutch.lua` | Clipset `move_heist_lester` |
| **Telemetria de Pulso e Temp** | P-Ambulancejob | `p_ambulancejob/client/pulse.lua` | State Bags replicados de parâmetros vitais | Ligação direta com os minigames de estetoscópio e pressão | `client/pulse.lua`, `client/temperature.lua` | State Bag change handler |
| **Bloqueio de Volante (Arm)** | OSP Ambulance | `osp_ambulance/client/fractures.lua` | Perda intermitente de direção ao dirigir ferido | Adicionado desvio involuntário no steering veicular | `client/damages.lua` | Teste em condução veicular |
| **Triagem START (MCI)** | OSP Ambulance | `osp_ambulance/client/conditions.lua` | Tags de cor por gravidade de trauma em catástrofes | Visualização 3D de marcadores para socorristas em campo | `client/triage.lua`, `server/triage.lua` | Teste em multiplayer |
