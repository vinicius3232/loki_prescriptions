# 🎯 Arquitetura Alvo Unificada (TARGET_ARCHITECTURE)

A arquitetura alvo sintetiza os melhores padrões das 7 referências em um ecossistema médico e farmacêutico definitivo para FiveM/QBox.

---

## 1. Princípios de Engenharia
1. **Server Authority Total:** O cliente apenas renderiza a interface e captura inputs; o servidor valida proximidade física, posse de itens, CRM médico e disponibilidade de saldo.
2. **State Bag Driven:** Eliminação de threads ativas (`while true do Wait(0)`); todos os dados vitais (`pulse`, `temperature`, `hasSaline`, `hasLucas3`, `triageTag`, `inBed`) utilizam State Bags replicados reativos.
3. **Resiliência a Desconexão:** Se o médico ou o paciente desconectar durante qualquer procedimento cirúrgico, a sessão é encerrada de forma fail-closed sem travar a entidade.
4. **Desacoplamento por Adaptadores:** As integrações com `vp_needs`, `nexus_os`, `vp_tablet` e `vp_phone` operam via feature-flags; se o resource não existir, o sistema entra em modo fallback silencioso.
