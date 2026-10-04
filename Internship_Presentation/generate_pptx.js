/**
 * Generate Formal, Clean & Modern PowerPoint Presentation (.pptx)
 * Project: Wind Turbine Pitch Control System - Gear Design Studio
 * Candidate: Ahmed Majdy Ahmed
 */

const pptxgen = require('pptxgenjs');
const path = require('path');
const fs = require('fs');

const pres = new pptxgen();

// Set 16:9 Modern Widescreen Layout (13.333" x 7.5")
pres.defineLayout({ name: 'WIDE_16_9', width: 13.333, height: 7.5 });
pres.layout = 'WIDE_16_9';

// Theme Colors
const C = {
  bg: '0A0E17',
  cardBg: '111827',
  cardBorder: '1E293B',
  cyan: '38BDF8',
  cyanLight: '7DD3FC',
  blue: '3B82F6',
  emerald: '10B981',
  amber: 'F59E0B',
  textMain: 'F8FAFC',
  textMuted: '94A3B8',
  textDim: '64748B',
  mathBg: '030712'
};

const ASSETS = {
  planetaryOverview: path.join(__dirname, 'assets', 'planetary_overview.png'),
  planetaryDropdown: path.join(__dirname, 'assets', 'planetary_dropdown_options.png'),
  planetarySun: path.join(__dirname, 'assets', 'planetary_sun_isolated.png'),
  planetaryPlanet: path.join(__dirname, 'assets', 'planetary_planet_isolated.png'),
  spiralBevel: path.join(__dirname, 'assets', 'spiral_bevel_view.png'),
  straightBevel: path.join(__dirname, 'assets', 'straight_bevel_view.png'),
  straightMesh2d: path.join(__dirname, 'assets', 'straight_bevel_mesh2d.png'),
  zerolBevel: path.join(__dirname, 'assets', 'zerol_bevel_3d.png'),
  spurGear: path.join(__dirname, 'assets', 'spur_gear_3d.png'),
  cadToast: path.join(__dirname, 'assets', 'cad_export_toast.png')
};

// Helper: Add Standard Engineering Slide Header & Footer
function setupSlideChrome(slide, slideNum, categoryTag, title, subtitle) {
  slide.background = { color: C.bg };

  // Category Tag Pill
  slide.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.45, w: 3.2, h: 0.28,
    fill: { color: '0F172A' },
    line: { color: C.cyan, width: 1 }
  });
  slide.addText(categoryTag.toUpperCase(), {
    x: 0.8, y: 0.45, w: 3.2, h: 0.28,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.cyan,
    align: 'center', valign: 'middle'
  });

  // Slide Title & Subtitle
  slide.addText(title, {
    x: 0.8, y: 0.78, w: 11.5, h: 0.45,
    fontFace: 'Segoe UI', fontSize: 22, bold: true, color: C.textMain,
    valign: 'middle'
  });

  slide.addText(subtitle, {
    x: 0.8, y: 1.25, w: 11.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 11, color: C.textMuted,
    valign: 'top'
  });

  // Top accent horizontal line
  slide.addShape(pres.ShapeType.line, {
    x: 0.8, y: 1.58, w: 11.733, h: 0,
    line: { color: C.cardBorder, width: 1 }
  });

  // Footer
  slide.addShape(pres.ShapeType.line, {
    x: 0.8, y: 6.85, w: 11.733, h: 0,
    line: { color: C.cardBorder, width: 1 }
  });

  slide.addText('Wind Turbine Pitch Control System  |  Custom Gear Design Studio', {
    x: 0.8, y: 6.95, w: 5.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, color: C.textDim,
    valign: 'middle'
  });

  slide.addText('Ahmed Majdy Ahmed  —  Internship Technical Defense', {
    x: 5.5, y: 6.95, w: 4.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  slide.addText(`Slide ${slideNum} of 16`, {
    x: 10.5, y: 6.95, w: 2.033, h: 0.3,
    fontFace: 'Consolas', fontSize: 9.5, color: C.cyan, bold: true,
    align: 'right', valign: 'middle'
  });
}

// ==============================================================================
// SLIDE 1: Title & Executive Overview
// ==============================================================================
{
  const s = pres.addSlide();
  s.background = { color: C.bg };

  // Category Tag
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.6, w: 3.4, h: 0.32,
    fill: { color: '0F172A' },
    line: { color: C.cyan, width: 1 }
  });
  s.addText('FINAL INTERNSHIP DEFENSE', {
    x: 0.8, y: 0.6, w: 3.4, h: 0.32,
    fontFace: 'Consolas', fontSize: 10, bold: true, color: C.cyan,
    align: 'center', valign: 'middle'
  });

  // Main Titles
  s.addText('Wind Turbine Pitch Control System', {
    x: 0.8, y: 1.05, w: 7.2, h: 0.6,
    fontFace: 'Segoe UI', fontSize: 26, bold: true, color: C.textMain
  });
  s.addText('Multi-Architecture Gear Engineering Studio, Kinematic Simulation Engine & In-Browser CAD Exporter Suite', {
    x: 0.8, y: 1.68, w: 7.0, h: 0.5,
    fontFace: 'Segoe UI', fontSize: 12.5, color: C.textMuted
  });

  // Left Card: Candidate & Scope
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 2.35, w: 6.2, h: 3.1,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('PROJECT SCOPE & CANDIDATE OWNERSHIP', {
    x: 1.0, y: 2.5, w: 5.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Candidate: ', options: { bold: true, color: C.textMain } },
    { text: 'Ahmed Majdy Ahmed\n', options: { color: C.textMain } },
    { text: 'Specialization: ', options: { bold: true, color: C.textMain } },
    { text: 'Mechanical Drive Engineering, Computational Kinematics & WebGL CAD Kernels\n\n', options: { color: C.textMuted } },
    { text: 'Core Engineering Accomplishments:\n', options: { bold: true, color: C.cyanLight } },
    { text: '• Formulated mathematical models for 7 wind turbine gear architectures.\n', options: { color: C.textMuted } },
    { text: '• Built native MATLAB calculation suites adhering to ISO 6336 standards.\n', options: { color: C.textMuted } },
    { text: '• Developed 100% client-side Three.js WebGL CAD Studio with real-time 3D kinematics.\n', options: { color: C.textMuted } },
    { text: '• Engineered in-browser ISO 10303-21 STEP AP214 B-Rep and STL CAD exporters.', options: { color: C.textMuted } }
  ], {
    x: 1.0, y: 2.85, w: 5.8, h: 2.4,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  // 3 Metric Badges
  const badges = [
    { num: '7', label: 'Gear Architectures' },
    { num: '100%', label: 'Client-Side CAD' },
    { num: '< 0.2s', label: 'Synthesis Latency' }
  ];
  badges.forEach((b, i) => {
    const bx = 0.8 + i * 2.15;
    s.addShape(pres.ShapeType.rect, {
      x: bx, y: 5.65, w: 1.95, h: 0.95,
      fill: { color: C.cardBg },
      line: { color: C.cardBorder, width: 1 }
    });
    s.addText(b.num, {
      x: bx, y: 5.75, w: 1.95, h: 0.45,
      fontFace: 'Consolas', fontSize: 20, bold: true, color: C.cyan,
      align: 'center'
    });
    s.addText(b.label, {
      x: bx, y: 6.2, w: 1.95, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 9, color: C.textMuted,
      align: 'center'
    });
  });

  // Right Side Image Frame
  s.addShape(pres.ShapeType.rect, {
    x: 7.25, y: 1.2, w: 5.25, h: 5.4,
    fill: { color: '000000' },
    line: { color: C.cyan, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.planetaryOverview)) {
    s.addImage({
      path: ASSETS.planetaryOverview,
      x: 7.27, y: 1.22, w: 5.21, h: 5.0
    });
  }
  s.addText('Figure 1.1: Web CAD Studio Core Interface (Three.js WebGL Parametric Assembly)', {
    x: 7.3, y: 6.25, w: 5.15, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 1: Executive Overview
Welcome the committee and mentors. State your name (Ahmed Majdy Ahmed).
Key Message: This project represents a complete, synchronized engineering suite designed to solve the critical challenges of wind turbine blade pitch actuation—spanning deep mathematical foundations, native MATLAB tools, and an innovative, zero-backend WebGL CAD Studio.`);
}

// ==============================================================================
// SLIDE 2: Problem Statement & Engineering Context
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 2, 'BACKGROUND & MOTIVATION', 'Wind Turbine Pitch Actuation Challenges', 'Aerodynamic regulation, extreme cyclic fatigue, zero-backlash limits, and nacelle envelope constraints');

  const cards = [
    {
      title: 'Aerodynamic Pitch Regulation',
      body: [
        { text: 'Wind turbine blades (up to 80m+) continuously micro-pitch to maximize the aerodynamic power coefficient (Cp):\n\n', options: { color: C.textMuted } },
        { text: 'P_aero = 0.5 * rho * A * V^3 * Cp(lambda, beta)\n\n', options: { fontFace: 'Consolas', bold: true, color: C.cyanLight } },
        { text: '• Operation Envelope: ', options: { bold: true, color: C.textMain } },
        { text: 'Cut-in 3 m/s, Rated 11.5 m/s, Cut-out 25 m/s.\n', options: { color: C.textMuted } },
        { text: '• Emergency Feathering: ', options: { bold: true, color: C.textMain } },
        { text: 'Rapid 90° braking feather in < 5 seconds under massive aerodynamic drag torque.', options: { color: C.textMuted } }
      ]
    },
    {
      title: 'Severe Mechanical Demands',
      body: [
        { text: 'The pitch gearbox operates under brutal mechanical conditions inside the rotating hub:\n\n', options: { color: C.textMuted } },
        { text: '• Cyclic Fatigue: ', options: { bold: true, color: C.textMain } },
        { text: 'Alternating gravitational and wind shear bending moments on every rotor revolution.\n\n', options: { color: C.textMuted } },
        { text: '• Near-Zero Backlash: ', options: { bold: true, color: C.textMain } },
        { text: 'Play > 0.05 mm causes blade flutter, leading to premature bearing failure.\n\n', options: { color: C.textMuted } },
        { text: '• High Transmission Ratios: ', options: { bold: true, color: C.textMain } },
        { text: 'Reducing 3000 RPM servomotors to 0.5–2 RPM (ratios 50:1 to 150:1 in compact space).', options: { color: C.textMuted } }
      ]
    },
    {
      title: 'Engineering Mission & Need',
      body: [
        { text: 'Prior to this project, designing custom pitch gearboxes required fragmented, inefficient tools:\n\n', options: { color: C.textMuted } },
        { text: '• Legacy Bottlenecks: ', options: { bold: true, color: C.textMain } },
        { text: 'Manual drafting across expensive proprietary CAD software (SolidWorks/CATIA) taking days per iteration.\n\n', options: { color: C.textMuted } },
        { text: '• Our Objective: ', options: { bold: true, color: C.cyan } },
        { text: 'Build a unified platform combining instantaneous mathematical gear synthesis, 3D kinematic simulation, and direct client-side CAD export in a single accessible suite.', options: { color: C.textMain } }
      ]
    }
  ];

  cards.forEach((c, i) => {
    const cx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.85, w: 3.75, h: 4.75,
      fill: { color: C.cardBg },
      line: { color: i === 2 ? C.cyan : C.cardBorder, width: i === 2 ? 1.5 : 1 }
    });
    s.addText(c.title, {
      x: cx + 0.25, y: 2.05, w: 3.25, h: 0.4,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: i === 2 ? C.cyan : C.textMain
    });
    s.addText(c.body, {
      x: cx + 0.25, y: 2.55, w: 3.25, h: 3.85,
      fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 2: Wind Turbine Pitch Actuation Challenges
Explain the physical wind turbine context. Why is pitch control so critical? Explain aerodynamic power regulation Cp and storm braking emergency feathering (90° in < 5s).
Highlight cyclic aerodynamic moments, extreme cyclic fatigue, zero-backlash needs, and space constraints inside the blade root and nacelle.`);
}

// ==============================================================================
// SLIDE 3: System Evolution & Chronology
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 3, 'DEVELOPMENT MILESTONES', 'System Evolution & Chronology', 'Three progressive architectural stages from analytical MATLAB formulations to an in-browser WebGL CAD suite');

  const phases = [
    {
      tag: 'PHASE 1',
      title: 'Analytical Math Foundations',
      points: [
        'Formulated Gleason Zerol bevel tooth flank equations.',
        'Derived Gleason circular cutter radius geometry: rc = (A0 * sin(delta2)) / cos(delta1).',
        'Involute profile generation via differential roll-angle coordinates.',
        'Direct SolidWorks VBA macro curve generators (.bas).'
      ]
    },
    {
      tag: 'PHASE 2',
      title: 'Multi-Gear MATLAB Suites',
      points: [
        'Expanded to 6 distinct modular engineering suites.',
        'Integrated ISO 6336 bending and Hertzian contact stress calculations.',
        'Created native MATLAB App Designer GUI (zerol_bevel_gui.m).',
        'Built PrintComp module for 3D printer shrinkage & clearance compensation.'
      ]
    },
    {
      tag: 'PHASE 3',
      title: 'WebGL CAD Studio (Web_App)',
      points: [
        'Migrated math to 100% client-side JavaScript (Vite + Three.js).',
        'Real-time multi-body 3D kinematics (true Willis planetary orbiting).',
        'Pure JS ISO 10303-21 STEP AP214 B-Rep and IEEE 754 STL exporters.',
        'High-precision 2D Tredgold meshing & line-of-action diagnostic canvas.'
      ]
    }
  ];

  phases.forEach((p, i) => {
    const px = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: px, y: 1.85, w: 3.75, h: 4.75,
      fill: { color: C.cardBg },
      line: { color: i === 2 ? C.cyan : C.cardBorder, width: i === 2 ? 1.5 : 1 }
    });

    s.addShape(pres.ShapeType.rect, {
      x: px + 0.25, y: 2.1, w: 1.2, h: 0.28,
      fill: { color: '0F172A' },
      line: { color: C.cyan, width: 1 }
    });
    s.addText(p.tag, {
      x: px + 0.25, y: 2.1, w: 1.2, h: 0.28,
      fontFace: 'Consolas', fontSize: 9, bold: true, color: C.cyan,
      align: 'center', valign: 'middle'
    });

    s.addText(p.title, {
      x: px + 0.25, y: 2.5, w: 3.25, h: 0.45,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.textMain
    });

    const bodyText = p.points.map(pt => ({ text: `• ${pt}\n\n`, options: { color: C.textMuted } }));
    s.addText(bodyText, {
      x: px + 0.25, y: 3.05, w: 3.25, h: 3.35,
      fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
    });
  });

  s.addNotes(`Slide 3: Development Chronology & Architecture Stages
Walk the panel through your 3 developmental milestones:
1. Phase 1: Pure analytical derivation of Gleason cutter geometry and involute tooth generation.
2. Phase 2: Expanding into 6 modular MATLAB suites with stress checks and desktop App Designer GUI.
3. Phase 3: Transitioning to the interactive WebGL CAD Studio (Web_App), enabling real-time 3D simulation and direct client-side CAD export.`);
}

// ==============================================================================
// SLIDE 4: Mathematical & Theoretical Foundations
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 4, 'ENGINEERING RIGOR', 'Mathematical & Kinematic Formulations', 'Exact analytical equations governing involute curves, Gleason face-milling, Willis kinematics, and ISO stress ratings');

  // Left Card: Involute & Gleason
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('INVOLUTE & GLEASON GEOMETRY', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Parametric Involute Profile (Spur, Helical, Ring):\n', options: { bold: true, color: C.textMain } },
    { text: 'x(theta) = r_b * (cos(theta) + theta * sin(theta))\ny(theta) = r_b * (sin(theta) - theta * cos(theta))\n\n', options: { fontFace: 'Consolas', color: C.cyanLight } },
    { text: 'Gleason Zerol Bevel Flank Equations:\n', options: { bold: true, color: C.textMain } },
    { text: 'Enforcing zero spiral angle at midface (beta_m = 0°):\n', options: { color: C.textMuted } },
    { text: 'beta_m = 0°  ==>  F_axial ~ 0  (Zero Axial Gearbox Thrust)\nr_cutter = (A0 * sin(delta_2)) / cos(delta_1)\n\n', options: { fontFace: 'Consolas', color: C.cyanLight } },
    { text: 'Engineering Significance:\n', options: { bold: true, color: C.textMain } },
    { text: 'Zerol bevels combine the smooth, elliptical localized contact patch of spiral bevels (accommodating shaft deflection) with the zero-axial-thrust advantage of straight bevels, saving bearing weight in wind turbine pitch heads.', options: { color: C.textMuted } }
  ], {
    x: 1.1, y: 2.5, w: 5.15, h: 3.9,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  // Right Card: Willis & ISO Stress
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('PLANETARY KINEMATICS & ISO 6336 STRESS', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Willis Epicyclic Kinematic Formulation:\n', options: { bold: true, color: C.textMain } },
    { text: 'i_0 = (omega_s - omega_c) / (omega_r - omega_c) = - (N_r / N_s)\nFixed Ring: i = 1 + (N_r / N_s)\nCoaxial Assembly Constraint: N_r = N_s + 2 * N_p\n\n', options: { fontFace: 'Consolas', color: C.cyanLight } },
    { text: 'ISO 6336 Bending & Contact Stress Verification:\n', options: { bold: true, color: C.textMain } },
    { text: 'sigma_F = (F_t / (b * m_n)) * Y_F * Y_S * K_A * K_V <= [sigma_FP]\nsigma_H = Z_H * Z_E * Z_eps * sqrt((F_t / (d1 * b)) * ((u+1)/u)) <= [sigma_HP]\n\n', options: { fontFace: 'Consolas', color: C.cyanLight } },
    { text: 'Engineering Significance:\n', options: { bold: true, color: C.textMain } },
    { text: 'Guarantees that synthesized gears satisfy bending safety factors (S_F >= 1.4) and pitting resistance (S_H >= 1.2) under 20-year wind turbine design lifetimes.', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.5, w: 5.15, h: 3.9,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  s.addNotes(`Slide 4: Mathematical & Kinematic Formulations
Demonstrate your mathematical competence. Walk through the parametric involute equation and highlight Gleason Zerol geometry where spiral angle beta_m = 0° at midface.
Explain why Zerol bevels are ideal for pitch actuators: they give the smooth, elliptical localized contact of spiral gears without generating axial thrust that damages bearings.
Present Willis planetary kinematics and ISO 6336 bending & surface contact stress criteria.`);
}

// ==============================================================================
// SLIDE 5: Multi-Gear Architecture Matrix
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 5, 'SYSTEM CAPABILITIES', 'Multi-Gear Architecture Matrix', 'Analytical modeling, kinematic simulation, and CAD generation across all pitch actuation configurations');

  const rows = [
    [
      { text: 'Architecture', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Kinematics', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Contact Mechanics', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Primary Wind Turbine Function', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Validation', options: { bold: true, color: C.cyan, fill: '0F172A' } }
    ],
    [
      { text: 'Zerol Bevel Gear', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=90°, beta_m=0°', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Gleason curved flank, localized contact ellipse', options: { color: C.textMuted } },
      { text: 'Right-angle pitch motor bevel box (zero axial load)', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Straight Bevel Gear', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=90°, straight cone', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Tredgold spherical back-cone projection', options: { color: C.textMuted } },
      { text: 'Compact right-angle auxiliary emergency actuators', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Spiral Bevel Gear', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=90°, beta_m=35°', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Curved circular spiral, high overlap (eps_beta > 2.0)', options: { color: C.textMuted } },
      { text: 'High-torque heavy-duty offshore pitch drives', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'External Involute Spur', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=0°, parallel', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'True involute with trochoidal root fillet', options: { color: C.textMuted } },
      { text: 'Multi-pinion load-sharing pitch reducer drives', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Internal Spur Ring Gear', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=0°, annular internal', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Internal involute, root tip clearance correction', options: { color: C.textMuted } },
      { text: 'Direct blade bearing slewing ring drive gear', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Helical Gear', options: { bold: true, color: C.textMain } },
      { text: 'Sigma=0°, beta=15°–25°', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Smooth progressive engagement, overlap contact', options: { color: C.textMuted } },
      { text: 'Ultra-quiet multi-stage reduction primary stages', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Epicyclic Planetary Gear', options: { bold: true, color: C.textMain } },
      { text: 'Coaxial Sun-Planet-Ring', options: { fontFace: 'Consolas', color: C.textMuted } },
      { text: 'Willis kinematics, multi-contact load sharing', options: { color: C.textMuted } },
      { text: 'High-ratio compact nacelle pitch gearboxes', options: { color: C.textMuted } },
      { text: 'ISO Verified', options: { bold: true, color: C.emerald } }
    ]
  ];

  s.addTable(rows, {
    x: 0.8, y: 1.85, w: 11.733, h: 4.75,
    colW: [2.3, 1.8, 2.9, 3.4, 1.333],
    fill: C.cardBg,
    border: { pt: 1, color: C.cardBorder },
    fontFace: 'Segoe UI', fontSize: 10,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 5: Multi-Gear Architecture Matrix
Summarize the breadth of the suite: all 7 gear architectures used in wind turbine pitch & yaw systems.
Point out how each gear serves a distinct wind turbine subsystem: Zerol for orthogonal bevel drives, Involute Spur for multi-pinion clusters, Internal Spur for the slewing ring, and Epicyclic Planetary for high-reduction nacelle gearboxes.`);
}

// ==============================================================================
// SLIDE 6: Native MATLAB Computational Suite & Desktop GUI
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 6, 'ENGINEERING SOLVERS', 'Modular MATLAB Computational Suite & Desktop GUI', 'High-precision numerical solvers, live stress gauges, material presets, and direct CAD translators');

  // Left Card: Native GUI
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('MATLAB APP DESIGNER GUI (zerol_bevel_gui.m)', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Interactive Desktop Engineering Tool:\n', options: { bold: true, color: C.textMain } },
    { text: 'Engineered a standalone desktop GUI for rapid parameter exploration:\n\n', options: { color: C.textMuted } },
    { text: '• Real-Time Stress Gauges: ', options: { bold: true, color: C.textMain } },
    { text: 'Live graphical meters updating Lewis bending stress (sigma_b) and Hertz contact stress (sigma_c) as sliders move.\n\n', options: { color: C.textMuted } },
    { text: '• Industrial Material Library: ', options: { bold: true, color: C.textMain } },
    { text: 'Built-in material endurance presets for 4140 Alloy Steel, 8620 Carburized Steel, Phosphor Bronze, and technical polymers (PLA/Nylon).\n\n', options: { color: C.textMuted } },
    { text: '• One-Click Disk CAD Exporters: ', options: { bold: true, color: C.textMain } },
    { text: 'Direct disk export of SolidWorks VBA macros (.bas), IGES surfaces, and 3D printable STL meshes directly from MATLAB memory.', options: { color: C.textMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  // Right Card: Modular Architecture
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('CLEAN MODULAR ARCHITECTURE PATTERN', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Standardized Structure Across All 6 MATLAB Suites:\n\n', options: { bold: true, color: C.textMain } },
    { text: 'Matlab_<GearType>/\n', options: { fontFace: 'Consolas', bold: true, color: C.cyanLight } },
    { text: '├── Core/      --> Exact kinematic equations & 3D matrices\n', options: { fontFace: 'Consolas', color: C.textMuted } },
    { text: '├── Viz/       --> 2D mesh contact & 3D surface plotters\n', options: { fontFace: 'Consolas', color: C.textMuted } },
    { text: '├── Export/    --> STEP, STL, IGES & SolidWorks macro exporters\n', options: { fontFace: 'Consolas', color: C.textMuted } },
    { text: '└── PrintComp/ --> FDM/SLA thermal shrinkage & bore offsets\n\n', options: { fontFace: 'Consolas', color: C.textMuted } },
    { text: 'Engineering Rigor:\n', options: { bold: true, color: C.textMain } },
    { text: 'Decoupling geometry calculation from visualization ensures that computational modules can be independently unit-tested against textbook ISO benchmark cases without graphical overhead.', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 6: Modular MATLAB Computational Suite & Native GUI
Explain the native MATLAB environment. Demonstrate how you built zerol_bevel_gui.m using App Designer with interactive dials and gauges for real-time stress validation.
Highlight the modular directory architecture (Core/, Viz/, Export/, PrintComp/), which enforces software engineering clean architecture principles.`);
}

// ==============================================================================
// SLIDE 7: Web CAD Studio Architecture
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 7, 'SOFTWARE ARCHITECTURE', 'Interactive Web CAD Studio Architecture (Web_App)', '100% client-side zero-backend design using Vite, Three.js WebGL, and Vanilla JavaScript');

  // Left Column: 3 Cards
  const leftCards = [
    {
      title: 'Zero-Backend Client Execution',
      body: 'Zero server latency, zero cloud computing costs, and complete IP protection: proprietary wind turbine pitch designs never leave the engineer\'s browser.'
    },
    {
      title: 'Modular Decoupled Design',
      body: 'Strict separation of concerns: gearGeometry.js (analytical math), viewer3d.js (Three.js WebGL), plot2d.js (2D diagnostics), and cadExporters.js (CAD serializers).'
    },
    {
      title: 'Dual Resizable Workspace',
      body: 'Zero-dependency draggable split gutter allowing engineers to smoothly reallocate screen area between 2D meshing diagnostics and 3D kinematics.'
    }
  ];

  leftCards.forEach((c, i) => {
    const cy = 1.85 + i * 1.62;
    s.addShape(pres.ShapeType.rect, {
      x: 0.8, y: cy, w: 5.75, h: 1.45,
      fill: { color: C.cardBg },
      line: { color: C.cardBorder, width: 1 }
    });
    s.addText(c.title, {
      x: 1.05, y: cy + 0.15, w: 5.25, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.cyan
    });
    s.addText(c.body, {
      x: 1.05, y: cy + 0.5, w: 5.25, h: 0.85,
      fontFace: 'Segoe UI', fontSize: 10, color: C.textMuted,
      lineSpacingMultiple: 1.15
    });
  });

  // Right Side Image Frame
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cyan, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.planetaryOverview)) {
    s.addImage({
      path: ASSETS.planetaryOverview,
      x: 6.8, y: 1.87, w: 5.71, h: 4.35
    });
  }
  s.addText('Figure 7.1: Interactive Web CAD Studio (Three.js WebGL + Resizable Split Workspace)', {
    x: 6.8, y: 6.25, w: 5.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 7: Interactive Web CAD Studio Architecture
Discuss the software architecture of Web_App. Emphasize that it is 100% client-side: no server latency, zero cloud costs, and proprietary CAD data never leaves the engineer's browser.
Highlight the resizable dual-panel workspace allowing engineers to customize their visual canvas.`);
}

// ==============================================================================
// SLIDE 8: Real-Time 3D Kinematics & WebGL Visualization Engine
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 8, 'VISUALIZATION & SIMULATION', 'Real-Time 3D Kinematics & WebGL Engine', 'Parametric mesh synthesis, true Willis planetary orbiting, and multi-mode shader inspection');

  // Left Image
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cyan, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.zerolBevel)) {
    s.addImage({
      path: ASSETS.zerolBevel,
      x: 0.82, y: 1.87, w: 5.71, h: 4.35
    });
  }
  s.addText('Figure 8.1: Zerol Bevel Gear 3D Parametric Mesh in Three.js (Orthogonal Sigma = 90°)', {
    x: 0.82, y: 6.25, w: 5.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  // Right Card: Features
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('CORE 3D KINEMATIC CAPABILITIES', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: '• Parametric Buffer Geometry Synthesis:\n', options: { bold: true, color: C.textMain } },
    { text: 'Zero external mesh downloads; every vertex, normal, and face index is computed parametrically on-the-fly in < 200 ms.\n\n', options: { color: C.textMuted } },
    { text: '• Synchronized Epicyclic Motion:\n', options: { bold: true, color: C.textMain } },
    { text: 'In planetary mode, planets synchronously rotate on individual needle bearings while orbiting the central sun at exact Willis carrier velocity: omega_c = omega_s / (1 + N_r / N_s).\n\n', options: { color: C.textMuted } },
    { text: '• 3-Pinion Multi-Drive Synchronization:\n', options: { bold: true, color: C.textMain } },
    { text: 'Simulates 3 servomotor pinions driving a single giant blade root internal slewing ring spaced at 120°.\n\n', options: { color: C.textMuted } },
    { text: '• Multi-Mode Diagnostic Shading:\n', options: { bold: true, color: C.textMain } },
    { text: 'Toggles between Smooth PBR metallic rendering, Wireframe overlay (mesh density check), and Pitch Cone Ghosting.', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 8: Real-Time 3D Kinematics & WebGL Engine
Point to Figure 8.1. Describe how Three.js dynamic buffer geometry was synthesized from parametric equations.
Explain the synchronized kinematics: planets orbit at exact Willis carrier velocity while rotating about their own centers; orthogonal bevels mesh with zero penetration.`);
}

// ==============================================================================
// SLIDE 9: 2D Meshing & Line-of-Action Diagnostics
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 9, 'CONTACT MECHANICS', '2D Meshing & Line-of-Action Diagnostics', 'High-precision HTML5 Canvas visualizer with dynamic pitch point and virtual Tredgold projection');

  // Left Image
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cyan, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.straightMesh2d)) {
    s.addImage({
      path: ASSETS.straightMesh2d,
      x: 0.82, y: 1.87, w: 5.71, h: 4.35
    });
  }
  s.addText('Figure 9.1: 2D Active Line of Action & Virtual Tredgold Conjugate Profiles', {
    x: 0.82, y: 6.25, w: 5.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  // Right Card: Features
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('2D DIAGNOSTIC CAPABILITIES', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: '• Virtual Tredgold Spherical Projection:\n', options: { bold: true, color: C.textMain } },
    { text: 'For straight and spiral bevels, computes virtual tooth numbers (z_v = z / cos(delta)) and virtual radii (r_v = r / cos(delta)) to project spherical tooth engagement onto a 2D plane without distortion.\n\n', options: { color: C.textMuted } },
    { text: '• Line of Action & Pressure Angle:\n', options: { bold: true, color: C.textMain } },
    { text: 'Draws the precise line of action tangent to both base circles (r_b = r * cos(alpha)) through Pitch Point P.\n\n', options: { color: C.textMuted } },
    { text: '• Dynamic Engagement Tracking:\n', options: { bold: true, color: C.textMain } },
    { text: 'An animated contact marker travels along the line of action during gear rotation, proving conjugate action and verifying the absence of tooth root interference or undercutting.\n\n', options: { color: C.textMuted } },
    { text: '• Interactive Canvas Navigation:\n', options: { bold: true, color: C.textMain } },
    { text: 'Smooth mouse-wheel zooming, click-drag panning, and auto-reset button.', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 9: 2D Meshing & Line-of-Action Diagnostics
Explain the 2D HTML5 canvas diagnostic tool. Highlight the virtual Tredgold back-cone transformation that projects 3D bevel cones onto a flat 2D plane without geometric distortion.
Explain the line of action tangent to the base circles and how animated contact points verify conjugate action.`);
}

// ==============================================================================
// SLIDE 10: In-Browser Direct CAD Exporters Suite
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 10, 'ENGINEERING INTEROPERABILITY', 'In-Browser Direct CAD Exporters Suite', 'Generating ISO 10303-21 STEP B-Rep, binary STL, and SolidWorks macros without a CAD kernel');

  // Left Card: Exporter Specs
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('ZERO-KERNEL CLIENT-SIDE CAD GENERATION', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: '• ISO 10303-21 STEP AP214 B-Rep:\n', options: { bold: true, color: C.textMain } },
    { text: 'Constructs full Boundary Representation (B-Rep) topological entities (MANIFOLD_SOLID_BREP, CLOSED_SHELL, ADVANCED_FACE, CARTESIAN_POINT) in pure JavaScript, importing as native solid bodies in SolidWorks and CATIA.\n\n', options: { color: C.textMuted } },
    { text: '• Binary IEEE 754 STL Exporter:\n', options: { bold: true, color: C.textMain } },
    { text: 'Compiles binary STL with 50-byte headers, normal vectors, and 32-bit float vertices for high-precision 3D slicing.\n\n', options: { color: C.textMuted } },
    { text: '• IGES 5.3 Surfaces:\n', options: { bold: true, color: C.textMain } },
    { text: 'Generates Entity 128 (B-Spline) and Entity 144 (Trimmed Surfaces) for legacy aerospace CAM pipelines.\n\n', options: { color: C.textMuted } },
    { text: '• SolidWorks VBA (.bas) & CATIA (.catvbs):\n', options: { bold: true, color: C.textMain } },
    { text: 'Procedural macro generators that construct native sketch equation curves and extruded tooth cuts inside SolidWorks.', options: { color: C.textMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  // Right Image
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cyan, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.planetaryDropdown)) {
    s.addImage({
      path: ASSETS.planetaryDropdown,
      x: 6.8, y: 1.87, w: 5.71, h: 4.35
    });
  }
  s.addText('Figure 10.1: Granular Component Download Selector (Sun, Planet, Ring & Complete ZIP)', {
    x: 6.8, y: 6.25, w: 5.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 10: In-Browser Direct CAD Exporters Suite
Highlight this as one of your standout technical breakthroughs: generating CAD files completely client-side in JavaScript without requiring a CAD kernel or server backend.
Explain the four export standards: ISO 10303-21 STEP AP214 B-Rep, Binary IEEE 754 STL, IGES 5.3 surfaces, and SolidWorks VBA macros.`);
}

// ==============================================================================
// SLIDE 11: Granular Component Isolation & Multi-Part CAD
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 11, 'MANUFACTURING READINESS', 'Granular Component Isolation & Multi-Part CAD', 'Individual export capabilities for planetary sun, planet, ring gears, and pinions');

  // Col 1: Sun Isolated
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 3.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cardBorder, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetarySun)) {
    s.addImage({
      path: ASSETS.planetarySun,
      x: 0.82, y: 1.87, w: 3.71, h: 4.35
    });
  }
  s.addText('Figure 11.1: Sun Gear Isolated (Z=18, Motor Shaft Bore)', {
    x: 0.82, y: 6.25, w: 3.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 8.5, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  // Col 2: Planet Isolated
  s.addShape(pres.ShapeType.rect, {
    x: 4.78, y: 1.85, w: 3.75, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.cardBorder, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetaryPlanet)) {
    s.addImage({
      path: ASSETS.planetaryPlanet,
      x: 4.8, y: 1.87, w: 3.71, h: 4.35
    });
  }
  s.addText('Figure 11.2: Planet Gear Isolated (Z=27, Needle Bearing Bore)', {
    x: 4.8, y: 6.25, w: 3.71, h: 0.3,
    fontFace: 'Consolas', fontSize: 8.5, color: C.textDim,
    align: 'center', valign: 'middle'
  });

  // Col 3: Manufacturing Card
  s.addShape(pres.ShapeType.rect, {
    x: 8.78, y: 1.85, w: 3.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('WHY ISOLATION MATTERS', {
    x: 9.03, y: 2.1, w: 3.25, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Manufacturing Reality:\n', options: { bold: true, color: C.textMain } },
    { text: 'In CNC hobbing, wire EDM, and 3D printing, fabricating an assembled planetary gearbox as a single monolithic file is physically impossible.\n\n', options: { color: C.textMuted } },
    { text: '• Individual Toolpaths: ', options: { bold: true, color: C.textMain } },
    { text: 'Each component requires dedicated G-code generation and setup datum origins.\n\n', options: { color: C.textMuted } },
    { text: '• Unique Tolerancing: ', options: { bold: true, color: C.textMain } },
    { text: 'Sun gear requires motor shaft press-fit, while planets require needle bearing slip-fit tolerances.\n\n', options: { color: C.textMuted } },
    { text: '• Organized ZIP Package: ', options: { bold: true, color: C.textMain } },
    { text: 'One-click bundle extracts individual parts + assembly.', options: { color: C.textMuted } }
  ], {
    x: 9.03, y: 2.55, w: 3.25, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 11: Granular Component Isolation & Multi-Part CAD
Point out the new individual component download feature: Sun gear alone, Planet gear alone, Ring gear alone, and Carrier assembly.
Explain the manufacturing reality: CNC machine tools and 3D printers require isolated component G-codes with individual tolerancing.`);
}

// ==============================================================================
// SLIDE 12: Additive Manufacturing & Print Compensation
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 12, 'PHYSICAL PROTOTYPING', 'Additive Manufacturing & Print Compensation', 'Bridging mathematical CAD geometry to real-world FDM/SLA tolerance shrinkage');

  // Left Card: PrintComp Algorithm
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('PRINTCOMP ALGORITHMIC COMPENSATION', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Polymer Shrinkage Physics:\n', options: { bold: true, color: C.textMain } },
    { text: 'Polymer 3D printing (PLA, PETG, Nylon) experiences radial thermal contraction (0.3%–0.8%) and nozzle bead expansion, causing gear teeth to bind tightly if printed from nominal CAD.\n\n', options: { color: C.textMuted } },
    { text: 'Mathematical Compensation Formulas:\n', options: { bold: true, color: C.textMain } },
    { text: 's_offset = s_0 - Delta_thermal - Delta_backlash\nd_bore_adj = d_shaft + delta_clearance   (+0.15 mm)\n\n', options: { fontFace: 'Consolas', color: C.cyanLight } },
    { text: '• Involute Flank Thinning: ', options: { bold: true, color: C.textMain } },
    { text: 'Programmatic thinning (0.08–0.15 mm along profile normal) guarantees running backlash.\n\n', options: { color: C.textMuted } },
    { text: '• Shaft Bore Dilation: ', options: { bold: true, color: C.textMain } },
    { text: 'Compensates for the \'elephant foot\' effect, allowing press-fit bearings to seat cleanly without secondary reaming.', options: { color: C.textMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  // Right Card: Physical Validation
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('PHYSICAL PROTOTYPE VALIDATION', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Rigorous Slicer & Print Bed Verification:\n\n', options: { bold: true, color: C.textMain } },
    { text: '• 100% Watertight Manifold Topology: ', options: { bold: true, color: C.textMain } },
    { text: 'Generated STL meshes verify zero non-manifold edges, zero reversed normal facets, and zero self-intersections in PrusaSlicer and Cura.\n\n', options: { color: C.textMuted } },
    { text: '• Sub-0.01 mm Chordal Error: ', options: { bold: true, color: C.textMain } },
    { text: 'Involute curvature discretized with optimal angular increments, delivering smooth tooth flank finish without polygon facets.\n\n', options: { color: C.textMuted } },
    { text: '• Physical Test Meshing: ', options: { bold: true, color: C.textMain } },
    { text: 'Printed 3D gear pairs demonstrated smooth, hand-cranked mesh rotation without tooth tip binding or excessive backlash play.', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 12: Additive Manufacturing & Print Compensation
Demonstrate your understanding of physical fabrication. Explain the PrintComp module: polymer cooling shrinkage causes binding if printed from nominal CAD.
Explain programmatic tooth thinning (0.08 - 0.15 mm) and bore clearance offsets (+0.15 mm) to ensure parts fit off the print bed without post-machining.`);
}

// ==============================================================================
// SLIDE 13: UI/UX Modernization & Professional Standards
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 13, 'HUMAN-COMPUTER INTERACTION', 'UI/UX Modernization & Professional Design', 'Transforming the interface into a sleek, engineering-grade CAD tool');

  const uiCards = [
    {
      title: 'Precision CAD Vector Iconography',
      body: 'Eliminated all informal emojis and consumer icons across the entire application. Replaced with custom, precision SVG vector CAD symbols (gears, calipers, download vectors, and eye toggles) aligned with ISO software engineering standards.'
    },
    {
      title: 'Ergonomic Dark Glassmorphism',
      body: 'Engineered a modern engineering dark-slate design system with WCAG AAA compliant contrast ratios, backdrop blur filters, and subtle cyan accents to eliminate eye strain during lengthy engineering design sessions.'
    },
    {
      title: 'Draggable Resizable Panels',
      body: 'Implemented a zero-dependency draggable split gutter between the 2D Diagnostic Canvas and 3D Kinematics Viewport, giving engineers complete ergonomic control over their visualization workspace.'
    }
  ];

  uiCards.forEach((c, i) => {
    const cx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.85, w: 3.75, h: 4.75,
      fill: { color: C.cardBg },
      line: { color: i === 0 ? C.cyan : C.cardBorder, width: i === 0 ? 1.5 : 1 }
    });
    s.addText(c.title, {
      x: cx + 0.25, y: 2.1, w: 3.25, h: 0.45,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
    });
    s.addText(c.body, {
      x: cx + 0.25, y: 2.7, w: 3.25, h: 3.6,
      fontFace: 'Segoe UI', fontSize: 10.5, color: C.textMuted,
      lineSpacingMultiple: 1.2
    });
  });

  s.addNotes(`Slide 13: UI/UX Modernization & Professional Standards
Showcase the transition to a formal, modern engineering interface: vector CAD iconography, dark glassmorphism system, and draggable split panels.`);
}

// ==============================================================================
// SLIDE 14: Key Technical Hurdles & Engineering Solutions
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 14, 'PROBLEM SOLVING', 'Key Technical Hurdles & Engineering Solutions', 'Overcoming computational, geometric, and format constraints');

  const hurdles = [
    {
      title: 'Hurdle 1: Gleason Surface in Pure JS',
      challenge: 'Gleason face-milling equations produce non-uniform 3D spiral flanks normally calculated using dedicated CAD kernel APIs.',
      solution: 'Formulated a parametric circular cutting path generator that sweeps the cutter radius along the pitch cone, producing mathematically exact normals and vertices with sub-millimeter precision.'
    },
    {
      title: 'Hurdle 2: 2D Bevel Meshing Distortion',
      challenge: 'Bevel gears mesh along intersecting cones; projecting them directly onto a flat 2D plane caused severe distortion and false tooth interpenetration.',
      solution: 'Implemented the Tredgold Spherical Back-Cone transformation in plot2d.js, mapping 3D conical kinematics to an equivalent 2D virtual spur gear pair.'
    },
    {
      title: 'Hurdle 3: Direct STEP B-Rep Serialization',
      challenge: 'Writing an ISO 10303-21 text file from scratch requires strict topological syntax (CLOSED_SHELL, ORIENTED_EDGE, EDGE_LOOP).',
      solution: 'Built a custom topological graph serializer in JavaScript that automatically tracks vertex indices and assigns correct surface normals.'
    },
    {
      title: 'Hurdle 4: Planetary Component Extraction',
      challenge: 'Users needed individual Sun, Planet, and Ring gears for fabrication, but the scene was rendered as a single monolithic Three.js group.',
      solution: 'Refactored cadExporters.js with component isolation flags, allowing on-the-fly extraction of individual parts or complete ZIP packages.'
    }
  ];

  hurdles.forEach((h, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const hx = 0.8 + col * 5.95;
    const hy = 1.85 + row * 2.45;

    s.addShape(pres.ShapeType.rect, {
      x: hx, y: hy, w: 5.75, h: 2.25,
      fill: { color: C.cardBg },
      line: { color: C.cardBorder, width: 1 }
    });
    s.addText(h.title, {
      x: hx + 0.25, y: hy + 0.15, w: 5.25, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.cyan
    });
    s.addText([
      { text: 'Challenge: ', options: { bold: true, color: C.amber } },
      { text: `${h.challenge}\n`, options: { color: C.textMuted } },
      { text: 'Solution: ', options: { bold: true, color: C.emerald } },
      { text: h.solution, options: { color: C.textMain } }
    ], {
      x: hx + 0.25, y: hy + 0.48, w: 5.25, h: 1.65,
      fontFace: 'Segoe UI', fontSize: 9.5, lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 14: Key Technical Hurdles & Engineering Solutions
Discuss the four hardest technical challenges you overcame: Gleason 3D surfaces in WebGL, 2D bevel meshing via Tredgold, writing ISO 10303-21 STEP B-Rep text entities in JavaScript, and multi-component planetary extraction.`);
}

// ==============================================================================
// SLIDE 15: Quantitative Impact & Productivity Transformation
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 15, 'PERFORMANCE BENCHMARKING', 'Quantitative Impact & Productivity Transformation', 'Benchmarking the new Gear Design Studio against legacy engineering workflows');

  const tableRows = [
    [
      { text: 'Performance Metric', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Legacy Workflow', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'New Gear Design Studio', options: { bold: true, color: C.cyan, fill: '0F172A' } },
      { text: 'Improvement Factor', options: { bold: true, color: C.cyan, fill: '0F172A' } }
    ],
    [
      { text: 'Gearset Design Iteration', options: { bold: true, color: C.textMain } },
      { text: '2 – 4 Hours (Manual recalculations)', options: { color: C.textMuted } },
      { text: '< 100 Milliseconds (Live sliders)', options: { fontFace: 'Consolas', color: C.cyan, bold: true } },
      { text: '~1000x Faster', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'CAD Model Generation', options: { bold: true, color: C.textMain } },
      { text: '1 – 3 Days (Complex CAD tooth drafting)', options: { color: C.textMuted } },
      { text: '< 2 Seconds (Instant STEP/STL)', options: { fontFace: 'Consolas', color: C.cyan, bold: true } },
      { text: 'Instantaneous', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Software Licensing Cost', options: { bold: true, color: C.textMain } },
      { text: '$5,000+ / seat (CAD/FEA packages)', options: { color: C.textMuted } },
      { text: '$0 (Open-Source Client-Side Web)', options: { fontFace: 'Consolas', color: C.cyan, bold: true } },
      { text: '100% Cost Reduction', options: { bold: true, color: C.emerald } }
    ],
    [
      { text: 'Cross-Platform Accessibility', options: { bold: true, color: C.textMain } },
      { text: 'Windows workstation with CAD installed', options: { color: C.textMuted } },
      { text: 'Any Modern Browser (Zero install)', options: { fontFace: 'Consolas', color: C.cyan, bold: true } },
      { text: 'Universal Portability', options: { bold: true, color: C.emerald } }
    ]
  ];

  s.addTable(tableRows, {
    x: 0.8, y: 1.85, w: 11.733, h: 3.3,
    colW: [2.8, 3.2, 3.2, 2.533],
    fill: C.cardBg,
    border: { pt: 1, color: C.cardBorder },
    fontFace: 'Segoe UI', fontSize: 11,
    align: 'left', valign: 'middle'
  });

  // 3 Metric Badges
  const impactBadges = [
    { num: '7 / 7', label: 'Architectures Supported' },
    { num: '4 Formats', label: 'STEP • STL • IGES • SolidWorks' },
    { num: '0 KB', label: 'Server Overhead' }
  ];
  impactBadges.forEach((b, i) => {
    const bx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: bx, y: 5.4, w: 3.75, h: 1.2,
      fill: { color: C.cardBg },
      line: { color: C.cyan, width: 1.5 }
    });
    s.addText(b.num, {
      x: bx, y: 5.5, w: 3.75, h: 0.55,
      fontFace: 'Consolas', fontSize: 24, bold: true, color: C.cyan,
      align: 'center'
    });
    s.addText(b.label, {
      x: bx, y: 6.1, w: 3.75, h: 0.35,
      fontFace: 'Segoe UI', fontSize: 11, color: C.textMuted,
      align: 'center'
    });
  });

  s.addNotes(`Slide 15: Quantitative Impact & Productivity Transformation
Review the before-and-after table: design iterations cut from hours to milliseconds; CAD generation reduced from days of manual drafting to a 2-second client-side download; 100% cost reduction in CAD licensing.`);
}

// ==============================================================================
// SLIDE 16: Conclusion & Professional Reflection
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 16, 'SUMMARY & NEXT STEPS', 'Conclusion, Skills Acquired & Q&A', 'Summary of internship contributions to wind turbine drive engineering');

  // Left Card: Key Achievements
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('KEY ACHIEVEMENTS SUMMARY', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.cyan
  });
  s.addText([
    { text: 'Enterprise-Ready Software Ecosystem:\n', options: { bold: true, color: C.textMain } },
    { text: '• Formulated mathematical models for 7 gear architectures with ISO 6336 stress validation.\n\n', options: { color: C.textMuted } },
    { text: '• Built native MATLAB computational suites and interactive GUI tools.\n\n', options: { color: C.textMuted } },
    { text: '• Engineered a high-performance WebGL CAD Studio with real-time 3D kinematics and 2D meshing diagnostics.\n\n', options: { color: C.textMuted } },
    { text: '• Authored pure client-side STEP, STL, and IGES exporters eliminating reliance on expensive CAD software.\n\n', options: { color: C.textMuted } },
    { text: '• Bridged virtual CAD design with physical 3D printing shrinkage compensation.', options: { color: C.textMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  // Right Side: Competencies + Floor Opening
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 3.1,
    fill: { color: C.cardBg },
    line: { color: C.cardBorder, width: 1 }
  });
  s.addText('PROFESSIONAL COMPETENCIES ACQUIRED', {
    x: 7.08, y: 2.05, w: 5.15, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.cyan
  });
  s.addText([
    { text: '• Advanced Mechanical Kinematics & ISO 6336 Standards\n', options: { color: C.textMuted } },
    { text: '• Computational Geometry & Involute/Gleason Flank Discretization\n', options: { color: C.textMuted } },
    { text: '• 3D Computer Graphics (WebGL, Three.js, Shaders, Scene Graphs)\n', options: { color: C.textMuted } },
    { text: '• Low-Level CAD Protocols (ISO 10303-21 STEP, IGES 5.3, IEEE 754 STL)\n', options: { color: C.textMuted } },
    { text: '• Full-Stack Mechanical Software Architecture & Git Version Control', options: { color: C.textMuted } }
  ], {
    x: 7.08, y: 2.4, w: 5.15, h: 2.4,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.2
  });

  // Floor Opening Card
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 5.15, w: 5.75, h: 1.45,
    fill: { color: '0F172A' },
    line: { color: C.cyan, width: 1.5 }
  });
  s.addText('THANK YOU FOR YOUR GUIDANCE & MENTORSHIP', {
    x: 7.08, y: 5.35, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.textMain,
    align: 'center'
  });
  s.addText('The floor is now open for questions and technical discussion.', {
    x: 7.08, y: 5.8, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 11, bold: true, color: C.cyan,
    align: 'center'
  });

  s.addNotes(`Slide 16: Conclusion, Skills Acquired & Q&A
Recap the project accomplishments and articulate the professional engineering skills acquired during the internship. Invite the panel to ask questions and suggest live demonstrations.`);
}

// ==============================================================================
// WRITE PPTX TO DISK
// ==============================================================================
const rootOutPath = path.join(__dirname, '..', 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');
const localOutPath = path.join(__dirname, 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');

pres.writeFile({ fileName: rootOutPath })
  .then(() => {
    console.log(`PPTX exported successfully to root: ${rootOutPath}`);
    // Also copy to Internship_Presentation folder for convenience
    fs.copyFileSync(rootOutPath, localOutPath);
    console.log(`PPTX copy saved to: ${localOutPath}`);
  })
  .catch(err => {
    console.error('Error exporting PPTX:', err);
    process.exit(1);
  });
