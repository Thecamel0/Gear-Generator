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
  calculatePlanetaryDesign,
  buildPlanetaryMesh,
  MATERIAL_PRESETS
} from './engine/gearGeometry.js';
import {
  downloadFile,
  exportSTLBinary,
  exportSTEP,
  exportIGES,
  exportSolidWorksMacro,
  exportCATIAMacro,
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
import { initParamTooltips } from './ui/paramTooltips.js';
import { initPanelResizers } from './ui/panelResizer.js';

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
  'spiral-high-ratio-12-60': { gear_type: 'spiral-bevel', m: 3.0, Np: 12, Ng: 60, phi_deg: 20, tooth_angle_deg: 35.0, Sigma_deg: 90, n_pinions: 3, F: 28.0, T_in_ring: 30, n_in_ring: 80 },

  // Planetary (Epicyclic) Presets
  'planetary-standard-12-18-48': { gear_type: 'planetary', m: 3.0, Np: 12, Ng: 18, Nr: 48, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 25.0, T_in_ring: 15, n_in_ring: 500 },
  'planetary-compact-18-18-54': { gear_type: 'planetary', m: 2.5, Np: 18, Ng: 18, Nr: 54, phi_deg: 20, Sigma_deg: 0, n_pinions: 3, F: 22.0, T_in_ring: 15, n_in_ring: 500 },
  'planetary-4planet-12-18-48': { gear_type: 'planetary', m: 3.0, Np: 12, Ng: 18, Nr: 48, phi_deg: 20, Sigma_deg: 0, n_pinions: 4, F: 28.0, T_in_ring: 20, n_in_ring: 500 },
  'planetary-5planet-25-15-55': { gear_type: 'planetary', m: 2.5, Np: 25, Ng: 15, Nr: 55, phi_deg: 20, Sigma_deg: 0, n_pinions: 5, F: 25.0, T_in_ring: 25, n_in_ring: 500 },
  'planetary-6planet-24-12-48': { gear_type: 'planetary', m: 3.0, Np: 24, Ng: 12, Nr: 48, phi_deg: 20, Sigma_deg: 0, n_pinions: 6, F: 30.0, T_in_ring: 30, n_in_ring: 500 }
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
  const isCylindrical = gearType === 'spur' || gearType === 'internal_spur' || gearType === 'helical' || gearType === 'planetary';
  const isPlanetary = gearType === 'planetary';
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

  const rowRingTeeth = document.getElementById('row-ring-teeth');
  const hintRingTeeth = document.getElementById('hint-ring-teeth');
  const hintPlanetsK = document.getElementById('hint-planets-k');
  const rowCarrierThickness = document.getElementById('row-carrier-thickness');
  const rowCarrierDia = document.getElementById('row-carrier-dia');
  const rowRingWall = document.getElementById('row-ring-wall');

  if (rowRingTeeth) rowRingTeeth.style.display = isPlanetary ? 'flex' : 'none';
  if (hintRingTeeth) hintRingTeeth.style.display = isPlanetary ? 'block' : 'none';
  if (hintPlanetsK) hintPlanetsK.style.display = isPlanetary ? 'block' : 'none';
  if (rowCarrierThickness) rowCarrierThickness.style.display = isPlanetary ? 'flex' : 'none';
  if (rowCarrierDia) rowCarrierDia.style.display = isPlanetary ? 'flex' : 'none';
  if (rowRingWall) rowRingWall.style.display = isPlanetary ? 'flex' : 'none';

  // Dynamic labels for inputs
  const lblNp = document.querySelector('#inp-Np')?.closest('.config-row')?.querySelector('.row-label');
  const lblNg = document.querySelector('#inp-Ng')?.closest('.config-row')?.querySelector('.row-label');
  const lblPinions = document.querySelector('#inp-pinions')?.closest('.config-row')?.querySelector('.row-label');

  if (lblNp) lblNp.textContent = isPlanetary ? 'Sun Teeth (Ns):' : 'Pinion Teeth (Np):';
  if (lblNg) lblNg.textContent = isPlanetary ? 'Planet Teeth (Np):' : 'Gear Teeth (Ng):';
  if (lblPinions) lblPinions.textContent = isPlanetary ? 'Planets (K):' : 'Multi-Pinions:';

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
    if (gearType === 'planetary') inpFilename.value = 'Planetary_Gear_Pitch_Drive';
    else if (gearType === 'internal_spur') inpFilename.value = 'Internal_Spur_Pitch_Drive';
    else if (gearType === 'spur') inpFilename.value = 'Spur_Gear_Pitch_Drive';
    else if (gearType === 'straight-bevel') inpFilename.value = 'Straight_Bevel_Pitch_Drive';
    else if (gearType === 'helical') inpFilename.value = 'Helical_Pitch_Drive';
    else if (gearType === 'spiral-bevel') inpFilename.value = 'Spiral_Bevel_Pitch_Drive';
    else inpFilename.value = 'Zerol_Bevel_Pitch_Drive';
  }

  const badge = document.getElementById('viewport-gear-type');
  if (badge) {
    if (gearType === 'planetary') badge.textContent = 'Planetary Gear';
    else if (gearType === 'internal_spur') badge.textContent = 'Internal Spur Ring';
    else if (gearType === 'spur') badge.textContent = 'Involute Spur';
    else if (gearType === 'straight-bevel') badge.textContent = 'Straight Bevel';
    else if (gearType === 'helical') badge.textContent = 'Helical Gear';
    else if (gearType === 'spiral-bevel') badge.textContent = 'Spiral Bevel';
    else badge.textContent = 'Zerol Bevel';
  }

  // Parameter defaults when switching gear families
  const inpNp = document.getElementById('inp-Np');
  const inpNg = document.getElementById('inp-Ng');
  const inpNr = document.getElementById('inp-Nr');
  const inpPinions = document.getElementById('inp-pinions');
  const inpTorque = document.getElementById('inp-torque');
  const inpRpm = document.getElementById('inp-rpm');

  if (gearType === 'planetary') {
    if (inpNp && inpNp.value === '16') inpNp.value = '12';
    if (inpNg && inpNg.value === '48') inpNg.value = '18';
    if (inpNr) {
      const ns = parseInt(inpNp?.value || '12', 10);
      const np = parseInt(inpNg?.value || '18', 10);
      inpNr.value = String(ns + 2 * np);
    }
    if (inpPinions && (inpPinions.value === '1' || !inpPinions.value)) inpPinions.value = '3';
    if (inpTorque && inpTorque.value === '20.0') inpTorque.value = '15.0';
    if (inpRpm && inpRpm.value === '100') inpRpm.value = '500';
    if (inpPinions) {
      inpPinions.min = '2';
      inpPinions.max = '8';
    }
  } else {
    if (inpPinions) {
      inpPinions.min = '1';
      inpPinions.max = '8';
    }
  }

  // Update export format selector options & planetary quick download row
  updateExportFormatOptions(gearType);
}

function getFormInputs() {
  const gearType = document.getElementById('sel-gear-type')?.value || 'zerol-bevel';
  const isCylindrical = gearType === 'spur' || gearType === 'internal_spur' || gearType === 'helical' || gearType === 'planetary';

  const rawNp = parseInt(document.getElementById('inp-Np').value, 10) || 16;
  const rawNg = parseInt(document.getElementById('inp-Ng').value, 10) || 48;
  const rawNr = parseInt(document.getElementById('inp-Nr')?.value, 10) || (rawNp + 2 * rawNg);
  const rawK = parseInt(document.getElementById('inp-pinions').value, 10) || 3;

  return {
    gear_type: gearType,
    m: parseFloat(document.getElementById('inp-m').value) || 3.0,
    Np: rawNp,
    Ng: rawNg,
    Ns: rawNp,
    Np_planet: rawNg,
    Nr: rawNr,
    K: rawK,
    phi_deg: parseFloat(document.getElementById('inp-phi').value) || 20.0,
    tooth_angle_deg: parseFloat(document.getElementById('inp-helix-angle')?.value) || (gearType === 'spiral-bevel' ? 35.0 : 15.0),
    Sigma_deg: isCylindrical ? 0.0 : (parseFloat(document.getElementById('inp-Sigma')?.value) || 90.0),
    n_pinions: rawK,
    f_factor: parseFloat(document.getElementById('inp-f-factor')?.value) || 0.28,
    F: parseFloat(document.getElementById('inp-f-mm')?.value) || 25.0,
    carrier_thickness: parseFloat(document.getElementById('inp-tc')?.value) || 8.0,
    carrier_diameter: parseFloat(document.getElementById('inp-carrier-dia')?.value) || null,
    ring_wall_thickness: parseFloat(document.getElementById('inp-trim')?.value) || 12.0,
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
  if (p.Nr && document.getElementById('inp-Nr')) {
    document.getElementById('inp-Nr').value = p.Nr;
  } else if (p.gear_type === 'planetary' && document.getElementById('inp-Nr')) {
    document.getElementById('inp-Nr').value = String(p.Np + 2 * p.Ng);
  }
  document.getElementById('inp-phi').value = p.phi_deg;
  if (p.tooth_angle_deg && document.getElementById('inp-helix-angle')) document.getElementById('inp-helix-angle').value = p.tooth_angle_deg;
  if (document.getElementById('inp-Sigma')) document.getElementById('inp-Sigma').value = p.Sigma_deg;
  document.getElementById('inp-pinions').value = p.n_pinions;
  if (p.F && document.getElementById('inp-f-mm')) document.getElementById('inp-f-mm').value = p.F;
  if (document.getElementById('inp-tc')) document.getElementById('inp-tc').value = p.carrier_thickness || '8.0';
  if (document.getElementById('inp-carrier-dia')) document.getElementById('inp-carrier-dia').value = p.carrier_diameter || '';
  if (document.getElementById('inp-trim')) document.getElementById('inp-trim').value = p.ring_wall_thickness || '12.0';
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
  const isPlanetary = calc.gear_type === 'planetary';
  const isInternal = calc.gear_type === 'internal_spur';
  const isSpur = calc.gear_type === 'spur';
  const isHelical = calc.gear_type === 'helical';
  const isStraight = calc.gear_type === 'straight-bevel';
  const isSpiral = calc.gear_type === 'spiral-bevel';
  const isCylindrical = isInternal || isSpur || isHelical || isPlanetary;

  // Right panel table
  if (isPlanetary) {
    document.getElementById('res-pd').textContent = `${calc.ds.toFixed(1)} / ${calc.dp.toFixed(1)} / ${calc.dr.toFixed(1)} mm`;
    document.getElementById('res-angles').textContent = `Coaxial Epicyclic (i=${calc.i_ratio.toFixed(1)}:1)`;
    document.getElementById('res-ao').textContent = `${calc.center_dist.toFixed(1)} mm (Orbit C)`;
    document.getElementById('res-f').textContent = `${calc.F.toFixed(2)} mm`;
    const resRcEl = document.getElementById('res-rc');
    const symDesc = calc.is_symmetric ? 'Symmetric' : 'Asymmetric';
    const clearDesc = calc.has_interference ? ' - COLLISION' : '';
    resRcEl.textContent = `K=${calc.K} Planets (${symDesc}${clearDesc})`;
    resRcEl.className = `td-val ${calc.has_interference ? 'highlight-warn' : ''}`;

    const inpPinions = document.getElementById('inp-pinions');
    if (inpPinions) {
      inpPinions.max = '8';
    }

    const hintPlanetsK = document.getElementById('hint-planets-k');
    if (hintPlanetsK) {
      if (calc.has_interference) {
        hintPlanetsK.className = 'field-note warn';
        hintPlanetsK.innerHTML = `<strong>⚠ Overlap:</strong> &Delta; = ${calc.clearance_adjacent_planets.toFixed(1)} mm! Max <strong>${calc.K_max}</strong> planets fit with Ns=${calc.Ns}, Np=${calc.Np}. Increase Ns (e.g. 24) or decrease Np to fit ${calc.K} planets.`;
      } else {
        hintPlanetsK.className = 'field-note success';
        hintPlanetsK.innerHTML = `✓ Clearance: ${calc.clearance_adjacent_planets.toFixed(1)} mm (Max capacity: <strong>${calc.K_max}</strong> planets)`;
      }
    }

    const crEl = document.getElementById('res-cr');
    crEl.textContent = `${calc.CR_sp.toFixed(3)} / ${calc.CR_pr.toFixed(3)}`;
    crEl.className = `td-val ${calc.CR_sp >= 1.2 ? 'highlight-green' : 'highlight-warn'}`;
    document.getElementById('res-speed').textContent = `${calc.n_carrier_out.toFixed(0)} RPM (Carrier)`;
    document.getElementById('res-torque').textContent = `${calc.T_carrier_out.toFixed(2)} N\u00B7m (Carrier)`;
    document.getElementById('res-forces').textContent = `${calc.Ft.toFixed(1)} / ${calc.F_resultant.toFixed(1)} N`;
    const sfEl = document.getElementById('res-sf');
    sfEl.textContent = `${calc.SF_b_s.toFixed(1)} / ${calc.SF_b_p.toFixed(1)} / ${calc.SF_b_r.toFixed(1)}`;
    sfEl.className = `td-val ${calc.SF_b_s >= 1.5 && calc.SF_b_p >= 1.5 ? 'highlight-green' : 'highlight-warn'}`;

    const inpCarrierDia = document.getElementById('inp-carrier-dia');
    if (inpCarrierDia && !inpCarrierDia.value) {
      inpCarrierDia.placeholder = `Auto (${(2 * calc.r_carrier_disc).toFixed(1)})`;
    }
  } else {
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
  }

  // Summary title card
  const summaryTitle = document.getElementById('summary-title');
  if (summaryTitle) {
    summaryTitle.textContent = isPlanetary
      ? `Planetary Gear (M${calc.m}, S${calc.Ns}/P${calc.Np}/R${calc.Nr}, K${calc.K})`
      : isInternal
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
    gearTypeBadge.textContent = isPlanetary ? 'Planetary (Epicyclic)' : isSpiral ? 'Spiral Bevel' : isInternal ? 'Internal Spur Ring' : isSpur ? 'Involute Spur' : isHelical ? 'Helical Gear' : isStraight ? 'Straight Bevel' : 'Zerol Bevel';
  }

  const specs = document.getElementById('viewport-specs');
  if (specs) specs.textContent = isPlanetary
    ? `Ns=${calc.Ns} \u00B7 Np=${calc.Np} \u00B7 Nr=${calc.Nr} \u00B7 K=${calc.K} \u00B7 m=${calc.m} \u00B7 i=${calc.i_ratio.toFixed(1)}:1`
    : isSpiral
    ? `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 m=${calc.m} \u00B7 \u03B2=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0`
    : isHelical
    ? `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 mn=${calc.mn} \u00B7 \u03B2=${calc.beta_deg}\u00B0`
    : `Np=${calc.Np} \u00B7 Ng=${calc.Ng} \u00B7 m=${calc.m} \u00B7 \u03C6${calc.phi_deg}\u00B0`;

  // HUD
  const hudCr = isPlanetary ? calc.CR_sp : calc.CR;
  document.getElementById('hud-cr').textContent = hudCr.toFixed(3);
  const hudCrStatus = document.getElementById('hud-cr-status');
  hudCrStatus.className = `hud-badge ${hudCr >= 1.5 ? 'safe' : hudCr >= 1.2 ? 'warn' : 'danger'}`;
  hudCrStatus.textContent = hudCr >= 1.5 ? 'GOOD (\u22651.5)' : hudCr >= 1.2 ? 'OK (\u22651.2)' : 'LOW';

  const sf1 = isPlanetary ? calc.SF_b_s : (isCylindrical ? calc.SF_b_p : calc.SF_p);
  const sf2 = isPlanetary ? calc.SF_b_p : (isCylindrical ? calc.SF_b_g : calc.SF_g);
  document.getElementById('hud-sf').textContent = `${sf1.toFixed(1)} / ${sf2.toFixed(1)}`;
  const hudSfStatus = document.getElementById('hud-sf-status');
  hudSfStatus.className = `hud-badge ${sf1 >= 1.5 && sf2 >= 1.5 ? 'safe' : 'warn'}`;
  hudSfStatus.textContent = sf1 >= 1.5 && sf2 >= 1.5 ? 'SAFE (\u22651.5)' : 'WARN';

  // Canvas Watermark
  const wmTitle = document.getElementById('wm-gear-title');
  if (wmTitle) {
    wmTitle.textContent = isPlanetary ? 'Planetary Gear (Epicyclic)' : isInternal ? 'Internal Spur Ring Gear' : isSpur ? 'Involute Spur Gear' : isHelical ? 'Helical Gear' : isSpiral ? 'Spiral Bevel Gear' : isStraight ? 'Straight Bevel Gear' : 'Zerol Bevel Gear';
  }

  const wmParams = document.getElementById('wm-gear-params');
  if (wmParams) wmParams.textContent = isPlanetary
    ? `S=${calc.Ns} \u2022 P=${calc.Np} \u2022 R=${calc.Nr} \u2022 K=${calc.K} \u2022 M=${calc.m}`
    : isHelical
    ? `Z=${calc.Np}/${calc.Ng} \u2022 mn=${calc.mn} \u2022 \u03B2${calc.beta_deg}\u00B0`
    : isSpiral
    ? `Z=${calc.Np}/${calc.Ng} \u2022 M=${calc.m} \u2022 \u03B2m=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0`
    : `Z=${calc.Np}/${calc.Ng} \u2022 M=${calc.m} \u2022 \u03C6${calc.phi_deg}\u00B0`;

  const wmDims = document.getElementById('wm-gear-dims');
  if (wmDims) {
    if (isPlanetary) {
      wmDims.innerHTML = `Pitch Dia: ${calc.ds.toFixed(1)} / ${calc.dp.toFixed(1)} / ${calc.dr.toFixed(1)} mm<br>Orbit Radius: ${calc.center_dist.toFixed(1)} mm<br>Carrier Thk: ${calc.carrier_thickness.toFixed(1)} mm<br>Ratio: ${calc.i_ratio.toFixed(2)}:1`;
    } else if (isCylindrical) {
      wmDims.innerHTML = `Pitch Dia: ${calc.dp.toFixed(1)} / ${calc.dg.toFixed(1)} mm<br>Center Dist: ${calc.center_dist.toFixed(1)} mm<br>Face Width: ${calc.F.toFixed(1)} mm`;
    } else {
      wmDims.innerHTML = `Pitch Dia: ${calc.dp.toFixed(1)} / ${calc.dg.toFixed(1)} mm<br>Outer Cone Ao: ${calc.Ao.toFixed(1)} mm<br>Face Width: ${calc.F.toFixed(1)} mm`;
    }
  }

  // Update part isolation dropdown with exact multi-pinion count
  const selPart = document.getElementById('sel-part-mode');
  if (selPart) {
    const n = isPlanetary ? (calc.K || 3) : (calc.n_pinions || 3);
    const currentMode = selPart.value;
    if (isPlanetary) {
      selPart.innerHTML = `
        <option value="assembly">Full Assembly (Sun, ${n} Planets, Ring, Carrier)</option>
        <option value="sun">Sun Gear Alone</option>
        <option value="planet">Planet Gears Alone (All ${n})</option>
        <option value="ring">Ring Gear Alone</option>
        <option value="carrier">Carrier Alone</option>
        <option value="single-pair">Single Planet Pair Only</option>
      `;
    } else if (calc.gear_type === 'internal_spur') {
      selPart.innerHTML = `
        <option value="assembly">Full Assembly (${n > 1 ? `All ${n} Pinions + Ring` : 'Pinion & Ring'})</option>
        ${n > 1 ? '<option value="single-pair">Single Pair Only (1 Pinion)</option>' : ''}
        <option value="pinion">${n > 1 ? `Pinions Only (All ${n})` : 'Pinion Only'}</option>
        <option value="gear">Internal Ring Gear Only</option>
      `;
    } else {
      selPart.innerHTML = `
        <option value="assembly">Full Assembly (${n > 1 ? `All ${n} Pinions + Gear` : 'Pinion & Gear'})</option>
        ${n > 1 ? '<option value="single-pair">Single Pair Only (1 Pinion)</option>' : ''}
        <option value="pinion">${n > 1 ? `Pinions Only (All ${n})` : 'Pinion Only'}</option>
        <option value="gear">Gear Only</option>
      `;
    }
    if (Array.from(selPart.options).some(o => o.value === currentMode)) {
      selPart.value = currentMode;
    } else {
      selPart.value = 'assembly';
    }
  }
}

// =========================================================================
// Master Recalculation Routine
// =========================================================================

function recalculateAndRender() {
  try {
    const inputs = getFormInputs();

    if (inputs.gear_type === 'planetary') {
      currentCalc = calculatePlanetaryDesign(inputs);

      const { sunMesh, planetMesh, ringMesh, carrierMesh } = buildPlanetaryMesh(currentCalc, 4, 36);
      currentPinionMesh = planetMesh;
      currentGearMesh = ringMesh;
      currentCalc.sunMesh = sunMesh;
      currentCalc.planetMesh = planetMesh;
      currentCalc.ringMesh = ringMesh;
      currentCalc.carrierMesh = carrierMesh;

      updateResultsUI(currentCalc);

      if (viewer3D) viewer3D.updateGears(currentCalc, currentPinionMesh, currentGearMesh, { sunMesh, carrierMesh });
      if (plot2D && activeTab === '2d') plot2D.updatePlot(currentCalc);
      return;
    } else if (inputs.gear_type === 'internal_spur') {
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
        currentCalc.s_p_print, currentCalc.crowning_p, 1.0,
        0, +1
      );

      currentGearMesh = buildBevelMesh(
        currentCalc.Ng, currentCalc.m, currentCalc.phi,
        currentCalc.a_g, currentCalc.b_g_print, currentCalc.gamma_g,
        currentCalc.Ao, currentCalc.F, currentCalc.r_cutter,
        inputs.n_inv, inputs.n_sec, 3, 3,
        currentCalc.s_g_print, currentCalc.crowning_g, 1.0,
        0, -1
      );
    }

    updateResultsUI(currentCalc);

    if (viewer3D) viewer3D.updateGears(currentCalc, currentPinionMesh, currentGearMesh);
    if (plot2D && activeTab === '2d') plot2D.updatePlot(currentCalc);
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
    if (currentCalc.gear_type === 'planetary') {
      return `Planetary_Gear_m${currentCalc.m}_Ns${currentCalc.Ns}_Np${currentCalc.Np}_Nr${currentCalc.Nr}_K${currentCalc.K}`;
    }
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
    case 'planetary': return 'Planetary';
    case 'helical': return 'Helical';
    case 'spur': return 'Spur';
    case 'internal_spur': return 'Internal_Spur';
    case 'straight-bevel': return 'Straight_Bevel';
    case 'spiral-bevel': return 'Spiral_Bevel';
    default: return 'Zerol_Bevel';
  }
}

export function updateExportFormatOptions(gearType) {
  const selFormat = document.getElementById('sel-export-format');
  const rowPlanetaryQuick = document.getElementById('row-planetary-quick-download');
  if (!selFormat) return;

  const prevValue = selFormat.value;
  const isPlanetary = gearType === 'planetary';
  const isInternal = gearType === 'internal_spur';

  if (rowPlanetaryQuick) {
    rowPlanetaryQuick.style.display = isPlanetary ? 'flex' : 'none';
  }

  if (isPlanetary) {
    selFormat.innerHTML = `
      <optgroup label="Complete Packages">
        <option value="zip">Complete CAD Package (.ZIP)</option>
        <option value="step">STEP AP214 Package (.zip)</option>
        <option value="stl">Binary STL Package (.zip)</option>
        <option value="iges">IGES 5.3 Package (.zip)</option>
        <option value="solidworks">SolidWorks Automation (.zip)</option>
      </optgroup>
      <optgroup label="STEP Solid Models (.stp)">
        <option value="step-assembly">STEP Full Assembly in Mesh (.stp)</option>
        <option value="step-sun">STEP Sun Gear Alone (.stp)</option>
        <option value="step-planet">STEP Planet Gear Alone (.stp)</option>
        <option value="step-ring">STEP Ring Gear Alone (.stp)</option>
        <option value="step-carrier">STEP Planet Carrier Alone (.stp)</option>
      </optgroup>
      <optgroup label="Binary STL Printable (.stl)">
        <option value="stl-assembly">STL Full Assembly in Mesh (.stl)</option>
        <option value="stl-sun">STL Sun Gear Alone (.stl)</option>
        <option value="stl-planet">STL Planet Gear Alone (.stl)</option>
        <option value="stl-ring">STL Ring Gear Alone (.stl)</option>
        <option value="stl-carrier">STL Planet Carrier Alone (.stl)</option>
      </optgroup>
      <optgroup label="IGES 5.3 Surfaces (.igs)">
        <option value="iges-sun">IGES Sun Gear Alone (.igs)</option>
        <option value="iges-planet">IGES Planet Gear Alone (.igs)</option>
        <option value="iges-ring">IGES Ring Gear Alone (.igs)</option>
        <option value="iges-carrier">IGES Planet Carrier Alone (.igs)</option>
      </optgroup>
      <optgroup label="Reports & Automation">
        <option value="catia">CATIA V5 Automation (.catvbs)</option>
        <option value="csv">Design Report (.csv)</option>
        <option value="png">2D Mesh Diagram (.png)</option>
      </optgroup>
    `;
  } else {
    const gearLabel = isInternal ? 'Internal Ring' : 'Gear';
    selFormat.innerHTML = `
      <optgroup label="Complete Packages">
        <option value="zip">Complete CAD Package (.ZIP)</option>
        <option value="step">STEP AP214 Package (.zip)</option>
        <option value="stl">Binary STL Package (.zip)</option>
        <option value="iges">IGES 5.3 Package (.zip)</option>
        <option value="solidworks">SolidWorks Automation (.zip)</option>
      </optgroup>
      <optgroup label="STEP Solid Models (.stp)">
        <option value="step-assembly">STEP Assembly in Mesh (.stp)</option>
        <option value="step-pinion">STEP Pinion Only (.stp)</option>
        <option value="step-gear">STEP ${gearLabel} Only (.stp)</option>
      </optgroup>
      <optgroup label="Binary STL Printable (.stl)">
        <option value="stl-assembly">STL Assembly in Mesh (.stl)</option>
        <option value="stl-pinion">STL Pinion Only (.stl)</option>
        <option value="stl-gear">STL ${gearLabel} Only (.stl)</option>
      </optgroup>
      <optgroup label="IGES 5.3 Surfaces (.igs)">
        <option value="iges-pinion">IGES Pinion Only (.igs)</option>
        <option value="iges-gear">IGES ${gearLabel} Only (.igs)</option>
      </optgroup>
      <optgroup label="Reports & Automation">
        <option value="catia">CATIA V5 Automation (.catvbs)</option>
        <option value="csv">Design Report (.csv)</option>
        <option value="png">2D Mesh Diagram (.png)</option>
      </optgroup>
    `;
  }

  // Restore previous value if available, or smart mapping
  if (Array.from(selFormat.options).some(o => o.value === prevValue)) {
    selFormat.value = prevValue;
  } else if (prevValue.includes('pinion') && isPlanetary) {
    selFormat.value = prevValue.replace('pinion', 'planet');
  } else if (prevValue.includes('planet') && !isPlanetary) {
    selFormat.value = prevValue.replace('planet', 'pinion');
  } else if (prevValue.includes('sun') && !isPlanetary) {
    selFormat.value = prevValue.replace('sun', 'pinion');
  } else if (prevValue.includes('ring') && !isPlanetary) {
    selFormat.value = prevValue.replace('ring', 'gear');
  } else if (prevValue.includes('carrier') && !isPlanetary) {
    selFormat.value = prevValue.replace('carrier', 'assembly');
  } else {
    selFormat.value = 'zip';
  }
}

async function handleExport() {
  const btnExport = document.getElementById('btn-export-design');
  if (btnExport && btnExport.disabled) return;

  const originalText = btnExport ? btnExport.textContent : '';
  if (btnExport) {
    btnExport.disabled = true;
    btnExport.textContent = 'GENERATING...';
    btnExport.classList.add('loading');
  }

  // Yield to browser event loop so button state and toast render on screen
  await new Promise(r => setTimeout(r, 60));

  const format = document.getElementById('sel-export-format').value;
  const baseName = getBaseFilename();
  const typeName = getGearTypeName();

  try {
    switch (format) {
      case 'zip':
        await handleZipExport(baseName);
        break;

      // STEP AP214 Options
      case 'step':
        await handleStepZipExport(baseName);
        break;
      case 'step-pinion': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.planetMesh || currentPinionMesh) : currentPinionMesh;
        const pLabel = (currentCalc.gear_type === 'planetary') ? 'Planet Gear' : 'Pinion';
        showToast(`Generating STEP ${pLabel} model...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportSTEP(mesh, `${baseName}_pinion`, `${typeName} ${pLabel} m${currentCalc.m || currentCalc.mn} Np${currentCalc.Np}`);
        downloadFile(p, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'planet' : 'pinion'}.stp`, 'application/step');
        showToast(`Downloaded ${pLabel} STEP (.stp)`, 'success');
        break;
      }
      case 'step-gear': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.ringMesh || currentGearMesh) : currentGearMesh;
        const gLabel = (currentCalc.gear_type === 'planetary') ? 'Ring Gear' : (typeName === 'Internal_Spur' ? 'Ring Gear' : 'Gear');
        showToast(`Generating STEP ${gLabel} model...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const g = exportSTEP(mesh, `${baseName}_gear`, `${typeName} ${gLabel} m${currentCalc.m || currentCalc.mn} Ng${currentCalc.Ng || currentCalc.Nr}`);
        downloadFile(g, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'ring' : 'gear'}.stp`, 'application/step');
        showToast(`Downloaded ${gLabel} STEP (.stp)`, 'success');
        break;
      }
      case 'step-assembly': {
        showToast('Generating STEP Assembly in Mesh...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const a = exportAssemblySTEP(currentCalc, currentPinionMesh, currentGearMesh, baseName);
        downloadFile(a, `${baseName}_assembly.stp`, 'application/step');
        showToast('Downloaded Assembly STEP (.stp)', 'success');
        break;
      }
      case 'step-sun': {
        const mesh = currentCalc.sunMesh || currentPinionMesh;
        showToast('Generating STEP Sun Gear model...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const s = exportSTEP(mesh, `${baseName}_sun`, `Planetary Sun Gear m${currentCalc.m} Ns${currentCalc.Ns || currentCalc.Np}`);
        downloadFile(s, `${baseName}_sun.stp`, 'application/step');
        showToast('Downloaded Sun Gear STEP (.stp)', 'success');
        break;
      }
      case 'step-planet': {
        const mesh = currentCalc.planetMesh || currentPinionMesh;
        showToast('Generating STEP Planet Gear model...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportSTEP(mesh, `${baseName}_planet`, `Planetary Planet Gear m${currentCalc.m} Np${currentCalc.Np}`);
        downloadFile(p, `${baseName}_planet.stp`, 'application/step');
        showToast('Downloaded Planet Gear STEP (.stp)', 'success');
        break;
      }
      case 'step-ring': {
        const mesh = currentCalc.ringMesh || currentGearMesh;
        showToast('Generating STEP Ring Gear model...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const r_mesh = exportSTEP(mesh, `${baseName}_ring`, `Planetary Ring Gear m${currentCalc.m} Nr${currentCalc.Nr || currentCalc.Ng}`);
        downloadFile(r_mesh, `${baseName}_ring.stp`, 'application/step');
        showToast('Downloaded Ring Gear STEP (.stp)', 'success');
        break;
      }
      case 'step-carrier': {
        const mesh = currentCalc.carrierMesh;
        if (!mesh) {
          showToast('No carrier mesh available for current configuration', 'warn');
          break;
        }
        showToast('Generating STEP Carrier model...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const c = exportSTEP(mesh, `${baseName}_carrier`, `Planetary Carrier K${currentCalc.K || 3}`);
        downloadFile(c, `${baseName}_carrier.stp`, 'application/step');
        showToast('Downloaded Carrier STEP (.stp)', 'success');
        break;
      }

      // Binary STL Options
      case 'stl':
        await handleStlZipExport(baseName);
        break;
      case 'stl-pinion': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.planetMesh || currentPinionMesh) : currentPinionMesh;
        const pLabel = (currentCalc.gear_type === 'planetary') ? 'Planet Gear' : 'Pinion';
        showToast(`Generating Binary STL ${pLabel}...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportSTLBinary(mesh, `${typeName} ${pLabel}`);
        downloadFile(p, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'planet' : 'pinion'}.stl`, 'application/sla');
        showToast(`Downloaded ${pLabel} STL (.stl)`, 'success');
        break;
      }
      case 'stl-gear': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.ringMesh || currentGearMesh) : currentGearMesh;
        const gLabel = (currentCalc.gear_type === 'planetary') ? 'Ring Gear' : (typeName === 'Internal_Spur' ? 'Ring Gear' : 'Gear');
        showToast(`Generating Binary STL ${gLabel}...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const g = exportSTLBinary(mesh, `${typeName} ${gLabel}`);
        downloadFile(g, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'ring' : 'gear'}.stl`, 'application/sla');
        showToast(`Downloaded ${gLabel} STL (.stl)`, 'success');
        break;
      }
      case 'stl-assembly': {
        showToast('Generating STL Assembly in Mesh...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const a = exportAssemblySTLBinary(currentCalc, currentPinionMesh, currentGearMesh, `${typeName} Assembly`);
        downloadFile(a, `${baseName}_assembly.stl`, 'application/sla');
        showToast('Downloaded Assembly STL (.stl)', 'success');
        break;
      }
      case 'stl-sun': {
        const mesh = currentCalc.sunMesh || currentPinionMesh;
        showToast('Generating Binary STL Sun Gear...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const s = exportSTLBinary(mesh, 'Planetary Sun Gear');
        downloadFile(s, `${baseName}_sun.stl`, 'application/sla');
        showToast('Downloaded Sun Gear STL (.stl)', 'success');
        break;
      }
      case 'stl-planet': {
        const mesh = currentCalc.planetMesh || currentPinionMesh;
        showToast('Generating Binary STL Planet Gear...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportSTLBinary(mesh, 'Planetary Planet Gear');
        downloadFile(p, `${baseName}_planet.stl`, 'application/sla');
        showToast('Downloaded Planet Gear STL (.stl)', 'success');
        break;
      }
      case 'stl-ring': {
        const mesh = currentCalc.ringMesh || currentGearMesh;
        showToast('Generating Binary STL Ring Gear...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const r_mesh = exportSTLBinary(mesh, 'Planetary Ring Gear');
        downloadFile(r_mesh, `${baseName}_ring.stl`, 'application/sla');
        showToast('Downloaded Ring Gear STL (.stl)', 'success');
        break;
      }
      case 'stl-carrier': {
        const mesh = currentCalc.carrierMesh;
        if (!mesh) {
          showToast('No carrier mesh available for current configuration', 'warn');
          break;
        }
        showToast('Generating Binary STL Carrier...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const c = exportSTLBinary(mesh, 'Planetary Carrier');
        downloadFile(c, `${baseName}_carrier.stl`, 'application/sla');
        showToast('Downloaded Carrier STL (.stl)', 'success');
        break;
      }

      // IGES Options
      case 'iges':
        await handleIgesZipExport(baseName);
        break;
      case 'iges-pinion': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.planetMesh || currentPinionMesh) : currentPinionMesh;
        const pLabel = (currentCalc.gear_type === 'planetary') ? 'Planet Gear' : 'Pinion';
        showToast(`Generating IGES ${pLabel} model...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportIGES(mesh, `${baseName}_pinion`, `${typeName} ${pLabel} IGES 5.3`);
        downloadFile(p, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'planet' : 'pinion'}.igs`, 'application/iges');
        showToast(`Downloaded ${pLabel} IGES (.igs)`, 'success');
        break;
      }
      case 'iges-gear': {
        const mesh = (currentCalc.gear_type === 'planetary') ? (currentCalc.ringMesh || currentGearMesh) : currentGearMesh;
        const gLabel = (currentCalc.gear_type === 'planetary') ? 'Ring Gear' : (typeName === 'Internal_Spur' ? 'Ring Gear' : 'Gear');
        showToast(`Generating IGES ${gLabel} model...`, 'download');
        await new Promise(r => setTimeout(r, 30));
        const g = exportIGES(mesh, `${baseName}_gear`, `${typeName} ${gLabel} IGES 5.3`);
        downloadFile(g, `${baseName}_${currentCalc.gear_type === 'planetary' ? 'ring' : 'gear'}.igs`, 'application/iges');
        showToast(`Downloaded ${gLabel} IGES (.igs)`, 'success');
        break;
      }
      case 'iges-sun': {
        const mesh = currentCalc.sunMesh || currentPinionMesh;
        showToast('Generating IGES Sun Gear surface...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const s = exportIGES(mesh, `${baseName}_sun`, 'Planetary Sun Gear IGES 5.3');
        downloadFile(s, `${baseName}_sun.igs`, 'application/iges');
        showToast('Downloaded Sun Gear IGES (.igs)', 'success');
        break;
      }
      case 'iges-planet': {
        const mesh = currentCalc.planetMesh || currentPinionMesh;
        showToast('Generating IGES Planet Gear surface...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const p = exportIGES(mesh, `${baseName}_planet`, 'Planetary Planet Gear IGES 5.3');
        downloadFile(p, `${baseName}_planet.igs`, 'application/iges');
        showToast('Downloaded Planet Gear IGES (.igs)', 'success');
        break;
      }
      case 'iges-ring': {
        const mesh = currentCalc.ringMesh || currentGearMesh;
        showToast('Generating IGES Ring Gear surface...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const r_mesh = exportIGES(mesh, `${baseName}_ring`, 'Planetary Ring Gear IGES 5.3');
        downloadFile(r_mesh, `${baseName}_ring.igs`, 'application/iges');
        showToast('Downloaded Ring Gear IGES (.igs)', 'success');
        break;
      }
      case 'iges-carrier': {
        const mesh = currentCalc.carrierMesh;
        if (!mesh) {
          showToast('No carrier mesh available for current configuration', 'warn');
          break;
        }
        showToast('Generating IGES Carrier surface...', 'download');
        await new Promise(r => setTimeout(r, 30));
        const c = exportIGES(mesh, `${baseName}_carrier`, 'Planetary Carrier IGES 5.3');
        downloadFile(c, `${baseName}_carrier.igs`, 'application/iges');
        showToast('Downloaded Carrier IGES (.igs)', 'success');
        break;
      }

      // SolidWorks, CATIA & Reports
      case 'solidworks':
        await handleSolidWorksZipExport(baseName);
        break;
      case 'catia': {
        showToast('Generating CATIA V5 Automation Script...', 'download');
        const script = exportCATIAMacro(currentCalc);
        downloadFile(script, `${baseName}_catia_healer.catvbs`, 'application/octet-stream');
        showToast('Downloaded CATIA Automation Script (.catvbs)', 'success');
        break;
      }
      case 'csv':
        handleCsvExport(baseName);
        break;
      case 'png':
        handlePngExport(baseName);
        break;
      default:
        await handleZipExport(baseName);
    }
  } catch (err) {
    console.error('Export error:', err);
    showToast('Export error: ' + err.message, 'warn');
  } finally {
    if (btnExport) {
      btnExport.disabled = false;
      btnExport.textContent = originalText;
      btnExport.classList.remove('loading');
    }
  }
}

async function handleZipExport(baseName) {
  showToast('Bundling complete CAD package into ZIP...', 'download');
  try {
    const zipBlob = await createCompleteCADZip(currentCalc, currentPinionMesh, currentGearMesh, (msg) => {
      showToast(msg, 'download');
    });
    downloadFile(zipBlob, `${baseName}.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create ZIP: ' + err.message, 'warn');
  }
}

async function handleStepZipExport(baseName) {
  const isPlanetary = currentCalc?.gear_type === 'planetary';
  showToast(isPlanetary ? 'Bundling STEP models (Sun, Planet, Ring, Carrier & Assembly)...' : 'Bundling STEP models (Pinion, Gear & Assembly)...', 'download');
  try {
    const zipBlob = await exportSTEPZip(currentCalc, currentPinionMesh, currentGearMesh, baseName, (msg) => {
      showToast(msg, 'download');
    });
    downloadFile(zipBlob, `${baseName}_STEP.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_STEP.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create STEP ZIP: ' + err.message, 'warn');
  }
}

async function handleStlZipExport(baseName) {
  const isPlanetary = currentCalc?.gear_type === 'planetary';
  showToast(isPlanetary ? 'Bundling STL models (Sun, Planet, Ring, Carrier & Assembly)...' : 'Bundling STL models (Pinion, Gear & Assembly)...', 'download');
  try {
    const zipBlob = await exportSTLZip(currentCalc, currentPinionMesh, currentGearMesh, baseName, (msg) => {
      showToast(msg, 'download');
    });
    downloadFile(zipBlob, `${baseName}_STL.zip`, 'application/zip');
    showToast(`Downloaded ${baseName}_STL.zip`, 'success');
  } catch (err) {
    console.error(err);
    showToast('Failed to create STL ZIP: ' + err.message, 'warn');
  }
}

async function handleIgesZipExport(baseName) {
  const isPlanetary = currentCalc?.gear_type === 'planetary';
  showToast(isPlanetary ? 'Bundling IGES models (Sun, Planet, Ring & Carrier)...' : 'Bundling IGES models...', 'download');
  try {
    const zipBlob = await exportIGESZip(currentCalc, currentPinionMesh, currentGearMesh, baseName, (msg) => {
      showToast(msg, 'download');
    });
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
  // Initialize Interactive Parameter Tooltips & Engineering Guidance
  initParamTooltips();

  // Initialize draggable panel splitters (left config ↔ viewport ↔ right export)
  initPanelResizers();

  // Input changes
  const inputIds = [
    'inp-m', 'inp-Np', 'inp-Ng', 'inp-Nr', 'inp-phi', 'inp-helix-angle', 'inp-Sigma', 'inp-pinions',
    'inp-f-factor', 'inp-f-mm', 'inp-tc', 'inp-carrier-dia', 'inp-trim', 'inp-rc', 'inp-khw', 'inp-c-factor', 'inp-torque',
    'inp-rpm', 'inp-eta', 'inp-sigma-allow', 'inp-n-inv', 'inp-n-sec'
  ];
  inputIds.forEach(id => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('input', scheduleRecalculate);
  });

  const btnAutoCarrierDia = document.getElementById('btn-auto-carrier-dia');
  if (btnAutoCarrierDia) {
    btnAutoCarrierDia.addEventListener('click', () => {
      const el = document.getElementById('inp-carrier-dia');
      if (el) el.value = '';
      recalculateAndRender();
      showToast('Carrier diameter reset to Auto', 'info');
    });
  }

  // Bidirectional Synchronization between Sun (Np), Planet (Ng), and Ring (Nr) for Planetary
  const inpNpEl = document.getElementById('inp-Np');
  const inpNgEl = document.getElementById('inp-Ng');
  const inpNrEl = document.getElementById('inp-Nr');
  const hintRingTeethEl = document.getElementById('hint-ring-teeth');

  function syncRingFromSunAndPlanet() {
    const gearType = document.getElementById('sel-gear-type')?.value;
    if (gearType !== 'planetary') return;
    const ns = parseInt(inpNpEl?.value, 10);
    const np = parseInt(inpNgEl?.value, 10);
    if (!isNaN(ns) && !isNaN(np) && inpNrEl) {
      const nr = ns + 2 * np;
      inpNrEl.value = String(nr);
      if (hintRingTeethEl) {
        hintRingTeethEl.className = 'field-note';
        hintRingTeethEl.textContent = `Coaxial rule: Nr = ${ns} + 2·(${np}) = ${nr}`;
      }
    }
  }

  function syncPlanetFromRing() {
    const gearType = document.getElementById('sel-gear-type')?.value;
    if (gearType !== 'planetary') return;
    const ns = parseInt(inpNpEl?.value, 10);
    const nr = parseInt(inpNrEl?.value, 10);
    if (!isNaN(ns) && !isNaN(nr)) {
      const diff = nr - ns;
      if (diff > 0 && diff % 2 === 0) {
        const np = diff / 2;
        if (inpNgEl) inpNgEl.value = String(np);
        if (hintRingTeethEl) {
          hintRingTeethEl.className = 'field-note success';
          hintRingTeethEl.textContent = `✓ Coaxial: Np = (${nr} - ${ns})/2 = ${np}`;
        }
      } else if (diff <= 0) {
        if (hintRingTeethEl) {
          hintRingTeethEl.className = 'field-note warn';
          hintRingTeethEl.textContent = `⚠ Ring teeth (Nr) must be greater than Sun teeth (Ns).`;
        }
      } else {
        if (hintRingTeethEl) {
          hintRingTeethEl.className = 'field-note warn';
          hintRingTeethEl.textContent = `⚠ (Nr - Ns) is odd (${diff}). Must be an even difference for whole planet teeth.`;
        }
      }
    }
  }

  if (inpNpEl) inpNpEl.addEventListener('input', syncRingFromSunAndPlanet);
  if (inpNgEl) inpNgEl.addEventListener('input', syncRingFromSunAndPlanet);
  if (inpNrEl) inpNrEl.addEventListener('input', syncPlanetFromRing);

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
        if (exportType === 'step') {
          if (!selFormat.value.startsWith('step')) selFormat.value = 'step';
        } else if (exportType === 'stl') {
          if (!selFormat.value.startsWith('stl')) selFormat.value = 'stl';
        } else {
          selFormat.value = exportType;
        }
      }
    });
  });

  if (selFormat) {
    selFormat.addEventListener('change', () => {
      const val = selFormat.value;
      cadCards.forEach(c => {
        const ct = c.dataset.exportType;
        if (ct === val || (ct === 'step' && val.startsWith('step')) || (ct === 'stl' && val.startsWith('stl'))) {
          c.classList.add('active');
        } else {
          c.classList.remove('active');
        }
      });
    });
  }

  // Planetary Quick Part Download Buttons (1-click export of Sun, Planet, Ring, Carrier)
  const partDlButtons = document.querySelectorAll('.btn-part-dl');
  partDlButtons.forEach(btn => {
    btn.addEventListener('click', async () => {
      const part = btn.dataset.part;
      if (!currentCalc) return;

      // Determine active format category (check active CAD card or current selection)
      const activeCard = document.querySelector('.cad-card.active')?.dataset.exportType;
      const curFormat = document.getElementById('sel-export-format')?.value || 'step';

      let targetFormat = `step-${part}`;
      if (activeCard === 'stl' || curFormat.startsWith('stl')) {
        targetFormat = `stl-${part}`;
      } else if (activeCard === 'iges' || curFormat.startsWith('iges')) {
        targetFormat = `iges-${part}`;
      } else {
        targetFormat = `step-${part}`;
      }

      const selFormat = document.getElementById('sel-export-format');
      if (selFormat) {
        selFormat.value = targetFormat;
        cadCards.forEach(c => {
          const ct = c.dataset.exportType;
          if (ct === targetFormat || (ct === 'step' && targetFormat.startsWith('step')) || (ct === 'stl' && targetFormat.startsWith('stl'))) {
            c.classList.add('active');
          } else {
            c.classList.remove('active');
          }
        });
      }

      await handleExport();
    });
  });

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
