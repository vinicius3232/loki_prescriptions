# 💊 Integração Farmacológica com vp_needs

O `loki_prescriptions` v2.0 possui integração nativa e bidirecional com o sistema metabólico do [`vp_needs`](../vp_needs).

---

## 🧬 Mapeamento dos Efeitos Fisiológicos

| Medicamento | Ação Clínica Principal | Gatilho / Efeito no `vp_needs` |
| :--- | :--- | :--- |
| **`clearairin`** | Broncodilatador Inalatório | Interrompe imediatamente crises agudas de tosse e engasgo (`consumption_choking.lua`). |
| **`gutguard`** | Protetor da Mucosa Gástrica | Cancela episódios de náusea e vômito causados por comida estragada ou excesso de álcool. |
| **`painaway`** | Analgésico Opioide | Concede alívio maciço de estresse (`-50`) e recuperação gradual de vida. |
| **`ibrofenix`** | Anti-inflamatório | Reduz estresse (`-15`) e suprime perda acelerada de estamina pós-combate. |
| **`vironix` / `zithromed`** | Antivirais / Antibióticos | Aceleram a recuperação clínica e diminuem o tempo de desintoxicação na clínica Parsons. |
| **`loprexin`** | Beta-bloqueador Cardíaco | Restaura a estamina (`+30`) e estabiliza pulso cardíaco após perseguições ou tiroteios. |

---

## ⚠️ Mecânica de Overdose (Intoxicação Medicamentosa)

O script monitora as doses ingeridas em uma janela móvel de 60 segundos:
- Se um jogador ingerir **3 ou mais doses** em menos de 60 segundos, é acionado o estado de intoxicação medicamentosa.
- **Sintomas:**
  - Visão turva via shader `drug_drive_blend01`.
  - Tremor de câmera (`DRUNK_SHAKE`).
  - Queda momentânea em ragdoll (desmaio breve).
  - Náusea e episódios de vômito espasmódico a cada 8 segundos durante a duração da crise (padrão: 30 segundos).

---

## 🛠️ Como Adicionar Novos Remédios

No arquivo `config.lua`, adicione uma nova entrada na tabela `Config.Medicine`:

```lua
{
    item = 'meu_remedio',
    label = "Nome do Remédio",
    cost = 300,
    refills = 2, -- 1 para retenção obrigatória, >1 para uso contínuo
    description = "Descrição farmacêutica detalhada.",
    vp_effects = {
        hp = 20,              -- Restaura HP
        stamina = 15,         -- Restaura estamina
        stress = -25,         -- Reduz estresse
        cure_choking = true,  -- Para crises de tosse
        cure_nausea = true,   -- Para crises de enjoo
        detox_boost = true    -- Acelera desintoxicação em Parsons
    }
}
```

O item será automaticamente registrado como usável pelo servidor no arquivo `server/medicine_consumer.lua` sem necessidade de editar nenhum script adicional!