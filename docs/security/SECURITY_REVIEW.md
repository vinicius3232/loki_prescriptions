# 🛡️ Auditoria de Segurança e Revisão Adversarial (SECURITY_REVIEW)

Análise minuciosa de vetores de exploração, duplicatas de itens, injeção de parâmetros e race conditions.

---

## 1. Vetores Mitigados
1. **Source Spoofing & NetEvent Forging:** Todos os eventos de tratamento e cura usam `source` do remetente autenticado pelo servidor, nunca IDs informados pelo cliente.
2. **Proximity Cheating (Cura à Distância):** O servidor calcula a distância euclidiana (`#(medicCoords - targetCoords) <= 4.5m`) antes de conceder qualquer efeito de cura ou item.
3. **Double-Spend & Duplicação de Medicamentos:** A remoção do item ou dedução financeira ocorre no início da transação (fail-closed). Se o cliente fechar o jogo no meio do progresso, ele perde o item e não ganha a recompensa duplicada.
4. **Exploits de Desfibrilação e Revive:** Cooldown de 5 segundos e trava de estado impedem que múltiplos médicos revivam a mesma vítima simultaneamente recebendo recompensas duplicadas.
