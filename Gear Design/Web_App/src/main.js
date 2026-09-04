/**
 * MAIN APPLICATION CONTROLLER — GEAR MASTER SUITE
 * Connects parameters, geometric calculations, 3D viewer, 2D canvas,
 * and direct in-browser CAD file exporters.
 *
 * Author: Ahmed Majdy Ahmed
 */

import {
  calculateGearDesign,
  buildBevelMesh,
  calculateSpurDesign,
  buildSpurMesh,
  calculateInternalSpurDesign,
  buildInternalRingMesh,
  calculateStraightBevelDesign,
  calculateSpiralBevelDesign,
  buildSpiralBevelMesh,
  calculateHelicalDesign,
  buildHelicalMesh,
  MATERIAL_PRESETS
} from './engine/gearGeometry.js';
import {
  downloadFile,
  exportSTLBinary,
  exportSTEP,
  exportIGES,
  exportSolidWorksMacro,
  exportSolidWorksEquations,
  exportDesignReportCSV,
  createCompleteCADZip,
  exportSTEPZip,
  exportSTLZip,
  exportIGESZip,
  exportSolidWorksZip,
  exportAssemblySTEP,
  exportAssemblySTLBinary
} from './engine/cadExporters.js';
import { GearViewer3D } from './viz/viewer3d.js';
import { GearPlot2D } from './viz/plot2d.js';

// Application State
let currentCalc = null;
let currentPinionMesh = null;
let currentGearMesh = null;
let activeTab = '3d';
let isAnimatingMotion = false;
let viewer3D = null;
let plot2D = null;
let updateTimer = null;

// Design Presets
const PRESETS = {
  // Zerol Bevel Presets
  'standard-16-48': { gear_type: 'zerol-bevel', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, f_factor: 0.28, F: 21.25, T_in_ring: 20, n_in_ring: 100 },
  'compact-18-36': { gear_type: 'zerol-bevel', m: 2.5, Np: 18, Ng: 36, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, f_factor: 0.28, F: 18.0, T_in_ring: 15, n_in_ring: 150 },
  'high-reduction-12-60': { gear_type: 'zerol-bevel', m: 3.5, Np: 12, Ng: 60, phi_deg: 22.5, Sigma_deg: 90, n_pinions: 3, f_factor: 0.30, F: 26.0, T_in_ring: 30, n_in_ring: 80 },
  'heavy-duty-20-60': { gear_type: 'zerol-bevel', m: 4.0, Np: 20, Ng: 60, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, f_factor: 0.28, F: 35.0, T_in_ring: 50, n_in_ring: 60 },

  // Spur Gear Presets
  'spur-standard-16-48': { gear_type: 'spur', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 25.0, T_in_ring: 20, n_in_ring: 100 },
  'spur-high-speed-18-54': { gear_type: 'spur', m: 2.5, Np: 18, Ng: 54, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 22.0, T_in_ring: 18, n_in_ring: 120 },
  'spur-heavy-duty-20-60': { gear_type: 'spur', m: 4.0, Np: 20, Ng: 60, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 35.0, T_in_ring: 45, n_in_ring: 80 },

  // Internal Spur Presets
  'internal-standard-16-48': { gear_type: 'internal_spur', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 25.0, T_in_ring: 20, n_in_ring: 100 },
  'internal-compact-18-54': { gear_type: 'internal_spur', m: 2.5, Np: 18, Ng: 54, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 22.0, T_in_ring: 18, n_in_ring: 120 },
  'internal-high-ratio-16-64': { gear_type: 'internal_spur', m: 3.0, Np: 16, Ng: 64, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 30.0, T_in_ring: 30, n_in_ring: 80 },

  // Straight Bevel Presets
  'straight-standard-16-48': { gear_type: 'straight-bevel', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, F: 25.0, T_in_ring: 20, n_in_ring: 100 },
  'straight-compact-18-36': { gear_type: 'straight-bevel', m: 2.5, Np: 18, Ng: 36, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, F: 18.0, T_in_ring: 15, n_in_ring: 150 },
  'straight-high-ratio-12-60': { gear_type: 'straight-bevel', m: 3.5, Np: 12, Ng: 60, phi_deg: 20, Sigma_deg: 90, n_pinions: 3, F: 26.0, T_in_ring: 30, n_in_ring: 80 },

  // Helical Presets
  'helical-standard-16-48': { gear_type: 'helical', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, tooth_angle_deg: 15.0, Sigma_deg: 0, n_pinions: 3, F: 40.0, T_in_ring: 20, n_in_ring: 100 },
  'helical-compact-18-36': { gear_type: 'helical', m: 2.5, Np: 18, Ng: 36, phi_deg: 20, tooth_angle_deg: 20.0, Sigma_deg: 0, n_pinions: 3, F: 30.0, T_in_ring: 15, n_in_ring: 150 },
  'helical-high-ratio-12-60': { gear_type: 'helical', m: 3.0, Np: 12, Ng: 60, phi_deg: 20, tooth_angle_deg: 15.0, Sigma_deg: 0, n_pinions: 3, F: 45.0, T_in_ring: 30, n_in_ring: 80 },

  // Spiral Bevel Presets (Gleason 90 deg)
  'spiral-standard-16-48': { gear_type: 'spiral-bevel', m: 3.0, Np: 16, Ng: 48, phi_deg: 20, tooth_angle_deg: 35.0, Sigma_deg: 90, n_pinions: 3, F: 25.0, T_in_ring: 20, n_in_ring: 100 },
  'spiral-compact-18-36': { gear_type: 'spiral-bevel', m: 2.5, Np: 18, Ng: 36, phi_deg: 20, tooth_angle_deg: 35.0, Sigma_deg: 90, n_pinions: 3, F: 20.0, T_in_ring: 15, n_in_ring: 150 },
  'spiral-high-ratio-12-60': { gear_type: 'spiral-bevel', m: 3.0, Np: 12, Ng: 60, phi_deg: 20, tooth_angle_deg: 35.0, Sigma_deg: 90, n_pinions: 3, F: 28.0, T_in_ring: 30, n_in_ring: 80 }
};

// =========================================================================
// UI Notifications
// =========================================================================

function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'toast';

  const indicator = document.createElement('span');
  indicator.className = `toast-indicator toast-indicator--${type}`;

  const text = document.createElement('span');
  text.textContent = message;

  toast.appendChild(indicator);
  toast.appendChild(text);
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    toast.style.transition = 'all 0.3s';
    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 300);
  }, 3500);
}

// =========================================================================
// Read Inputs & Gear Type Handler
// =========================================================================

function handleGearTypeChange(gearType) {
  const isCylindrical = gearType === 'spur' || gearType === 'internal_spur' || gearType === 'helical';
  const isStraight = gearType === 'straight-bevel';
  const isSpiral = gearType === 'spiral-bevel';
  const isHelical = gearType === 'helical';
  const rowShaft = document.getElementById('row-shaft-angle');
  const rowFaceFactor = document.getElementById('row-face-factor');
  const rowFaceMm = document.getElementById('row-face-mm');
  const rowHelixAngle = document.getElementById('row-helix-angle');

  if (rowShaft) rowShaft.style.display = isCylindrical ? 'none' : 'flex';
  if (rowFaceFactor) rowFaceFactor.style.display = (isCylindrical || isStraight || isSpiral) ? 'none' : 'flex';
  if (rowFaceMm) rowFaceMm.style.display = (isCylindrical || isStraight || isSpiral) ? 'flex' : 'none';
  if (rowHelixAngle) rowHelixAngle.style.display = (isHelical || isSpiral) ? 'flex' : 'none';

  const inpHlx = document.getElementById('inp-helix-angle');
  if (inpHlx) {
    if (isSpiral && parseFloat(inpHlx.value) < 25) {
      inpHlx.value = '35.0';
    } else if (isHelical && parseFloat(inpHlx.value) > 30) {
      inpHlx.value = '15.0';
    }
  }

  const inpFilename = document.getElementById('inp-filename');
  if (inpFilename) {
    if (gearType === 'internal_spur') inpFilename.value = 'Internal_Spur_Pitch_Drive';
    else if (gearType === 'spur') inpFilename.value = 'Spur_Gear_Pitch_Drive';
    else if (gearType === 'straight-bevel') inpFilename.value = 'Straight_Bevel_Pitch_Drive';
    else if (gearType === 'helical') inpFilename.value = 'Helical_Pitch_Drive';
    else if (gearType === 'spiral-bevel') inpFilename.value = 'Spiral_Bevel_Pitch_Drive';
    else inpFilename.value = 'Zerol_Bevel_Pitch_Drive';
  }

  const badge = document.getElementById('viewport-gear-type');
  if (badge) {
    if (gearType === 'internal_spur') badge.textContent = 'Internal Spur Ring';
    else if (gearType === 'spur') badge.textContent = 'Involute Spur';
    else if (gearType === 'straight-bevel') badge.textContent = 'Straight Bevel';
    else if (gearType === 'helical') badge.textContent = 'Helical Gear';
    else if (gearType === 'spiral-bevel') badge.textContent = 'Spiral Bevel';
    else badge.textContent = 'Zerol Bevel';
  }
}

function getFormInputs() {
  const gearType = document.getElementById('sel-gear-type')?.value || 'zerol-bevel';
  const isCylindrical = gearType === 'spur' || gearType === 'internal_spur' || gearType === 'helical';

  return {
    gear_type: gearType,
    m: parseFloat(document.getElementById('inp-m').value) || 3.0,
    Np: parseInt(document.getElementById('inp-Np').value, 10) || 16,
    Ng: parseInt(document.getElementById('inp-Ng').value, 10) || 48,
    phi_deg: parseFloat(document.getElementById('inp-phi').value) || 20.0,
    tooth_angle_deg: parseFloat(document.getElementById('inp-helix-angle')?.value) || (gearType === 'spiral-bevel' ? 35.0 : 15.0),
    Sigma_deg: isCylindrical ? 0.0 : (parseFloat(document.getElementById('inp-Sigma')?.value) || 90.0),
    n_pinions: parseInt(document.getElementById('inp-pinions').value, 10) || 3,
    f_factor: parseFloat(document.getElementById('inp-f-factor')?.value) || 0.28,
    F: parseFloat(document.getElementById('inp-f-mm')?.value) || 25.0,
    r_cutter: parseFloat(document.getElementById('inp-rc')?.value) || null,
    khw_factor: parseFloat(document.getElementById('inp-khw')?.value) || 2.00,
    c_factor: parseFloat(document.getElementById('inp-c-factor')?.value) || 0.188,
    T_in_ring: parseFloat(document.getElementById('inp-torque').value) || 20.0,
    n_in_ring: parseFloat(document.getElementById('inp-rpm').value) || 100.0,
    eta: parseFloat(document.getElementById('inp-eta').value) || 0.97,
    sigma_allow_bend: parseFloat(document.getElementById('inp-sigma-allow').value) || 40.0,
    print_material: document.getElementById('sel-material').value || 'PLA',
    n_inv: parseInt(document.getElementById('inp-n-inv').value, 10) || 20,
    n_sec: parseInt(document.getElementById('inp-n-sec').value, 10) || 16
  };
}

// =========================================================================
// Apply Preset
// =========================================================================

function applyPreset(presetKey) {
  const p = PRESETS[presetKey];
  if (!p) return;

  if (p.gear_type) {
    const selGear = document.getElementById('sel-gear-type');
    if (selGear) selGear.value = p.gear_type;
    handleGearTypeChange(p.gear_type);
  }

  document.getElementById('inp-m').value = p.m;
  document.getElementById('inp-Np').value = p.Np;
  document.getElementById('inp-Ng').value = p.Ng;
  document.getElementById('inp-phi').value = p.phi_deg;
  if (p.tooth_angle_deg && document.getElementById('inp-helix-angle')) document.getElementById('inp-helix-angle').value = p.tooth_angle_deg;
  if (document.getElementById('inp-Sigma')) document.getElementById('inp-Sigma').value = p.Sigma_deg;
  document.getElementById('inp-pinions').value = p.n_pinions;
  if (p.f_factor && document.getElementById('inp-f-factor')) document.getElementById('inp-f-factor').value = p.f_factor;
  if (p.F && document.getElementById('inp-f-mm')) document.getElementById('inp-f-mm').value = p.F;
  document.getElementById('inp-torque').value = p.T_in_ring;
  document.getElementById('inp-rpm').value = p.n_in_ring;
  if (document.getElementById('inp-rc')) document.getElementById('inp-rc').value = '';

  showToast(`Loaded Preset: ${presetKey.replace(/-/g, ' ')}`, 'info');
  recalculateAndRender();
}

// =========================================================================
// Update Results UI
// =========================================================================

function updateResultsUI(calc) {
  const isInternal = calc.gear_type === 'internal_spur';
  const isSpur = calc.gear_type === 'spur';
  const isHelical = calc.gear_type === 'helical';
  const isStraight = calc.gear_type === 'straight-bevel';
  const isSpiral = calc.gear_type === 'spiral-bevel';
  const isCylindrical = isInternal || isSpur || isHelical;

  // Right panel table
  document.getElementById('res-pd').textContent = `${calc.dp.toFixed(1)} / ${calc.dg.toFixed(1)} mm`;
  document.getElementById('res-angles').textContent = isSpiral
    ? `${calc.gamma_p_deg.toFixed(2)}\u00B0 / ${calc.gamma_g_deg.toFixed(2)}\u00B0 (\u03B2m=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0)`
    : isHelical
    ? `${calc.beta_deg.toFixed(1)}\u00B0 (\u03B2) / Parallel`
    : isCylindrical
    ? '0.00\u00B0 / 0.00\u00B0 (Parallel)'
    : `${calc.gamma_p_deg.toFixed(2)}\u00B0 / ${calc.gamma_g_deg.toFixed(2)}\u00B0`;
  document.getElementById('res-ao').textContent = isCylindrical ? `${calc.center_dist.toFixed(1)} mm (Center C)` : `${calc.Ao.toFixed(2)} mm`;
  document.getElementById('res-f').textContent = `${calc.F.toFixed(2)} mm`;
  document.getElementById('res-rc').textContent = isStraight ? 'N/A (Straight Teeth)' : isHelical ? 'N/A (Helical Teeth)' : isCylindrical ? 'N/A (Cylindrical)' : `${(calc.r_cutter || 0).toFixed(2)} mm`;

  const crEl = document.getElementById('res-cr');
  crEl.textContent = `${calc.CR.toFixed(3)}`;
  crEl.className = `td-val ${calc.CR >= 1.5 ? 'highlight-green' : 'highlight-warn'}`;

  document.getElementById('res-speed').textContent = `${calc.n_pinion_out.toFixed(0)} RPM`;
  document.getElementById('res-torque').textContent = `${calc.T_pinion_each.toFixed(2)} N\u00B7m`;
  document.getElementById('res-forces').textContent = `${calc.Ft.toFixed(1)} / ${calc.F_resultant.toFixed(1)} N`;

  const sfEl = document.getElementById('res-sf');
  const sf_p_val = isCylindrical ? calc.SF_b_p : calc.SF_p;
  const sf_g_val = isCylindrical ? calc.SF_b_g : calc.SF_g;
  sfEl.textContent = `${sf_p_val.toFixed(1)} / ${sf_g_val.toFixed(1)}`;
  sfEl.className = `td-val ${sf_p_val >= 1.5 && sf_g_val >= 1.5 ? 'highlight-green' : 'highlight-warn'}`;

  // Summary title card
  const summaryTitle = document.getElementById('summary-title');
  if (summaryTitle) {
    summaryTitle.textContent = isInternal
      ? `Internal Ring (M${calc.m}, Z${calc.Np}/${calc.Ng})`
      : isSpur
      ? `Involute Spur (M${calc.m}, Z${calc.Np}/${calc.Ng})`
      : isHelical
      ? `Helical Drive (M${calc.mn}, \u03B2${calc.beta_deg}\u00B0, Z${calc.Np}/${calc.Ng})`
      : isSpiral
      ? `Spiral Bevel (M${calc.m}, \u03B2${(calc.beta_m_deg || 35).toFixed(0)}\u00B0, Z${calc.Np}/${calc.Ng})`
      : isStraight
      ? `Straight Bevel (M${calc.m}, Z${calc.Np}/${calc.Ng})`
      : `Zerol Bevel (M${calc.m}, Z${calc.Np}/${calc.Ng})`;
  }

  // Viewport title
  const gearTypeBadge = document.getElementById('viewport-gear-type');
  if (gearTypeBadge) {
    gearTypeBadge.textContent = isSpiral ? 'Spiral Bevel' : isInternal ? 'Internal Spur Ring' : isSpur ? 'Involute Spur' : isHelical ? 'Helical Gear' : isStraight ? 'Straight Bevel' : 'Zerol Bevel';
  }

  const specs = document.getElementById('viewport-specs');
  if (specs) specs.textContent = isSpiral
    ? `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 m=${calc.m} \u00B7 \u03B2=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0`
    : isHelical
    ? `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 mn=${calc.mn} \u00B7 \u03B2=${calc.beta_deg}\u00B0`
    : `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 m=${calc.m} \u00B7 \u03C6${calc.phi_deg}\u00B0`;

  // HUD
  document.getElementById('hud-cr').textContent = calc.CR.toFixed(3);
  const hudCrStatus = document.getElementById('hud-cr-status');
  hudCrStatus.className = `hud-badge ${calc.CR >= 1.5 ? 'safe' : calc.CR >= 1.2 ? 'warn' : 'danger'}`;
  hudCrStatus.textContent = calc.CR >= 1.5 ? 'GOOD (\u22651.5)' : calc.CR >= 1.2 ? 'OK (\u22651.2)' : 'LOW';

  document.getElementById('hud-sf').textContent = `${sf_p_val.toFixed(1)} / ${sf_g_val.toFixed(1)}`;
  const hudSfStatus = document.getElementById('hud-sf-status');
  hudSfStatus.className = `hud-badge ${sf_p_val >= 1.5 && sf_g_val >= 1.5 ? 'safe' : 'warn'}`;
  hudSfStatus.textContent = sf_p_val >= 1.5 && sf_g_val >= 1.5 ? 'SAFE (\u22651.5)' : 'WARN';

  // Canvas Watermark
  const wmTitle = document.getElementById('wm-gear-title');
  if (wmTitle) {
    wmTitle.textContent = isInternal ? 'Internal Spur Ring Gear' : isSpur ? 'Involute Spur Gear' : isHelical ? 'Helical Gear' : isSpiral ? 'Spiral Bevel Gear' : isStraight ? 'Straight Bevel Gear' : 'Zerol Bevel Gear';
  }

  const wmParams = document.getElementById('wm-gear-params');
  if (wmParams) wmParams.textContent = isHelical
    ? `Z=${calc.Np}/${calc.Ng} \u2022 mn=${calc.mn} \u2022 \u03B2${calc.beta_deg}\u00B0`
    : isSpiral
    ? `Z=${calc.Np}/${calc.Ng} \u2022 M=${calc.m} \u2022 \u03B2m=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0`
    : `Z=${calc.Np}/${calc.Ng} \u2022 M=${calc.m} \u2022 \u03C6${calc.phi_deg}\u00B0`;

  const wmDims = document.getElementById('wm-gear-dims');
  if (wmDims) {
    if (isCylindrical) {
      wmDims.innerHTML = `Pitch Dia: ${calc.dp.toFixed(1)} / ${calc.dg.toFixed(1)} mm<br>Center Dist: ${calc.center_dist.toFixed(1)} mm<br>Face Width: ${calc.F.toFixed(1)} mm`;
    } else {
      wmDims.innerHTML = `Pitch Dia: ${calc.dp.toFixed(1)} / ${calc.dg.toFixed(1)} mm<br>Outer Cone Ao: ${calc.Ao.toFixed(1)} mm<br>Face Width: ${calc.F.toFixed(1)} mm`;
    }
  }
}

// =========================================================================
// Master Recalculation Routine
// =========================================================================

function recalculateAndRender() {
  try {
    const inputs = getFormInputs();

    if (inputs.gear_type === 'internal_spur') {
      currentCalc = calculateInternalSpurDesign(inputs);

      currentPinionMesh = buildSpurMesh(
        currentCalc.Np, currentCalc.m, currentCalc.phi,
        currentCalc.a_p, currentCalc.b_p, currentCalc.s_p,
        currentCalc.F, 4, 0, 40
      );

      currentGearMesh = buildInternalRingMesh(currentCalc, 4, 40);
    } else if (inputs.gear_type === 'spur') {
      currentCalc = calculateSpurDesign(inputs);

      currentPinionMesh = buildSpurMesh(
        currentCalc.Np, currentCalc.m, currentCalc.phi,
        currentCalc.a_p, currentCalc.b_p, currentCalc.s_p,
        currentCalc.F, 4, 0, 50
      );

      currentGearMesh = buildSpurMesh(
        currentCalc.Ng, currentCalc.m, currentCalc.phi,
        currentCalc.a_g, currentCalc.b_g, currentCalc.s_g,
        currentCalc.F, 4, 0, 50
      );
    } else if (inputs.gear_type === 'helical') {
      currentCalc = calculateHelicalDesign(inputs);

      currentPinionMesh = buildHelicalMesh(
        currentCalc.Np, currentCalc.mn, currentCalc.beta_deg, currentCalc.phi_n_deg,
        currentCalc.a_p, currentCalc.b_p, currentCalc.st_p,
        currentCalc.F, +1, 16, 20, 0
      );

      currentGearMesh = buildHelicalMesh(
        currentCalc.Ng, currentCalc.mn, currentCalc.beta_deg, currentCalc.phi_n_deg,
        currentCalc.a_g, currentCalc.b_g, currentCalc.st_g,
        currentCalc.F, -1, 16, 20, 0
      );
    } else if (inputs.gear_type === 'straight-bevel') {
      currentCalc = calculateStraightBevelDesign(inputs);

      currentPinionMesh = buildBevelMesh(
        currentCalc.Np, currentCalc.m, currentCalc.phi,
        currentCalc.a_p, currentCalc.b_p, currentCalc.gamma_p,
        currentCalc.Ao, currentCalc.F, null, // null cutter radius -> straight tooth!
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_p, currentCalc.crowning_p, 1.0
      );

      currentGearMesh = buildBevelMesh(
        currentCalc.Ng, currentCalc.m, currentCalc.phi,
        currentCalc.a_g, currentCalc.b_g, currentCalc.gamma_g,
        currentCalc.Ao, currentCalc.F, null, // null cutter radius -> straight tooth!
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_g, currentCalc.crowning_g, 1.0
      );
    } else if (inputs.gear_type === 'spiral-bevel') {
      currentCalc = calculateSpiralBevelDesign(inputs);

      currentPinionMesh = buildBevelMesh(
        currentCalc.Np, currentCalc.m, currentCalc.phi_n,
        currentCalc.a_p, currentCalc.b_p, currentCalc.gamma_p,
        currentCalc.Ao, currentCalc.F, currentCalc.r_cutter,
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_p, currentCalc.crowning_p, 1.0,
        currentCalc.beta_m_deg, +1
      );

      currentGearMesh = buildBevelMesh(
        currentCalc.Ng, currentCalc.m, currentCalc.phi_n,
        currentCalc.a_g, currentCalc.b_g, currentCalc.gamma_g,
        currentCalc.Ao, currentCalc.F, currentCalc.r_cutter,
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_g, currentCalc.crowning_g, 1.0,
        currentCalc.beta_m_deg, -1
      );
    } else {
      currentCalc = calculateGearDesign(inputs);

      currentPinionMesh = buildBevelMesh(
        currentCalc.Np, currentCalc.m, currentCalc.phi,
        currentCalc.a_p, currentCalc.b_p_print, currentCalc.gamma_p,
        currentCalc.Ao, currentCalc.F, currentCalc.r_cutter,
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_p_print, currentCalc.crowning_p, currentCalc.ps.shrinkage_factor
      );

      currentGearMesh = buildBevelMesh(
        currentCalc.Ng, currentCalc.m, currentCalc.phi,
        currentCalc.a_g, currentCalc.b_g_print, currentCalc.gamma_g,
        currentCalc.Ao, currentCalc.F, currentCalc.r_cutter,
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_g_print, currentCalc.crowning_g, currentCalc.ps.shrinkage_factor
      );
    }

    updateResultsUI(currentCalc);

    if (viewer3D) viewer3D.updateGears(currentCalc, currentPinionMesh, currentGearMesh);
    if (plot2D) plot2D.updatePlot(currentCalc);
  } catch (err) {
    console.error('Recalculation error:', err);
    showToast('Recalculation error: ' + err.message, 'error');
  }
}

function scheduleRecalculate() {
  if (updateTimer) clearTimeout(updateTimer);
  updateTimer = setTimeout(() => recalculateAndRender(), 150);
}

// =========================================================================
// Export Handling
// =========================================================================

function getBaseFilename() {
  const custom = document.getElementById('inp-filename')?.value?.trim();
  if (custom && custom.length > 0) return custom;
  if (currentCalc) {
    if (currentCalc.gear_type === 'internal_spur') {
      return `Internal_Spur_m${currentCalc.m}_Np${currentCalc.Np}_Ng${currentCalc.Ng}`;
    }
    if (currentCalc.gear_type === 'spur') {
      return `Spur_Gear_m${currentCalc.m}_Np${currentCalc.Np}_Ng${currentCalc.Ng}`;
    }
    if (currentCalc.gear_type === 'straight-bevel') {
      return `Straight_Bevel_m${currentCalc.m}_Np${currentCalc.Np}_Ng${currentCalc.Ng}`;
    }
    if (currentCalc.gear_type === 'helical') {
      return `Helical_Gear_m${currentCalc.mn}_Np${currentCalc.Np}_Ng${currentCalc.Ng}_beta${currentCalc.beta_deg}`;
    }
    if (currentCalc.gear_type === 'spiral-bevel') {
      return `Spiral_Bevel_m${currentCalc.m}_Np${currentCalc.Np}_Ng${currentCalc.Ng}_beta${currentCalc.beta_m_deg.toFixed(0)}`;
    }
  }
  return `Zerol_Bevel_m${currentCalc.m}_Np${currentCalc.Np}_Ng${currentCalc.Ng}`;
}

function getGearTypeName() {
  if (!currentCalc) return 'Gear';
  switch (currentCalc.gear_type) {
    case 'helical': return 'Helical';
    case 'spur': return 'Spur';
    case 'internal_spur': return 'Internal_Spur';
    case 'straight-bevel': return 'Straight_Bevel';
    case 'spiral-bevel': return 'Spiral_Bevel';
    default: return 'Zerol_Bevel';
  }
}

async function handleExport() {
  const format = document.getElementById('sel-export-format').value;
  const baseName = getBaseFilename();
  const typeName = getGearTypeName();

  switch (format) {
    case 'zip':
      handleZipExport(baseName);
      break;

    // STEP AP214 Options
    case 'step':
      handleStepZipExport(baseName);
      break;
    case 'step-pinion': {
      showToast('Generating STEP Pinion model...', 'download');
      const p = exportSTEP(currentPinionMesh, `${baseName}_pinion`, `${typeName} Pinion m${currentCalc.m || currentCalc.mn} Np${currentCalc.Np}`);
      downloadFile(p, `${baseName}_pinion.stp`, 'application/step');
      showToast('Downloaded Pinion STEP (.stp)', 'success');
      break;
    }
    case 'step-gear': {
      showToast('Generating STEP Gear model...', 'download');
      const g = exportSTEP(currentGearMesh, `${baseName}_gear`, `${typeName} Gear m${currentCalc.m || currentCalc.mn} Ng${currentCalc.Ng}`);
      downloadFile(g, `${baseName}_gear.stp`, 'application/step');
      showToast('Downloaded Gear STEP (.stp)', 'success');
      break;
    }
    case 'step-assembly': {
      showToast('Generating STEP Assembly in Mesh...', 'download');
      const a = exportAssemblySTEP(currentCalc, currentPinionMesh, currentGearMesh, baseName);
      downloadFile(a, `${baseName}_assembly.stp`, 'application/step');
      showToast('Downloaded Assembly STEP (.stp)', 'success');
      break;
    }

    // Binary STL Options
    case 'stl':
      handleStlZipExport(baseName);
      break;
    case 'stl-pinion': {
      showToast('Generating Binary STL Pinion...', 'download');
      const p = exportSTLBinary(currentPinionMesh, `${typeName} Pinion`);
      downloadFile(p, `${baseName}_pinion.stl`, 'application/sla');
      showToast('Downloaded Pinion STL (.stl)', 'success');
      break;
    }
    case 'stl-gear': {
      showToast('Generating Binary STL Gear...', 'download');
      const g = exportSTLBinary(currentGearMesh, `${typeName} Gear`);
      downloadFile(g, `${baseName}_gear.stl`, 'application/sla');
      showToast('Downloaded Gear STL (.stl)', 'success');
      break;
    }
    case 'stl-assembly': {
      showToast('Generating STL Assembly in Mesh...', 'download');
      const a = exportAssemblySTLBinary(currentCalc, currentPinionMesh, currentGearMesh, `${typeName} Assembly`);
      downloadFile(a, `${baseName}_assembly.stl`, 'application/sla');
      showToast('Downloaded Assembly STL (.stl)', 'success');
      break;
    }

    // SolidWorks & IGES Packages
    case 'solidworks':
      handleSolidWorksZipExport(baseName);
      break;
    case 'iges':
      handleIgesZipExport(baseName);
      break;

    // Reports & Diagrams
    case 'csv':
      handleCsvExport(baseName);
      break;
    case 'png':
      handlePngExport(baseName);
      break;
    default:
      handleZipExport(baseName);
  }
}

async function handleZipExport(baseName) {
  showToast('Bundling complete CAD package into ZIP...', 'download');
  try {
    const zipBlob = await createCompleteCADZip(currentCalc, currentPinionMesh, currentGearMesh);
    downloadFile(zipBlob, `${baseName}.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create ZIP: ' + err.message, 'warn');
  }
}

async function handleStepZipExport(baseName) {
  showToast('Bundling STEP models (Pinion, Gear & Assembly)...', 'download');
  try {
    const zipBlob = await exportSTEPZip(currentCalc, currentPinionMesh, currentGearMesh, baseName);
    downloadFile(zipBlob, `${baseName}_STEP.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_STEP.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create STEP ZIP: ' + err.message, 'warn');
  }
}

async function handleStlZipExport(baseName) {
  showToast('Bundling STL models (Pinion, Gear & Assembly)...', 'download');
  try {
    const zipBlob = await exportSTLZip(currentCalc, currentPinionMesh, currentGearMesh, baseName);
    downloadFile(zipBlob, `${baseName}_STL.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_STL.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create STL ZIP: ' + err.message, 'warn');
  }
}

async function handleIgesZipExport(baseName) {
  showToast('Bundling IGES models...', 'download');
  try {
    const zipBlob = await exportIGESZip(currentCalc, currentPinionMesh, currentGearMesh, baseName);
    downloadFile(zipBlob, `${baseName}_IGES.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_IGES.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create IGES ZIP: ' + err.message, 'warn');
  }
}

async function handleSolidWorksZipExport(baseName) {
  showToast('Bundling SolidWorks Macro & Equations...', 'download');
  try {
    const zipBlob = await exportSolidWorksZip(currentCalc, baseName);
    downloadFile(zipBlob, `${baseName}_SolidWorks.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_SolidWorks.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create SolidWorks ZIP: ' + err.message, 'warn');
  }
}

function handleCsvExport(baseName) {
  downloadFile(exportDesignReportCSV(currentCalc), `${baseName}_report.csv`, 'text/csv');
  showToast('Downloaded Design Report (.csv)', 'success');
}

function handlePngExport(baseName) {
  if (activeTab !== '2d') plot2D.updatePlot(currentCalc);
  const dataUrl = plot2D.exportPNG();
  const a = document.createElement('a');
  a.href = dataUrl;
  a.download = `${baseName}_2d_mesh.png`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  showToast('Downloaded 2D Mesh Diagram (.png)', 'success');
}

// =========================================================================
// Setup Event Listeners
// =========================================================================

function setupEvents() {
  // Input changes
  const inputIds = [
    'inp-m', 'inp-Np', 'inp-Ng', 'inp-phi', 'inp-helix-angle', 'inp-Sigma', 'inp-pinions',
    'inp-f-factor', 'inp-f-mm', 'inp-rc', 'inp-khw', 'inp-c-factor', 'inp-torque',
    'inp-rpm', 'inp-eta', 'inp-sigma-allow', 'inp-n-inv', 'inp-n-sec'
  ];
  inputIds.forEach(id => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('input', scheduleRecalculate);
  });

  // Material select with dynamic allowable stress & safety factor update
  const selMaterial = document.getElementById('sel-material');
  if (selMaterial) {
    selMaterial.addEventListener('change', (e) => {
      const matKey = (e.target.value || 'PLA').toUpperCase();
      const ps = MATERIAL_PRESETS[matKey] || MATERIAL_PRESETS.PLA;
      const inpSigma = document.getElementById('inp-sigma-allow');
      if (inpSigma && ps && ps.sigma_allow_bend) {
        inpSigma.value = ps.sigma_allow_bend.toFixed(0);
      }
      recalculateAndRender();
      showToast(`Material updated: ${ps.name} (Allowable Stress: ${ps.sigma_allow_bend} MPa)`, 'info');
    });
  }

  // Gear type change
  const selGearType = document.getElementById('sel-gear-type');
  if (selGearType) {
    selGearType.addEventListener('change', () => {
      const chosenType = selGearType.value;
      handleGearTypeChange(chosenType);
      recalculateAndRender();
      showToast(`Switched to: ${selGearType.options[selGearType.selectedIndex].text}`, 'info');
    });
  }

  // Auto cutter radius button
  document.getElementById('btn-auto-rc').addEventListener('click', () => {
    document.getElementById('inp-rc').value = '';
    recalculateAndRender();
    showToast('Cutter radius reset to Auto', 'info');
  });

  // Presets
  document.querySelectorAll('.preset-pill[data-preset]').forEach(btn => {
    btn.addEventListener('click', () => applyPreset(btn.dataset.preset));
  });

  // Accordion cards
  document.querySelectorAll('.accordion-header').forEach(header => {
    header.addEventListener('click', () => {
      const targetId = header.dataset.target;
      const content = document.getElementById(targetId);
      if (!content) return;
      const isOpen = header.classList.contains('open');
      if (isOpen) {
        header.classList.remove('open');
        content.style.display = 'none';
      } else {
        header.classList.add('open');
        content.style.display = 'flex';
      }
    });
  });

  // Action Buttons
  document.getElementById('btn-generate').addEventListener('click', () => {
    recalculateAndRender();
    showToast('Gear design updated and regenerated', 'success');
  });

  document.getElementById('btn-export-design').addEventListener('click', handleExport);

  // CAD Quick Cards
  const cadCards = document.querySelectorAll('.cad-card');
  const selFormat = document.getElementById('sel-export-format');

  cadCards.forEach(card => {
    card.addEventListener('click', () => {
      cadCards.forEach(c => c.classList.remove('active'));
      card.classList.add('active');
      const exportType = card.dataset.exportType;
      if (selFormat) {
        selFormat.value = exportType;
      }
    });
  });

  if (selFormat) {
    selFormat.addEventListener('change', () => {
      cadCards.forEach(c => {
        if (c.dataset.exportType === selFormat.value) {
          c.classList.add('active');
        } else {
          c.classList.remove('active');
        }
      });
    });
  }

  // Tab switching (3D vs 2D)
  const tab3D = document.getElementById('tab-3d');
  const tab2D = document.getElementById('tab-2d');
  const container3D = document.getElementById('canvas-3d-container');
  const canvas2D = document.getElementById('canvas-2d');
  const groupExploded = document.getElementById('group-exploded');
  const floatingCadTools = document.querySelector('.floating-cad-tools');
  const viewportHud = document.querySelector('.viewport-hud');
  const blueprintWatermark = document.querySelector('.canvas-dimensions-watermark');
  const btnAnimateRot = document.getElementById('btn-animate-rot');
  const cameraBtnGroup = document.querySelector('.camera-btn-group');
  const selPartMode = document.getElementById('sel-part-mode');
  const toolbarSepElements = document.querySelectorAll('.viewport-controls-cluster .toolbar-sep');

  tab3D.addEventListener('click', () => {
    activeTab = '3d';
    tab3D.classList.add('active');
    tab2D.classList.remove('active');
    container3D.style.display = 'block';
    canvas2D.style.display = 'none';
    groupExploded.style.display = 'flex';

    if (floatingCadTools) floatingCadTools.style.display = 'flex';
    if (viewportHud) viewportHud.style.display = 'flex';
    if (blueprintWatermark) blueprintWatermark.style.display = 'block';
    if (btnAnimateRot) btnAnimateRot.style.display = 'inline-flex';
    if (cameraBtnGroup) cameraBtnGroup.style.display = 'inline-flex';
    if (selPartMode) selPartMode.style.display = 'block';
    toolbarSepElements.forEach(sep => (sep.style.display = 'block'));

    viewer3D.handleResize();
  });

  tab2D.addEventListener('click', () => {
    activeTab = '2d';
    tab2D.classList.add('active');
    tab3D.classList.remove('active');
    container3D.style.display = 'none';
    canvas2D.style.display = 'block';
    groupExploded.style.display = 'none';

    if (floatingCadTools) floatingCadTools.style.display = 'none';
    if (viewportHud) viewportHud.style.display = 'none';
    if (blueprintWatermark) blueprintWatermark.style.display = 'none';
    if (btnAnimateRot) btnAnimateRot.style.display = 'none';
    if (cameraBtnGroup) cameraBtnGroup.style.display = 'none';
    if (selPartMode) selPartMode.style.display = 'none';
    toolbarSepElements.forEach(sep => (sep.style.display = 'none'));

    plot2D.resize();
    plot2D.updatePlot(currentCalc);
  });

  // Exploded slider
  document.getElementById('slider-exploded').addEventListener('input', e => {
    viewer3D.setExplodedFactor(parseFloat(e.target.value));
  });

  // Motion simulation
  const btnAnimate = document.getElementById('btn-animate-rot');
  btnAnimate.addEventListener('click', () => {
    isAnimatingMotion = !isAnimatingMotion;
    viewer3D.setRotation(isAnimatingMotion, 12);
    if (isAnimatingMotion) {
      btnAnimate.classList.add('active');
      btnAnimate.querySelector('span').textContent = 'Pause';
    } else {
      btnAnimate.classList.remove('active');
      btnAnimate.querySelector('span').textContent = 'Simulate';
    }
  });

  // Camera views
  document.getElementById('cam-iso').addEventListener('click', () => viewer3D.setCameraPreset('iso'));
  document.getElementById('cam-front').addEventListener('click', () => viewer3D.setCameraPreset('front'));
  document.getElementById('cam-top').addEventListener('click', () => viewer3D.setCameraPreset('top'));
  document.getElementById('cam-mesh').addEventListener('click', () => viewer3D.setCameraPreset('mesh-zoom'));

  // Part isolation
  document.getElementById('sel-part-mode').addEventListener('change', e => {
    viewer3D.setViewMode(e.target.value);
  });

  // Floating Blueprint CAD Tools
  const btnZoomIn = document.getElementById('btn-cad-zoom-in');
  if (btnZoomIn) btnZoomIn.addEventListener('click', () => viewer3D.zoomIn());

  const btnZoomOut = document.getElementById('btn-cad-zoom-out');
  if (btnZoomOut) btnZoomOut.addEventListener('click', () => viewer3D.zoomOut());

  const btnReset = document.getElementById('btn-cad-reset');
  if (btnReset) btnReset.addEventListener('click', () => viewer3D.resetView());

  const btnFullscreen = document.getElementById('btn-cad-fullscreen');
  if (btnFullscreen) {
    btnFullscreen.addEventListener('click', () => {
      const elem = document.getElementById('view-area-container');
      if (!document.fullscreenElement) {
        if (elem.requestFullscreen) elem.requestFullscreen();
      } else {
        if (document.exitFullscreen) document.exitFullscreen();
      }
    });
  }

  // Left rail download button
  const railBtnExport = document.getElementById('rail-btn-export');
  if (railBtnExport) {
    railBtnExport.addEventListener('click', () => {
      const exportPanel = document.querySelector('.panel-export');
      if (exportPanel) {
        exportPanel.scrollIntoView({ behavior: 'smooth' });
        const exportHeader = exportPanel.querySelector('.export-header-title');
        if (exportHeader) {
          exportHeader.scrollIntoView({ behavior: 'smooth' });
        }
      }
      showToast('CAD Export panel selected', 'info');
    });
  }
}

// =========================================================================
// Startup
// =========================================================================

window.addEventListener('DOMContentLoaded', () => {
  const container3D = document.getElementById('canvas-3d-container');
  const canvas2D = document.getElementById('canvas-2d');

  viewer3D = new GearViewer3D(container3D);
  plot2D = new GearPlot2D(canvas2D);

  // Theme toggle with live 3D background update
  const themeBtn = document.getElementById('btn-theme-toggle');
  if (themeBtn) {
    themeBtn.addEventListener('click', () => {
      const html = document.documentElement;
      const current = html.getAttribute('data-theme');
      const next = current === 'dark' ? 'light' : 'dark';
      html.setAttribute('data-theme', next);
      localStorage.setItem('zerol-theme', next);
      if (viewer3D) viewer3D.setTheme(next);
    });

    const saved = localStorage.getItem('zerol-theme');
    if (saved) {
      document.documentElement.setAttribute('data-theme', saved);
      if (viewer3D) viewer3D.setTheme(saved);
    }
  }

  setupEvents();
  const initType = document.getElementById('sel-gear-type')?.value || 'zerol-bevel';
  handleGearTypeChange(initType);
  recalculateAndRender();

  showToast('Gear Master Suite Initialized', 'success');
});
