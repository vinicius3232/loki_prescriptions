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

  /* =========================================================================
     PLUTO INTERACTIVE MINIGAMES ENGINE (LATION MEDICAL SUITE)
     ========================================================================= */

  // 1. Surgical Suturing Minigame
  let isSutureActive = false;
  let currentStitch = 0;
  const totalStitchesNeeded = 8;
  let sutureTargetSrc = null;
  let sutureBone = null;

  function startSutureMinigame(targetSrc, bone) {
    sutureTargetSrc = targetSrc;
    sutureBone = bone || 'torso';
    isSutureActive = true;
    currentStitch = 0;

    const container = document.getElementById('suture-minigame-container');
    const canvas = document.getElementById('suture-canvas');
    const area = document.getElementById('suture-canvas-area');
    const needle = document.getElementById('suture-needle');
    const fill = document.getElementById('suture-fill');

    if (!container || !canvas || !area) return;

    fill.style.width = '0%';
    container.classList.remove('hidden');
    needle.style.display = 'block';

    const rect = area.getBoundingClientRect();
    canvas.width = rect.width || 600;
    canvas.height = rect.height || 320;
    const ctx = canvas.getContext('2d');

    const points = [];
    const centerY = canvas.height / 2;
    const spacing = (canvas.width - 120) / (totalStitchesNeeded - 1);

    for (let i = 0; i < totalStitchesNeeded; i++) {
      points.push({
        x: 60 + i * spacing,
        yTop: centerY - 45,
        yBottom: centerY + 45,
        completed: false,
        active: i === 0
      });
    }

    function drawWound() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Deep realistic tissue
      const skinGrd = ctx.createRadialGradient(canvas.width / 2, centerY, 40, canvas.width / 2, centerY, canvas.width / 1.7);
      skinGrd.addColorStop(0, '#be8467');
      skinGrd.addColorStop(0.5, '#995a43');
      skinGrd.addColorStop(1, '#5a2d20');
      ctx.fillStyle = skinGrd;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // Bruising
      const bruiseGrd = ctx.createRadialGradient(canvas.width / 2, centerY, 20, canvas.width / 2, centerY, 160);
      bruiseGrd.addColorStop(0, 'rgba(120, 15, 35, 0.55)');
      bruiseGrd.addColorStop(0.6, 'rgba(70, 10, 50, 0.25)');
      bruiseGrd.addColorStop(1, 'rgba(0, 0, 0, 0)');
      ctx.fillStyle = bruiseGrd;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // Closed scar line
      ctx.beginPath();
      ctx.moveTo(35, centerY);
      ctx.bezierCurveTo(canvas.width / 3, centerY - 15, (2 * canvas.width) / 3, centerY + 15, canvas.width - 35, centerY);
      ctx.lineWidth = 3;
      ctx.strokeStyle = 'rgba(74, 8, 8, 0.45)';
      ctx.lineCap = 'round';
      ctx.stroke();

      // Open wound fissure
      const lastStitchX = currentStitch > 0 ? points[currentStitch - 1].x : 35;
      const transitionWidth = spacing * 1.5;

      if (currentStitch < totalStitchesNeeded) {
        ctx.save();
        ctx.beginPath();
        ctx.moveTo(35, centerY);
        ctx.bezierCurveTo(canvas.width / 3, centerY - 15, (2 * canvas.width) / 3, centerY + 15, canvas.width - 35, centerY);

        const outerGrd = ctx.createLinearGradient(lastStitchX - transitionWidth / 2, 0, lastStitchX + transitionWidth / 2, 0);
        outerGrd.addColorStop(0, 'rgba(60, 4, 4, 0)');
        outerGrd.addColorStop(1, 'rgba(60, 4, 4, 1)');
        ctx.lineWidth = 14;
        ctx.strokeStyle = outerGrd;
        ctx.stroke();

        const innerGrd = ctx.createLinearGradient(lastStitchX - transitionWidth / 2, 0, lastStitchX + transitionWidth / 2, 0);
        innerGrd.addColorStop(0, 'rgba(180, 10, 10, 0)');
        innerGrd.addColorStop(1, 'rgba(180, 10, 10, 1)');
        ctx.lineWidth = 7;
        ctx.strokeStyle = innerGrd;
        ctx.stroke();
        ctx.restore();
      }

      // Punctures & Threads
      points.forEach((p) => {
        ctx.beginPath();
        ctx.arc(p.x, p.yTop, 4, 0, Math.PI * 2);
        ctx.fillStyle = '#1e0404';
        ctx.fill();

        ctx.beginPath();
        ctx.arc(p.x, p.yBottom, 4, 0, Math.PI * 2);
        ctx.fillStyle = '#1e0404';
        ctx.fill();

        if (p.active) {
          ctx.beginPath();
          ctx.arc(p.x, p.yTop, 9, 0, Math.PI * 2);
          ctx.strokeStyle = 'rgba(16, 185, 129, 0.9)';
          ctx.lineWidth = 2.5;
          ctx.stroke();
        }

        if (p.completed) {
          ctx.beginPath();
          ctx.moveTo(p.x, p.yTop);
          ctx.quadraticCurveTo(p.x + 5, centerY, p.x, p.yBottom);
          ctx.lineWidth = 3;
          ctx.strokeStyle = '#f8fafc';
          ctx.stroke();

          ctx.beginPath();
          ctx.arc(p.x, p.yTop, 3.5, 0, Math.PI * 2);
          ctx.fillStyle = '#fff';
          ctx.fill();
        }
      });
    }

    drawWound();

    let isDragging = false;

    function onMouseDown(e) {
      if (!isSutureActive) return;
      const rect = area.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      const p = points[currentStitch];
      if (!p) return;
      if (Math.hypot(mx - p.x, my - p.yTop) < 30) {
        isDragging = true;
      }
    }

    function onMouseMove(e) {
      if (!isSutureActive) return;
      const rect = area.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      needle.style.left = mx + 'px';
      needle.style.top = (my - (needle.offsetHeight || 60)) + 'px';

      if (isDragging) drawWound();
    }

    function onMouseUp(e) {
      if (!isSutureActive || !isDragging) return;
      isDragging = false;

      const rect = area.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      const p = points[currentStitch];
      if (!p) return;

      if (Math.hypot(mx - p.x, my - p.yBottom) < 32) {
        p.completed = true;
        p.active = false;
        currentStitch++;

        const progress = (currentStitch / totalStitchesNeeded) * 100;
        fill.style.width = progress + '%';

        if (currentStitch < totalStitchesNeeded) {
          points[currentStitch].active = true;
        } else {
          setTimeout(() => closeSutureMinigame(true), 400);
        }
      }
      drawWound();
    }

    area.onmousedown = onMouseDown;
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    window.sutureCleanup = () => {
      area.onmousedown = null;
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }

  function closeSutureMinigame(success) {
    isSutureActive = false;
    const container = document.getElementById('suture-minigame-container');
    const needle = document.getElementById('suture-needle');
    if (container) container.classList.add('hidden');
    if (needle) needle.style.display = 'none';

    if (window.sutureCleanup) {
      window.sutureCleanup();
      window.sutureCleanup = null;
    }

    postNUI('sutureMinigameResult', {
      success: !!success,
      targetSrc: sutureTargetSrc,
      part: sutureBone
    });
  }

  // 2. Vascular Hemostasis & Clamping Minigame
  let isClampActive = false;
  let clampAnimRef = null;
  let vesselSegments = [];
  let activeVesselEnd = null;
  let currentVesselSuture = null;
  let isVesselSuturing = false;
  let clampTargetSrc = null;
  let clampBone = null;

  function areVesselsLinked() {
    return vesselSegments.length > 0 && vesselSegments.every(s => s.isLinked);
  }

  function areVesselsSutured() {
    return vesselSegments.length > 0 && vesselSegments.every(s => s.stitches.every(st => st.completed));
  }

  function drawClampMinigameScene(canvas, ctx, ms) {
    const w = canvas.width;
    const h = canvas.height;
    const centerY = h * 0.54;

    ctx.clearRect(0, 0, w, h);

    // Anatomical tissue bed
    const skin = ctx.createLinearGradient(0, 0, 0, h);
    skin.addColorStop(0, '#a66d52');
    skin.addColorStop(0.5, '#8f5744');
    skin.addColorStop(1, '#69382b');
    ctx.fillStyle = skin;
    ctx.fillRect(0, 0, w, h);

    const incisionW = w * 1.4;
    const incisionH = h * 0.82;
    const cavity = ctx.createRadialGradient(w * 0.5, centerY, 40, w * 0.5, centerY, incisionW * 0.55);
    cavity.addColorStop(0, '#3d0606');
    cavity.addColorStop(0.6, '#220303');
    cavity.addColorStop(1, '#0e0101');
    ctx.fillStyle = cavity;
    ctx.beginPath();
    ctx.ellipse(w * 0.5, centerY, incisionW * 0.5, incisionH * 0.5, 0, 0, Math.PI * 2);
    ctx.fill();

    const pulse = 0.55 + 0.45 * Math.sin(ms * 0.015);
    const activeVesselWidth = Math.max(18, w * 0.024);

    vesselSegments.forEach((seg) => {
      const isArtery = seg.kind === 'artery';
      const colorMain = isArtery ? '#c0392b' : '#2980b9';
      const colorDeep = isArtery ? '#7b241c' : '#1a5276';

      const drawSegmentBody = (points, side) => {
        if (points.length < 2) return;

        // Shadow
        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);
        for (let i = 1; i < points.length; i++) ctx.lineTo(points[i].x, points[i].y);
        ctx.strokeStyle = '#000';
        ctx.lineWidth = activeVesselWidth + 8;
        ctx.globalAlpha = 0.6;
        ctx.stroke();
        ctx.globalAlpha = 1.0;

        // Body tube
        const grad = ctx.createLinearGradient(points[0].x, points[0].y, points[points.length - 1].x, points[points.length - 1].y);
        grad.addColorStop(0, colorDeep);
        grad.addColorStop(0.5, colorMain);
        grad.addColorStop(1, colorDeep);

        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);
        for (let i = 1; i < points.length; i++) ctx.lineTo(points[i].x, points[i].y);
        ctx.strokeStyle = grad;
        ctx.lineWidth = activeVesselWidth;
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        ctx.stroke();

        // Severed end & arterial spurt
        if (!seg.isLinked) {
          const end = side === 'left' ? points[points.length - 1] : points[0];
          ctx.beginPath();
          ctx.arc(end.x, end.y, activeVesselWidth / 2, 0, Math.PI * 2);
          ctx.fillStyle = '#000';
          ctx.fill();
          ctx.strokeStyle = '#f43f5e';
          ctx.lineWidth = 3;
          ctx.stroke();

          if (side === 'left' && isArtery) {
            const spurt = 12 + 22 * pulse;
            const bGrad = ctx.createRadialGradient(end.x, end.y, 2, end.x, end.y, spurt);
            bGrad.addColorStop(0, `rgba(244, 63, 94, ${0.8 + 0.15 * pulse})`);
            bGrad.addColorStop(1, 'rgba(150, 0, 0, 0)');
            ctx.fillStyle = bGrad;
            ctx.beginPath();
            ctx.arc(end.x, end.y, spurt, 0, Math.PI * 2);
            ctx.fill();
          }
        }
      };

      if (seg.isLinked) {
        const combined = [...seg.leftPath, ...seg.rightPath];
        drawSegmentBody(combined, 'linked');

        seg.stitches.forEach((st) => {
          ctx.beginPath();
          ctx.arc(st.x, st.yTop, 4, 0, Math.PI * 2);
          ctx.fillStyle = '#1a0202';
          ctx.fill();

          ctx.beginPath();
          ctx.arc(st.x, st.yBottom, 4, 0, Math.PI * 2);
          ctx.fillStyle = '#1a0202';
          ctx.fill();

          if (st.completed) {
            ctx.beginPath();
            ctx.moveTo(st.x, st.yTop);
            ctx.quadraticCurveTo(st.x + 4, (st.yTop + st.yBottom) / 2, st.x, st.yBottom);
            ctx.strokeStyle = '#fff';
            ctx.lineWidth = 2.5;
            ctx.stroke();
          } else if (isVesselSuturing && st.active) {
            ctx.beginPath();
            ctx.arc(st.x, st.yTop, 8, 0, Math.PI * 2);
            ctx.strokeStyle = 'rgba(16, 185, 129, 0.9)';
            ctx.lineWidth = 2;
            ctx.stroke();
          }
        });
      } else {
        drawSegmentBody(seg.leftPath, 'left');
        drawSegmentBody(seg.rightPath, 'right');
      }
    });
  }

  function startClampMinigame(targetSrc, bone) {
    clampTargetSrc = targetSrc;
    clampBone = bone || 'torso';
    isClampActive = true;
    isVesselSuturing = false;

    const container = document.getElementById('clamp-minigame-container');
    const area = document.getElementById('clamp-canvas-area');
    const canvas = document.getElementById('clamp-canvas');
    const needle = document.getElementById('vessel-suture-needle');
    const hint = document.getElementById('clamp-hint');

    if (!container || !area || !canvas) return;

    container.classList.remove('hidden');
    needle.style.display = 'none';
    hint.innerText = 'ARRASTE AS PONTAS DOS VASOS E CONECTE-AS';

    const rect = area.getBoundingClientRect();
    canvas.width = rect.width || 700;
    canvas.height = rect.height || 360;
    const ctx = canvas.getContext('2d');

    const midX = canvas.width * 0.5;
    const gap = 130;
    const h = canvas.height;

    vesselSegments = [
      {
        kind: 'artery',
        isLinked: false,
        leftPath: [{ x: -60, y: h * 0.4 }, { x: midX - gap, y: h * 0.42 }],
        rightPath: [{ x: midX + gap, y: h * 0.42 }, { x: canvas.width + 60, y: h * 0.4 }],
        stitches: []
      },
      {
        kind: 'vein',
        isLinked: false,
        leftPath: [{ x: -60, y: h * 0.62 }, { x: midX - gap, y: h * 0.6 }],
        rightPath: [{ x: midX + gap, y: h * 0.6 }, { x: canvas.width + 60, y: h * 0.62 }],
        stitches: []
      }
    ];

    activeVesselEnd = null;
    currentVesselSuture = null;
    let isDraggingNeedle = false;

    function animate(t) {
      if (!isClampActive) return;
      drawClampMinigameScene(canvas, ctx, t || 0);
      clampAnimRef = requestAnimationFrame(animate);
    }
    clampAnimRef = requestAnimationFrame(animate);

    function onMouseDown(e) {
      if (!isClampActive) return;
      const rect = area.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      if (!areVesselsLinked()) {
        vesselSegments.forEach((seg, sIdx) => {
          if (seg.isLinked) return;
          const endL = seg.leftPath[seg.leftPath.length - 1];
          if (Math.hypot(mx - endL.x, my - endL.y) < 50) {
            activeVesselEnd = { sIdx, side: 'left' };
          }
        });
      } else if (isVesselSuturing) {
        vesselSegments.forEach((seg, sIdx) => {
          seg.stitches.forEach((st, stIdx) => {
            if (st.active && Math.hypot(mx - st.x, my - st.yTop) < 24) {
              isDraggingNeedle = true;
              currentVesselSuture = { sIdx, stIdx };
            }
          });
        });
      }
    }

    function onMouseMove(e) {
      if (!isClampActive) return;
      const rect = area.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      if (activeVesselEnd) {
        const seg = vesselSegments[activeVesselEnd.sIdx];
        const endL = seg.leftPath[seg.leftPath.length - 1];
        endL.x = mx;
        endL.y = my;

        const endR = seg.rightPath[0];
        if (Math.hypot(mx - endR.x, my - endR.y) < 45) {
          seg.isLinked = true;
          activeVesselEnd = null;
          endL.x = endR.x;
          endL.y = endR.y;

          // Add stitches for junction
          const stitchCount = 3;
          const spacing = 16;
          for (let i = 0; i < stitchCount; i++) {
            seg.stitches.push({
              x: endR.x - spacing + i * spacing,
              yTop: endR.y - 20,
              yBottom: endR.y + 20,
              completed: false,
              active: i === 0
            });
          }

          if (areVesselsLinked()) {
            isVesselSuturing = true;
            needle.style.display = 'block';
            hint.innerText = 'VASOS CONECTADOS! SUTURE AS JUNÇÕES.';
          }
        }
      }

      if (isVesselSuturing) {
        needle.style.left = mx + 'px';
        needle.style.top = (my - (needle.offsetHeight || 60)) + 'px';
      }
    }

    function onMouseUp(e) {
      if (!isClampActive) return;
      activeVesselEnd = null;

      if (isDraggingNeedle && currentVesselSuture) {
        const rect = area.getBoundingClientRect();
        const mx = e.clientX - rect.left;
        const my = e.clientY - rect.top;

        const seg = vesselSegments[currentVesselSuture.sIdx];
        const st = seg.stitches[currentVesselSuture.stIdx];

        if (Math.hypot(mx - st.x, my - st.yBottom) < 28) {
          st.completed = true;
          st.active = false;

          if (currentVesselSuture.stIdx < seg.stitches.length - 1) {
            seg.stitches[currentVesselSuture.stIdx + 1].active = true;
          } else {
            const nextVessel = vesselSegments.find(s => s.stitches.some(st => !st.completed));
            if (nextVessel) {
              const nextStitch = nextVessel.stitches.find(st => !st.completed);
              if (nextStitch) nextStitch.active = true;
            }
          }
        }
        isDraggingNeedle = false;

        if (areVesselsSutured()) {
          setTimeout(() => closeClampMinigame(true), 600);
        }
      }
    }

    area.onmousedown = onMouseDown;
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    window.clampCleanup = () => {
      area.onmousedown = null;
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
      if (clampAnimRef) cancelAnimationFrame(clampAnimRef);
    };
  }

  function closeClampMinigame(success) {
    isClampActive = false;
    isVesselSuturing = false;
    const container = document.getElementById('clamp-minigame-container');
    const needle = document.getElementById('vessel-suture-needle');
    if (container) container.classList.add('hidden');
    if (needle) needle.style.display = 'none';

    if (window.clampCleanup) {
      window.clampCleanup();
      window.clampCleanup = null;
    }

    postNUI('clampMinigameResult', {
      success: !!success,
      targetSrc: clampTargetSrc,
      part: clampBone
    });
  }

  // 3. Bullet Extraction Minigame
  let isSurgeryActive = false;
  let isSurgeryDragging = false;
  let bulletTargetSrc = null;
  let bulletBone = null;

  function startBulletMinigame(targetSrc, bone) {
    bulletTargetSrc = targetSrc;
    bulletBone = bone || 'torso';
    isSurgeryActive = true;
    isSurgeryDragging = false;

    const container = document.getElementById('bullet-minigame-container');
    const area = document.getElementById('extraction-canvas-area');
    const canvas = document.getElementById('extraction-canvas');
    const bullet = document.getElementById('extraction-bullet');
    const exitTarget = document.getElementById('extraction-target');

    if (!container || !area || !canvas || !bullet) return;

    container.classList.remove('hidden');

    const rect = area.getBoundingClientRect();
    canvas.width = rect.width || 650;
    canvas.height = rect.height || 400;
    const ctx = canvas.getContext('2d');

    const relPoints = [
      { x: 0.08, y: 0.1 },
      { x: 0.25, y: 0.24 },
      { x: 0.18, y: 0.55 },
      { x: 0.46, y: 0.45 },
      { x: 0.68, y: 0.35 },
      { x: 0.6, y: 0.74 },
      { x: 0.92, y: 0.88 }
    ];

    const points = relPoints.map(p => ({
      x: p.x * canvas.width,
      y: p.y * canvas.height
    }));

    function drawPath() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const wallGrd = ctx.createRadialGradient(canvas.width / 2, canvas.height / 2, 40, canvas.width / 2, canvas.height / 2, canvas.width);
      wallGrd.addColorStop(0, '#4a0808');
      wallGrd.addColorStop(1, '#1e0202');
      ctx.fillStyle = wallGrd;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // Border wall
      ctx.beginPath();
      ctx.lineWidth = Math.min(Math.max(canvas.width * 0.16, 80), 140);
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.strokeStyle = '#380000';
      ctx.moveTo(points[0].x, points[0].y);
      for (let i = 1; i < points.length; i++) ctx.lineTo(points[i].x, points[i].y);
      ctx.stroke();

      // Safe arterial lumen
      ctx.beginPath();
      ctx.lineWidth = Math.min(Math.max(canvas.width * 0.11, 58), 100);
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.strokeStyle = '#e11d48';
      ctx.moveTo(points[0].x, points[0].y);
      for (let i = 1; i < points.length; i++) ctx.lineTo(points[i].x, points[i].y);
      ctx.stroke();

      // Highlights
      ctx.strokeStyle = 'rgba(255, 120, 120, 0.22)';
      ctx.lineWidth = Math.min(Math.max(canvas.width * 0.06, 30), 65);
      ctx.stroke();
    }

    drawPath();

    const startX = 0.08 * canvas.width - 25;
    const startY = 0.1 * canvas.height - 25;
    bullet.style.left = startX + 'px';
    bullet.style.top = startY + 'px';

    exitTarget.style.left = (0.92 * canvas.width - exitTarget.offsetWidth / 2) + 'px';
    exitTarget.style.top = (0.88 * canvas.height - exitTarget.offsetHeight / 2) + 'px';

    function checkCollision(x, y) {
      const cx = Math.floor(x + 25);
      const cy = Math.floor(y + 25);
      if (cx < 0 || cx >= canvas.width || cy < 0 || cy >= canvas.height) return true;
      const pixel = ctx.getImageData(cx, cy, 1, 1).data;
      return pixel[0] < 115;
    }

    let dragOffset = { x: 0, y: 0 };

    bullet.onmousedown = (e) => {
      if (!isSurgeryActive) return;
      e.preventDefault();
      isSurgeryDragging = true;
      bullet.classList.add('dragging');
      const bRect = bullet.getBoundingClientRect();
      dragOffset.x = e.clientX - bRect.left;
      dragOffset.y = e.clientY - bRect.top;
    };

    function onMouseMove(e) {
      if (!isSurgeryDragging || !isSurgeryActive) return;
      e.preventDefault();

      const aRect = area.getBoundingClientRect();
      const x = e.clientX - aRect.left - dragOffset.x;
      const y = e.clientY - aRect.top - dragOffset.y;

      if (checkCollision(x, y)) {
        isSurgeryDragging = false;
        bullet.classList.remove('dragging');
        bullet.style.left = startX + 'px';
        bullet.style.top = startY + 'px';
        area.style.borderColor = 'rgba(244, 63, 94, 0.9)';
        setTimeout(() => { area.style.borderColor = 'rgba(244, 63, 94, 0.35)'; }, 200);
        return;
      }

      bullet.style.left = x + 'px';
      bullet.style.top = y + 'px';

      const exitX = 0.92 * canvas.width;
      const exitY = 0.88 * canvas.height;
      if (Math.hypot(x + 25 - exitX, y + 25 - exitY) < canvas.width * 0.08) {
        closeBulletMinigame(true);
      }
    }

    function onMouseUp() {
      isSurgeryDragging = false;
      bullet.classList.remove('dragging');
    }

    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    window.bulletCleanup = () => {
      bullet.onmousedown = null;
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }

  function closeBulletMinigame(success) {
    isSurgeryActive = false;
    isSurgeryDragging = false;
    const container = document.getElementById('bullet-minigame-container');
    if (container) container.classList.add('hidden');

    if (window.bulletCleanup) {
      window.bulletCleanup();
      window.bulletCleanup = null;
    }

    postNUI('bulletMinigameResult', {
      success: !!success,
      targetSrc: bulletTargetSrc,
      part: bulletBone
    });
  }

  // 4. Blood Pressure Monitor Minigame
  let isBPActive = false;
  let isBPDragging = false;
  let bpTargetSrc = null;
  let bpBone = null;

  function updateBPTube() {
    if (!isBPActive) return;
    const machine = document.getElementById('bp-machine-display');
    const cuff = document.getElementById('bp-cuff-item');
    if (!machine || !cuff) return;

    const mRect = machine.getBoundingClientRect();
    const cRect = cuff.getBoundingClientRect();

    const x1 = mRect.left + mRect.width / 2;
    const y1 = mRect.top + mRect.height * 0.85;

    const x2 = cRect.left + cRect.width / 2;
    const y2 = cRect.top + cRect.height / 2;

    const curveOffset = window.innerHeight * 0.15;
    const pathData = `M ${x1} ${y1} C ${x1} ${y1 + curveOffset}, ${x2} ${y2 + curveOffset}, ${x2} ${y2}`;

    document.getElementById('bp-tube-base').setAttribute('d', pathData);
    document.getElementById('bp-tube-main').setAttribute('d', pathData);
    document.getElementById('bp-tube-highlight').setAttribute('d', pathData);
  }

  function startBPMinigame(targetSrc, bone) {
    bpTargetSrc = targetSrc;
    bpBone = bone || 'rightArm';
    isBPActive = true;
    isBPDragging = false;

    const container = document.getElementById('bp-minigame-container');
    const cuff = document.getElementById('bp-cuff-item');
    const target = document.getElementById('bp-target-zone');
    const values = document.getElementById('bp-values');

    if (!container || !cuff || !target) return;

    container.classList.remove('hidden');
    cuff.style.display = 'block';

    const w = window.innerWidth;
    const h = window.innerHeight;
    const cuffW = cuff.offsetWidth || 280;
    const cuffH = cuff.offsetHeight || 280;

    const startX = w / 2 - cuffW / 2;
    const startY = h * 0.72 - cuffH / 2;

    cuff.style.left = startX + 'px';
    cuff.style.top = startY + 'px';
    cuff.style.transform = 'rotate(148deg)';

    document.getElementById('systolic').innerText = '--';
    document.getElementById('diastolic').innerText = '--';
    document.getElementById('pulse-rate').innerText = '--';
    values.style.opacity = '0';

    setTimeout(updateBPTube, 100);

    let dragOffset = { x: 0, y: 0 };

    cuff.onmousedown = (e) => {
      if (!isBPActive) return;
      isBPDragging = true;
      const cRect = cuff.getBoundingClientRect();
      dragOffset.x = e.clientX - cRect.left;
      dragOffset.y = e.clientY - cRect.top;
    };

    function onMouseMove(e) {
      if (!isBPDragging || !isBPActive) return;
      const x = e.clientX - dragOffset.x;
      const y = e.clientY - dragOffset.y;

      cuff.style.left = x + 'px';
      cuff.style.top = y + 'px';
      updateBPTube();

      const tRect = target.getBoundingClientRect();
      const dist = Math.hypot(x - tRect.left, y - tRect.top);
      if (dist < 100) {
        target.style.background = 'rgba(16, 185, 129, 0.45)';
        target.style.borderColor = 'var(--lation-emerald)';
      } else {
        target.style.background = 'rgba(6, 182, 212, 0.2)';
        target.style.borderColor = 'rgba(6, 182, 212, 0.7)';
      }
    }

    function onMouseUp() {
      if (!isBPDragging || !isBPActive) return;
      isBPDragging = false;

      const cRect = cuff.getBoundingClientRect();
      const tRect = target.getBoundingClientRect();
      const dist = Math.hypot(cRect.left - tRect.left, cRect.top - tRect.top);

      if (dist < 120) {
        cuff.style.left = tRect.left + 'px';
        cuff.style.top = tRect.top + 'px';
        updateBPTube();
        finishBPMeasurement();
      } else {
        cuff.style.left = startX + 'px';
        cuff.style.top = startY + 'px';
        updateBPTube();
      }
    }

    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    window.bpCleanup = () => {
      cuff.onmousedown = null;
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }

  function finishBPMeasurement() {
    const sys = Math.floor(Math.random() * (135 - 110) + 110);
    const dia = Math.floor(Math.random() * (85 - 70) + 70);
    const pulse = Math.floor(Math.random() * (85 - 65) + 65);

    setTimeout(() => {
      document.getElementById('systolic').innerText = sys;
      document.getElementById('diastolic').innerText = dia;
      document.getElementById('pulse-rate').innerText = `${pulse} BPM`;
      document.getElementById('bp-values').style.opacity = '1';

      setTimeout(() => {
        closeBPMinigame(true, { sys, dia, pulse });
      }, 3500);
    }, 1000);
  }

  function closeBPMinigame(success, vitals) {
    isBPActive = false;
    isBPDragging = false;
    const container = document.getElementById('bp-minigame-container');
    if (container) container.classList.add('hidden');

    if (window.bpCleanup) {
      window.bpCleanup();
      window.bpCleanup = null;
    }

    postNUI('bpMinigameResult', {
      success: !!success,
      targetSrc: bpTargetSrc,
      part: bpBone,
      vitals: vitals || null
    });
  }

  // 5. Trauma Dressing Minigame
  let currentDressingStep = 1;
  let activeTool = null;
  let woundCleanliness = 0;
  let tapeCount = 0;
  let dressingTargetSrc = null;
  let dressingBone = null;
  let isBandageActive = false;

  function startBandageMinigame(targetSrc, bone) {
    dressingTargetSrc = targetSrc;
    dressingBone = bone || 'torso';
    currentDressingStep = 1;
    activeTool = null;
    woundCleanliness = 0;
    tapeCount = 0;
    isBandageActive = true;

    const container = document.getElementById('bandage-minigame-container');
    const area = document.getElementById('dressing-canvas-area');
    const canvas = document.getElementById('dressing-base-canvas');
    const limbBox = document.getElementById('limb-visual-container');

    if (!container || !area || !canvas) return;

    container.classList.remove('hidden');

    // Reset UI
    document.querySelectorAll('.step-indicator').forEach(el => el.classList.remove('active', 'complete'));
    document.getElementById('step-clean').classList.add('active');

    document.querySelectorAll('.tool-item').forEach(el => el.classList.add('disabled', 'active'));
    const swab = document.getElementById('tool-swab');
    swab.classList.remove('disabled', 'active');

    document.getElementById('gauze-target').classList.add('hidden');
    document.getElementById('placed-gauze').classList.add('hidden');
    document.getElementById('bandage-finish-btn').classList.add('hidden');
    document.getElementById('tape-container').innerHTML = '';
    document.getElementById('dressing-instruction').innerText = 'Selecione o ANTISSÉPTICO para higienizar a lesão.';

    const rect = area.getBoundingClientRect();
    canvas.width = rect.width || window.innerWidth;
    canvas.height = rect.height || window.innerHeight;
    const ctx = canvas.getContext('2d');

    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    const targetGauze = document.getElementById('gauze-target');
    const placedGauze = document.getElementById('placed-gauze');
    targetGauze.style.left = centerX + 'px';
    targetGauze.style.top = centerY + 'px';
    placedGauze.style.left = centerX + 'px';
    placedGauze.style.top = centerY + 'px';

    const limbW = Math.min(canvas.width * 0.32, 420);
    const limbH = Math.min(canvas.height * 0.72, 800);
    const woundScale = limbW / 260;

    function drawLimb() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const limbX = centerX - limbW / 2;
      const limbY = centerY - limbH / 2;
      const limbRadius = limbW * 0.12;

      const limbGrd = ctx.createLinearGradient(limbX, centerY, limbX + limbW, centerY);
      limbGrd.addColorStop(0, '#8d5543');
      limbGrd.addColorStop(0.3, '#d3a68d');
      limbGrd.addColorStop(0.7, '#d3a68d');
      limbGrd.addColorStop(1, '#8d5543');
      ctx.fillStyle = limbGrd;

      ctx.beginPath();
      ctx.roundRect(limbX, limbY, limbW, limbH, limbRadius);
      ctx.fill();

      // Bruising & Wound
      const dirtOpacity = 1 - woundCleanliness / 100;
      const bruiseGrd = ctx.createRadialGradient(centerX, centerY, 10 * woundScale, centerX, centerY, 90 * woundScale);
      bruiseGrd.addColorStop(0, `rgba(80, 0, 40, ${0.4 + 0.1 * dirtOpacity})`);
      bruiseGrd.addColorStop(0.5, `rgba(50, 0, 80, ${0.2 + 0.1 * dirtOpacity})`);
      bruiseGrd.addColorStop(1, 'rgba(0, 0, 0, 0)');
      ctx.fillStyle = bruiseGrd;
      ctx.beginPath();
      ctx.ellipse(centerX, centerY, 80 * woundScale, 110 * woundScale, 0, 0, Math.PI * 2);
      ctx.fill();

      ctx.fillStyle = 'rgba(50, 0, 0, 0.9)';
      ctx.beginPath();
      ctx.ellipse(centerX, centerY, 22 * woundScale, 42 * woundScale, 0.2, 0, Math.PI * 2);
      ctx.fill();
    }

    drawLimb();

    const cursor = document.getElementById('active-tool-cursor');

    function onMouseMove(e) {
      if (!isBandageActive) return;
      const rect = area.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      if (activeTool) {
        cursor.style.left = (e.clientX - 35) + 'px';
        cursor.style.top = (e.clientY - 35) + 'px';
        cursor.classList.remove('hidden');
      } else {
        cursor.classList.add('hidden');
      }

      // Step 1 scrubbing
      if (currentDressingStep === 1 && activeTool === 'swab' && e.buttons === 1) {
        const dist = Math.hypot(x - centerX, y - centerY);
        if (dist < 90 * woundScale) {
          cursor.classList.add('scrubbing');
          woundCleanliness = Math.min(100, woundCleanliness + 3);

          // Spawn foam bubble
          const foam = document.createElement('div');
          foam.className = 'foam-layer';
          foam.style.left = (x - 12) + 'px';
          foam.style.top = (y - 12) + 'px';
          foam.style.width = '24px';
          foam.style.height = '24px';
          limbBox.appendChild(foam);
          setTimeout(() => foam.remove(), 700);

          drawLimb();
          if (woundCleanliness >= 100) {
            cursor.classList.remove('scrubbing');
            completeStep1();
          }
        }
      }
    }

    function onMouseDown(e) {
      if (!isBandageActive) return;
      const rect = area.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      if (currentDressingStep === 2 && activeTool === 'gauze') {
        const dist = Math.hypot(x - centerX, y - centerY);
        if (dist < 80) {
          completeStep2();
        }
      } else if (currentDressingStep === 3 && activeTool === 'tape') {
        placeTape(x, y);
      }
    }

    // Tool click
    document.querySelectorAll('.tool-item').forEach(el => {
      el.onclick = () => {
        const step = parseInt(el.dataset.step, 10);
        if (step !== currentDressingStep || el.classList.contains('disabled')) return;

        document.querySelectorAll('.tool-item').forEach(t => t.classList.remove('active'));
        el.classList.add('active');
        activeTool = el.id.split('-')[1];

        if (activeTool === 'swab') {
          cursor.innerHTML = '<img src="img/cotton.png" style="width:50px;height:50px;object-fit:contain;" alt="Swab">';
        } else if (activeTool === 'gauze') {
          cursor.innerHTML = '<i class="fas fa-layer-group" style="color:var(--lation-cyan)"></i>';
          document.getElementById('gauze-target').classList.remove('hidden');
        } else if (activeTool === 'tape') {
          cursor.innerHTML = '<i class="fas fa-tape" style="color:#fde047"></i>';
        }
      };
    });

    area.addEventListener('mousemove', onMouseMove);
    area.addEventListener('mousedown', onMouseDown);

    window.bandageCleanup = () => {
      area.removeEventListener('mousemove', onMouseMove);
      area.removeEventListener('mousedown', onMouseDown);
    };
  }

  function completeStep1() {
    currentDressingStep = 2;
    activeTool = null;
    document.getElementById('step-clean').classList.remove('active');
    document.getElementById('step-clean').classList.add('complete');
    document.getElementById('step-apply').classList.add('active');

    document.getElementById('tool-swab').classList.add('disabled');
    document.getElementById('tool-swab').classList.remove('active');
    document.getElementById('tool-gauze').classList.remove('disabled');
    document.getElementById('active-tool-cursor').classList.add('hidden');
    document.getElementById('dressing-instruction').innerHTML = '<i class="fas fa-check-circle" style="color:var(--lation-emerald)"></i> ÁREA ESTERILIZADA! Selecione e posicione a GAZE.';
  }

  function completeStep2() {
    currentDressingStep = 3;
    activeTool = null;
    document.getElementById('step-apply').classList.remove('active');
    document.getElementById('step-apply').classList.add('complete');
    document.getElementById('step-secure').classList.add('active');

    document.getElementById('tool-gauze').classList.add('disabled');
    document.getElementById('tool-gauze').classList.remove('active');
    document.getElementById('tool-tape').classList.remove('disabled');

    document.getElementById('gauze-target').classList.add('hidden');
    document.getElementById('placed-gauze').classList.remove('hidden');
    document.getElementById('active-tool-cursor').classList.add('hidden');
    document.getElementById('dressing-instruction').innerHTML = '<i class="fas fa-tape" style="color:#fde047"></i> GAZE APLICADA! Selecione a FITA para fixar as 4 bordas.';
  }

  function placeTape() {
    tapeCount++;
    const area = document.getElementById('dressing-canvas-area');
    const centerX = area.offsetWidth / 2;
    const centerY = area.offsetHeight / 2;

    const gauze = document.getElementById('placed-gauze');
    const gW = gauze.offsetWidth || 180;
    const gH = gauze.offsetHeight || 180;

    let top = centerY, left = centerX, width = gW + 20, rotate = 0;

    if (tapeCount === 1) { // Top
      top = centerY - gH / 2;
      left = centerX;
      rotate = 0;
    } else if (tapeCount === 2) { // Bottom
      top = centerY + gH / 2;
      left = centerX;
      rotate = 0;
    } else if (tapeCount === 3) { // Left
      top = centerY;
      left = centerX - gW / 2;
      width = gH + 20;
      rotate = 90;
    } else if (tapeCount === 4) { // Right
      top = centerY;
      left = centerX + gW / 2;
      width = gH + 20;
      rotate = 90;
    }

    const tape = document.createElement('div');
    tape.className = 'tape-strip';
    tape.style.top = top + 'px';
    tape.style.left = left + 'px';
    tape.style.width = width + 'px';
    tape.style.transform = `translate(-50%, -50%) rotate(${rotate}deg)`;
    document.getElementById('tape-container').appendChild(tape);

    if (tapeCount >= 4) {
      document.getElementById('step-secure').classList.remove('active');
      document.getElementById('step-secure').classList.add('complete');
      document.getElementById('tool-tape').classList.add('disabled');
      document.getElementById('active-tool-cursor').classList.add('hidden');
      document.getElementById('bandage-finish-btn').classList.remove('hidden');
      document.getElementById('dressing-instruction').innerText = 'Procedimento completo! Clique para concluir.';
    }
  }

  window.finishDressingProcedure = function() {
    closeBandageMinigame(true);
  };

  function closeBandageMinigame(success) {
    isBandageActive = false;
    const container = document.getElementById('bandage-minigame-container');
    if (container) container.classList.add('hidden');

    if (window.bandageCleanup) {
      window.bandageCleanup();
      window.bandageCleanup = null;
    }

    postNUI('bandageMinigameResult', {
      success: !!success,
      targetSrc: dressingTargetSrc,
      part: dressingBone
    });
  }

  // 6. Digital Breathalyzer Device
  let isBreathActive = false;
  let isBreathPlayer = false;
  let breathOfficerId = null;
  let breathPos = 0;
  let breathProgress = 0;
  let isKeyEHeld = false;
  let breathLoopTimer = null;
  let lastSyncTime = 0;

  function openBreathalyzer(officerId, isPlayer) {
    breathOfficerId = officerId;
    isBreathPlayer = !!isPlayer;
    isBreathActive = true;
    isKeyEHeld = false;
    breathProgress = 0;
    breathPos = 0;

    const view = document.getElementById('breathalyzer-view');
    const screen = document.getElementById('breath-screen');
    const status = document.getElementById('breath-status');
    const val = document.getElementById('breath-value');
    const minigame = document.getElementById('breath-minigame');
    const clickZone = document.getElementById('mouthpiece-click');

    if (!view || !screen) return;

    view.classList.remove('hidden');
    screen.classList.remove('hidden');
    screen.classList.remove('screen-error', 'screen-success');

    status.innerText = isPlayer ? 'CLIQUE NA BOQUILHA P/ ASSOPRAR' : 'AGUARDANDO CONDUTOR...';
    status.style.color = '#fff';
    val.innerText = '0.00%';
    minigame.classList.add('hidden');

    if (isPlayer) {
      clickZone.classList.remove('hidden');
    } else {
      clickZone.classList.add('hidden');
      minigame.classList.remove('hidden');
    }
  }

  window.startBreathalyzerMinigame = function() {
    if (!isBreathPlayer) return;

    document.getElementById('mouthpiece-click').classList.add('hidden');
    document.getElementById('breath-status').innerText = 'SOPRANDO... MANTENHA NO VERDE';
    document.getElementById('breath-minigame').classList.remove('hidden');

    startBreathLoop();
  };

  function updateBreathUI(progress, pos) {
    const indicator = document.getElementById('breath-indicator');
    const status = document.getElementById('breath-status');
    if (indicator) indicator.style.left = pos + '%';

    if (pos >= 40 && pos <= 60) {
      if (status) status.style.color = 'var(--lation-emerald)';
    } else {
      if (status) status.style.color = 'var(--lation-amber)';
    }
  }

  function startBreathLoop() {
    if (breathLoopTimer) cancelAnimationFrame(breathLoopTimer);

    function loop(time) {
      if (!isBreathActive) return;

      if (isKeyEHeld) {
        breathPos += 1.3;
      } else {
        breathPos -= 0.9;
      }

      if (breathPos < 0) breathPos = 0;
      if (breathPos > 100) breathPos = 100;

      updateBreathUI(breathProgress, breathPos);

      if (time - lastSyncTime > 100) {
        postNUI('syncBreathProgress', {
          officerId: breathOfficerId,
          progress: breathProgress,
          indicatorPos: breathPos
        });
        lastSyncTime = time;
      }

      if (breathPos >= 40 && breathPos <= 60) {
        breathProgress += 0.45;
      }

      if (breathProgress >= 100) {
        isBreathActive = false;
        postNUI('breathalyzerComplete', {
          officerId: breathOfficerId,
          success: true
        });
        return;
      }

      breathLoopTimer = requestAnimationFrame(loop);
    }

    breathLoopTimer = requestAnimationFrame(loop);
  }

  function finishBreathalyzer(success, bacResult) {
    isBreathActive = false;
    if (breathLoopTimer) cancelAnimationFrame(breathLoopTimer);

    const screen = document.getElementById('breath-screen');
    const status = document.getElementById('breath-status');
    const val = document.getElementById('breath-value');

    document.getElementById('breath-minigame').classList.add('hidden');

    if (success) {
      status.innerText = 'PROCESSANDO AMOSTRA...';
      setTimeout(() => {
        const bac = parseFloat(bacResult || 0).toFixed(2);
        val.innerText = bac + '%';

        if (parseFloat(bac) > 0.08) {
          status.innerText = 'ACIMA DO LIMITE LEGAL!';
          screen.classList.add('screen-error');
        } else {
          status.innerText = 'DENTRO DO LIMITE LEGAL';
          screen.classList.add('screen-success');
        }

        setTimeout(closeBreathalyzerUI, 4500);
      }, 1200);
    } else {
      status.innerText = 'AMOSTRA INSUFICIENTE / RECUSA';
      screen.classList.add('screen-error');
      setTimeout(closeBreathalyzerUI, 2000);
    }
  }

  function closeBreathalyzerUI() {
    const view = document.getElementById('breathalyzer-view');
    if (view) view.classList.add('hidden');
    isBreathActive = false;
    isKeyEHeld = false;
    postNUI('closeBreathalyzer');
  }

  // Key handlers for [E] hold in breathalyzer
  window.addEventListener('keydown', (e) => {
    if (e.key.toLowerCase() === 'e') {
      isKeyEHeld = true;
    }
  });

  window.addEventListener('keyup', (e) => {
    if (e.key.toLowerCase() === 'e') {
      isKeyEHeld = false;
    }
  });

  // 7. Staff Magnetic Card Swipe Minigame
  let isSwiping = false;
  let swipeStartX = 0;
  let swipeSuccess = false;

  function startSwipeMinigame() {
    const container = document.getElementById('swipe-card-container');
    const cardBox = document.getElementById('swipe-card-box');
    const status = document.getElementById('swipe-status');

    if (!container || !cardBox || !status) return;

    swipeSuccess = false;
    isSwiping = false;

    status.innerText = 'AGUARDANDO LEITURA...';
    status.className = 'swipe-status';
    cardBox.style.left = '20px';
    cardBox.style.transition = 'none';

    container.classList.remove('hidden');

    cardBox.onmousedown = (e) => {
      if (swipeSuccess) return;
      e.preventDefault();
      isSwiping = true;
      swipeStartX = e.clientX - cardBox.offsetLeft;
      cardBox.style.transition = 'none';
    };

    function onMouseMove(e) {
      if (!isSwiping || swipeSuccess) return;
      let x = e.clientX - swipeStartX;
      if (x < 20) x = 20;
      if (x > 900) x = 900;
      cardBox.style.left = x + 'px';

      if (x > 840) {
        finishSwipe(true);
      }
    }

    function onMouseUp() {
      if (!isSwiping || swipeSuccess) return;
      isSwiping = false;
      const x = parseInt(cardBox.style.left, 10) || 0;
      if (x < 840) {
        finishSwipe(false);
      }
    }

    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);

    window.swipeCleanup = () => {
      cardBox.onmousedown = null;
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }

  function finishSwipe(success) {
    isSwiping = false;
    const cardBox = document.getElementById('swipe-card-box');
    const status = document.getElementById('swipe-status');
    const container = document.getElementById('swipe-card-container');

    if (success) {
      swipeSuccess = true;
      status.innerText = 'ACESSO AUTORIZADO';
      status.className = 'swipe-status success';
      cardBox.style.left = '900px';
      cardBox.style.transition = 'left 0.2s';

      setTimeout(() => {
        container.classList.add('hidden');
        if (window.swipeCleanup) window.swipeCleanup();
        postNUI('swipeSuccess', { success: true });
      }, 900);
    } else {
      status.innerText = 'LEITURA INVÁLIDA - DESLIZE ATÉ O FINAL';
      status.className = 'swipe-status error';
      cardBox.style.transition = 'left 0.3s';
      cardBox.style.left = '20px';

      setTimeout(() => {
        if (!swipeSuccess) {
          status.innerText = 'AGUARDANDO LEITURA...';
          status.className = 'swipe-status';
        }
      }, 1000);
    }
  }

  window.closeSwipeMinigame = function() {
    const container = document.getElementById('swipe-card-container');
    if (container) container.classList.add('hidden');
    if (window.swipeCleanup) window.swipeCleanup();
    postNUI('closeSwipe');
  };

  // Global Keydown (Escape to close any active modal or minigame)
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (isSutureActive) closeSutureMinigame(false);
      if (isClampActive) closeClampMinigame(false);
      if (isSurgeryActive) closeBulletMinigame(false);
      if (isBPActive) closeBPMinigame(false);
      if (isBandageActive) closeBandageMinigame(false);
      if (isBreathActive) closeBreathalyzerUI();
      const swipeCont = document.getElementById('swipe-card-container');
      if (swipeCont && !swipeCont.classList.contains('hidden')) {
        window.closeSwipeMinigame();
      }
      if (isCreationOpen || isViewOpen) {
        closeAllModals();
      }
    }
  });

  // Comprehensive NUI Message Listener
  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;

    const action = data.action || data.event;

    // Prescriptions
    if (action === 'load_config') {
      if (Array.isArray(data.medicine)) Config.medicines = data.medicine;
      if (data.locale) Config.locale = data.locale;
      if (data.style) Config.style = data.style;
    } else if (action === 'open_nui') {
      openCreationUI();
    } else if (action === 'show_prescription') {
      openViewerUI(data.prescription, data.date);
    } else if (action === 'close_nui') {
      creationModal.classList.remove('active');
      viewerModal.classList.remove('active');
      isCreationOpen = false;
      isViewOpen = false;
    }

    // Minigames Dispatch
    else if (action === 'amb_startSutureMinigame' || action === 'loki:startSuture') {
      startSutureMinigame(data.targetSrc, data.part);
    } else if (action === 'amb_startClampMinigame' || action === 'loki:startClamp') {
      startClampMinigame(data.targetSrc, data.part);
    } else if (action === 'amb_startBulletMinigame' || action === 'loki:startBullet') {
      startBulletMinigame(data.targetSrc, data.part);
    } else if (action === 'amb_startBPMinigame' || action === 'loki:startBP') {
      startBPMinigame(data.targetSrc, data.part);
    } else if (action === 'amb_startBandageMinigame' || action === 'loki:startBandage') {
      startBandageMinigame(data.targetSrc, data.part);
    } else if (action === 'openBreathalyzer' || action === 'loki:openBreathalyzer') {
      openBreathalyzer(data.officerId, data.isPlayer);
    } else if (action === 'syncBreathProgress') {
      if (!isBreathPlayer) {
        updateBreathUI(data.progress, data.indicatorPos);
      }
    } else if (action === 'showBreathResult') {
      finishBreathalyzer(true, data.result);
    } else if (action === 'startSwipeMinigame' || action === 'loki:startSwipe') {
      startSwipeMinigame();
    }
  });

  // Request config from server on startup
  postNUI('load_config');
})();

