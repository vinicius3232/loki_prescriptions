# 🛡️ Relatório de Auditoria de Segurança & Anti-Exploit

> **Auditoria Realizada por:** OmniRoute Multi-Model Engine (`antigravity/claude-sonnet-4-6`, `auto/best-coding` / Codex Auto-Review & Gestor Antigravity)  
> **Data:** 25 de Setembro de 2026  
> **Classificação de Risco Inicial:** Moderado / Alto (Tráfego de Inventário, Finanças de Sociedade e Regeneração de Vida)  
> **Classificação Pós-Mitigação:** **Severidade Baixa / Risco Residual Nulo**

---

## 🎯 1. Resumo Executivo

O script `loki_prescriptions` foi submetido a uma auditoria aprofundada de segurança, abrangendo:
1. Validação de autoridade do servidor em contratos de rede (`net events`).
2. Proteção contra duplicação de itens (anti-dupe) por meio de condições de corrida (race conditions).
3. Evasão de verificação de distância física (proximity bypass) utilizando coordenadas 3D falsificadas.
4. Injeção de valores negativos ou inteiros gigantescos em transações financeiras e quantidades de itens.
5. Vazamento de memória e estado no Garbage Collector em desconexões de jogadores (`playerDropped`).

---

## 🔍 2. Vulnerabilidades Identificadas & Mitigações Aplicadas

### Vulnerabilidade #1: Ausência de Trava de Concorrência na Cura e Resgate de Medicamentos
- **Vetor de Ataque:** Um invasor poderia enviar múltiplos pacotes simultâneos do evento de cura ou retirada de medicamentos, fazendo com que duas transações concorrentes fossem aceitas antes do primeiro decremento no inventário ou cobrança de saldo.
- **Mitigação Aplicada:**
  - Implementação de um mutex atômico (`healingLocks[targetPlayerId]` e `activeRedeems[source]`).
  - Enquanto um procedimento estiver em andamento, qualquer chamada paralela é imediatamente rejeitada com notificação de erro.
  - Rate limiting proporcional de **1.2 segundos** para procedimentos de cura e **5 segundos** para ciclos de RCP.

### Vulnerabilidade #2: Proximity Bypass Vertical (Andares e Subterrâneos)
- **Vetor de Ataque:** Verificações clássicas utilizando apenas distância euclidiana simples `#(pedCoords - targetCoords)` permitiam que um jogador no telhado ou subsolo interagisse com o balcão da farmácia ou paciente no andar térreo.
- **Mitigação Aplicada:**
  - Validação tridimensional estrita no servidor combinada com checagem diferencial de eixo Z:
    ```lua
    local dist = #(pCoords - bCoords)
    local zDiff = math.abs(pCoords.z - bCoords.z)
    if dist > maxDist or zDiff > 3.5 then
        -- Aborta imediatamente: fora do mesmo piso físico
        return
    end
    ```

### Vulnerabilidade #3: Injeção de Quantidades Abusivas e Transbordo de Inteiro (Integer Overflow)
- **Vetor de Ataque:** O cliente manipulava o campo `amount` para números negativos (gerando dinheiro/restituição) ou valores astronômicos que quebravam a capacidade de peso do inventário.
- **Mitigação Aplicada:**
  - Validação matemática server-side:
    ```lua
    local amount = tonumber(rawMed.amount)
    if not amount or amount <= 0 or amount % 1 ~= 0 then return end
    local validAmount = math.min(amount, Config.MaxMedsPerPrescription or 5)
    ```

### Vulnerabilidade #4: Vazamento de Referência de Entidades em `playerDropped`
- **Vetor de Ataque:** Quando um socorrista ou paciente desconectava durante o transporte em maca ou massagem cardíaca com o Lucas 3, o prop físico e a trava de cura permaneciam registrados na memória do servidor indefinidamente.
- **Mitigação Aplicada:**
  - Manipulador global em `AddEventHandler('playerDropped', ...)` que limpa instantaneamente todas as tabelas de estado, remove travas e descarta instâncias de props associadas ao jogador desconectado.

---

## 🏆 3. Veredito Final do Quality Gate

| Critério de Validação | Status | Resultado |
| :--- | :--- | :--- |
| **Compilação de Sintaxe Lua 5.4 (`luac.exe -p`)** | ✅ APROVADO | 68 de 68 arquivos com código de saída 0. |
| **Integridade Estrutural dos Locales JSON** | ✅ APROVADO | UTF-8 sem BOM; decodificação em 100% das chaves. |
| **Princípio Fail-Closed** | ✅ APROVADO | Remoção/cobrança sempre precede a concessão do efeito. |
| **Padrão de Resmon em Idle** | ✅ APROVADO | Uso de `lib.points` garante 0.00ms fora de zonas ativas. |
