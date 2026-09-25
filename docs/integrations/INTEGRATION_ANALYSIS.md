# 🔗 Análise Completa de Integrações (INTEGRATION_ANALYSIS)

Mapeamento das fronteiras de integração do sistema médico com o ecossistema FiveM / QBox.

---

## 1. Integração com `vp_needs` (Motor Fisiológico)
* **Ponte Server:** `bridge/integrations/vp_needs_server.lua`.
* **Mecanismos Compartilhados:**
  * `VpNeedsBridge.ApplyMedicineEffects`: Modifica fome, sede, estresse e cura dependências químicas.
  * `VpNeedsBridge.ApplyBloodTransfusion`: Restaura volemia e hidratação crítica (+25 sede).
  * `VpNeedsBridge.ApplySalineTick`: Infusão intravenosa lenta (+3 sede, +1 fome, -2 estresse a cada 3s).
  * `VpNeedsBridge.GetToxicology`: Relatório de dosagem de álcool no sangue (BAC) e toxicidade para o médico.

## 2. Integração com `nexus_os` / `vp_tablet` (MDT e Dispositivos Médicos)
* **Ponte Client/Server:** `bridge/integrations/nexus_os_server.lua` e `vp_tablet_server.lua`.
* **Mecanismos:**
  * Acesso ao prontuário eletrônico unificado pelo tablet do médico.
  * Emissão de receitas carimbadas sincronizadas com o histórico do cidadão no sistema do governo.

## 3. Integração com `ox_inventory`
* **Definições Nativas:** Snippet oficial em `docs/ITEMS_AND_INVENTORY.md`.
* **Hooks de Usabilidade:** Registro seguro via `Bridge.Framework.registerItem`.
