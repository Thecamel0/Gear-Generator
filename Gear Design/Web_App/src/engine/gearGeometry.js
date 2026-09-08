/**
 * ZEROL BEVEL GEAR GEOMETRY & KINEMATICS ENGINE
 * Replicates the complete Gleason face-milling Zerol bevel gear design logic
 * from zerol_bevel_design_v2.m, gleason_tooth_surface.m, build_bevel_mesh_v2.m,
 * and print_settings.m.
 *
 * Author: Ahmed Majdy Ahmed (Engine Port)
 */

import * as THREE from 'three';

export const MATERIAL_PRESETS = {
  PLA: {
    name: 'PLA (FDM)',
    shrinkage_factor: 1.003,
    extra_backlash: 0.15,
    tip_relief: 0.10,
    tip_relief_start: 0.85,
    root_fillet_scale: 1.3,
    lengthwise_crown: 0.012,
    profile_crown: 0.008,
    min_wall: 1.2,
    clearance_add: 0.10,
    tolerance: 0.15,
    sigma_allow_bend: 40.0,
    sigma_allow_contact: 65.0,
    description: 'PLA (FDM) — Prototype printing, good detail, brittle (σ_allow = 40 MPa)'
  },
  ABS: {
    name: 'ABS (FDM)',
    shrinkage_factor: 1.006,
    extra_backlash: 0.20,
    tip_relief: 0.12,
    tip_relief_start: 0.85,
    root_fillet_scale: 1.3,
    lengthwise_crown: 0.015,
    profile_crown: 0.010,
    min_wall: 1.5,
    clearance_add: 0.15,
    tolerance: 0.20,
    sigma_allow_bend: 30.0,
    sigma_allow_contact: 50.0,
    description: 'ABS (FDM) — Tougher than PLA, higher thermal shrinkage (σ_allow = 30 MPa)'
  },
  PETG: {
    name: 'PETG (FDM)',
    shrinkage_factor: 1.004,
    extra_backlash: 0.15,
    tip_relief: 0.10,
    tip_relief_start: 0.85,
    root_fillet_scale: 1.2,
    lengthwise_crown: 0.012,
    profile_crown: 0.008,
    min_wall: 1.2,
    clearance_add: 0.10,
    tolerance: 0.15,
    sigma_allow_bend: 35.0,
    sigma_allow_contact: 55.0,
    description: 'PETG (FDM) — Good balance of strength and durability (σ_allow = 35 MPa)'
  },
  NYLON: {
    name: 'Nylon (FDM/SLS)',
    shrinkage_factor: 1.015,
    extra_backlash: 0.25,
    tip_relief: 0.15,
    tip_relief_start: 0.80,
    root_fillet_scale: 1.4,
    lengthwise_crown: 0.020,
    profile_crown: 0.012,
    min_wall: 1.5,
    clearance_add: 0.20,
    tolerance: 0.25,
    sigma_allow_bend: 45.0,
    sigma_allow_contact: 70.0,
    description: 'Nylon (FDM/SLS) — Tough, high fatigue resistance (σ_allow = 45 MPa)'
  },
  RESIN: {
    name: 'Resin (SLA/DLP)',
    shrinkage_factor: 1.002,
    extra_backlash: 0.08,
    tip_relief: 0.05,
    tip_relief_start: 0.90,
    root_fillet_scale: 1.1,
    lengthwise_crown: 0.008,
    profile_crown: 0.005,
    min_wall: 0.8,
    clearance_add: 0.05,
    tolerance: 0.05,
    sigma_allow_bend: 40.0,
    sigma_allow_contact: 65.0,
    description: 'Resin (SLA/DLP) — High precision optical resolution (σ_allow = 40 MPa)'
  },
  STEEL: {
    name: 'Steel (CNC)',
    shrinkage_factor: 1.000,
    extra_backlash: 0.02,
    tip_relief: 0.02,
    tip_relief_start: 0.92,
    root_fillet_scale: 1.0,
    lengthwise_crown: 0.005,
    profile_crown: 0.003,
    min_wall: 0.0,
    clearance_add: 0.00,
    tolerance: 0.02,
    sigma_allow_bend: 250.0,
    sigma_allow_contact: 600.0,
    description: 'Steel 1045 (CNC) — High-strength industrial gear alloy (σ_allow = 250 MPa)'
  },
  NONE: {
    name: 'Theoretical (None)',
    shrinkage_factor: 1.000,
    extra_backlash: 0.00,
    tip_relief: 0.00,
    tip_relief_start: 1.00,
    root_fillet_scale: 1.0,
    lengthwise_crown: 0.000,
    profile_crown: 0.000,
    min_wall: 0.0,
    clearance_add: 0.00,
    tolerance: 0.00,
    sigma_allow_bend: 250.0,
    sigma_allow_contact: 600.0,
    description: 'No compensation — nominal CAD geometry reference (σ_allow = 250 MPa)'
  }
};

/**
 * Calculates complete gear dimensions, kinematics, forces, and stress analysis.
 */
export function calculateGearDesign(inputs) {
  const m = Number(inputs.m) || 3.0;
  const Np = Math.round(Number(inputs.Np)) || 16;
  const Ng = Math.round(Number(inputs.Ng)) || 48;
  const phi_deg = Number(inputs.phi_deg) || 20.0;
  const Sigma_deg = Number(inputs.Sigma_deg) || 90.0;
  const n_pinions = Math.round(Number(inputs.n_pinions)) || 3;
  const khw_factor = Number(inputs.khw_factor) || 2.00;
  const c_factor = Number(inputs.c_factor) || 0.188;
  const f_factor = Number(inputs.f_factor) || 0.28;
  const T_in_ring = Number(inputs.T_in_ring) || 20.0;
  const n_in_ring = Number(inputs.n_in_ring) || 100.0;
  const eta = Number(inputs.eta) || 0.97;
  const sigma_allow_bend = Number(inputs.sigma_allow_bend) || 250.0;
  const materialKey = (inputs.print_material || 'PLA').toUpperCase();
  const ps = MATERIAL_PRESETS[materialKey] || MATERIAL_PRESETS.PLA;

  const phi = (phi_deg * Math.PI) / 180;
  const Sigma_r = (Sigma_deg * Math.PI) / 180;
  const i_ratio = Ng / Np;

  // Pitch diameters
  const dp = m * Np;
  const dg = m * Ng;

  // Pitch cone angles
  const gamma_p = Math.atan2(Math.sin(Sigma_r), Ng / Np + Math.cos(Sigma_r));
  const gamma_g = Sigma_r - gamma_p;

  // Cone distances
  const Ao = dp / (2 * Math.sin(gamma_p));
  const F = f_factor * Ao;
  const Am = Ao - F / 2;
  const Ai = Ao - F;

  // Cutter radius (auto = Am)
  let r_cutter = Number(inputs.r_cutter);
  if (!r_cutter || isNaN(r_cutter) || r_cutter <= 0) {
    r_cutter = Am;
  }

  // Tooth dimensions (Gleason unequal addendum: 60% pinion, 40% gear)
  const hw = khw_factor * m;
  const c_std = c_factor * m;
  const ht = hw + c_std;

  const a_p = 0.60 * hw;
  const a_g = 0.40 * hw;
  const b_p = ht - a_p;
  const b_g = ht - a_g;

  // Tooth thickness (Gleason shift balance)
  const s_nom = (Math.PI * m) / 2;
  const s_shift = 0.180 * m;
  const s_p = s_nom + s_shift;
  const s_g = s_nom - s_shift;

  // Outside diameters
  const Do_p = dp + 2 * a_p * Math.cos(gamma_p);
  const Do_g = dg + 2 * a_g * Math.cos(gamma_g);

  // Back cone radius & virtual teeth
  const rb_p = dp / (2 * Math.cos(gamma_p));
  const rb_g = dg / (2 * Math.cos(gamma_g));
  const Nv_p = Np / Math.cos(gamma_p);
  const Nv_g = Ng / Math.cos(gamma_g);

  // Contact ratio
  const rv_p = (m * Nv_p) / 2;
  const rv_g = (m * Nv_g) / 2;
  const rav_p = rv_p + a_p;
  const rav_g = rv_g + a_g;
  const rbv_p = rv_p * Math.cos(phi);
  const rbv_g = rv_g * Math.cos(phi);
  const pb = Math.PI * m * Math.cos(phi);
  const CR =
    (Math.sqrt(rav_p * rav_p - rbv_p * rbv_p) +
      Math.sqrt(rav_g * rav_g - rbv_g * rbv_g) -
      (rv_p + rv_g) * Math.sin(phi)) /
    pb;

  // Mounting distances
  const MD_p = Ao * Math.cos(gamma_p) - a_p * Math.sin(gamma_p);
  const MD_g = Ao * Math.cos(gamma_g) - a_g * Math.sin(gamma_g);

  // Circular & diametral pitch
  const pc = Math.PI * m;
  const P_d = 25.4 / m;

  // Drivetrain kinematics
  const n_pinion_out = n_in_ring * i_ratio;
  const T_ring_per_mesh = T_in_ring / n_pinions;
  const T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_ring * 2 * Math.PI * n_in_ring) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  // Forces at mean cone distance
  const dg_mean = (dg * Am) / Ao;
  const Ft = (2 * T_ring_per_mesh * 1000) / dg_mean;
  const Fr_p = Ft * Math.tan(phi) * Math.cos(gamma_p);
  const Fa_p = Ft * Math.tan(phi) * Math.sin(gamma_p);
  const F_resultant = Math.sqrt(Ft * Ft + Fr_p * Fr_p + Fa_p * Fa_p);

  // Lewis bending stress
  const m_mean = (m * Am) / Ao;
  const Y_p = (0.484 - 2.87 / Nv_p) * Math.pow(s_p / s_nom, 2);
  const Y_g = (0.484 - 2.87 / Nv_g) * Math.pow(s_g / s_nom, 2);
  const sigma_b_p = Ft / (F * m_mean * Y_p);
  const sigma_b_g = Ft / (F * m_mean * Y_g);
  const SF_p = sigma_allow_bend / (sigma_b_p || 1e-6);
  const SF_g = sigma_allow_bend / (sigma_b_g || 1e-6);

  // Print compensation adjustments
  const crowning_p = {
    lengthwise: ps.lengthwise_crown,
    profile: ps.profile_crown,
    tip_relief: ps.tip_relief,
    tip_relief_start: ps.tip_relief_start
  };
  const crowning_g = { ...crowning_p };

  const s_p_print = s_p - ps.extra_backlash;
  const s_g_print = s_g - ps.extra_backlash;
  const c_print = c_std + ps.clearance_add;
  const ht_print = hw + c_print;
  const b_p_print = ht_print - a_p;
  const b_g_print = ht_print - a_g;

  return {
    m,
    Np,
    Ng,
    phi_deg,
    phi,
    Sigma_deg,
    Sigma_r,
    n_pinions,
    i_ratio,
    dp,
    dg,
    gamma_p,
    gamma_g,
    gamma_p_deg: (gamma_p * 180) / Math.PI,
    gamma_g_deg: (gamma_g * 180) / Math.PI,
    Ao,
    Am,
    Ai,
    F,
    f_factor,
    r_cutter,
    khw_factor,
    c_factor,
    hw,
    ht,
    c_std,
    a_p,
    a_g,
    b_p,
    b_g,
    s_nom,
    s_shift,
    s_p,
    s_g,
    Do_p,
    Do_g,
    rb_p,
    rb_g,
    Nv_p,
    Nv_g,
    CR,
    MD_p,
    MD_g,
    pc,
    P_d,
    T_in_ring,
    n_in_ring,
    eta,
    n_pinion_out,
    T_ring_per_mesh,
    T_pinion_each,
    P_in_total,
    P_out_each,
    Ft,
    Fr_p,
    Fa_p,
    F_resultant,
    sigma_b_p,
    sigma_b_g,
    SF_p,
    SF_g,
    sigma_allow_bend,
    ps,
    print_material: materialKey,
    crowning_p,
    crowning_g,
    s_p_print,
    s_g_print,
    c_print,
    ht_print,
    b_p_print,
    b_g_print
  };
}

/**
 * Generates 2D Involute Profile (all N teeth) in Tregold back-cone plane.
 */
export function generateInvoluteProfile(N, m, phi, a, b, n_inv, n_top, n_root, tooth_thick) {
  const r_p = (m * N) / 2;
  const r_b = r_p * Math.cos(phi);
  const r_a = r_p + a;
  const r_d = Math.max(r_p - b, 0.3 * r_b);

  const tau = tooth_thick / (2 * r_p);
  const inv_phi = Math.tan(phi) - phi;

  const root_below_base = r_d < r_b;
  const r_inv_start = Math.max(r_b, r_d);

  const alpha_tip = Math.acos(Math.min(r_b / r_a, 1));
  const theta_tip = tau + inv_phi - (Math.tan(alpha_tip) - alpha_tip);

  let theta_root;
  if (root_below_base) {
    theta_root = tau + inv_phi;
  } else {
    const alpha_root = Math.acos(Math.min(r_b / r_d, 1));
    theta_root = tau + inv_phi - (Math.tan(alpha_root) - alpha_root);
  }
  const theta_next_root = (2 * Math.PI) / N - theta_root;

  const tooth_r = [];
  const tooth_t = [];

  // Left flank
  if (root_below_base) {
    const nr = Math.max(3, Math.round(n_inv * 0.2));
    for (let i = 0; i < nr; i++) {
      const rr = r_d + (i / (nr - 1 || 1)) * (r_b - r_d);
      tooth_r.push(rr);
      tooth_t.push(-(tau + inv_phi));
    }
  }

  for (let i = 0; i < n_inv; i++) {
    const rr = r_inv_start + (i / (n_inv - 1 || 1)) * (r_a - r_inv_start);
    const alpha = Math.acos(Math.min(r_b / rr, 1));
    const inv_alpha = Math.tan(alpha) - alpha;
    const tt = -(tau + inv_phi - inv_alpha);
    tooth_r.push(rr);
    tooth_t.push(tt);
  }

  // Tip land
  if (n_top > 0) {
    const n_tip_pts = n_top + 2;
    for (let i = 1; i < n_tip_pts - 1; i++) {
      const tt_top = -theta_tip + (i / (n_tip_pts - 1)) * (2 * theta_tip);
      tooth_r.push(r_a);
      tooth_t.push(tt_top);
    }
  }

  // Right flank
  for (let i = 0; i < n_inv; i++) {
    const rr = r_a - (i / (n_inv - 1 || 1)) * (r_a - r_inv_start);
    const alpha = Math.acos(Math.min(r_b / rr, 1));
    const inv_alpha = Math.tan(alpha) - alpha;
    const tt = tau + inv_phi - inv_alpha;
    tooth_r.push(rr);
    tooth_t.push(tt);
  }

  if (root_below_base) {
    const nr = Math.max(3, Math.round(n_inv * 0.2));
    for (let i = 0; i < nr; i++) {
      const rr = r_b - (i / (nr - 1 || 1)) * (r_b - r_d);
      tooth_r.push(rr);
      tooth_t.push(tau + inv_phi);
    }
  }

  // Root land
  const n_root_pts = Math.max(n_root, 2);
  const n_root_total = n_root_pts + 2;
  for (let i = 1; i < n_root_total - 1; i++) {
    const tt_root = theta_root + (i / (n_root_total - 1)) * (theta_next_root - theta_root);
    tooth_r.push(r_d);
    tooth_t.push(tt_root);
  }

  // Replicate for all N teeth
  const M_tooth = tooth_r.length;
  const angles = [];
  const radii = [];

  for (let t = 0; t < N; t++) {
    const offset = (t * 2 * Math.PI) / N;
    for (let j = 0; j < M_tooth; j++) {
      angles.push(tooth_t[j] + offset);
      radii.push(tooth_r[j]);
    }
  }

  return { angles, radii, M: angles.length };
}

export function computeSmoothNormals(verts, faces) {
  const n_v = verts.length;
  const normals = new Float32Array(n_v * 3);
  for (let f = 0; f < faces.length; f++) {
    const [i1, i2, i3] = faces[f];
    const v1 = verts[i1], v2 = verts[i2], v3 = verts[i3];
    const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
    const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
    const nx = ay * bz - az * by;
    const ny = az * bx - ax * bz;
    const nz = ax * by - ay * bx;
    const len = Math.hypot(nx, ny, nz) || 1;
    const fnx = nx / len, fny = ny / len, fnz = nz / len;
    for (const idx of [i1, i2, i3]) {
      normals[idx * 3] += fnx;
      normals[idx * 3 + 1] += fny;
      normals[idx * 3 + 2] += fnz;
    }
  }
  for (let i = 0; i < n_v; i++) {
    const nx = normals[i * 3], ny = normals[i * 3 + 1], nz = normals[i * 3 + 2];
    const len = Math.hypot(nx, ny, nz);
    if (len > 1e-6) {
      normals[i * 3] /= len;
      normals[i * 3 + 1] /= len;
      normals[i * 3 + 2] /= len;
    }
  }
  return normals;
}

/**
 * Builds 3D Bevel Mesh (Straight, Zerol, and Spiral Bevel) with true conical
 * projection, circular cutter arc offset, and watertight triangulation caps matching MATLAB.
 */
export function buildBevelMesh(
  N,
  m,
  phi,
  a,
  b,
  gamma,
  Ao,
  F,
  r_cutter,
  n_inv = 16,
  n_sec = 12,
  n_top = 3,
  n_root = 3,
  tooth_thick,
  crowning = {},
  shrinkage = 1.0,
  beta_deg = 0,
  hand = 1
) {
  const C_L = crowning.lengthwise || 0;
  const C_P = crowning.profile || 0;
  const C_tip = crowning.tip_relief || 0;
  const tip_start = crowning.tip_relief_start || 0.85;

  const Ai = Ao - F;
  const Am = Ao - F / 2;
  const r_p = (m * N) / 2;
  const r_a = r_p + a;

  // Transverse pressure angle for spiral bevel (Gleason standard matching MATLAB)
  let phi_eff = phi;
  if (beta_deg && Math.abs(beta_deg) > 1e-4) {
    const beta_rad = (beta_deg * Math.PI) / 180;
    phi_eff = Math.atan(Math.tan(phi) / Math.cos(beta_rad));
  }

  const s_thick = tooth_thick || ((Math.PI * m) / 2);

  // 1. Reference 2D profile at outer cone
  const { angles: ref_angles, radii: ref_radii, M } = generateInvoluteProfile(
    N,
    m,
    phi_eff,
    a,
    b,
    n_inv,
    n_top,
    n_root,
    s_thick
  );

  const verts_3d = [];

  // 2. Sections along face width
  for (let s = 0; s < n_sec; s++) {
    const A_s = Ai + (s / (n_sec - 1 || 1)) * F;
    const sf = A_s / Ao;

    // Tooth trace circular-arc offset (Zerol or Spiral Bevel)
    let delta_theta = 0;
    if (r_cutter && r_cutter > 0) {
      if (!beta_deg || Math.abs(beta_deg) < 1e-4) {
        // Zerol Bevel: cutter centered at Am on pitch line
        const delta = A_s - Am;
        const arg = r_cutter * r_cutter - delta * delta;
        if (arg > 0) {
          delta_theta = -(r_cutter - Math.sqrt(arg)) / (A_s * Math.sin(gamma));
        }
      } else {
        // Spiral Bevel: Gleason circular cutter arc at mean spiral angle beta_m
        const beta_rad = (beta_deg * Math.PI) / 180;
        const uc = Am - r_cutter * Math.sin(beta_rad);
        const vc = r_cutter * Math.cos(beta_rad);
        const delta_u = A_s - uc;
        const arg = Math.max(0, r_cutter * r_cutter - delta_u * delta_u);
        const v_s = vc - Math.sqrt(arg);
        delta_theta = hand * (v_s / (A_s * Math.sin(gamma)));
      }
    }

    const r_cone = A_s * Math.sin(gamma);
    const z_cone = A_s * Math.cos(gamma);
    const r_pitch_local = r_p * sf;

    // Crowning parameters for section
    const t_norm = (2 * s) / (n_sec - 1 || 1) - 1;
    const delta_L = C_L * t_norm * t_norm;

    const r_d_local = Math.max((r_p - b) * sf, 0);
    const r_a_local = r_a * sf;
    const h_range = r_a_local - r_d_local;

    const r_relief_start = r_cone + a * sf * tip_start * Math.cos(gamma);
    const r_a_cone = r_cone + a * sf * Math.cos(gamma);

    // Smooth sine taper: at toe (s = 0) and heel (s = n_sec - 1), w_s = 0,
    // guaranteeing 100% mathematically flat planar end faces perpendicular to the gear axis.
    const w_s = (n_sec > 1) ? Math.sin((Math.PI * s) / (n_sec - 1)) : 0;

    for (let k = 0; k < M; k++) {
      const scaled_radius = ref_radii[k] * sf;
      const scaled_angle = ref_angles[k] + delta_theta;

      const delta_r = scaled_radius - r_pitch_local;
      let r_3d = r_cone + delta_r * Math.cos(gamma);
      let z_3d = z_cone - w_s * delta_r * Math.sin(gamma);

      // Apply Lengthwise crowning
      if (delta_L > 0) {
        r_3d -= delta_L * Math.cos(gamma);
        z_3d += w_s * delta_L * Math.sin(gamma);
      }

      // Apply Profile crowning
      if (C_P > 0 && h_range > 0) {
        const delta_from_pitch = r_3d - r_cone;
        let h_frac = (delta_from_pitch + b * sf) / h_range;
        h_frac = Math.max(0, Math.min(1, h_frac));
        const delta_P = C_P * Math.pow(2 * h_frac - 1, 2);
        r_3d -= delta_P * Math.cos(gamma);
        z_3d += w_s * delta_P * Math.sin(gamma);
      }

      // Apply Tip relief
      if (C_tip > 0 && r_3d > r_relief_start) {
        const frac = Math.min(1, Math.max(0, (r_3d - r_relief_start) / (r_a_cone - r_relief_start + 1e-6)));
        r_3d -= C_tip * frac * Math.cos(gamma);
        z_3d += w_s * C_tip * frac * Math.sin(gamma);
      }

      // Shrinkage scaling
      const x = r_3d * Math.cos(scaled_angle) * shrinkage;
      const y = r_3d * Math.sin(scaled_angle) * shrinkage;
      const z = z_3d * shrinkage;

      verts_3d.push([x, y, z]);
    }
  }

  // 3. Lateral Faces connecting adjacent cross-sections
  const lat_faces = [];
  for (let s = 0; s < n_sec - 1; s++) {
    for (let k = 0; k < M; k++) {
      const k_next = (k + 1) % M;
      const v1 = s * M + k;
      const v2 = s * M + k_next;
      const v3 = (s + 1) * M + k_next;
      const v4 = (s + 1) * M + k;

      lat_faces.push([v1, v2, v3]);
      lat_faces.push([v1, v3, v4]);
    }
  }

  // 4. End Caps (Inner Toe & Outer Heel) via Radial Fan Triangulation to Star Center
  // Both caps are 100% mathematically flat planes perpendicular to the gear axis.
  const cap_faces = [];

  // Toe Center Vertex (s = 0)
  const z_c_toe = verts_3d[0][2];
  const idx_c_toe = verts_3d.length;
  verts_3d.push([0, 0, z_c_toe]);

  for (let k = 0; k < M; k++) {
    const k_next = (k + 1) % M;
    // Outward normal points toward apex (-Z), opposite to lateral face traversal k -> k_next
    cap_faces.push([idx_c_toe, k_next, k]);
  }

  // Heel Center Vertex (s = n_sec - 1)
  const idx_outer_start = (n_sec - 1) * M;
  const z_c_heel = verts_3d[idx_outer_start][2];
  const idx_c_heel = verts_3d.length;
  verts_3d.push([0, 0, z_c_heel]);

  for (let k = 0; k < M; k++) {
    const k_next = (k + 1) % M;
    // Outward normal points away from apex (+Z), opposite to lateral face traversal
    cap_faces.push([idx_c_heel, idx_outer_start + k, idx_outer_start + k_next]);
  }

  const all_faces = lat_faces.concat(cap_faces);

  return {
    vertices: verts_3d,
    faces: all_faces,
    n_lat_faces: lat_faces.length,
    isBevel: true,
    n_verts: verts_3d.length,
    n_faces: all_faces.length,
    M,
    n_sec
  };
}

// =========================================================================
// INVOLUTE SPUR GEAR ENGINE (Ported from Matlab_Spur)
// =========================================================================

/**
 * Generates 2D closed polygon coordinates of an involute spur gear.
 * Guarantees zero duplicate vertices at curve junctions.
 */
export function generateSpurProfile2D(N, m, phi, a, b, tooth_thick, n_pts = 60) {
  const r_p = (m * N) / 2;
  const r_b = r_p * Math.cos(phi);
  const r_a = r_p + a;
  const r_d = Math.max(r_p - b, 0.25 * r_b);

  const tau = tooth_thick / (2 * r_p);
  const inv_phi = Math.tan(phi) - phi;

  const root_below_base = r_d < r_b;
  const r_inv_start = Math.max(r_b, r_d);

  const alpha_tip = Math.acos(Math.min(r_b / r_a, 1.0));
  const theta_tip = tau + inv_phi - (Math.tan(alpha_tip) - alpha_tip);

  let theta_root;
  if (root_below_base) {
    theta_root = tau + inv_phi;
  } else {
    const alpha_root = Math.acos(Math.min(r_b / r_d, 1.0));
    theta_root = tau + inv_phi - (Math.tan(alpha_root) - alpha_root);
  }
  const theta_next_root = (2 * Math.PI) / N - theta_root;

  const xc_tooth = [];
  const yc_tooth = [];

  // 1. Left root transition
  if (root_below_base) {
    const nr = Math.max(5, Math.round(n_pts * 0.12));
    for (let i = 0; i < nr - 1; i++) {
      const rr = r_d + (i / (nr - 1)) * (r_b - r_d);
      const tt = -(tau + inv_phi);
      xc_tooth.push(rr * Math.cos(tt));
      yc_tooth.push(rr * Math.sin(tt));
    }
  }

  // 2. Left involute
  for (let i = 0; i < n_pts - 1; i++) {
    const rr = r_inv_start + (i / (n_pts - 1)) * (r_a - r_inv_start);
    const alpha = Math.acos(Math.min(r_b / rr, 1.0));
    const inv_alpha = Math.tan(alpha) - alpha;
    const tt = -(tau + inv_phi - inv_alpha);
    xc_tooth.push(rr * Math.cos(tt));
    yc_tooth.push(rr * Math.sin(tt));
  }

  // 3. Tip land arc
  const n_tip = Math.max(8, Math.round(n_pts * 0.1));
  for (let i = 0; i < n_tip - 1; i++) {
    const tt = -theta_tip + (i / (n_tip - 1)) * (2 * theta_tip);
    xc_tooth.push(r_a * Math.cos(tt));
    yc_tooth.push(r_a * Math.sin(tt));
  }

  // 4. Right involute
  for (let i = 0; i < n_pts - 1; i++) {
    const rr = r_a - (i / (n_pts - 1)) * (r_a - r_inv_start);
    const alpha = Math.acos(Math.min(r_b / rr, 1.0));
    const inv_alpha = Math.tan(alpha) - alpha;
    const tt = tau + inv_phi - inv_alpha;
    xc_tooth.push(rr * Math.cos(tt));
    yc_tooth.push(rr * Math.sin(tt));
  }

  // 5. Right root transition
  if (root_below_base) {
    const nr = Math.max(5, Math.round(n_pts * 0.12));
    for (let i = 0; i < nr - 1; i++) {
      const rr = r_b - (i / (nr - 1)) * (r_b - r_d);
      const tt = tau + inv_phi;
      xc_tooth.push(rr * Math.cos(tt));
      yc_tooth.push(rr * Math.sin(tt));
    }
  }

  // 6. Root land arc
  const n_root_pts = Math.max(8, Math.round(n_pts * 0.1));
  for (let i = 0; i < n_root_pts - 1; i++) {
    const tt = theta_root + (i / (n_root_pts - 1)) * (theta_next_root - theta_root);
    xc_tooth.push(r_d * Math.cos(tt));
    yc_tooth.push(r_d * Math.sin(tt));
  }

  // Replicate for all N teeth around 360 degrees
  const M_raw = xc_tooth.length;
  const xc_raw = [];
  const yc_raw = [];

  for (let t = 0; t < N; t++) {
    const angle = (t * 2 * Math.PI) / N;
    const c = Math.cos(angle);
    const s = Math.sin(angle);
    for (let j = 0; j < M_raw; j++) {
      xc_raw.push(xc_tooth[j] * c - yc_tooth[j] * s);
      yc_raw.push(xc_tooth[j] * s + yc_tooth[j] * c);
    }
  }

  // Filter collinear and duplicate vertices to guarantee 0 degenerate triangles in CAD triangulation
  const xc = [];
  const yc = [];
  const nRaw = xc_raw.length;
  for (let i = 0; i < nRaw; i++) {
    const ip = (i - 1 + nRaw) % nRaw;
    const inxt = (i + 1) % nRaw;
    const ax = xc_raw[i] - xc_raw[ip];
    const ay = yc_raw[i] - yc_raw[ip];
    const bx = xc_raw[inxt] - xc_raw[i];
    const by = yc_raw[inxt] - yc_raw[i];
    const cross = Math.abs(ax * by - ay * bx);
    const segLenSq = ax * ax + ay * ay;
    // Skip if point is duplicate (segLenSq < 1e-10) or collinear with both neighbors (cross < 1e-7)
    if (segLenSq > 1e-10 && cross > 1e-7) {
      xc.push(xc_raw[i]);
      yc.push(yc_raw[i]);
    }
  }

  return { xc, yc, r_p, r_b, r_a, r_d };
}

/**
 * Calculates complete spur gear dimensions, forces, kinematics, and AGMA/Lewis stress.
 */
export function calculateSpurDesign(inputs) {
  const m = Number(inputs.m) || 3.0;
  const Np = Math.round(Number(inputs.Np)) || 16;
  const Ng = Math.round(Number(inputs.Ng)) || 48;
  const phi_deg = Number(inputs.phi_deg) || 20.0;
  const F = Number(inputs.F) || 25.0;
  const n_pinions = Math.round(Number(inputs.n_pinions)) || 3;
  const T_in_gear = Number(inputs.T_in_ring || inputs.T_in_gear) || 20.0;
  const n_in_gear = Number(inputs.n_in_ring || inputs.n_in_gear) || 100.0;
  const eta = Number(inputs.eta) || 0.97;
  const sigma_allow_bend = Number(inputs.sigma_allow_bend) || 250.0;
  const sigma_allow_contact = 1500.0;

  const phi = (phi_deg * Math.PI) / 180;
  const dp = m * Np;
  const dg = m * Ng;
  const rp_p = dp / 2;
  const rp_g = dg / 2;
  const rb_p = rp_p * Math.cos(phi);
  const rb_g = rp_g * Math.cos(phi);

  const center_dist = rp_p + rp_g; // 96.0 mm
  const i_ratio = Ng / Np;

  const khw_factor = 2.0;
  const c_factor = 0.188;
  const hw = khw_factor * m;
  const ht = hw + c_factor * m;
  const c_std = c_factor * m;

  const a_p = 0.6 * hw;
  const a_g = 0.4 * hw;
  const b_p = ht - a_p;
  const b_g = ht - a_g;

  const s_nom = (Math.PI * m) / 2;
  const s_shift = 0.18 * m;
  const s_p = s_nom + s_shift;
  const s_g = s_nom - s_shift;

  const ra_p = rp_p + a_p;
  const ra_g = rp_g + a_g;
  const rd_p = rp_p - b_p;
  const rd_g = rp_g - b_g;

  // Transverse Contact Ratio
  const L_contact =
    Math.sqrt(ra_p * ra_p - rb_p * rb_p) +
    Math.sqrt(ra_g * ra_g - rb_g * rb_g) -
    center_dist * Math.sin(phi);
  const pb = Math.PI * m * Math.cos(phi);
  const CR = L_contact / pb;

  // Kinematics & forces
  const n_pinion_out = n_in_gear * i_ratio;
  const T_gear_per_mesh = T_in_gear / n_pinions;
  const T_pinion_each = (T_gear_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_gear * 2 * Math.PI * n_in_gear) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  const Ft = (2 * T_gear_per_mesh * 1000) / dg;
  const Fr = Ft * Math.tan(phi);
  const F_resultant = Math.sqrt(Ft * Ft + Fr * Fr);

  // Lewis Bending Stress
  const Y_p = (0.484 - 2.87 / Np) * Math.pow(s_p / s_nom, 2);
  const Y_g = (0.484 - 2.87 / Ng) * Math.pow(s_g / s_nom, 2);
  const sigma_b_p = Ft / (F * m * Y_p);
  const sigma_b_g = Ft / (F * m * Y_g);
  const SF_b_p = sigma_allow_bend / Math.max(sigma_b_p, 1e-6);
  const SF_b_g = sigma_allow_bend / Math.max(sigma_b_g, 1e-6);

  // Hertzian Contact Stress
  const E_mod = 206000;
  const nu = 0.3;
  const E_star = E_mod / (2 * (1 - nu * nu));
  const rho_p = rb_p * Math.tan(phi);
  const rho_g = rb_g * Math.tan(phi);
  const rho_eq = (rho_p * rho_g) / (rho_p + rho_g);
  const sigma_H = Math.sqrt((Ft / (Math.PI * F * Math.cos(phi))) * (E_star / rho_eq));
  const SF_contact = sigma_allow_contact / Math.max(sigma_H, 1e-6);

  return {
    gear_type: 'spur',
    m,
    Np,
    Ng,
    phi_deg,
    phi,
    F,
    n_pinions,
    i_ratio,
    dp,
    dg,
    rp_p,
    rp_g,
    rb_p,
    rb_g,
    ra_p,
    ra_g,
    rd_p,
    rd_g,
    center_dist,
    hw,
    ht,
    c_std,
    a_p,
    a_g,
    b_p,
    b_g,
    s_p,
    s_g,
    CR,
    L_contact,
    pb,
    T_in_ring: T_in_gear,
    n_in_ring: n_in_gear,
    n_pinion_out,
    T_ring_per_mesh: T_gear_per_mesh,
    T_pinion_each,
    P_in_total,
    P_out_each,
    Ft,
    Fr,
    F_resultant,
    sigma_b_p,
    sigma_b_g,
    SF_b_p,
    SF_b_g,
    sigma_H,
    SF_contact,
    Ao: center_dist,
    Am: center_dist,
    gamma_p: 0,
    gamma_g: 0,
    gamma_p_deg: 0,
    gamma_g_deg: 0,
    r_cutter: 0,
    MD_p: 0,
    MD_g: 0,
    material: inputs.print_material || 'PLA'
  };
}

/**
 * Builds watertight 3D solid mesh for an involute spur gear.
 * Uses dedicated planar cap vertices with strict normals [0, 1, 0] (top) and [0, -1, 0] (bottom)
 * in Three.js space, guaranteeing 100% flat, silky smooth end caps without triangular creases.
 */
export function buildSpurMesh(N, m, phi, a, b, tooth_thick, F = 25, n_sec = 4, r_bore = 0, n_pts = 60) {
  const prof = generateSpurProfile2D(N, m, phi, a, b, tooth_thick, n_pts);
  const xc = prof.xc;
  const yc = prof.yc;
  const M_outer = xc.length;

  const has_bore = r_bore > 1.0 && r_bore < prof.r_d * 0.85;
  let xb = [], yb = [];
  let M_inner = 0;
  if (has_bore) {
    const n_bore = Math.max(36, Math.round(N * 4));
    for (let k = 0; k < n_bore; k++) {
      const th = (k * 2 * Math.PI) / n_bore;
      xb.push(r_bore * Math.cos(th));
      yb.push(r_bore * Math.sin(th));
    }
    M_inner = n_bore;
  }

  const n_slice_verts = M_outer + M_inner;
  const z_levels = [];
  for (let s = 0; s < n_sec; s++) {
    z_levels.push(-F / 2 + (s / (n_sec - 1)) * F);
  }

  // 1. Side wall vertices
  const side_verts = [];
  for (let s = 0; s < n_sec; s++) {
    const z = z_levels[s];
    for (let k = 0; k < M_outer; k++) {
      side_verts.push([xc[k], yc[k], z]);
    }
    if (has_bore) {
      for (let k = 0; k < M_inner; k++) {
        side_verts.push([xb[k], yb[k], z]);
      }
    }
  }

  // 2. Side wall faces
  const side_faces = [];
  for (let s = 0; s < n_sec - 1; s++) {
    const b1 = s * n_slice_verts;
    const b2 = (s + 1) * n_slice_verts;
    for (let k = 0; k < M_outer; k++) {
      const kn = (k + 1) % M_outer;
      side_faces.push([b1 + k, b1 + kn, b2 + kn]);
      side_faces.push([b1 + k, b2 + kn, b2 + k]);
    }
    if (has_bore) {
      for (let k = 0; k < M_inner; k++) {
        const kn = (k + 1) % M_inner;
        const v1 = b1 + M_outer + k;
        const v2 = b1 + M_outer + kn;
        const v3 = b2 + M_outer + kn;
        const v4 = b2 + M_outer + k;
        side_faces.push([v1, v3, v2]);
        side_faces.push([v1, v4, v3]);
      }
    }
  }

  // 3. Planar End Caps
  const bot_faces = [];
  const top_faces = [];
  const b_top = (n_sec - 1) * n_slice_verts;

  if (!has_bore) {
    // Solid Spur Gear: Clean planar triangulation without center star vertex
    // Eliminates radial spoke/texture lines in SolidWorks and CATIA
    const outer_pts = [];
    for (let k = 0; k < M_outer; k++) {
      outer_pts.push(new THREE.Vector2(xc[k], yc[k]));
    }
    const capTris = THREE.ShapeUtils.triangulateShape(outer_pts, []);
    for (const tri of capTris) {
      const [i1, i2, i3] = tri;
      const v1 = side_verts[i1], v2 = side_verts[i2], v3 = side_verts[i3];
      const nz = (v2[0] - v1[0]) * (v3[1] - v1[1]) - (v2[1] - v1[1]) * (v3[0] - v1[0]);
      // Bottom cap outward normal points in -Z
      bot_faces.push(nz > 0 ? [i1, i3, i2] : [i1, i2, i3]);
      // Top cap outward normal points in +Z
      const idx1 = b_top + i1, idx2 = b_top + i2, idx3 = b_top + i3;
      top_faces.push(nz < 0 ? [idx1, idx3, idx2] : [idx1, idx2, idx3]);
    }
  } else {
    // Gear with Bore: Annular cap directly indexing side_verts without detached duplicate vertices
    const outer_pts = [];
    for (let k = 0; k < M_outer; k++) {
      outer_pts.push(new THREE.Vector2(xc[k], yc[k]));
    }
    const hole_pts = [];
    for (let k = 0; k < M_inner; k++) {
      const th = 2 * Math.PI - (k * 2 * Math.PI) / M_inner;
      hole_pts.push(new THREE.Vector2(r_bore * Math.cos(th), r_bore * Math.sin(th)));
    }
    const raw_cap_tris = THREE.ShapeUtils.triangulateShape(outer_pts, [hole_pts]);
    const all_cap_pts = outer_pts.concat(hole_pts);

    function mapCapToSlice(idx, sliceBase) {
      if (idx < M_outer) return sliceBase + idx;
      const bore_k = idx - M_outer;
      return sliceBase + M_outer + bore_k;
    }

    for (let i = 0; i < raw_cap_tris.length; i++) {
      const [i1, i2, i3] = raw_cap_tris[i];
      const p1 = all_cap_pts[i1], p2 = all_cap_pts[i2], p3 = all_cap_pts[i3];
      const cz = (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);

      const b_i1 = mapCapToSlice(i1, 0), b_i2 = mapCapToSlice(i2, 0), b_i3 = mapCapToSlice(i3, 0);
      if (cz > 0) {
        bot_faces.push([b_i1, b_i3, b_i2]);
      } else {
        bot_faces.push([b_i1, b_i2, b_i3]);
      }

      const t_i1 = mapCapToSlice(i1, b_top), t_i2 = mapCapToSlice(i2, b_top), t_i3 = mapCapToSlice(i3, b_top);
      if (cz < 0) {
        top_faces.push([t_i1, t_i3, t_i2]);
      } else {
        top_faces.push([t_i1, t_i2, t_i3]);
      }
    }
  }

  const all_verts = side_verts;
  const all_faces = side_faces.concat(bot_faces, top_faces);

  return {
    vertices: all_verts,
    faces: all_faces,
    n_verts: all_verts.length,
    n_faces: all_faces.length,
    r_pitch: prof.r_p,
    r_root: prof.r_d,
    r_bore: r_bore,
    F: F
  };
}

// =========================================================================
// 8. INTERNAL SPUR GEAR (RING GEAR) GEOMETRY & MESH
// =========================================================================

export function calculateInternalSpurDesign(inputs = {}) {
  const m = parseFloat(inputs.m) || 3.0;
  const Np = parseInt(inputs.Np, 10) || 16;
  const Ng = parseInt(inputs.Ng, 10) || 48;
  const phi_deg = parseFloat(inputs.phi_deg) || 20.0;
  const phi = (phi_deg * Math.PI) / 180.0;
  const F = parseFloat(inputs.F) || 25.0;
  const n_pinions = parseInt(inputs.n_pinions, 10) || 3;

  const T_in_ring = parseFloat(inputs.T_in_ring) || 20.0;
  const n_in_ring = parseFloat(inputs.n_in_ring) || 100.0;
  const eta = parseFloat(inputs.eta) || 0.97;
  const sigma_allow_bend = parseFloat(inputs.sigma_allow_bend) || 250.0;
  const sigma_allow_contact = 1500.0;

  const dp = m * Np;
  const dg = m * Ng;
  const rp_p = dp / 2;
  const rp_g = dg / 2;
  const rb_p = rp_p * Math.cos(phi);
  const rb_g = rp_g * Math.cos(phi);

  const center_dist = rp_g - rp_p;
  const i_ratio = Ng / Np;

  const khw_factor = 2.0;
  const c_factor = 0.188;
  const hw = khw_factor * m;
  const ht = hw + c_factor * m;
  const c_std = c_factor * m;

  const a_p = 0.6 * hw;
  const b_p = ht - a_p;
  const a_g = 0.4 * hw;
  const b_g = ht - a_g;

  const s_nom = (Math.PI * m) / 2;
  const s_shift = 0.18 * m;
  const s_p = s_nom + s_shift;
  const s_g = s_nom - s_shift;

  const ra_p = rp_p + a_p;
  const rd_p = rp_p - b_p;

  const ra_g_int = rp_g - a_g;
  const rd_g_int = rp_g + b_g;
  const r_rim = rd_g_int + 12.0;
  const D_outer = 2 * r_rim;

  const L_p = Math.sqrt(Math.max(0, ra_p * ra_p - rb_p * rb_p));
  const L_g = Math.sqrt(Math.max(0, ra_g_int * ra_g_int - rb_g * rb_g));
  const L_contact = L_p - L_g + center_dist * Math.sin(phi);
  const pb = Math.PI * m * Math.cos(phi);
  const CR = L_contact / pb;

  const n_pinion_out = n_in_ring * i_ratio;
  const T_ring_per_mesh = T_in_ring / n_pinions;
  const T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_ring * 2 * Math.PI * n_in_ring) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  const Ft = (2 * T_ring_per_mesh * 1000) / dg;
  const Fr = Ft * Math.tan(phi);
  const F_resultant = Math.sqrt(Ft * Ft + Fr * Fr);

  const Y_p = (0.484 - 2.87 / Np) * Math.pow(s_p / s_nom, 2);
  const Y_g = (0.484 + 1.5 / Ng) * Math.pow(s_g / s_nom, 2);
  const sigma_b_p = Ft / (F * m * Y_p);
  const sigma_b_g = Ft / (F * m * Y_g);
  const SF_b_p = sigma_allow_bend / Math.max(sigma_b_p, 1e-6);
  const SF_b_g = sigma_allow_bend / Math.max(sigma_b_g, 1e-6);

  const E_mod = 206000;
  const nu = 0.30;
  const E_star = E_mod / (2 * (1 - nu * nu));
  const rho_p = rb_p * Math.tan(phi);
  const rho_g = rb_g * Math.tan(phi);
  const rho_eq = (rho_p * rho_g) / Math.max(rho_g - rho_p, 1e-3);
  const sigma_H = Math.sqrt((Ft / (Math.PI * F * Math.cos(phi))) * (E_star / rho_eq));
  const SF_contact = sigma_allow_contact / Math.max(sigma_H, 1e-6);

  return {
    gear_type: 'internal_spur',
    m, Np, Ng, phi_deg, phi, F, n_pinions, i_ratio, center_dist,
    dp, dg, rp_p, rp_g, rb_p, rb_g, ra_p, rd_p,
    ra_g_int, rd_g_int, r_rim, D_outer,
    hw, ht, c_std, a_p, a_g, b_p, b_g, s_p, s_g,
    CR, L_contact, pb,
    T_in_ring, n_in_ring, n_pinion_out,
    T_ring_per_mesh, T_pinion_each,
    P_in_total, P_out_each,
    Ft, Fr, F_resultant,
    sigma_b_p, sigma_b_g, SF_b_p, SF_b_g,
    sigma_H, SF_contact
  };
}

export function generateInternalSpurProfile2D(calc, n_pts = 36) {
  const Ng = calc.Ng;
  const phi = calc.phi;
  const r_pg = calc.rp_g;
  const r_bg = calc.rb_g;
  const r_ai = calc.ra_g_int;
  const r_di = calc.rd_g_int;
  const r_rim = calc.r_rim;

  const tau_g = calc.s_g / (2 * r_pg);
  const inv_phi = Math.tan(phi) - phi;

  // Corrected internal involute: thinner at tip, thicker at root
  // theta(r) = tau_g - inv_phi + inv_alpha(r)
  const alpha_ai = Math.acos(Math.min(r_bg / r_ai, 1.0));
  const inv_ai = Math.tan(alpha_ai) - alpha_ai;
  const theta_tip = tau_g - inv_phi + inv_ai;

  const alpha_di = Math.acos(Math.min(r_bg / r_di, 1.0));
  const inv_di = Math.tan(alpha_di) - alpha_di;
  const theta_root = tau_g - inv_phi + inv_di;
  const theta_next_root = (2 * Math.PI) / Ng - theta_root;

  const xc_single = [];
  const yc_single = [];

  // Left internal flank (root down to crest)
  for (let i = 0; i < n_pts - 1; i++) {
    const r = r_di + ((r_ai - r_di) * i) / (n_pts - 1);
    const a = Math.acos(Math.min(r_bg / r, 1.0));
    const inv_d = Math.tan(a) - a;
    const tt = -(tau_g - inv_phi + inv_d);
    xc_single.push(r * Math.cos(tt));
    yc_single.push(r * Math.sin(tt));
  }

  // Crest arc at r_ai
  const n_tip = Math.max(5, Math.round(n_pts * 0.15));
  for (let i = 0; i < n_tip - 1; i++) {
    const tt = -theta_tip + ((2 * theta_tip) * i) / (n_tip - 1);
    xc_single.push(r_ai * Math.cos(tt));
    yc_single.push(r_ai * Math.sin(tt));
  }

  // Right internal flank (crest up to root)
  for (let i = 0; i < n_pts - 1; i++) {
    const r = r_ai + ((r_di - r_ai) * i) / (n_pts - 1);
    const a = Math.acos(Math.min(r_bg / r, 1.0));
    const inv_u = Math.tan(a) - a;
    const tt = tau_g - inv_phi + inv_u;
    xc_single.push(r * Math.cos(tt));
    yc_single.push(r * Math.sin(tt));
  }

  // Root land arc at r_di
  const n_root = Math.max(5, Math.round(n_pts * 0.15));
  for (let i = 0; i < n_root - 1; i++) {
    const tt = theta_root + ((theta_next_root - theta_root) * i) / (n_root - 1);
    xc_single.push(r_di * Math.cos(tt));
    yc_single.push(r_di * Math.sin(tt));
  }

  // Replicate for Ng teeth, shifted by -pi/Ng so tooth space is at angle 0
  const M_single = xc_single.length;
  const xc_ring = [];
  const yc_ring = [];
  const rot_shift = -Math.PI / Ng;
  const c_shift = Math.cos(rot_shift);
  const s_shift = Math.sin(rot_shift);

  for (let t = 0; t < Ng; t++) {
    const angle = (t * 2 * Math.PI) / Ng;
    const c = Math.cos(angle);
    const s = Math.sin(angle);
    for (let k = 0; k < M_single; k++) {
      const xt = xc_single[k] * c - yc_single[k] * s;
      const yt = xc_single[k] * s + yc_single[k] * c;
      xc_ring.push(xt * c_shift - yt * s_shift);
      yc_ring.push(xt * s_shift + yt * c_shift);
    }
  }

  // Filter collinear and duplicate vertices
  const clean_xc = [];
  const clean_yc = [];
  const nRaw = xc_ring.length;
  for (let i = 0; i < nRaw; i++) {
    const ip = (i - 1 + nRaw) % nRaw;
    const inxt = (i + 1) % nRaw;
    const ax = xc_ring[i] - xc_ring[ip];
    const ay = yc_ring[i] - yc_ring[ip];
    const bx = xc_ring[inxt] - xc_ring[i];
    const by = yc_ring[inxt] - yc_ring[i];
    const cross = Math.abs(ax * by - ay * bx);
    const segLenSq = ax * ax + ay * ay;
    if (segLenSq > 1e-10 && cross > 1e-7) {
      clean_xc.push(xc_ring[i]);
      clean_yc.push(yc_ring[i]);
    }
  }

  // Outer rim circle
  const n_rim = Math.max(64, Ng * 3);
  const x_rim = [];
  const y_rim = [];
  for (let k = 0; k < n_rim; k++) {
    const th = (k * 2 * Math.PI) / n_rim;
    x_rim.push(r_rim * Math.cos(th));
    y_rim.push(r_rim * Math.sin(th));
  }

  return { xc_ring: clean_xc, yc_ring: clean_yc, x_rim, y_rim };
}

export function buildInternalRingMesh(calc, n_sec = 4, n_pts = 36) {
  const F = calc.F;
  const { xc_ring, yc_ring, x_rim, y_rim } = generateInternalSpurProfile2D(calc, n_pts);

  const M_teeth = xc_ring.length;
  const M_rim = x_rim.length;
  const n_slice = M_teeth + M_rim;

  const z_levels = [];
  for (let s = 0; s < n_sec; s++) {
    z_levels.push(-F / 2 + (F * s) / (n_sec - 1));
  }

  const side_verts = [];
  const side_faces = [];

  for (let s = 0; s < n_sec; s++) {
    const z = z_levels[s];
    // Inner teeth
    for (let k = 0; k < M_teeth; k++) {
      side_verts.push([xc_ring[k], yc_ring[k], z]);
    }
    // Outer rim
    for (let k = 0; k < M_rim; k++) {
      side_verts.push([x_rim[k], y_rim[k], z]);
    }
  }

  // Inner teeth lateral faces
  for (let s = 0; s < n_sec - 1; s++) {
    const b1 = s * n_slice;
    const b2 = (s + 1) * n_slice;
    for (let k = 0; k < M_teeth; k++) {
      const kn = (k + 1) % M_teeth;
      side_faces.push([b1 + k, b2 + kn, b1 + kn]);
      side_faces.push([b1 + k, b2 + k, b2 + kn]);
    }
  }

  // Outer rim lateral faces
  for (let s = 0; s < n_sec - 1; s++) {
    const b1 = s * n_slice + M_teeth;
    const b2 = (s + 1) * n_slice + M_teeth;
    for (let k = 0; k < M_rim; k++) {
      const kn = (k + 1) % M_rim;
      side_faces.push([b1 + k, b1 + kn, b2 + kn]);
      side_faces.push([b1 + k, b2 + kn, b2 + k]);
    }
  }

  // Planar End Caps (Outer rim CCW, inner teeth CW)
  const outer_pts = [];
  for (let k = 0; k < M_rim; k++) {
    outer_pts.push(new THREE.Vector2(x_rim[k], y_rim[k]));
  }
  const hole_pts = [];
  for (let k = M_teeth - 1; k >= 0; k--) {
    hole_pts.push(new THREE.Vector2(xc_ring[k], yc_ring[k]));
  }

  const raw_cap_tris = THREE.ShapeUtils.triangulateShape(outer_pts, [hole_pts]);
  const all_cap_pts = outer_pts.concat(hole_pts);

  function mapRingCapToSlice(idx, sliceBase) {
    if (idx < M_rim) return sliceBase + M_teeth + idx;
    const tooth_rev_k = idx - M_rim;
    const k_tooth = (M_teeth - 1) - tooth_rev_k;
    return sliceBase + k_tooth;
  }

  const bot_faces = [];
  const top_faces = [];
  const b_top = (n_sec - 1) * n_slice;

  for (let i = 0; i < raw_cap_tris.length; i++) {
    const [i1, i2, i3] = raw_cap_tris[i];
    const p1 = all_cap_pts[i1], p2 = all_cap_pts[i2], p3 = all_cap_pts[i3];
    const cz = (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);

    const b_i1 = mapRingCapToSlice(i1, 0), b_i2 = mapRingCapToSlice(i2, 0), b_i3 = mapRingCapToSlice(i3, 0);
    if (cz > 0) {
      bot_faces.push([b_i1, b_i3, b_i2]);
    } else {
      bot_faces.push([b_i1, b_i2, b_i3]);
    }

    const t_i1 = mapRingCapToSlice(i1, b_top), t_i2 = mapRingCapToSlice(i2, b_top), t_i3 = mapRingCapToSlice(i3, b_top);
    if (cz < 0) {
      top_faces.push([t_i1, t_i3, t_i2]);
    } else {
      top_faces.push([t_i1, t_i2, t_i3]);
    }
  }

  const all_verts = side_verts;
  const all_faces = side_faces.concat(bot_faces, top_faces);

  return {
    vertices: all_verts,
    faces: all_faces,
    n_verts: all_verts.length,
    n_faces: all_faces.length,
    r_pitch: calc.rp_g,
    r_rim: calc.r_rim,
    F: F
  };
}

/**
 * Calculates complete kinematic, geometric, and stress properties for a Straight Bevel Gear drive.
 * Follows Gleason straight bevel standard & AGMA 2005-D03.
 */
export function calculateStraightBevelDesign(inputs) {
  const m = Number(inputs.m) || 3.0;
  const Np = Number(inputs.Np) || 16;
  const Ng = Number(inputs.Ng) || 48;
  const phi_deg = Number(inputs.phi_deg) || 20.0;
  const Sigma_deg = Number(inputs.Sigma_deg) || 90.0;
  const n_pinions = Number(inputs.n_pinions) || 3;
  const F_in = Number(inputs.F) || 25.0;

  const T_in_ring = Number(inputs.T_in_ring) || 20.0;
  const n_in_ring = Number(inputs.n_in_ring) || 100.0;
  const eta = Number(inputs.eta) || 0.97;
  const sigma_allow_bend = Number(inputs.sigma_allow_bend) || 250.0;
  const sigma_allow_contact = 1500.0;

  const materialKey = (inputs.print_material || 'PLA').toUpperCase();
  const ps = MATERIAL_PRESETS[materialKey] || MATERIAL_PRESETS.PLA;

  const phi = (phi_deg * Math.PI) / 180;
  const Sigma = (Sigma_deg * Math.PI) / 180;
  const i_ratio = Ng / Np;

  // Pitch cone angles
  const gamma_p = Math.atan2(Math.sin(Sigma), Ng / Np + Math.cos(Sigma));
  const gamma_g = Sigma - gamma_p;

  // Pitch diameters
  const dp = m * Np;
  const dg = m * Ng;
  const rp_p = dp / 2;
  const rp_g = dg / 2;

  // Outer cone distance Ao
  const Ao = rp_p / Math.sin(gamma_p);

  // Face width F
  const F_max = Math.min(Ao / 3, 10 * m);
  const F = Math.min(F_in, F_max);

  const Ai = Ao - F;
  const Am = Ao - F / 2;

  // Mean pitch diameters
  const dmp = dp * (Am / Ao);
  const dmg = dg * (Am / Ao);
  const rm_p = dmp / 2;
  const rm_g = dmg / 2;

  // Gleason standard straight bevel tooth proportions
  const a_p = 1.00 * m;
  const a_g = 1.00 * m;
  const b_p = 1.25 * m;
  const b_g = 1.25 * m;
  const hw = a_p + a_g; // 2.0 * m
  const ht = a_p + b_p; // 2.25 * m
  const c_std = b_p - a_p; // 0.25 * m

  const s_p = (Math.PI * m) / 2;
  const s_g = (Math.PI * m) / 2;

  // Outside / tip diameters
  const Do_p = dp + 2 * a_p * Math.cos(gamma_p);
  const Do_g = dg + 2 * a_g * Math.cos(gamma_g);
  const ra_p = Do_p / 2;
  const ra_g = Do_g / 2;
  const rd_p = (dp - 2 * b_p * Math.cos(gamma_p)) / 2;
  const rd_g = (dg - 2 * b_g * Math.cos(gamma_g)) / 2;

  // Tredgold back cone & virtual equivalent gears
  const Nv_p = Np / Math.cos(gamma_p);
  const Nv_g = Ng / Math.cos(gamma_g);
  const rv_p = rp_p / Math.cos(gamma_p);
  const rv_g = rp_g / Math.cos(gamma_g);
  const rbv_p = rv_p * Math.cos(phi);
  const rbv_g = rv_g * Math.cos(phi);
  const rav_p = rv_p + a_p;
  const rav_g = rv_g + a_g;

  // Contact ratio
  const pb = Math.PI * m * Math.cos(phi);
  const L_contact =
    Math.sqrt(rav_p * rav_p - rbv_p * rbv_p) +
    Math.sqrt(rav_g * rav_g - rbv_g * rbv_g) -
    (rv_p + rv_g) * Math.sin(phi);
  const CR = L_contact / pb;

  // Drivetrain kinematics
  const n_pinion_out = n_in_ring * i_ratio;
  const T_ring_per_mesh = T_in_ring / n_pinions;
  const T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_ring * 2 * Math.PI * n_in_ring) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  // Mesh forces at mean cone distance rm_g
  const Ft = (T_ring_per_mesh * 1000) / rm_g;
  const Fr_p = Ft * Math.tan(phi) * Math.cos(gamma_p);
  const Fa_p = Ft * Math.tan(phi) * Math.sin(gamma_p);
  const F_resultant = Math.sqrt(Ft * Ft + Fr_p * Fr_p + Fa_p * Fa_p);

  // AGMA / Lewis bending stress
  const bevel_factor = Ao / Am;
  const Y_p = 0.154 - 0.912 / Nv_p;
  const Y_g = 0.154 - 0.912 / Nv_g;
  const sigma_b_p = (Ft / (F * m * Y_p)) * bevel_factor;
  const sigma_b_g = (Ft / (F * m * Y_g)) * bevel_factor;
  const SF_p = sigma_allow_bend / (sigma_b_p || 1e-6);
  const SF_g = sigma_allow_bend / (sigma_b_g || 1e-6);

  // Hertzian contact stress
  const E_mod = 206000;
  const nu = 0.30;
  const E_star = E_mod / (2 * (1 - nu * nu));
  const rho_p = rbv_p * Math.tan(phi);
  const rho_g = rbv_g * Math.tan(phi);
  const rho_eq = (rho_p * rho_g) / (rho_p + rho_g);
  const sigma_H = Math.sqrt((Ft / (Math.PI * F * Math.cos(phi))) * (E_star / rho_eq) * bevel_factor);
  const SF_contact = sigma_allow_contact / (sigma_H || 1e-6);

  // Mounting distances
  const MD_p = Ao * Math.cos(gamma_p) - a_p * Math.sin(gamma_p);
  const MD_g = Ao * Math.cos(gamma_g) - a_g * Math.sin(gamma_g);

  return {
    gear_type: 'straight-bevel',
    m,
    Np,
    Ng,
    phi_deg,
    phi,
    Sigma_deg,
    Sigma,
    n_pinions,
    i_ratio,
    dp,
    dg,
    rp_p,
    rp_g,
    gamma_p,
    gamma_g,
    gamma_p_deg: (gamma_p * 180) / Math.PI,
    gamma_g_deg: (gamma_g * 180) / Math.PI,
    Ao,
    Am,
    Ai,
    F,
    dmp,
    dmg,
    rm_p,
    rm_g,
    r_cutter: null,
    hw,
    ht,
    c_std,
    a_p,
    a_g,
    b_p,
    b_g,
    s_p,
    s_g,
    Do_p,
    Do_g,
    ra_p,
    ra_g,
    rd_p,
    rd_g,
    Nv_p,
    Nv_g,
    rv_p,
    rv_g,
    rbv_p,
    rbv_g,
    rav_p,
    rav_g,
    MD_p,
    MD_g,
    CR,
    L_contact,
    pb,
    T_in_ring,
    n_in_ring,
    eta,
    n_pinion_out,
    T_ring_per_mesh,
    T_pinion_each,
    P_in_total,
    P_out_each,
    Ft,
    Fr_p,
    Fa_p,
    F_resultant,
    sigma_b_p,
    sigma_b_g,
    SF_p,
    SF_g,
    sigma_H,
    SF_contact,
    sigma_allow_bend,
    ps,
    print_material: materialKey,
    crowning_p: {},
    crowning_g: {},
    s_p_print: s_p,
    s_g_print: s_g,
    b_p_print: b_p,
    b_g_print: b_g
  };
}

// =========================================================================
// HELICAL GEAR CALCULATION & 3D MESH GENERATOR
// =========================================================================

export function calculateHelicalDesign(inputs) {
  const mn = parseFloat(inputs.m || 3.0);
  const Np = parseInt(inputs.Np || 16, 10);
  const Ng = parseInt(inputs.Ng || 48, 10);
  const phi_n_deg = parseFloat(inputs.phi_deg || 20.0);
  const beta_deg = parseFloat(inputs.tooth_angle_deg != null ? inputs.tooth_angle_deg : (inputs.helix_angle_deg != null ? inputs.helix_angle_deg : (inputs.beta_deg != null ? inputs.beta_deg : 15.0)));
  const n_pinions = parseInt(inputs.n_pinions || 3, 10);
  const F = parseFloat(inputs.f_mm || inputs.F || 40.0);
  const T_in_ring = parseFloat(inputs.T_in_ring || 20.0);
  const n_in_ring = parseFloat(inputs.n_in_ring || 100.0);
  const eta = 1.0;

  const beta = (beta_deg * Math.PI) / 180;
  const phi_n = (phi_n_deg * Math.PI) / 180;

  // Transverse module
  const mt = mn / Math.cos(beta);

  // Transverse pressure angle
  const tan_phi_t = Math.tan(phi_n) / Math.cos(beta);
  const phi_t = Math.atan(tan_phi_t);
  const phi_t_deg = (phi_t * 180) / Math.PI;

  const i_ratio = Ng / Np;

  // Pitch diameters
  const dp = mt * Np;
  const dg = mt * Ng;
  const rp_p = dp / 2;
  const rp_g = dg / 2;

  // Center distance
  const center_dist = (dp + dg) / 2;

  // Base diameters
  const db_p = dp * Math.cos(phi_t);
  const db_g = dg * Math.cos(phi_t);
  const rb_p = db_p / 2;
  const rb_g = db_g / 2;

  // Standard full-depth proportions (normal plane)
  const a_p = 1.0 * mn;
  const a_g = 1.0 * mn;
  const b_p = 1.25 * mn;
  const b_g = 1.25 * mn;
  const hw = a_p + a_g;
  const ht = a_p + b_p;
  const c_std = b_p - a_p;

  // Standard tooth thickness (normal & transverse)
  const sn_p = (Math.PI * mn) / 2;
  const sn_g = (Math.PI * mn) / 2;
  const st_p = sn_p / Math.cos(beta);
  const st_g = sn_g / Math.cos(beta);

  // Outside (tip) and root diameters
  const da_p = dp + 2 * a_p;
  const da_g = dg + 2 * a_g;
  const ra_p = da_p / 2;
  const ra_g = da_g / 2;

  const dd_p = dp - 2 * b_p;
  const dd_g = dg - 2 * b_g;
  const rd_p = dd_p / 2;
  const rd_g = dd_g / 2;

  // Virtual tooth counts
  const Nvn_p = Np / Math.pow(Math.cos(beta), 3);
  const Nvn_g = Ng / Math.pow(Math.cos(beta), 3);

  // Contact ratios
  const p_bt = Math.PI * mt * Math.cos(phi_t);
  const g_alpha = Math.sqrt(ra_p * ra_p - rb_p * rb_p) + Math.sqrt(ra_g * ra_g - rb_g * rb_g) - center_dist * Math.sin(phi_t);
  const eps_alpha = g_alpha / p_bt;
  const p_x = (Math.PI * mn) / Math.sin(beta);
  const eps_beta = (F * Math.sin(beta)) / (Math.PI * mn);
  const eps_gamma = eps_alpha + eps_beta;
  const CR = eps_gamma;

  // Torques and speeds
  const n_pinion_out = n_in_ring * i_ratio;
  const T_ring_per_mesh = T_in_ring / n_pinions;
  const T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_ring * 2 * Math.PI * n_in_ring) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  // 3D Force components
  const Ft = (2 * T_ring_per_mesh * 1000) / dg;
  const Fr = Ft * Math.tan(phi_t);
  const Fa = Ft * Math.tan(beta);
  const F_resultant = Math.sqrt(Ft * Ft + Fr * Fr + Fa * Fa);

  // Bending stress (AGMA / ISO)
  const Y_F_p = 0.154 - 0.912 / Nvn_p;
  const Y_F_g = 0.154 - 0.912 / Nvn_g;
  const Y_beta = 1 - beta_deg / 120;
  const sigma_b_p = (Ft / (F * mn * Y_F_p)) * Y_beta;
  const sigma_b_g = (Ft / (F * mn * Y_F_g)) * Y_beta;

  // Contact stress (Hertzian)
  const E_mod = 206000;
  const nu = 0.3;
  const Z_E = Math.sqrt(E_mod / (2 * Math.PI * (1 - nu * nu)));
  const Z_H = Math.sqrt((2 * Math.cos(beta)) / (Math.pow(Math.cos(phi_t), 2) * Math.sin(phi_t)));
  const Z_beta = Math.sqrt(Math.cos(beta));
  const Z_eps = Math.sqrt(Math.max(0.1, (4 - eps_alpha) / 3));
  const u = i_ratio;
  const sigma_H = Z_H * Z_E * Z_eps * Z_beta * Math.sqrt((Ft / (dp * F)) * ((u + 1) / u));

  const sigma_allow_bend = parseFloat(inputs.sigma_allow_bend) || 250.0;
  const sigma_allow_contact = 1500.0;
  const SF_b_p = sigma_allow_bend / Math.max(sigma_b_p, 1e-6);
  const SF_b_g = sigma_allow_bend / Math.max(sigma_b_g, 1e-6);
  const SF_contact = sigma_allow_contact / Math.max(sigma_H, 1e-6);

  return {
    gear_type: 'helical',
    m: mn,
    mn,
    Np,
    Ng,
    tooth_angle_deg: beta_deg,
    beta_deg,
    beta,
    phi_n_deg,
    phi_n,
    phi_t_deg,
    phi_t,
    phi_deg: phi_n_deg,
    phi: phi_n,
    mt,
    n_pinions,
    i_ratio,
    F,
    center_dist,
    dp,
    dg,
    rp_p,
    rp_g,
    db_p,
    db_g,
    rb_p,
    rb_g,
    a_p,
    a_g,
    b_p,
    b_g,
    hw,
    ht,
    c_std,
    sn_p,
    sn_g,
    st_p,
    st_g,
    da_p,
    da_g,
    ra_p,
    ra_g,
    dd_p,
    dd_g,
    rd_p,
    rd_g,
    Nvn_p,
    Nvn_g,
    p_bt,
    g_alpha,
    eps_alpha,
    p_x,
    eps_beta,
    eps_gamma,
    CR,
    T_in_ring,
    n_in_ring,
    n_pinion_out,
    T_ring_per_mesh,
    T_pinion_each,
    P_in_total,
    P_out_each,
    Ft,
    Fr,
    Fa,
    F_resultant,
    sigma_b_p,
    sigma_b_g,
    SF_b_p,
    SF_b_g,
    sigma_H,
    SF_contact,
    Ao: center_dist,
    gamma_p: 0,
    gamma_g: 0,
    gamma_p_deg: 0,
    gamma_g_deg: 0,
    r_cutter: 0,
    material: inputs.print_material || 'PLA',
    print_material: inputs.print_material || 'PLA'
  };
}

export function buildHelicalMesh(N, mn, beta_deg, phi_n_deg, a, b, s_thick_t, F = 40, hand = 1, n_inv = 16, n_sec = 20, r_bore = 0) {
  const beta = (beta_deg * Math.PI) / 180;
  const phi_n = (phi_n_deg * Math.PI) / 180;
  const phi_t = Math.atan(Math.tan(phi_n) / Math.cos(beta));
  const mt = mn / Math.cos(beta);
  const rp = (mt * N) / 2;

  // 1. Generate 2D Transverse Involute Profile
  const prof = generateSpurProfile2D(N, mt, phi_t, a, b, s_thick_t, n_inv * 4);
  const xc_base = prof.xc;
  const yc_base = prof.yc;
  const M_outer = xc_base.length;

  const has_bore = r_bore > 1.0 && r_bore < prof.r_d * 0.85;
  let xb_base = [], yb_base = [];
  let M_inner = 0;
  if (has_bore) {
    const n_bore = Math.max(36, Math.round(N * 4));
    for (let k = 0; k < n_bore; k++) {
      const th = (k * 2 * Math.PI) / n_bore;
      xb_base.push(r_bore * Math.cos(th));
      yb_base.push(r_bore * Math.sin(th));
    }
    M_inner = n_bore;
  }

  const n_slice_verts = M_outer + M_inner;
  const z_levels = [];
  for (let s = 0; s < n_sec; s++) {
    z_levels.push(-F / 2 + (s / (n_sec - 1)) * F);
  }

  // 2. Lateral Side Vertices (swept along Z with continuous helical twist)
  const side_verts = [];
  for (let s = 0; s < n_sec; s++) {
    const z = z_levels[s];
    const delta_theta = hand * (z * Math.tan(beta)) / rp;
    const cos_dt = Math.cos(delta_theta);
    const sin_dt = Math.sin(delta_theta);

    for (let k = 0; k < M_outer; k++) {
      const x = xc_base[k] * cos_dt - yc_base[k] * sin_dt;
      const y = xc_base[k] * sin_dt + yc_base[k] * cos_dt;
      side_verts.push([x, y, z]);
    }
    if (has_bore) {
      for (let k = 0; k < M_inner; k++) {
        side_verts.push([xb_base[k], yb_base[k], z]);
      }
    }
  }

  // 3. Lateral Faces
  const side_faces = [];
  for (let s = 0; s < n_sec - 1; s++) {
    const b1 = s * n_slice_verts;
    const b2 = (s + 1) * n_slice_verts;
    for (let k = 0; k < M_outer; k++) {
      const kn = (k + 1) % M_outer;
      side_faces.push([b1 + k, b1 + kn, b2 + kn]);
      side_faces.push([b1 + k, b2 + kn, b2 + k]);
    }
    if (has_bore) {
      for (let k = 0; k < M_inner; k++) {
        const kn = (k + 1) % M_inner;
        const v1 = b1 + M_outer + k;
        const v2 = b1 + M_outer + kn;
        const v3 = b2 + M_outer + kn;
        const v4 = b2 + M_outer + k;
        side_faces.push([v1, v3, v2]);
        side_faces.push([v1, v4, v3]);
      }
    }
  }

  // 4. Dedicated Planar End Caps (Triangulate outer shape with inner hole)
  // Bottom Cap (s = 0, Z = -F/2)
  const dt_bot = hand * ((-F / 2) * Math.tan(beta)) / rp;
  // 4. Planar End Caps
  const bot_faces = [];
  const top_faces = [];
  const b_top = (n_sec - 1) * n_slice_verts;

  if (!has_bore) {
    // Solid Helical Gear: Clean planar triangulation without center star vertex
    // Eliminates radial spoke/texture lines in SolidWorks and CATIA
    const dt_bot = hand * ((-F / 2) * Math.tan(beta)) / rp;
    const cos_bot = Math.cos(dt_bot), sin_bot = Math.sin(dt_bot);
    const outer_pts_bot = [];
    for (let k = 0; k < M_outer; k++) {
      const x = xc_base[k] * cos_bot - yc_base[k] * sin_bot;
      const y = xc_base[k] * sin_bot + yc_base[k] * cos_bot;
      outer_pts_bot.push(new THREE.Vector2(x, y));
    }
    const capTris = THREE.ShapeUtils.triangulateShape(outer_pts_bot, []);
    for (const tri of capTris) {
      const [i1, i2, i3] = tri;
      const v1 = side_verts[i1], v2 = side_verts[i2], v3 = side_verts[i3];
      const nz = (v2[0] - v1[0]) * (v3[1] - v1[1]) - (v2[1] - v1[1]) * (v3[0] - v1[0]);
      // Bottom cap outward normal points in -Z
      bot_faces.push(nz > 0 ? [i1, i3, i2] : [i1, i2, i3]);
      // Top cap outward normal points in +Z
      const idx1 = b_top + i1, idx2 = b_top + i2, idx3 = b_top + i3;
      top_faces.push(nz < 0 ? [idx1, idx3, idx2] : [idx1, idx2, idx3]);
    }
  } else {
    // Gear with Bore: directly map annular cap to side_verts
    const dt_bot = hand * ((-F / 2) * Math.tan(beta)) / rp;
    const cos_bot = Math.cos(dt_bot), sin_bot = Math.sin(dt_bot);
    const outer_pts_bot = [];
    for (let k = 0; k < M_outer; k++) {
      const x = xc_base[k] * cos_bot - yc_base[k] * sin_bot;
      const y = xc_base[k] * sin_bot + yc_base[k] * cos_bot;
      outer_pts_bot.push(new THREE.Vector2(x, y));
    }
    const hole_pts = [];
    for (let k = 0; k < M_inner; k++) {
      const th = 2 * Math.PI - (k * 2 * Math.PI) / M_inner;
      hole_pts.push(new THREE.Vector2(r_bore * Math.cos(th), r_bore * Math.sin(th)));
    }
    const raw_cap_tris = THREE.ShapeUtils.triangulateShape(outer_pts_bot, [hole_pts]);
    const all_cap_pts = outer_pts_bot.concat(hole_pts);

    function mapCapToSlice(idx, sliceBase) {
      if (idx < M_outer) return sliceBase + idx;
      const bore_k = idx - M_outer;
      return sliceBase + M_outer + bore_k;
    }

    for (let i = 0; i < raw_cap_tris.length; i++) {
      const [i1, i2, i3] = raw_cap_tris[i];
      const p1 = all_cap_pts[i1], p2 = all_cap_pts[i2], p3 = all_cap_pts[i3];
      const cz = (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);

      const b_i1 = mapCapToSlice(i1, 0), b_i2 = mapCapToSlice(i2, 0), b_i3 = mapCapToSlice(i3, 0);
      if (cz > 0) bot_faces.push([b_i1, b_i3, b_i2]);
      else bot_faces.push([b_i1, b_i2, b_i3]);

      const t_i1 = mapCapToSlice(i1, b_top), t_i2 = mapCapToSlice(i2, b_top), t_i3 = mapCapToSlice(i3, b_top);
      if (cz < 0) top_faces.push([t_i1, t_i3, t_i2]);
      else top_faces.push([t_i1, t_i2, t_i3]);
    }
  }

  const all_verts = side_verts;
  const all_faces = side_faces.concat(bot_faces, top_faces);

  return {
    vertices: all_verts,
    faces: all_faces,
    F,
    hand
  };
}

// =========================================================================
// SPIRAL BEVEL GEAR CALCULATION & 3D WATERTIGHT MESH GENERATOR
// =========================================================================

/**
 * Calculates complete Gleason Spiral Bevel Gear kinematics, geometry,
 * 3D forces, and contact ratios according to AGMA 2005-D03 and ISO 23509.
 */
export function calculateSpiralBevelDesign(inputs) {
  const m = parseFloat(inputs.m || 3.0);
  const Np = parseInt(inputs.Np || 16, 10);
  const Ng = parseInt(inputs.Ng || 48, 10);
  const phi_n_deg = parseFloat(inputs.phi_deg || 20.0);
  const beta_m_deg = parseFloat(inputs.tooth_angle_deg != null ? inputs.tooth_angle_deg : (inputs.helix_angle_deg != null ? inputs.helix_angle_deg : 35.0));
  const Sigma_deg = parseFloat(inputs.Sigma_deg || 90.0);
  const n_pinions = parseInt(inputs.n_pinions || 3, 10);
  const F_in = parseFloat(inputs.f_mm || inputs.F || 25.0);
  const T_in_ring = parseFloat(inputs.T_in_ring || 20.0);
  const n_in_ring = parseFloat(inputs.n_in_ring || 100.0);

  const phi_n = (phi_n_deg * Math.PI) / 180;
  const beta_m = (beta_m_deg * Math.PI) / 180;
  const Sigma = (Sigma_deg * Math.PI) / 180;

  const i_ratio = Ng / Np;
  const dp = m * Np;
  const dg = m * Ng;
  const rp = dp / 2;
  const rg = dg / 2;

  // Pitch cone angles
  const gamma_p = Math.atan(Math.sin(Sigma) / (i_ratio + Math.cos(Sigma)));
  const gamma_g = Sigma - gamma_p;
  const gamma_p_deg = (gamma_p * 180) / Math.PI;
  const gamma_g_deg = (gamma_g * 180) / Math.PI;

  // Cone distances
  const Ao = rp / Math.sin(gamma_p);
  const F_max = Math.min(Ao / 3, 10 * m);
  const F = Math.min(F_in, F_max);
  const Am = Ao - F / 2;
  const Ai = Ao - F;

  // Mean pitch diameters
  const dmp = dp * (Am / Ao);
  const dmg = dg * (Am / Ao);
  const rmp = dmp / 2;
  const rmg = dmg / 2;

  // Cutter radius (Standard Gleason ~0.525 Am)
  const r_cutter = Math.round(0.525 * Am * 10) / 10 || 40.0;

  // Spiral angles
  const tan_beta_m = Math.tan(beta_m);
  const beta_o = Math.atan(tan_beta_m * (Ao / Am));
  const beta_i = Math.atan(tan_beta_m * (Ai / Am));
  const beta_o_deg = (beta_o * 180) / Math.PI;
  const beta_i_deg = (beta_i * 180) / Math.PI;

  // Transverse pressure angle
  const tan_phi_t = Math.tan(phi_n) / Math.cos(beta_m);
  const phi_t = Math.atan(tan_phi_t);
  const phi_t_deg = (phi_t * 180) / Math.PI;

  // Tooth proportions (Gleason Spiral Bevel System)
  const hw = 1.700 * m;
  const ht = 1.888 * m;
  const c_std = 0.188 * m;
  const a_p = 0.54 * hw;
  const a_g = hw - a_p;
  const b_p = ht - a_p;
  const b_g = ht - a_g;

  // Outer circular tooth thicknesses
  const s_p = (Math.PI * m) / 2 + (a_p - a_g) * Math.tan(phi_n);
  const s_g = Math.PI * m - s_p;

  // Outer tip & root diameters
  const Do_p = dp + 2 * a_p * Math.cos(gamma_p);
  const Do_g = dg + 2 * a_g * Math.cos(gamma_g);
  const ra_p = Do_p / 2;
  const ra_g = Do_g / 2;
  const rd_p = (dp - 2 * b_p * Math.cos(gamma_p)) / 2;
  const rd_g = (dg - 2 * b_g * Math.cos(gamma_g)) / 2;

  // Tredgold back cone virtual gears
  const Nv_p = Np / Math.cos(gamma_p);
  const Nv_g = Ng / Math.cos(gamma_g);
  const rv_p = rp / Math.cos(gamma_p);
  const rv_g = rg / Math.cos(gamma_g);
  const rvb_p = rv_p * Math.cos(phi_t);
  const rvb_g = rv_g * Math.cos(phi_t);
  const rva_p = rv_p + a_p;
  const rva_g = rv_g + a_g;

  // Contact ratios (Transverse, Overlap, Total)
  const pbt = (Math.PI * m * Math.cos(phi_t)) / Math.cos(beta_m);
  const L_alpha = Math.sqrt(rva_p * rva_p - rvb_p * rvb_p) +
                  Math.sqrt(rva_g * rva_g - rvb_g * rvb_g) -
                  (rv_p + rv_g) * Math.sin(phi_t);
  const eps_alpha = Math.max(1.0, L_alpha / pbt);
  const m_nm = m * (Am / Ao);
  const eps_beta = (F * Math.sin(beta_m)) / (Math.PI * m_nm);
  const eps_gamma = Math.sqrt(eps_alpha * eps_alpha + eps_beta * eps_beta);
  const CR = eps_gamma;

  // Drivetrain kinematics & 3D Forces (AGMA 2005-D03)
  const n_pinion_out = n_in_ring * i_ratio;
  const T_ring_per_mesh = T_in_ring / n_pinions;
  const eta = 0.97;
  const T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
  const P_in_total = (T_in_ring * 2 * Math.PI * n_in_ring) / 60;
  const P_out_each = (T_pinion_each * 2 * Math.PI * n_pinion_out) / 60;

  const Ft = (T_pinion_each * 2000) / dmp;
  // Pinion is RH driving:
  const Fr_p = (Ft / Math.cos(beta_m)) * (Math.tan(phi_n) * Math.cos(gamma_p) + Math.sin(beta_m) * Math.sin(gamma_p));
  const Fa_p = (Ft / Math.cos(beta_m)) * (Math.tan(phi_n) * Math.sin(gamma_p) - Math.sin(beta_m) * Math.cos(gamma_p));
  const F_resultant = Math.sqrt(Ft * Ft + Fr_p * Fr_p + Fa_p * Fa_p);

  // Stresses & Safety Factors
  const Y_p = 0.154 - 0.912 / Nv_p;
  const Y_g = 0.154 - 0.912 / Nv_g;
  const sigma_b_p = (Ft * (Ao / Am)) / (F * m * Math.max(Y_p, 0.1));
  const sigma_b_g = (Ft * (Ao / Am)) / (F * m * Math.max(Y_g, 0.1));

  const sigma_allow_bend = 250.0;
  const SF_b_p = sigma_allow_bend / Math.max(sigma_b_p, 0.1);
  const SF_b_g = sigma_allow_bend / Math.max(sigma_b_g, 0.1);

  const I_factor = (Math.cos(phi_t) * Math.sin(phi_t) * (i_ratio / (i_ratio + 1))) / 2;
  const Ze = 187.0;
  const sigma_H = Ze * Math.sqrt((Ft * (Ao / Am)) / (dmp * F * Math.cos(beta_m) * Math.max(I_factor, 0.05)));
  const sigma_allow_contact = 1500.0;
  const SF_contact = sigma_allow_contact / Math.max(sigma_H, 1.0);

  const materialKey = inputs.materialKey || 'STEEL';
  const ps = MATERIAL_PRESETS[materialKey] || MATERIAL_PRESETS.PLA;

  return {
    gear_type: 'spiral-bevel',
    m,
    mn: m,
    Np,
    Ng,
    phi: phi_n,
    phi_deg: phi_n_deg,
    phi_n,
    phi_n_deg,
    phi_t,
    phi_t_deg,
    beta_m,
    beta_m_deg,
    beta_deg: beta_m_deg,
    beta_o_deg,
    beta_i_deg,
    Sigma,
    Sigma_deg,
    i_ratio,
    dp,
    dg,
    rp,
    rg,
    dmp,
    dmg,
    rmp,
    rmg,
    Ao,
    Am,
    Ai,
    F,
    r_cutter,
    gamma_p,
    gamma_p_deg,
    gamma_g,
    gamma_g_deg,
    hw,
    ht,
    c_std,
    a_p,
    a_g,
    b_p,
    b_g,
    s_p,
    s_g,
    Do_p,
    Do_g,
    ra_p,
    ra_g,
    rd_p,
    rd_g,
    Nv_p,
    Nv_g,
    rv_p,
    rv_g,
    rvb_p,
    rvb_g,
    rva_p,
    rva_g,
    eps_alpha,
    eps_beta,
    eps_gamma,
    CR,
    n_pinions,
    T_in_ring,
    n_in_ring,
    n_pinion_out,
    T_pinion_each,
    P_in_total,
    P_out_each,
    Ft,
    Fr: Fr_p,
    Fr_p,
    Fa: Fa_p,
    Fa_p,
    F_resultant,
    sigma_b_p,
    sigma_b_g,
    SF_b_p,
    SF_b_g,
    SF_p: SF_b_p,
    SF_g: SF_b_g,
    sigma_H,
    SF_contact,
    sigma_allow_bend,
    ps,
    print_material: materialKey,
    MD_p: Ao * Math.cos(gamma_p) - a_p * Math.sin(gamma_p),
    MD_g: Ao * Math.cos(gamma_g) - a_g * Math.sin(gamma_g),
    crowning_p: ps ? { lengthwise: ps.lengthwise_crown, profile: ps.profile_crown, tip_relief: ps.tip_relief, tip_relief_start: ps.tip_relief_start } : {},
    crowning_g: ps ? { lengthwise: ps.lengthwise_crown, profile: ps.profile_crown, tip_relief: ps.tip_relief, tip_relief_start: ps.tip_relief_start } : {},
    s_p_print: s_p,
    s_g_print: s_g,
    b_p_print: b_p,
    b_g_print: b_g
  };
}

/**
 * Builds Watertight 3D Spiral Bevel Mesh using Gleason circular cutter arc
 * tooth surfaces with planar toe and heel end caps matching buildBevelMesh.
 */
export function buildSpiralBevelMesh(
  N,
  m,
  phi_n_deg,
  a,
  b,
  gamma_rad,
  Ao,
  F,
  beta_m_deg = 35.0,
  r_cutter = 40.0,
  hand = 1,
  tooth_thick,
  n_inv = 16,
  n_sec = 16
) {
  const phi_n = (phi_n_deg * Math.PI) / 180;
  return buildBevelMesh(
    N,
    m,
    phi_n,
    a,
    b,
    gamma_rad,
    Ao,
    F,
    r_cutter,
    n_inv,
    n_sec,
    3,
    3,
    tooth_thick,
    {},
    1.0,
    beta_m_deg,
    hand
  );
}
