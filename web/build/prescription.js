/* =========================================================================
   LATION UI PRESCRIPTION & MEDICAL CERTIFICATE CONTROLLER
   Integrated NUI Handler for Loki Prescriptions
   ========================================================================= */

(function () {
  const RESOURCE_NAME = window.GetParentResourceName ? window.GetParentResourceName() : 'loki_prescriptions';

  const Config = {
    medicines: [
      { item: 'med_paracetamol', label: 'Paracetamol', cost: 15, refills: 3 },
      { item: 'med_ibuprofen', label: 'Ibuprofeno', cost: 20, refills: 2 },
      { item: 'med_amoxicillin', label: 'Amoxicilina 500mg', cost: 45, refills: 1 },
      { item: 'med_morphine', label: 'Morfina Clínica', cost: 120, refills: 1 },
      { item: 'med_codeine', label: 'Codeína Xarope', cost: 60, refills: 2 },
      { item: 'med_xanax', label: 'Alprazolam', cost: 80, refills: 1 },
      { item: 'burncream', label: 'Pomada para Queimadura', cost: 25, refills: 3 },
      { item: 'suturekit', label: 'Kit de Sutura Estéril', cost: 50, refills: 2 }
    ],
    locale: 'pt-BR',
    style: 'lation'
  };

  let activeMedications = [];
  let isCreationOpen = false;
  let isViewOpen = false;

  // Initialize Container in DOM
  const container = document.getElementById('prescription-app') || document.body;

  // Build Creation Modal HTML
  const creationModal = document.createElement('div');
  creationModal.id = 'lation-rx-create-modal';
  creationModal.className = 'lation-rx-backdrop';
  creationModal.innerHTML = `
    <div class="lation-rx-card">
      <div class="lation-rx-header">
        <div class="lation-rx-brand">
          <div class="lation-rx-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2v20M2 12h20M7 7l10 10M17 7L7 17"/>
            </svg>
          </div>
          <div class="lation-rx-title-group">
            <h2>Receituário Médico <span class="lation-badge lation-badge-emerald">Oficial</span></h2>
            <p>Los Santos Emergency Medical Services • Registro Clínico</p>
          </div>
        </div>
        <div class="lation-badge lation-badge-cyan">EMS LSMC</div>
      </div>

      <div class="lation-rx-body">
        <div class="lation-form-grid">
          <div class="lation-field">
            <label class="lation-label">Nome Completo do Paciente</label>
            <input type="text" id="rx-patient-name" class="lation-input" placeholder="Ex: John Doe" autocomplete="off" />
          </div>
          <div class="lation-field">
            <label class="lation-label">Passaporte / Cidadania (ID)</label>
            <input type="text" id="rx-patient-id" class="lation-input" placeholder="Ex: 1042 / LS-8821" autocomplete="off" />
          </div>
          <div class="lation-field full">
            <label class="lation-label">Endereço Residencial</label>
            <input type="text" id="rx-patient-address" class="lation-input" placeholder="Ex: Spanish Ave, Apt 4B" autocomplete="off" />
          </div>
        </div>

        <div class="lation-med-section">
          <div class="lation-med-header">
            <label class="lation-label">Medicamentos Prescritos & Dosagem</label>
            <span class="lation-badge lation-badge-emerald" id="rx-med-count">1 Item</span>
          </div>
          <div class="lation-med-list" id="rx-med-list">
            <!-- Dynamic Medication Rows -->
          </div>
          <button type="button" class="lation-add-med-btn" id="rx-btn-add-med">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 5v14M5 12h14"/></svg>
            Adicionar Medicamento
          </button>
        </div>

        <div class="lation-field">
          <label class="lation-label">Instruções Clínicas & Posologia</label>
          <textarea id="rx-notes" class="lation-textarea" placeholder="Ex: Ingerir 1 comprimido a cada 8 horas após as refeições. Retorno em 7 dias..."></textarea>
        </div>

        <div class="lation-form-grid">
          <div class="lation-field">
            <label class="lation-label">Data de Emissão</label>
            <input type="text" id="rx-date" class="lation-input" readonly />
          </div>
          <div class="lation-field">
            <label class="lation-label">Assinatura Digital do Médico</label>
            <div class="lation-signature-box">
              <div class="lation-signature-preview" id="rx-sig-preview">Dr. Médico Responsável</div>
              <input type="text" id="rx-signature-input" class="lation-input" style="margin-top:6px;font-size:0.8rem;" placeholder="Digite seu nome para assinar" />
            </div>
          </div>
        </div>
      </div>

      <div class="lation-rx-footer">
        <button type="button" class="lation-btn lation-btn-ghost" id="rx-btn-cancel">Cancelar</button>
        <button type="button" class="lation-btn lation-btn-primary" id="rx-btn-submit">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
          Emitir Receituário
        </button>
      </div>
    </div>
  `;
  container.appendChild(creationModal);

  // Build Viewer Modal HTML (Read-only prescription inspection)
  const viewerModal = document.createElement('div');
  viewerModal.id = 'lation-rx-view-modal';
  viewerModal.className = 'lation-rx-backdrop';
  viewerModal.innerHTML = `
    <div class="lation-rx-card lation-view-card">
      <div class="lation-watermark">AUTÊNTICO</div>
      <div class="lation-rx-header">
        <div class="lation-rx-brand">
          <div class="lation-rx-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M2 12h20"/></svg>
          </div>
          <div class="lation-rx-title-group">
            <h2>Receituário Médico Dispensável</h2>
            <p>Los Santos Emergency Medical Services • Farmacologia</p>
          </div>
        </div>
        <div class="lation-view-badge-bar">
          <span class="lation-badge lation-badge-emerald">Verificado</span>
          <span class="lation-badge lation-badge-cyan" id="view-rx-id">RX-#0000</span>
        </div>
      </div>

      <div class="lation-rx-body">
        <div class="lation-view-meta">
          <div class="lation-meta-item">
            <span class="lation-meta-label">Paciente</span>
            <span class="lation-meta-val" id="view-patient-name">---</span>
          </div>
          <div class="lation-meta-item">
            <span class="lation-meta-label">Documento / ID</span>
            <span class="lation-meta-val" id="view-patient-dob">---</span>
          </div>
          <div class="lation-meta-item">
            <span class="lation-meta-label">Emissão</span>
            <span class="lation-meta-val" id="view-rx-date">---</span>
          </div>
        </div>

        <div class="lation-field full">
          <label class="lation-label">Endereço Registrado</label>
          <div style="font-size:0.85rem;color:var(--lation-text-muted);" id="view-patient-address">---</div>
        </div>

        <div class="lation-field">
          <label class="lation-label">Medicamentos Autorizados</label>
          <div class="lation-view-meds" id="view-med-list"></div>
        </div>

        <div class="lation-view-notes">
          <h5>Posologia & Orientações Médicas</h5>
          <p id="view-rx-notes">Sem instruções adicionais registradas.</p>
        </div>

        <div class="lation-security-seal">
          <div class="lation-barcode">||| ||||| |||| ||| |||||||</div>
          <div class="lation-doctor-sign">
            <span>Médico Emitente</span>
            <h3 id="view-doctor-signature">Dr. Médico</h3>
          </div>
        </div>
      </div>

      <div class="lation-rx-footer">
        <button type="button" class="lation-btn lation-btn-ghost" id="view-btn-close">Fechar</button>
      </div>
    </div>
  `;
  container.appendChild(viewerModal);

  // Helper: POST NUI callback
  function postNUI(callbackName, data = {}) {
    return fetch(`https://${RESOURCE_NAME}/${callbackName}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data)
    }).catch(err => {
      // In browser testing, suppress connection error
      console.log(`[NUI Mock] Sent to ${callbackName}:`, data);
    });
  }

  // Render Medication Rows in Creator
  function renderMedicationRows() {
    const list = document.getElementById('rx-med-list');
    if (!list) return;
    list.innerHTML = '';

    activeMedications.forEach((med, idx) => {
      const row = document.createElement('div');
      row.className = 'lation-med-row';
      row.innerHTML = `
        <select class="rx-select-med" data-idx="${idx}">
          ${Config.medicines.map(m => `
            <option value="${m.label}" ${m.label === med.label ? 'selected' : ''}>
              ${m.label} ($${m.cost || 0})
            </option>
          `).join('')}
        </select>
        <div class="lation-qty-control">
          <button type="button" class="lation-qty-btn rx-btn-minus" data-idx="${idx}">&minus;</button>
          <span class="lation-qty-val">${med.amount}</span>
          <button type="button" class="lation-qty-btn rx-btn-plus" data-idx="${idx}">&#43;</button>
        </div>
        <button type="button" class="lation-btn-icon-danger rx-btn-del" data-idx="${idx}" title="Remover">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6L6 18M6 6l12 12"/></svg>
        </button>
      `;
      list.appendChild(row);
    });

    const countBadge = document.getElementById('rx-med-count');
    if (countBadge) {
      countBadge.innerText = `${activeMedications.length} ${activeMedications.length === 1 ? 'Item' : 'Itens'}`;
    }

    // Attach row events
    list.querySelectorAll('.rx-select-med').forEach(sel => {
      sel.addEventListener('change', (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        if (activeMedications[idx]) {
          activeMedications[idx].label = e.target.value;
        }
      });
    });

    list.querySelectorAll('.rx-btn-minus').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        if (activeMedications[idx] && activeMedications[idx].amount > 1) {
          activeMedications[idx].amount -= 1;
          renderMedicationRows();
        }
      });
    });

    list.querySelectorAll('.rx-btn-plus').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        if (activeMedications[idx] && activeMedications[idx].amount < 10) {
          activeMedications[idx].amount += 1;
          renderMedicationRows();
        }
      });
    });

    list.querySelectorAll('.rx-btn-del').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        activeMedications.splice(idx, 1);
        if (activeMedications.length === 0 && Config.medicines[0]) {
          activeMedications.push({ label: Config.medicines[0].label, amount: 1 });
        }
        renderMedicationRows();
      });
    });
  }

  // Open Creation UI
  function openCreationUI() {
    isCreationOpen = true;
    isViewOpen = false;
    viewerModal.classList.remove('active');

    // Reset fields
    document.getElementById('rx-patient-name').value = '';
    document.getElementById('rx-patient-id').value = '';
    document.getElementById('rx-patient-address').value = '';
    document.getElementById('rx-notes').value = '';
    
    const now = new Date();
    document.getElementById('rx-date').value = now.toLocaleDateString(Config.locale || 'pt-BR');
    
    const defaultDoctor = 'Dr. Responsável';
    const sigInput = document.getElementById('rx-signature-input');
    const sigPreview = document.getElementById('rx-sig-preview');
    sigInput.value = defaultDoctor;
    sigPreview.innerText = defaultDoctor;

    activeMedications = [{
      label: Config.medicines[0] ? Config.medicines[0].label : 'Paracetamol',
      amount: 1
    }];

    renderMedicationRows();
    creationModal.classList.add('active');
  }

  // Open Viewer UI
  function openViewerUI(data, dateStr) {
    isViewOpen = true;
    isCreationOpen = false;
    creationModal.classList.remove('active');

    if (!data) return;

    document.getElementById('view-patient-name').innerText = data.name || 'Paciente Não Identificado';
    document.getElementById('view-patient-dob').innerText = data.dob || data.identifier || 'LS-DESCONHECIDO';
    document.getElementById('view-patient-address').innerText = data.adress || data.address || 'Sem endereço cadastrado';
    document.getElementById('view-rx-date').innerText = dateStr || (data.date ? new Date(data.date).toLocaleDateString(Config.locale || 'pt-BR') : new Date().toLocaleDateString(Config.locale || 'pt-BR'));
    document.getElementById('view-rx-notes').innerText = data.notes && data.notes.trim() ? data.notes : 'Nenhuma restrição ou dosagem extra informada.';
    document.getElementById('view-doctor-signature').innerText = data.signature || 'Dr(a). Médico';

    const medsList = document.getElementById('view-med-list');
    medsList.innerHTML = '';

    const meds = data.medications || [];
    if (meds.length === 0 && data.medication) {
      meds.push({ label: data.medication, amount: data.amount || 1, refills_remaining: 1 });
    }

    meds.forEach(m => {
      const itemEl = document.createElement('div');
      itemEl.className = 'lation-view-med-item';
      itemEl.innerHTML = `
        <div class="lation-view-med-left">
          <div class="lation-view-med-pill">Rx</div>
          <div class="lation-view-med-info">
            <h4>${m.amount}x ${m.label || m.item || 'Medicamento'}</h4>
            <p>Uso Terapêutico Controlado</p>
          </div>
        </div>
        <div class="lation-view-refills">
          ${m.refills_remaining !== undefined ? `${m.refills_remaining} Retirada(s)` : 'Autorizado'}
        </div>
      `;
      medsList.appendChild(itemEl);
    });

    viewerModal.classList.add('active');
  }

  // Close all modals
  function closeAllModals() {
    isCreationOpen = false;
    isViewOpen = false;
    creationModal.classList.remove('active');
    viewerModal.classList.remove('active');
    postNUI('nuiClosed');
  }

  // Event Listeners
  document.getElementById('rx-btn-add-med').addEventListener('click', () => {
    if (activeMedications.length >= 4) return;
    activeMedications.push({
      label: Config.medicines[0] ? Config.medicines[0].label : 'Medicamento',
      amount: 1
    });
    renderMedicationRows();
  });

  document.getElementById('rx-signature-input').addEventListener('input', (e) => {
    document.getElementById('rx-sig-preview').innerText = e.target.value.trim() || 'Dr(a). Médico';
  });

  document.getElementById('rx-btn-cancel').addEventListener('click', closeAllModals);
  document.getElementById('view-btn-close').addEventListener('click', closeAllModals);

  document.getElementById('rx-btn-submit').addEventListener('click', () => {
    const pName = document.getElementById('rx-patient-name').value.trim();
    if (!pName) {
      document.getElementById('rx-patient-name').focus();
      return;
    }

    const payload = {
      name: pName,
      adress: document.getElementById('rx-patient-address').value.trim() || 'Los Santos',
      dob: document.getElementById('rx-patient-id').value.trim() || 'N/A',
      notes: document.getElementById('rx-notes').value.trim(),
      signature: document.getElementById('rx-signature-input').value.trim() || 'Dr. Médico',
      medications: activeMedications
    };

    postNUI('submit_prescription', payload);
    closeAllModals();
  });

  // Global Keydown (Escape to close)
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && (isCreationOpen || isViewOpen)) {
      closeAllModals();
    }
  });

  // NUI Message Listener
  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;

    if (data.event === 'load_config') {
      if (Array.isArray(data.medicine)) {
        Config.medicines = data.medicine;
      }
      if (data.locale) Config.locale = data.locale;
      if (data.style) Config.style = data.style;
    } else if (data.event === 'open_nui') {
      openCreationUI();
    } else if (data.event === 'show_prescription') {
      openViewerUI(data.prescription, data.date);
    } else if (data.event === 'close_nui') {
      creationModal.classList.remove('active');
      viewerModal.classList.remove('active');
      isCreationOpen = false;
      isViewOpen = false;
    }
  });

  // Request config from server on startup
  postNUI('load_config');
})();
