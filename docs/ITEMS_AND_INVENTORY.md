# 📦 Catálogo de Itens e Configuração do Inventário

Este documento contém a relação oficial de todos os itens utilizados pelo **Loki Medical Suite**, suas especificações de peso, comportamento de empilhamento (stack), usabilidade e o snippet pronto para inclusão no `ox_inventory/data/items.lua`.

---

## 📋 Tabela Geral de Itens

| Item ID | Nome Exibido (Label) | Peso (g) | Stack | Close | Usável | Finalidade Principal |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `prescription_pad` | Bloco de Receitas Oficiais | 200 | Não | Sim | Sim | Utilizado por médicos para emitir receituários. |
| `prescription` | Receituário Médico Carimbado | 50 | Não | Sim | Sim | Documento do paciente contendo os remédios liberados. |
| `medical_certificate` | Atestado Médico Oficial | 50 | Não | Sim | Sim | Licença médica com prazo e motivo de afastamento. |
| `sedative` | Seringa de Sedativo Clínico | 100 | Sim | Sim | Sim | Sedação de pacientes agitados ou em crise. |
| `burncream` | Pomada para Queimadura | 150 | Sim | Sim | Sim | Tratamento de queimaduras térmicas e químicas. |
| `suturekit` | Kit de Sutura Estéril | 200 | Sim | Sim | Sim | Fechamento de lacerações cirúrgicas e cortes. |
| `tweezers` | Pinça Cirúrgica de Extração | 80 | Sim | Sim | Sim | Remoção de projéteis alojados no paciente. |
| `icepack` | Bolsa de Gelo Térmica | 250 | Sim | Sim | Sim | Redução de edema e alívio de fraturas agudas. |
| `blood_bag` | Bolsa de Sangue Total | 500 | Sim | Sim | Sim | Transfusão intravenosa para choque hipovolêmico. |
| `defib` | Desfibrilador Portátil AED | 2500 | Não | Sim | Sim | Reanimação cardíaca por choque elétrico bifásico. |
| `stretcher` | Maca Fernocot Articulada | 8000 | Não | Sim | Sim | Transporte e acoplamento em ambulâncias. |
| `crutch` | Muleta Ortopédica | 1200 | Não | Sim | Sim | Auxílio de locomoção para membros inferiores lesionados. |
| `wheelchair` | Cadeira de Rodas Hospitalar | 9000 | Não | Sim | Sim | Cadeira articulada para transporte de convalescentes. |
| `medicbag` | Mochila de Trauma de Resgate | 1500 | Não | Sim | Sim | Recipiente móvel com suprimentos de primeiros socorros. |

---

## 💊 Medicamentos Farmacológicos Suportados

| Item ID | Nome Exibido (Label) | Preço Base ($) | Retiradas | Efeito Clínico / Farmacológico |
| :--- | :--- | :--- | :--- | :--- |
| `med_paracetamol` | Paracetamol 750mg | $15 | 3 | Antipirético e alívio de dor leve a moderada. |
| `med_ibuprofen` | Ibuprofeno 600mg | $20 | 2 | Anti-inflamatório não esteroide e alívio muscular. |
| `med_amoxicillin` | Amoxicilina 500mg | $45 | 1 | Antibiótico bactericida de amplo espectro (Retenção). |
| `med_morphine` | Morfina Hospitalar | $120 | 1 | Analgésico opioide potente (Retenção obrigatória). |
| `med_codeine` | Xarope de Codeína | $60 | 2 | Supressor de tosse crônica e analgesia moderada. |
| `med_xanax` | Alprazolam 2mg | $80 | 1 | Ansiolítico para alívio agudo de ataques de pânico. |

---

## 🛠️ Snippet para `ox_inventory/data/items.lua`

Copie e cole este bloco no seu arquivo `resources/[ox]/ox_inventory/data/items.lua`:

```lua
-- ====================================================================
-- LOKI MEDICAL SUITE - ITENS DE ATENDIMENTO DE EMERGÊNCIA E FARMACOLOGIA
-- ====================================================================

['prescription_pad'] = {
    label = 'Bloco de Receitas Oficiais',
    weight = 200,
    stack = false,
    close = true,
    description = 'Bloco oficial utilizado por médicos para emissão de receituários eletrônicos.'
},

['prescription'] = {
    label = 'Receituário Médico Carimbado',
    weight = 50,
    stack = false,
    close = true,
    description = 'Receita médica autenticada contendo medicamentos prescritos e posologia.'
},

['medical_certificate'] = {
    label = 'Atestado Médico Oficial',
    weight = 50,
    stack = false,
    close = true,
    description = 'Documento que comprova a dispensa de atividades laborais e serviços públicos.'
},

['sedative'] = {
    label = 'Seringa de Sedativo Clínico',
    weight = 100,
    stack = true,
    close = true,
    description = 'Seringa esterilizada contendo agente sedativo de indução rápida.'
},

['burncream'] = {
    label = 'Pomada para Queimadura',
    weight = 150,
    stack = true,
    close = true,
    description = 'Pomada tópica de alívio e regeneração para queimaduras de 1º a 3º grau.'
},

['suturekit'] = {
    label = 'Kit de Sutura Estéril',
    weight = 200,
    stack = true,
    close = true,
    description = 'Agulhas curvas e fios cirúrgicos para fechamento de lacerações profundas.'
},

['tweezers'] = {
    label = 'Pinça Cirúrgica de Extração',
    weight = 80,
    stack = true,
    close = true,
    description = 'Instrumento médico de precisão para remoção de projéteis alojados no tecido.'
},

['icepack'] = {
    label = 'Bolsa de Gelo Térmica',
    weight = 250,
    stack = true,
    close = true,
    description = 'Compressa térmica instantânea para alívio de inchaço e imobilização de fraturas.'
},

['blood_bag'] = {
    label = 'Bolsa de Sangue Total',
    weight = 500,
    stack = true,
    close = true,
    description = 'Bolsa plástica estéril com sangue total para infusão intravenosa.'
},

['defib'] = {
    label = 'Desfibrilador Portátil AED',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Desfibrilador automático bifásico para reanimação de vítimas em parada cardíaca.'
},

['stretcher'] = {
    label = 'Maca Fernocot Articulada',
    weight = 8000,
    stack = false,
    close = true,
    description = 'Maca dobrável hospitalar de emergência para resgate e transporte em ambulâncias.'
},

['crutch'] = {
    label = 'Muleta Ortopédica',
    weight = 1200,
    stack = false,
    close = true,
    description = 'Suporte ortopédico de alumínio para sustentação de marcha.'
},

['wheelchair'] = {
    label = 'Cadeira de Rodas Hospitalar',
    weight = 9000,
    stack = false,
    close = true,
    description = 'Cadeira de rodas para transporte assistido de pacientes convalescentes.'
},

['medicbag'] = {
    label = 'Mochila de Trauma de Resgate',
    weight = 1500,
    stack = false,
    close = true,
    description = 'Mochila tática completa com insumos de socorro pré-hospitalar.'
},

['med_paracetamol'] = {
    label = 'Paracetamol 750mg',
    weight = 50,
    stack = true,
    close = true,
    description = 'Cartela com comprimidos analgésicos e antitérmicos.'
},

['med_ibuprofen'] = {
    label = 'Ibuprofeno 600mg',
    weight = 50,
    stack = true,
    close = true,
    description = 'Anti-inflamatório para alívio de dor e inflamação.'
},

['med_amoxicillin'] = {
    label = 'Amoxicilina 500mg',
    weight = 80,
    stack = true,
    close = true,
    description = 'Antibiótico tarja vermelha de retenção de receita obrigatória.'
},

['med_morphine'] = {
    label = 'Morfina Hospitalar',
    weight = 100,
    stack = true,
    close = true,
    description = 'Analgésico opioide forte de retenção obrigatória.'
},
```
