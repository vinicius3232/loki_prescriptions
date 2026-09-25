# 🏗️ Arquitetura Atual do Sistema (CURRENT_ARCHITECTURE)

Mapeamento estrutural, técnico e de dependências do **loki_prescriptions** no estado atual.

---

## 1. Topologia de Camadas

```
┌────────────────────────────────────────────────────────┐
│                   INTERFACE NUI (CEF)                  │
│  - Web Build (HTML5 / Tailwind CSS / Vanilla JS)       │
│  - Estilo Lation Medical Glassmorphism (Dark Slate)    │
│  - 7 Minigames de Diagnóstico Cirúrgico do Pluto       │
│  - Prontuário, Bloco de Receitas e Laudos Médicos      │
└───────────────────────────▲────────────────────────────┘
                            │ NUI Callbacks / SendNUIMessage
┌───────────────────────────▼────────────────────────────┐
│                    CAMADA CLIENT                     │
│  - client/client.lua (Loops de leito, check-in)       │
│  - client/minigames.lua (Despacho dos 7 minigames)     │
│  - client/damages.lua (Mapeamento de 7 ossos/danos)    │
│  - client/pulse.lua (Simulação e State Bag de pulso)   │
│  - client/temperature.lua (Simulação de temperatura)   │
│  - client/saline.lua (Prop e efeitos de soro IV)       │
│  - client/lucas3.lua (Compressor mecânico torácico)    │
│  - client/crutch.lua & wheelchair.lua (Mobilidade)     │
│  - client/stretcher.lua (Maca articulada)              │
│  - client/knockout.lua (Nocaute em combate melee)      │
└───────────────────────────▲────────────────────────────┘
                            │ RPC (lib.callback) / NetEvents / StateBags
┌───────────────────────────▼────────────────────────────┐
│                    CAMADA SERVER                     │
│  - server/server.lua (Prontuários e prescrições)       │
│  - server/medicine_consumer.lua (Dosagens e consumo)   │
│  - server/database.lua (MySQL Queries via oxmysql)     │
│  - server/saline.lua (Infusão contínua e vp_needs)     │
│  - server/lucas3.lua (Gerenciamento de RCP contínua)   │
│  - server/minigames.lua (Recompensas e validação)      │
│  - bridge/server.lua (Camada de abstração QBox/ESX)    │
└───────────────────────────▲────────────────────────────┘
                            │ Queries Assíncronas
┌───────────────────────────▼────────────────────────────┐
│                   BANCO DE DADOS                       │
│  - oxmysql (Pool de Conexões MariaDB)                  │
│  - Tabelas: medical_records, prescriptions, etc.       │
└────────────────────────────────────────────────────────┘
```

---

## 2. Mapa de Módulos e Componentes

* **`bridge/`**: Adaptador universal de framework (`qbx_core`, `esx`) e inventário (`ox_inventory`).
* **`bridge/integrations/`**: Pontes especializadas para `vp_needs`, `nexus_os`, `vp_tablet` e `vp_phone`.
* **`client/`**: 25 arquivos gerenciando desde biometria até animações de maca, cadeira de rodas e minigames cirúrgicos.
* **`server/`**: 24 arquivos responsáveis pela persistência em banco, verificação de CRM médico e autoridade de itens.
* **`web/`**: Assets estáticos, áudios cirúrgicos e templates NUI.
