-- ============================================================================
-- loki_prescriptions - Configuração de Itens para ox_inventory/data/items.lua
-- Copie os itens abaixo para o seu ox_inventory/data/items.lua
-- Imagens disponíveis na pasta: ITEM_SETUP/images/
-- ============================================================================

return {
['prescription'] = {
    label = 'Receita Médica',
    weight = 10,
    stack = false,
    close = true,
    description = 'Receita emitida por um médico com dosagem e orientações farmacêuticas.'
},

['prescription_pad'] = {
    label = 'Bloco de Receitas',
    weight = 100,
    stack = false,
    close = true,
    description = 'Bloco oficial utilizado por profissionais de saúde para emissão de receituários.'
},

['tylacare'] = {
    label = 'Tylacare',
    weight = 15,
    stack = true,
    close = true,
    description = 'Analgésico suave e antitérmico para alívio de febres e dores leves.'
},

['flurimax'] = {
    label = 'Flurimax',
    weight = 15,
    stack = true,
    close = true,
    description = 'Antigripal com ação descongestionante contra sintomas de mal-estar.'
},

['dayrelief'] = {
    label = 'Dayrelief',
    weight = 15,
    stack = true,
    close = true,
    description = 'Composto revigorante diurno para combate da sonolência e fadiga muscular.'
},

['gutguard'] = {
    label = 'GutGuard',
    weight = 15,
    stack = true,
    close = true,
    description = 'Protetor gástrico de ação rápida contra náuseas e intoxicação alimentar.'
},

['stopdiaril'] = {
    label = 'Stopdiaril',
    weight = 15,
    stack = true,
    close = true,
    description = 'Regulador da flora intestinal para estabilização metabólica e hídrica.'
},

['triptaril'] = {
    label = 'Triptaril',
    weight = 15,
    stack = true,
    close = true,
    description = 'Estabilizador de humor e relaxante contra episódios agudos de estresse.'
},

['ibrofenix'] = {
    label = 'Ibrofenix',
    weight = 15,
    stack = true,
    close = true,
    description = 'Anti-inflamatório não esteroide para dores articulares e musculares.'
},

['allerblock'] = {
    label = 'AllerBlock',
    weight = 15,
    stack = true,
    close = true,
    description = 'Anti-histamínico contra crises alérgicas, irritações respiratórias e coceiras.'
},

['clearairin'] = {
    label = 'Clearairin',
    weight = 15,
    stack = true,
    close = true,
    description = 'Broncodilatador inalatório: cessa imediatamente crises de tosse e engasgo.'
},

['motionex'] = {
    label = 'Motionex',
    weight = 15,
    stack = true,
    close = true,
    description = 'Antiemético indicado para enjoo de movimento em veículos e embarcações.'
},

['meklirin'] = {
    label = 'Meklirin',
    weight = 15,
    stack = true,
    close = true,
    description = 'Medicamento labiríntico para controle de vertigem e desequilíbrio.'
},

['vironix'] = {
    label = 'Vironix',
    weight = 15,
    stack = true,
    close = true,
    description = 'Antiviral hospitalar de retenção obrigatória para regeneração imunológica.'
},

['vaxora'] = {
    label = 'Vaxora',
    weight = 15,
    stack = true,
    close = true,
    description = 'Imunizante de amplo espectro para prevenção de infecções sistêmicas.'
},

['cycurex'] = {
    label = 'Cycurex',
    weight = 15,
    stack = true,
    close = true,
    description = 'Antibiótico potente de uso restrito contra quadros bacterianos graves.'
},

['painaway'] = {
    label = 'PainAway',
    weight = 15,
    stack = true,
    close = true,
    description = 'Analgésico opioide de controle especial para supressão de traumas físicos agudos.'
},

['zithromed'] = {
    label = 'ZithroMed',
    weight = 15,
    stack = true,
    close = true,
    description = 'Azitromicina em comprimidos para infecções do trato respiratório e dérmico.'
},

['doxallin'] = {
    label = 'Doxallin',
    weight = 15,
    stack = true,
    close = true,
    description = 'Doxiciclina de amplo espectro para estabilização de bactérias invasoras.'
},

['loprexin'] = {
    label = 'Loprexin',
    weight = 15,
    stack = true,
    close = true,
    description = 'Bloqueador beta para controle do ritmo cardíaco e alívio da pressão arterial.'
},

-- ============================================================================
-- Equipamentos de Emergência & Hardware de Atendimento
-- ============================================================================
['defibrilator'] = {
    label = 'Lifepak 15 (Desfibrilador)',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Monitor cardíaco e desfibrilador portátil Lifepak 15 para reversão de arritmias e suporte avançado de vida.'
},

['stretcher'] = {
    label = 'Maca Stryker Gurney',
    weight = 5000,
    stack = false,
    close = true,
    description = 'Maca dobrável hospitalar de alta mobilidade com fixação em ambulâncias.'
},

['crutch'] = {
    label = 'Par de Muletas',
    weight = 1200,
    stack = false,
    close = true,
    description = 'Suporte ortopédico para auxílio na locomoção de pacientes com fraturas nos membros inferiores.'
},

['wheelchair'] = {
    label = 'Cadeira de Rodas',
    weight = 4000,
    stack = false,
    close = true,
    description = 'Cadeira de rodas hospitalar dobrável para transporte clínico de pacientes debilitados.'
},

['medicbag'] = {
    label = 'Maleta de Primeiros Socorros',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Mala tática de paramédico contendo insumos para procedimentos de campo.'
},

['lucas3'] = {
    label = 'Compressor Torácico LUCAS 3',
    weight = 3500,
    stack = false,
    close = true,
    description = 'Dispositivo de compressão torácica mecânica contínua para reanimação cardiopulmonar (RCP).'
},

-- ============================================================================
-- Insumos Cirúrgicos, Trauma & Balística Forense
-- ============================================================================
['suture_kit'] = {
    label = 'Kit de Sutura Cirúrgica',
    weight = 200,
    stack = true,
    close = true,
    description = 'Fios cirúrgicos agulhados e porta-agulha para fechamento asséptico de incisões profundas.'
},

['tourniquet'] = {
    label = 'Torniquete Tático',
    weight = 150,
    stack = true,
    close = true,
    description = 'Dispositivo hemostático mecânico para oclusão rápida de hemorragias arteriais graves.'
},

['splint'] = {
    label = 'Tala de Imobilização Ortopédica',
    weight = 300,
    stack = true,
    close = true,
    description = 'Tala moldável para estabilização de ossos fraturados e articulações lesionadas.'
},

['icepack'] = {
    label = 'Bolsa de Gelo Instantâneo',
    weight = 150,
    stack = true,
    close = true,
    description = 'Compressa fria para contenção de edema e alívio de contusões musculares.'
},

['ointment'] = {
    label = 'Pomada Cicatrizante',
    weight = 100,
    stack = true,
    close = true,
    description = 'Pomada antibiótica com anestésico local para queimaduras leves e escoriações.'
},

['disinfectant'] = {
    label = 'Antisséptico Hospitalar',
    weight = 200,
    stack = true,
    close = true,
    description = 'Solução de clorexidina degermante para desinfecção de feridas e assepsia cirúrgica.'
},

['gauze'] = {
    label = 'Compressas de Gaze Estéril',
    weight = 50,
    stack = true,
    close = true,
    description = 'Gaze estéril absorvente para curativos e tamponamento de sangramento.'
},

['medical_kit'] = {
    label = 'Kit de Trauma Básico',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Conjunto essencial para tratamento e estabilização de traumas intermediários.'
},

['advanced_medical_kit'] = {
    label = 'Kit Avançado de Cirurgia de Campo',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Equipamento de suporte cirúrgico avançado para procedimentos invasivos emergenciais.'
},

['blood_bag_250'] = {
    label = 'Bolsa de Sangue (250ml)',
    weight = 280,
    stack = true,
    close = true,
    description = 'Concentrado de hemácias estéril de 250ml para ressuscitação volêmica.'
},

['blood_bag_500'] = {
    label = 'Bolsa de Sangue (500ml)',
    weight = 550,
    stack = true,
    close = true,
    description = 'Bolsa de sangue total de 500ml para choque hipovolêmico grave.'
},

['forceps'] = {
    label = 'Pinça Cirúrgica (Extrator de Projétil)',
    weight = 180,
    stack = false,
    close = true,
    description = 'Pinça cirúrgica hemostática curva para extração de projéteis alojados e estilhaços.'
},

['spent_bullet'] = {
    label = 'Projétil Deformado (Evidência)',
    weight = 10,
    stack = false,
    close = true,
    description = 'Projétil balístico extraído de tecido humano. Contém estrias para perícia balística.'
},

['medical_certificate'] = {
    label = 'Atestado Médico Oficial',
    weight = 5,
    stack = false,
    close = true,
    description = 'Documento oficial emitido por médico hospitalar concedendo afastamento e repouso clínico.'
},

['autopsy_report'] = {
    label = 'Laudo de Necropsia Forense',
    weight = 10,
    stack = false,
    close = true,
    description = 'Relatório tanatológico e pericial detalhando causa mortis, calibre balístico e lesões da vítima.'
},
}