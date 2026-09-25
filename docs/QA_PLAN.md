# 🧪 Plano de Garantia de Qualidade e Matriz de Testes (QA_PLAN)

Diretrizes de testes rigorosos para validação funcional e de segurança.

---

## 1. Matriz de Cenários

| ID do Teste | Cenário | Comportamento Esperado | Resultado da Validação |
| :--- | :--- | :--- | :--- |
| **TC-01** | Prescrição de Medicamento sem CRM | Notificação de erro e aborto imediato | ✅ PASS |
| **TC-02** | Consumo de Antibiótico com Sobredosagem | Aplicação de toxicidade e efeito de náusea | ✅ PASS |
| **TC-03** | Instalação de Soro Fisiológico (Saline IV) | Prop anexado, ganho contínuo de HP/Sede | ✅ PASS |
| **TC-04** | Queda de Jogador Durante Procedimento | Remoção de locks, entidade limpa, sem crash | ✅ PASS |
| **TC-05** | Tentativa de Duplicação de Item Médico | Transação fail-closed remove item no início | ✅ PASS |
| **TC-06** | Condução com Braço Fraturado | Volante puxa intermitente a cada 15-20s | ✅ PASS |
| **TC-07** | Triagem START com Tag de Vítima | Tag visível para outros socorristas | ✅ PASS |
