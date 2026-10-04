/**
 * Generate UTM Mechanical Engineering Pitch Control Gear Presentation (.pptx)
 * 
 * Focus: Mechanical Engineering, Kinematics, Gear Geometry, ISO 6336 Stress & Manufacturing
 * Branding: Universiti Teknologi Malaysia (UTM) Modern Technical Deck
 * Author: Ahmed Majdy Ahmed
 * Target Audience: Academic Evaluators, Industry Mentors & Mechanical Engineering Leads
 */

const pptxgen = require('pptxgenjs');
const path = require('path');
const fs = require('fs');

const pres = new pptxgen();

// Set 16:9 Widescreen Layout (13.333" x 7.5")
pres.defineLayout({ name: 'WIDE_16_9', width: 13.333, height: 7.5 });
pres.layout = 'WIDE_16_9';

// UTM Engineering Color Palette (60-30-10 Rule)
const C = {
  white: 'FFFFFF',            // Canvas Background (60%)
  cardBg: 'FFFFFF',           // Crisp White Card Container
  cardAlt: 'F8FAFC',          // Light Slate-50 Container
  slateDark: '0F172A',        // Primary Engineering Typography (30%)
  slateMuted: '334155',       // Secondary Technical Text
  slateDim: '64748B',         // Annotations, Captions & Metadata
  borderSlate: 'CBD5E1',      // Precise Technical Borders (1px)
  maroon: '721422',           // UTM Primary Brand (10% Accent)
  maroonTint: 'F8EEF0',       // Light Maroon Pill Background
  maroonBorder: 'D89EA7',     // Pill & Box Border
  gold: 'C58B12',             // UTM Warm Gold Accent (Darkened for contrast on white)
  goldLight: 'FDF8EB',        // Light Gold Pill Background
  goldBorder: 'E6C77B',       // Gold Border
  emerald: '059669',          // Verified / Pass indicator
  navyCode: '0B192C'          // Formula Block Background
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

// Helper: Standard UTM Mechanical Engineering Slide Header & Footer
function setupMechanicalSlide(slide, slideNum, sectionTag, title, subtitle) {
  slide.background = { color: C.white };

  // Section Tag Pill (UTM Maroon Border & Text)
  slide.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.42, w: 3.6, h: 0.26,
    fill: { color: C.maroonTint },
    line: { color: C.maroonBorder, width: 1 }
  });
  slide.addText(sectionTag.toUpperCase(), {
    x: 0.8, y: 0.42, w: 3.6, h: 0.26,
    fontFace: 'Consolas', fontSize: 8.5, bold: true, color: C.maroon,
    align: 'center', valign: 'middle'
  });

  // Main Slide Title
  slide.addText(title, {
    x: 0.8, y: 0.74, w: 11.7, h: 0.45,
    fontFace: 'Segoe UI', fontSize: 22, bold: true, color: C.slateDark,
    valign: 'middle'
  });

  // Technical Subtitle
  slide.addText(subtitle, {
    x: 0.8, y: 1.22, w: 11.7, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 11, color: C.slateMuted,
    valign: 'top'
  });

  // Fine UTM Maroon Accent Divider Line
  slide.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.56, w: 11.733, h: 0.025,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });

  // Bottom Footer
  slide.addShape(pres.ShapeType.line, {
    x: 0.8, y: 6.9, w: 11.733, h: 0,
    line: { color: C.borderSlate, width: 0.8 }
  });

  slide.addText('Universiti Teknologi Malaysia (UTM)  |  Faculty of Mechanical Engineering', {
    x: 0.8, y: 6.96, w: 5.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9, color: C.slateDim,
    valign: 'middle'
  });

  slide.addText('Ahmed Majdy Ahmed  —  Wind Turbine Pitch Drive Gearbox Design', {
    x: 5.5, y: 6.96, w: 5.0, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9, color: C.slateDim,
    align: 'center', valign: 'middle'
  });

  slide.addText(`Slide ${String(slideNum).padStart(2, '0')} / 10`, {
    x: 10.7, y: 6.96, w: 1.833, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.maroon, bold: true,
    align: 'right', valign: 'middle'
  });
}

// ==============================================================================
// SLIDE 01: Title & Project Identification
// ==============================================================================
{
  const s = pres.addSlide();
  s.background = { color: C.maroon };

  // Left Gold Accent Bar
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.8, w: 0.12, h: 5.9,
    fill: { color: C.gold },
    line: { color: C.gold, width: 0 }
  });

  // Institution Banner
  s.addShape(pres.ShapeType.rect, {
    x: 1.2, y: 0.85, w: 5.2, h: 0.32,
    fill: { color: '580E18' },
    line: { color: C.gold, width: 1 }
  });
  s.addText('UNIVERSITI TEKNOLOGI MALAYSIA (UTM)', {
    x: 1.2, y: 0.85, w: 5.2, h: 0.32,
    fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.gold,
    align: 'center', valign: 'middle'
  });

  // Main Mechanical Title
  s.addText('Wind Turbine Blade Pitch Control Drivetrain:', {
    x: 1.2, y: 1.45, w: 10.8, h: 0.6,
    fontFace: 'Segoe UI', fontSize: 29, bold: true, color: C.white
  });
  s.addText('Multi-Architecture Gear Kinematics, ISO 6336 Stress & Manufacturing', {
    x: 1.2, y: 2.1, w: 10.8, h: 0.55,
    fontFace: 'Segoe UI', fontSize: 24, bold: true, color: C.gold
  });

  // Subtitle
  s.addText('Final Internship Technical Defense  —  Mechanical Drive Systems & Precision Gearing', {
    x: 1.2, y: 2.78, w: 10.8, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, color: 'E2E8F0'
  });

  // Divider
  s.addShape(pres.ShapeType.line, {
    x: 1.2, y: 3.25, w: 11.3, h: 0,
    line: { color: '8B1E2E', width: 1 }
  });

  // Candidate & Academic Info Box
  s.addShape(pres.ShapeType.rect, {
    x: 1.2, y: 3.55, w: 5.8, h: 3.0,
    fill: { color: '580E18' },
    line: { color: '8B1E2E', width: 1 }
  });
  s.addText('CANDIDATE & EXAMINATION METADATA', {
    x: 1.4, y: 3.7, w: 5.4, h: 0.28,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.gold
  });
  s.addText([
    { text: 'Candidate: ', options: { bold: true, color: C.white } },
    { text: 'Ahmed Majdy Ahmed\n', options: { color: 'F1F5F9' } },
    { text: 'Academic Institution: ', options: { bold: true, color: C.white } },
    { text: 'Universiti Teknologi Malaysia (UTM)\n', options: { color: 'F1F5F9' } },
    { text: 'Discipline: ', options: { bold: true, color: C.white } },
    { text: 'Mechanical Engineering (Machine Design & Drivetrains)\n', options: { color: 'F1F5F9' } },
    { text: 'Primary Standards: ', options: { bold: true, color: C.white } },
    { text: 'ISO 6336 (Method B), AGMA 2003-B02, Gleason Bevel Standards\n', options: { color: 'F1F5F9' } },
    { text: 'Deliverables: ', options: { bold: true, color: C.white } },
    { text: 'Kinematic Solvers, MATLAB Suites, SolidWorks B-Rep CAD Models', options: { color: 'F1F5F9' } }
  ], {
    x: 1.4, y: 4.05, w: 5.4, h: 2.35,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.2
  });

  // Right Side Preview Container: Real Planetary 3D Gear Assembly
  s.addShape(pres.ShapeType.rect, {
    x: 7.3, y: 3.55, w: 5.2, h: 3.0,
    fill: { color: '000000' },
    line: { color: C.gold, width: 1.2 }
  });
  if (fs.existsSync(ASSETS.planetaryOverview)) {
    s.addImage({
      path: ASSETS.planetaryOverview,
      x: 7.32, y: 3.57, w: 5.16, h: 2.65
    });
  }
  s.addText('Figure 1.1: Coaxial Epicyclic Pitch Reducer Assembly (Sun, 3 Planets, Fixed Ring)', {
    x: 7.32, y: 6.27, w: 5.16, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 1: Title & Project Identification
"Good morning, respected academic supervisors and mentors.
My name is Ahmed Majdy Ahmed from the Faculty of Mechanical Engineering at Universiti Teknologi Malaysia.
Today, I present the engineering results of my internship: the design, kinematic modeling, and ISO 6336 stress analysis of a precision gear drive for wind turbine blade pitch regulation.
Rather than treating this purely as software, I will focus on the mechanical machine design challenges: tooth contact kinematics, Gleason cutter geometry, Willis planetary velocity ratios, bending and contact stress safety factors, and manufacturing backlash tolerancing."`);
}

// ==============================================================================
// SLIDE 02: Pitch Mechanism Operating Conditions & Aerodynamic Load Cases
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 2, 'OPERATING ENVIRONMENT', 'Pitch Actuator Mechanical Operating Conditions & Load Cases', 'Aerodynamic pitch regulation, cyclic gravity moments, emergency storm feathering, and backlash limits');

  const cards = [
    {
      title: 'Aerodynamic Pitch Demands',
      badge: 'AERODYNAMICS',
      content: [
        { text: '• Power Coefficient Regulation: ', options: { bold: true, color: C.slateDark } },
        { text: 'Blades continuously adjust pitch angle beta between 0° and 30° to maintain optimal tip-speed ratio lambda and maximize aerodynamic efficiency Cp(lambda, beta).\n\n', options: { color: C.slateMuted } },
        { text: '• Emergency Full Feathering: ', options: { bold: true, color: C.slateDark } },
        { text: 'Must pitch 90° into feather within < 5 seconds (pitch rate theta_dot >= 8°/s) to arrest rotor rotation during extreme storm gusts (> 25 m/s).' }
      ]
    },
    {
      title: 'Structural & Dynamic Loads',
      badge: 'MECHANICAL FATIGUE',
      content: [
        { text: '• Cyclic Gravitational Bending: ', options: { bold: true, color: C.slateDark } },
        { text: 'Each 360° rotor rotation exerts alternating bending moments on the blade root bearing and drive pinion (over 10^8 cycles across 20-year lifespan).\n\n', options: { color: C.slateMuted } },
        { text: '• Aerodynamic Torsional Flutter: ', options: { bold: true, color: C.slateDark } },
        { text: 'Wind shear across rotor swept area produces fluctuating pitch axis torque, requiring strict gear tooth stiffness and surface durability.' }
      ]
    },
    {
      title: 'Kinematic & Backlash Limits',
      badge: 'PRECISION LIMITS',
      content: [
        { text: '• High Gear Reduction Ratios: ', options: { bold: true, color: C.slateDark } },
        { text: 'Servomotors operating at 1,500–3,000 RPM must be stepped down to 0.5–2 RPM at the blade root, requiring ratios of i = 50:1 to 150:1 in compact nacelle space.\n\n', options: { color: C.slateMuted } },
        { text: '• Strict Backlash Tolerance: ', options: { bold: true, color: C.slateDark } },
        { text: 'Circumferential backlash must not exceed jt <= 0.05 mm to prevent aerodynamic blade vibration and loss of active stall control.' }
      ]
    }
  ];

  cards.forEach((c, i) => {
    const cx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.82, w: 3.75, h: 4.8,
      fill: { color: C.cardBg },
      line: { color: C.borderSlate, width: 1 }
    });

    // Top Accent Stripe
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.82, w: 3.75, h: 0.04,
      fill: { color: i === 0 ? C.maroon : (i === 1 ? C.gold : C.slateDark) },
      line: { color: C.white, width: 0 }
    });

    s.addText(c.title, {
      x: cx + 0.25, y: 2.05, w: 3.25, h: 0.4,
      fontFace: 'Segoe UI', fontSize: 12.5, bold: true, color: C.slateDark
    });

    s.addShape(pres.ShapeType.rect, {
      x: cx + 0.25, y: 2.5, w: 1.6, h: 0.22,
      fill: { color: C.cardAlt },
      line: { color: C.borderSlate, width: 0.8 }
    });
    s.addText(c.badge, {
      x: cx + 0.25, y: 2.5, w: 1.6, h: 0.22,
      fontFace: 'Consolas', fontSize: 7.5, bold: true, color: C.maroon,
      align: 'center', valign: 'middle'
    });

    s.addText(c.content, {
      x: cx + 0.25, y: 2.9, w: 3.25, h: 3.5,
      fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 2: Pitch Actuator Mechanical Operating Conditions & Load Cases
"To design a reliable pitch gearbox, we must understand the mechanical load cases:
1. Aerodynamic power regulation requires continuous micro-pitching to hold the rated aerodynamic power curve, but in storms exceeding 25 m/s, the drive must feather 90 degrees in under 5 seconds against massive drag moments.
2. Cyclic fatigue: as each blade rotates, gravitational bending moments reverse every cycle, totaling over 100 million cycles in 20 years.
3. Kinematics: high reduction ratios between 50:1 and 150:1 are required to step down 3000 RPM servomotors to 1 RPM, while limiting backlash under 0.05 mm to prevent aerodynamic stall flutter."`);
}

// ==============================================================================
// SLIDE 03: Drivetrain Architecture: Central Ring to 3-Blade Pinions
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 3, 'DRIVETRAIN ARCHITECTURE', 'Pitch Drivetrain Topology: Central Ring to 3-Blade Pitch Pinions', 'Mechanical power transmission, 120° spatial layout, torque allocation, and kinematic step-down');

  // Left Side: Drivetrain Schematic & Technical Specs
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 6.0, h: 4.8,
    fill: { color: C.cardAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('DRIVETRAIN MECHANICAL SCHEMATIC & POWER FLOW', {
    x: 1.05, y: 2.02, w: 5.5, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.maroon
  });

  // Power flow diagram box
  s.addShape(pres.ShapeType.rect, {
    x: 1.05, y: 2.4, w: 5.5, h: 1.4,
    fill: { color: C.white },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText([
    { text: 'Actuation Motor  (100 RPM, T_in = 20.0 N·m, P = 209.4 W)\n', options: { fontFace: 'Consolas', fontSize: 9, bold: true, color: C.slateDark } },
    { text: '       │\n       ▼\n', options: { fontFace: 'Consolas', fontSize: 9, color: C.maroon } },
    { text: 'Central Ring Gear Driver  (Ng = 48 teeth, dg = 144.0 mm, m = 3.0 mm)\n', options: { fontFace: 'Consolas', fontSize: 9, bold: true, color: C.slateDark } },
    { text: '       ├─── [ 120° Spacing ] ──► Pinion #1 (16T, 300 RPM) ──► Blade 1 Shaft\n', options: { fontFace: 'Consolas', fontSize: 8.5, color: C.slateMuted } },
    { text: '       ├─── [ 120° Spacing ] ──► Pinion #2 (16T, 300 RPM) ──► Blade 2 Shaft\n', options: { fontFace: 'Consolas', fontSize: 8.5, color: C.slateMuted } },
    { text: '       └─── [ 120° Spacing ] ──► Pinion #3 (16T, 300 RPM) ──► Blade 3 Shaft', options: { fontFace: 'Consolas', fontSize: 8.5, color: C.slateMuted } }
  ], {
    x: 1.15, y: 2.45, w: 5.3, h: 1.3,
    lineSpacingMultiple: 1.1
  });

  // Table of Kinematic & Force Parameters
  const paramTable = [
    [
      { text: 'Kinematic Parameter', options: { bold: true, color: C.maroon, fill: C.maroonTint } },
      { text: 'Symbol / Formula', options: { bold: true, color: C.slateDark, fill: C.maroonTint } },
      { text: 'Design Value', options: { bold: true, color: C.slateDark, fill: C.maroonTint } }
    ],
    [
      { text: 'Shaft Angle (Orthogonal)', options: { bold: true } },
      { text: 'Sigma = delta_1 + delta_2', options: { fontFace: 'Consolas' } },
      { text: '90.0°', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Transmission Ratio (per mesh)', options: { bold: true } },
      { text: 'i = Ng / Np = 48 / 16', options: { fontFace: 'Consolas' } },
      { text: '1 : 3.0 (Speed Step-Up)', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Torque per Mesh Interface', options: { bold: true } },
      { text: 'T_mesh = T_total / 3', options: { fontFace: 'Consolas' } },
      { text: '6.67 N·m', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Output Torque per Pinion', options: { bold: true } },
      { text: 'T_pinion = (T_mesh / i) * eta', options: { fontFace: 'Consolas' } },
      { text: '2.16 N·m  (eta = 97%)', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Pitch Tangential Force', options: { bold: true } },
      { text: 'Ft = 2 * T_mesh / d_mean', options: { fontFace: 'Consolas' } },
      { text: '101.7 N', options: { fontFace: 'Consolas', bold: true } }
    ]
  ];

  s.addTable(paramTable, {
    x: 1.05, y: 3.95, w: 5.5, h: 2.5,
    colW: [2.3, 1.9, 1.3],
    fill: C.white,
    border: { pt: 0.8, color: C.borderSlate },
    fontFace: 'Segoe UI', fontSize: 9,
    align: 'left', valign: 'middle'
  });

  // Right Side: 3D Visualization of the Multi-Pinion Drive
  s.addShape(pres.ShapeType.rect, {
    x: 7.05, y: 1.82, w: 5.48, h: 4.8,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.spurGear)) {
    s.addImage({
      path: ASSETS.spurGear,
      x: 7.07, y: 1.84, w: 5.44, h: 4.4
    });
  }
  s.addText('Figure 3.1: 3-Pinion Load-Sharing Pitch Drive Synchronized at 120° Spatial Intervals', {
    x: 7.07, y: 6.3, w: 5.44, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 3: Pitch Drivetrain Topology: Central Ring to 3-Blade Pitch Pinions
"Here is the physical drivetrain topology:
A central driver gear (48 teeth, 144 mm pitch diameter) meshes simultaneously with three driven pinions (16 teeth each) spaced at 120 degrees around the perimeter.
Each pinion is keyed directly to one wind turbine blade pitch shaft.
Notice the mechanical advantage of this load-sharing architecture: total motor torque is split equally into three parallel paths (6.67 N·m per mesh), reducing tooth bending loads while ensuring all three blades pitch in perfect angular synchronization."`);
}

// ==============================================================================
// SLIDE 04: Gleason Zerol Bevel Gear Theory & Axial Thrust Elimination
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 4, 'BEVEL GEAR MECHANICS', 'Gleason Zerol Bevel Gear Theory & Axial Thrust Elimination', 'Zero mean spiral angle, localized crowned tooth contact, and bearing load reduction');

  // Left Column: Mechanical Theory & Equations
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('THE KINEMATIC PRINCIPLE OF ZEROL BEVELS', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'Definition & Geometry:\n', options: { bold: true, color: C.slateDark } },
    { text: 'A Zerol bevel gear is a curved-tooth bevel gear manufactured via the Gleason face-milling process where the spiral angle at midface is strictly zero (beta_m = 0°).\n\n', options: { color: C.slateMuted } },
    { text: 'Gleason Face-Cutter Radius Formulation:\n', options: { bold: true, color: C.slateDark } },
    { text: 'r_cutter = (A_0 * sin(delta_2)) / cos(delta_1)   ~= A_m (Mean Cone Distance)\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Tooth Force Decomposition (Zero Axial Thrust):\n', options: { bold: true, color: C.slateDark } },
    { text: '• Tangential force:   Ft = 2 * T_p / d_mp\n• Radial separating:  Fr = Ft * tan(phi) * cos(delta_p)\n• Axial thrust force: Fa = Ft * [tan(phi)*sin(delta_p) - tan(beta_m)*cos(delta_p)]\n\n', options: { fontFace: 'Consolas', color: C.slateDark } },
    { text: 'When beta_m = 0° ==> tan(beta_m) = 0:\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'The heavy axial thrust load generated by spiral bevel gears is eliminated, drastically reducing axial bearing preload requirements and housing mass.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
  });

  // Right Side: Zerol Bevel 3D Mesh & Mechanical Comparison Table
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 2.5,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.zerolBevel)) {
    s.addImage({
      path: ASSETS.zerolBevel,
      x: 6.8, y: 1.84, w: 5.71, h: 2.15
    });
  }
  s.addText('Figure 4.1: Zerol Bevel Gear Mesh showing Curved Flanks pointing to Cone Apex', {
    x: 6.8, y: 4.05, w: 5.71, h: 0.22,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Comparison Table: Straight vs Zerol vs Spiral
  const compTable = [
    [
      { text: 'Bevel Gear Type', options: { bold: true, color: C.maroon, fill: C.maroonTint } },
      { text: 'Spiral Angle', options: { bold: true, fill: C.maroonTint } },
      { text: 'Axial Thrust (Fa)', options: { bold: true, fill: C.maroonTint } },
      { text: 'Contact Pattern', options: { bold: true, fill: C.maroonTint } }
    ],
    [
      { text: 'Straight Bevel', options: { bold: true } },
      { text: 'beta = 0° (Straight)', options: { fontFace: 'Consolas' } },
      { text: 'Low', options: { fontFace: 'Consolas' } },
      { text: 'Full line contact (sensitive to misalignment)' }
    ],
    [
      { text: 'Zerol Bevel (Selected)', options: { bold: true, color: C.maroon } },
      { text: 'beta_m = 0° (Curved)', options: { fontFace: 'Consolas', bold: true } },
      { text: 'Zero / Minimal', options: { fontFace: 'Consolas', bold: true, color: C.emerald } },
      { text: 'Elliptical crowned contact (tolerates shaft deflection)', options: { bold: true } }
    ],
    [
      { text: 'Spiral Bevel', options: { bold: true } },
      { text: 'beta = 25°–35°', options: { fontFace: 'Consolas' } },
      { text: 'Very High', options: { fontFace: 'Consolas' } },
      { text: 'Overlapping helical contact (heavy thrust bearings)' }
    ]
  ];

  s.addTable(compTable, {
    x: 6.78, y: 4.4, w: 5.75, h: 2.2,
    colW: [1.7, 1.4, 1.1, 1.55],
    fill: C.white,
    border: { pt: 0.8, color: C.borderSlate },
    fontFace: 'Segoe UI', fontSize: 8.5,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 4: Gleason Zerol Bevel Gear Theory & Axial Thrust Elimination
"Why did we choose Zerol bevel gears for the blade pitch mechanism?
Look at the mechanical comparison table at the bottom right:
- Straight bevel gears have straight line contact, which concentrates stress at tooth edges under shaft deflection.
- Spiral bevel gears provide smooth overlap, but generate severe axial thrust forces, requiring heavy angular-contact duplex bearings.
- The Zerol bevel gear resolves both: its teeth follow a circular arc (cut with a 76.2 mm Gleason cutter), providing a localized elliptical contact patch that accommodates aerodynamic hub deflection, while setting beta_m = 0° eliminates axial thrust. This saves significant bearing mass in the wind turbine blade root."`);
}

// ==============================================================================
// SLIDE 05: Gleason Unequal Addendum System & Tooth Geometry
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 5, 'GEAR TOOTH GEOMETRY', 'Gleason Unequal Addendum System & Tooth Profile Geometry', 'Preventing pinion undercutting, balancing specific sliding velocities, and tooth depth standards');

  // Left Column: Unequal Addendum Explanation & Table
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('GLEASON 60/40 UNEQUAL ADDENDUM RATIO', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'The Undercutting Problem on Pinions (z < 17):\n', options: { bold: true, color: C.slateDark } },
    { text: 'Standard 20° full-depth involute teeth suffer from severe root undercutting when tooth count z < 17. Because our pitch pinion has only Np = 16 teeth, standard proportions would hollow out the tooth fillet, severely compromising bending fatigue strength.\n\n', options: { color: C.slateMuted } },
    { text: 'Gleason Addendum Modification Solution:\n', options: { bold: true, color: C.slateDark } },
    { text: 'We allocate 60% of working depth to the pinion and 40% to the gear:\n', options: { color: C.slateMuted } },
    { text: '• Pinion Addendum:  a_p = 0.60 * hw = 0.60 * (2.0 * m) = 3.600 mm\n• Gear Addendum:    a_g = 0.40 * hw = 0.40 * (2.0 * m) = 2.400 mm\n• Clearance:        c   = 0.188 * m = 0.564 mm\n• Whole Depth:      ht  = hw + c = 6.000 + 0.564 = 6.564 mm\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Kinematic Benefit:\n', options: { bold: true, color: C.slateDark } },
    { text: 'This shift displaces the active mesh contact outside the interference zone, completely eliminates undercutting, and balances maximum specific sliding velocities between pinion approach and recess.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
  });

  // Right Column: Tooth Proportions Table & Cone Angle Metrics
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('DERIVED BEVEL CONE PARAMETERS (m = 3.0 mm, Sigma = 90°)', {
    x: 7.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Consolas', fontSize: 9.5, bold: true, color: C.slateDark
  });

  const geomTable = [
    [
      { text: 'Parameter', options: { bold: true, color: C.maroon, fill: C.white } },
      { text: 'Formula', options: { bold: true, fill: C.white } },
      { text: 'Pinion (16T)', options: { bold: true, fill: C.white } },
      { text: 'Gear (48T)', options: { bold: true, fill: C.white } }
    ],
    [
      { text: 'Pitch Diameter (d)', options: { bold: true } },
      { text: 'm * N', options: { fontFace: 'Consolas' } },
      { text: '48.00 mm', options: { fontFace: 'Consolas', bold: true } },
      { text: '144.00 mm', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Pitch Cone Angle (delta)', options: { bold: true } },
      { text: 'atan(Np / Ng)', options: { fontFace: 'Consolas' } },
      { text: '18.435°', options: { fontFace: 'Consolas', bold: true } },
      { text: '71.565°', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Outer Cone Distance (A0)', options: { bold: true } },
      { text: 'd / (2 * sin(delta))', options: { fontFace: 'Consolas' } },
      { text: '75.895 mm', options: { fontFace: 'Consolas' } },
      { text: '75.895 mm', options: { fontFace: 'Consolas' } }
    ],
    [
      { text: 'Face Width (b)', options: { bold: true } },
      { text: 'min(10*m, 0.3*A0)', options: { fontFace: 'Consolas' } },
      { text: '20.00 mm', options: { fontFace: 'Consolas', bold: true } },
      { text: '20.00 mm', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Mean Cone Distance (Am)', options: { bold: true } },
      { text: 'A0 - b / 2', options: { fontFace: 'Consolas' } },
      { text: '65.895 mm', options: { fontFace: 'Consolas' } },
      { text: '65.895 mm', options: { fontFace: 'Consolas' } }
    ],
    [
      { text: 'Addendum Angle (alpha_a)', options: { bold: true } },
      { text: 'atan(a / A0)', options: { fontFace: 'Consolas' } },
      { text: '2.716°', options: { fontFace: 'Consolas' } },
      { text: '1.811°', options: { fontFace: 'Consolas' } }
    ],
    [
      { text: 'Face Angle (delta_f)', options: { bold: true } },
      { text: 'delta + alpha_a', options: { fontFace: 'Consolas' } },
      { text: '21.151°', options: { fontFace: 'Consolas', bold: true } },
      { text: '73.376°', options: { fontFace: 'Consolas', bold: true } }
    ]
  ];

  s.addTable(geomTable, {
    x: 7.05, y: 2.45, w: 5.25, h: 3.9,
    colW: [1.6, 1.45, 1.1, 1.1],
    fill: C.cardBg,
    border: { pt: 0.8, color: C.borderSlate },
    fontFace: 'Segoe UI', fontSize: 8.5,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 5: Gleason Unequal Addendum System & Tooth Geometry
"In standard gear design, a 16-tooth pinion would suffer severe undercutting because 16 is below the theoretical limit of 17 teeth.
To solve this, we applied the Gleason Unequal Addendum system:
The pinion is given 60% of the working depth (3.60 mm addendum), while the gear gets 40% (2.40 mm addendum).
This modification shifts the contact line away from the pinion root, eliminating undercutting and strengthening tooth root bending resistance without changing center distance or operating pressure angle."`);
}

// ==============================================================================
// SLIDE 06: Epicyclic Planetary Architecture & Willis Kinematics
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 6, 'PLANETARY TRANSMISSION', 'Epicyclic Planetary Architecture & Willis Velocity Kinematics', 'Coaxial high-reduction drive, Willis relative speed equation, assembly symmetry, and AGMA load sharing');

  // Left Column: Kinematic Equations & Assembly Rules
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('WILLIS RELATIVE VELOCITY & COAXIAL GEOMETRY', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'Willis Fundamental Epicyclic Equation:\n', options: { bold: true, color: C.slateDark } },
    { text: '(omega_sun - omega_carrier) / (omega_ring - omega_carrier) = - (N_ring / N_sun)\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Stationary Ring Gear Configuration (omega_ring = 0):\n', options: { bold: true, color: C.slateDark } },
    { text: '• Speed Ratio:         i = omega_sun / omega_carrier = 1 + (N_r / N_s)\n• For N_s = 12, N_r = 48 ==> i = 1 + (48 / 12) = 5.0 : 1\n• Planet Spin Speed:   omega_planet/carrier = - omega_c * (N_r / N_p)\n\n', options: { fontFace: 'Consolas', color: C.slateDark } },
    { text: 'Coaxial Kinematic Assembly Sizing Rule:\n', options: { bold: true, color: C.slateDark } },
    { text: 'N_ring = N_sun + 2 * N_planet  ==>  48 = 12 + 2 * (18)  [Verified Equal Center Distances]\n\n', options: { fontFace: 'Consolas', color: C.slateMuted } },
    { text: 'Symmetrical Planet Spacing Condition (K = 3 Planets at 120°):\n', options: { bold: true, color: C.slateDark } },
    { text: '(N_sun + N_ring) / K = (12 + 48) / 3 = 20  [Exact Integer ==> Symmetrical Mesh]\n\n', options: { fontFace: 'Consolas', color: C.emerald, bold: true } },
    { text: 'AGMA 6123-B06 Planetary Load-Sharing Factor:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Due to manufacturing pitch runout, load is not split perfectly 33.3%; we apply K_gamma = 1.10 to size tooth forces conservative for industrial reliability.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
  });

  // Right Column: Isolated Planetary Components (Sun + Planet + Assembly)
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 2.8,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetarySun)) {
    s.addImage({
      path: ASSETS.planetarySun,
      x: 6.8, y: 1.84, w: 2.85, h: 2.5
    });
  }
  if (fs.existsSync(ASSETS.planetaryPlanet)) {
    s.addImage({
      path: ASSETS.planetaryPlanet,
      x: 9.68, y: 1.84, w: 2.83, h: 2.5
    });
  }
  s.addText('Figure 6.1: Extracted Sun Gear (Left, Motor Bore) & Planet Gear (Right, Needle Bearing Bore)', {
    x: 6.8, y: 4.37, w: 5.71, h: 0.22,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Mechanical Metrics Card
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 4.7, w: 5.75, h: 1.92,
    fill: { color: C.cardAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('PLANETARY FORCE & TORQUE DISTRIBUTION (Input: 15 N·m @ 500 RPM)', {
    x: 7.0, y: 4.85, w: 5.3, h: 0.25,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.slateDark
  });
  s.addText([
    { text: '• Carrier Output Torque:  ', options: { bold: true, color: C.slateDark } },
    { text: 'T_out = T_in * i * eta = 15.0 * 5.0 * 0.97 = 72.75 N·m\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: '• Tangential Mesh Load:   ', options: { bold: true, color: C.slateDark } },
    { text: 'Ft = (2 * T_in / (d_s * K)) * K_gamma = (30,000 / (36 * 3)) * 1.10 = 305.6 N\n', options: { fontFace: 'Consolas', color: C.slateDark } },
    { text: '• Separating Radial Load: ', options: { bold: true, color: C.slateDark } },
    { text: 'Fr = Ft * tan(20°) = 305.6 * 0.364 = 111.2 N (balanced on central sun)', options: { fontFace: 'Consolas', color: C.slateMuted } }
  ], {
    x: 7.0, y: 5.15, w: 5.3, h: 1.35,
    fontFace: 'Segoe UI', fontSize: 9.5, lineSpacingMultiple: 1.2
  });

  s.addNotes(`Slide 6: Epicyclic Planetary Architecture & Willis Velocity Kinematics
"For high-torque, compact nacelle installations, we modeled the Epicyclic Planetary Gear Train:
1. Willis Kinematics: with a fixed ring gear, the speed reduction ratio is exactly 1 + Nr/Ns = 1 + 48/12 = 5:1.
2. Geometric coaxiality requires Nr = Ns + 2*Np (48 = 12 + 36), which equalizes the sun-planet and planet-ring center distances.
3. Assembly symmetry requires (Ns + Nr) / K to be an exact integer. (12 + 48)/3 = 20, guaranteeing that all three planets mesh with identical 120-degree phase spacing.
4. Force sharing: radial tooth forces cancel out symmetrically on the central sun shaft, eliminating bending loads on the high-speed motor shaft."`);
}

// ==============================================================================
// SLIDE 07: 2D Contact Diagnostics & Tredgold Back-Cone Mechanics
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 7, 'CONTACT MECHANICS', '2D Contact Diagnostics & Tredgold Back-Cone Kinematics', 'Conjugate tooth action, line-of-action tracking, base circle tangency, and spherical projection');

  // Left Side: 2D Contact Mesh Image
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.straightMesh2d)) {
    s.addImage({
      path: ASSETS.straightMesh2d,
      x: 0.82, y: 1.84, w: 5.71, h: 4.4
    });
  }
  s.addText('Figure 7.1: 2D Diagnostic Mesh displaying Pitch Circles, Base Circles, & Line of Action (alpha = 20°)', {
    x: 0.82, y: 6.3, w: 5.71, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Right Column: Tredgold Transformation & Conjugate Proof
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('TREDGOLD SPHERICAL BACK-CONE TRANSFORMATION', {
    x: 7.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'Why Planar Projection Fails for Bevel Gears:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Bevel teeth lie on a spherical surface centered at the apex. Projecting a 3D bevel cone directly onto a flat screen skews tooth curves and creates false visual interpenetration.\n\n', options: { color: C.slateMuted } },
    { text: 'Tredgold Virtual Spur Equivalent Equations:\n', options: { bold: true, color: C.slateDark } },
    { text: '• Virtual Pinion Teeth:   z_vp = N_p / cos(delta_p) = 16 / cos(18.435°) = 16.86\n• Virtual Gear Teeth:     z_vg = N_g / cos(delta_g) = 48 / cos(71.565°) = 151.79\n• Virtual Pitch Radii:    r_vp = r_p / cos(delta_p) = 24.0 / 0.9487 = 25.30 mm\n• Virtual Center Dist:    C_v  = r_vp + r_vg = 25.30 + 227.69 = 252.99 mm\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Conjugate Action Verification:\n', options: { bold: true, color: C.slateDark } },
    { text: 'The pressure line of action is drawn exactly tangent to both virtual base circles (r_b = r_v * cos(20°)).\nDuring rotation, the contact point tracks along this line, proving:\n1. Constant angular velocity transmission ratio (i = 3.0).\n2. Continuous contact ratio (epsilon_alpha = 1.62 > 1.20 minimum standard).\n3. Zero tooth tip interference or root gouging during roll.', options: { color: C.slateMuted } }
  ], {
    x: 7.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
  });

  s.addNotes(`Slide 7: 2D Contact Diagnostics & Tredgold Back-Cone Kinematics
"A critical mechanical challenge was verifying 2D conjugate meshing for bevel gears:
In 3D, bevel teeth lie on spheres. Projecting them onto a 2D plane creates perspective distortion.
We resolved this using the classical Tredgold Virtual Back-Cone Transformation:
We calculate virtual tooth counts: z_vp = 16 / cos(18.43°) = 16.86 teeth, and z_vg = 151.79 teeth.
This projects the true spherical tooth contact onto an equivalent planar rack and pinion conjugate pair.
As seen in Figure 7.1, the line of action is drawn tangent to the base circles with a calculated transverse contact ratio of 1.62, proving smooth, non-interfering conjugate motion."`);
}

// ==============================================================================
// SLIDE 08: ISO 6336 & AGMA Stress Verification
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 8, 'STRESS & FATIGUE ANALYSIS', 'ISO 6336 Tooth Root Bending & Hertzian Contact Durability', 'Lewis bending rating, AGMA dynamic factor, surface pitting resistance, and material endurance limits');

  // Left Column: Stress Formulations & Factor Breakdown
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('ISO 6336 METHOD B STRESS EQUATIONS', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: '1. Tooth Root Bending Stress (Lewis / ISO 6336):\n', options: { bold: true, color: C.slateDark } },
    { text: 'sigma_F = (F_t / (b * m_n)) * Y_F * Y_S * Y_beta * K_A * K_V * K_Fbeta <= [sigma_FP]\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: '• Y_F = 2.45: ', options: { bold: true, color: C.slateDark } },
    { text: 'Lewis Form Factor calculated from 30° tangent to root fillet.\n', options: { color: C.slateMuted } },
    { text: '• Y_S = 1.72: ', options: { bold: true, color: C.slateDark } },
    { text: 'Stress Concentration Factor at root trochoid radius.\n', options: { color: C.slateMuted } },
    { text: '• K_V = 1.15: ', options: { bold: true, color: C.slateDark } },
    { text: 'Dynamic factor accounting for pitch transmission error.\n\n', options: { color: C.slateMuted } },
    { text: '2. Hertzian Surface Contact Stress (Pitting Resistance):\n', options: { bold: true, color: C.slateDark } },
    { text: 'sigma_H = Z_H * Z_E * Z_eps * Z_beta * sqrt((F_t / (d1 * b)) * ((u+1)/u)) <= [sigma_HP]\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: '• Z_H = 2.495: Zone factor converting pitch geometry to equivalent cylinders.\n• Z_E = 189.8 MPa^0.5: Elasticity factor for mating Steel-on-Steel contact.\n• Z_eps = 0.88: Contact ratio factor accounting for load sharing.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.5, lineSpacingMultiple: 1.15
  });

  // Right Column: Material Library & Safety Factor Results
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('MATERIAL SELECTION & SAFETY FACTOR EVALUATION', {
    x: 7.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Consolas', fontSize: 9.5, bold: true, color: C.slateDark
  });

  const stressTable = [
    [
      { text: 'Stress & Safety Metric', options: { bold: true, color: C.maroon, fill: C.white } },
      { text: 'Calculated Value', options: { bold: true, fill: C.white } },
      { text: 'Allowable Limit', options: { bold: true, fill: C.white } },
      { text: 'Margin / Status', options: { bold: true, fill: C.white } }
    ],
    [
      { text: 'Bending Stress (Pinion)', options: { bold: true } },
      { text: '116.4 MPa', options: { fontFace: 'Consolas', bold: true } },
      { text: '250.0 MPa (4140 Q&T)', options: { fontFace: 'Consolas' } },
      { text: 'S_F = 2.15  [PASS]', options: { fontFace: 'Consolas', color: C.emerald, bold: true } }
    ],
    [
      { text: 'Bending Stress (Gear)', options: { bold: true } },
      { text: '88.2 MPa', options: { fontFace: 'Consolas', bold: true } },
      { text: '250.0 MPa (4140 Q&T)', options: { fontFace: 'Consolas' } },
      { text: 'S_F = 2.83  [PASS]', options: { fontFace: 'Consolas', color: C.emerald, bold: true } }
    ],
    [
      { text: 'Contact Pressure (Mesh)', options: { bold: true } },
      { text: '675.8 MPa', options: { fontFace: 'Consolas', bold: true } },
      { text: '1,000.0 MPa (Carb.)', options: { fontFace: 'Consolas' } },
      { text: 'S_H = 1.48  [PASS]', options: { fontFace: 'Consolas', color: C.emerald, bold: true } }
    ],
    [
      { text: 'Carrier Pin Shear Stress', options: { bold: true } },
      { text: '28.5 MPa', options: { fontFace: 'Consolas', bold: true } },
      { text: '120.0 MPa (Shear)', options: { fontFace: 'Consolas' } },
      { text: 'S_S = 4.21  [PASS]', options: { fontFace: 'Consolas', color: C.emerald, bold: true } }
    ]
  ];

  s.addTable(stressTable, {
    x: 7.05, y: 2.45, w: 5.25, h: 2.3,
    colW: [1.7, 1.15, 1.25, 1.15],
    fill: C.white,
    border: { pt: 0.8, color: C.borderSlate },
    fontFace: 'Segoe UI', fontSize: 8.5,
    align: 'left', valign: 'middle'
  });

  // Material Callout Box
  s.addShape(pres.ShapeType.rect, {
    x: 7.05, y: 4.9, w: 5.25, h: 1.55,
    fill: { color: C.white },
    line: { color: C.maroonBorder, width: 1 }
  });
  s.addText('SELECTED MATERIAL: 4140 ALLOY STEEL (32–36 HRC)', {
    x: 7.2, y: 5.02, w: 4.95, h: 0.25,
    fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.maroon
  });
  s.addText([
    { text: '• Core Toughness: ', options: { bold: true, color: C.slateDark } },
    { text: 'Quenched and tempered 4140 provides high impact toughness against wind gust dynamic shock.\n', options: { color: C.slateMuted } },
    { text: '• Case Hardening Option: ', options: { bold: true, color: C.slateDark } },
    { text: '8620 carburized steel (58–62 HRC) modeled for heavy offshore applications, raising surface limit to 1,500 MPa.', options: { color: C.slateMuted } }
  ], {
    x: 7.2, y: 5.3, w: 4.95, h: 1.05,
    fontFace: 'Segoe UI', fontSize: 8.5, lineSpacingMultiple: 1.15
  });

  s.addNotes(`Slide 8: ISO 6336 Tooth Root Bending & Hertzian Contact Durability
"Slide 8 demonstrates our mechanical stress validation adhering strictly to ISO 6336 Method B:
1. For tooth root bending, we calculate the Lewis form factor Y_F = 2.45 and stress concentration Y_S = 1.72, giving a nominal bending stress of 116.4 MPa against an allowable 250 MPa for 4140 steel—delivering a safety factor S_F = 2.15, well above the ISO 1.4 minimum.
2. For surface contact, we compute the Hertzian contact pressure using zone factor Z_H and elasticity factor Z_E = 189.8, resulting in 675.8 MPa against 1,000 MPa allowable, yielding S_H = 1.48 (exceeding the ISO 1.2 minimum).
This proves the pitch gearset will survive its 20-year design lifetime without pitting or fatigue fracture."`);
}

// ==============================================================================
// SLIDE 09: Manufacturing Tolerancing, Backlash & Physical 3D Prototyping
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 9, 'MANUFACTURING & TOLERANCES', 'Backlash Tolerancing, PrintComp Offsets & Prototype Validation', 'Thermal shrinkage compensation, operating backlash allocation, bearing press-fits, and slicer validation');

  // Left Column: Backlash Physics & PrintComp Algorithm
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('PRINTCOMP ALGORITHMIC COMPENSATION', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'Polymer Thermal Shrinkage Physics:\n', options: { bold: true, color: C.slateDark } },
    { text: 'In rapid prototyping (FDM printing in PETG / PLA-CF), cooling from 230°C to ambient causes 0.4%–0.7% radial thermal contraction, and molten bead convex bulging causes gears to bind tightly if printed from nominal CAD models.\n\n', options: { color: C.slateMuted } },
    { text: 'PrintComp Geometric Offsetting Equations:\n', options: { bold: true, color: C.slateDark } },
    { text: '• Tooth Normal Thinning:  s_offset = s_nom - Delta_shrink - Delta_backlash\n• Flank Thinning Offset:  Delta_s = 0.10 mm to 0.15 mm along profile normal\n• Bore Dilation Offset:   d_bore = d_shaft + 0.15 mm (608-2RS bearing fit)\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Manufacturing Backlash Allocation:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Normal backlash j_n = 0.08 mm to 0.12 mm is designed into the tooth flanks to accommodate thermal expansion across operating temperature ranges (-20°C to +45°C) and lubricant film thickness.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 4.0,
    fontFace: 'Segoe UI', fontSize: 9.8, lineSpacingMultiple: 1.15
  });

  // Right Column: Physical Prototype & Manufacturing Verification
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 2.5,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.cadToast)) {
    s.addImage({
      path: ASSETS.cadToast,
      x: 6.8, y: 1.84, w: 5.71, h: 2.15
    });
  }
  s.addText('Figure 9.1: Direct In-Memory STEP AP214 B-Rep CAD Export for CNC Machining Toolpaths', {
    x: 6.8, y: 4.05, w: 5.71, h: 0.22,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // 3 Manufacturing Metrics
  const mfgMetrics = [
    { num: '0.10 mm', label: 'Flank Thinning', desc: 'Calibrated backlash preventing mesh binding' },
    { num: '+0.15 mm', label: 'Bore Expansion', desc: 'Slip-fit seating for 608-2RS bearings' },
    { num: '0 Non-Manifold', label: 'Mesh Topology', desc: '100% watertight STL slicer verification' }
  ];

  mfgMetrics.forEach((m, i) => {
    const mx = 6.78 + i * 1.95;
    s.addShape(pres.ShapeType.rect, {
      x: mx, y: 4.4, w: 1.85, h: 2.22,
      fill: { color: C.cardAlt },
      line: { color: C.borderSlate, width: 1 }
    });
    s.addShape(pres.ShapeType.rect, {
      x: mx, y: 4.4, w: 1.85, h: 0.03,
      fill: { color: C.maroon },
      line: { color: C.maroon, width: 0 }
    });
    s.addText(m.num, {
      x: mx + 0.05, y: 4.6, w: 1.75, h: 0.35,
      fontFace: 'Consolas', fontSize: 13, bold: true, color: C.maroon,
      align: 'center'
    });
    s.addText(m.label, {
      x: mx + 0.05, y: 5.0, w: 1.75, h: 0.28,
      fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.slateDark,
      align: 'center'
    });
    s.addText(m.desc, {
      x: mx + 0.05, y: 5.35, w: 1.75, h: 1.1,
      fontFace: 'Segoe UI', fontSize: 8.5, color: C.slateMuted,
      align: 'center', lineSpacingMultiple: 1.1
    });
  });

  s.addNotes(`Slide 9: Backlash Tolerancing, PrintComp Offsets & Prototype Validation
"To bridge theory and manufacturing, Slide 9 explains our PrintComp compensation pipeline:
When 3D printing gears in polymers like PETG or PLA, cooling shrinkage of 0.5% and nozzle bead expansion cause teeth to bind tightly if printed to nominal CAD dimensions.
Our PrintComp algorithm applies two offsets:
1. Normal tooth thinning of 0.10 to 0.15 mm to guarantee running backlash (jn = 0.08–0.12 mm) across -20°C to +45°C wind turbine operating conditions.
2. Bore expansion of +0.15 mm so that 608 ball bearings slip-fit perfectly without lathe reaming.
Finally, Figure 9.1 shows our direct ISO 10303-21 STEP B-Rep export, which feeds directly into SolidWorks and CNC CAM software."`);
}

// ==============================================================================
// SLIDE 10: Conclusions, Mechanical Competencies Mastered & Acknowledgments
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 10, 'DEFENSE CONCLUSION', 'Conclusions, Mechanical Competencies Mastered & Acknowledgments', 'Synthesis of machine design theory, industrial gear standards, and academic appreciation');

  // Left Column: Key Mechanical Deliverables
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.15,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });
  s.addText('MECHANICAL ENGINEERING CONTRIBUTIONS', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: '• Formulated 7 Pitch Gear Architectures:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Derived exact analytical kinematics for Zerol bevels, straight bevels, spiral bevels, planetary drives, helical, and annular slewing rings.\n\n', options: { color: C.slateMuted } },
    { text: '• Gleason Zerol & Tredgold Kinematics:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Successfully eliminated gearbox axial thrust forces (Fa = 0) and mapped 3D conical spherical contact to 2D line-of-action conjugate diagnostics.\n\n', options: { color: C.slateMuted } },
    { text: '• ISO 6336 Mechanical Stress Verification:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Demonstrated bending safety SF = 2.15 and pitting resistance SH = 1.48, guaranteeing 20-year structural fatigue life.\n\n', options: { color: C.slateMuted } },
    { text: '• Physical Prototype Fabrication:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Validated PrintComp shrinkage compensation, producing functional, non-binding physical prototypes.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 3.3,
    fontFace: 'Segoe UI', fontSize: 9.5, lineSpacingMultiple: 1.15
  });

  // Right Column: Professional Competencies & Acknowledgments
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.15,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 0.04,
    fill: { color: C.gold },
    line: { color: C.gold, width: 0 }
  });
  s.addText('COMPETENCIES MASTERED & ACKNOWLEDGMENTS', {
    x: 7.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.slateDark
  });
  s.addText([
    { text: 'Core Machine Design Competencies Mastered:\n', options: { bold: true, color: C.maroon } },
    { text: '1. Advanced Involute & Bevel Gear Kinematics (Gleason, Willis, Tredgold).\n2. ISO 6336 & AGMA Stress Calculation (Lewis factor, Hertz contact pressure).\n3. Drivetrain Load Allocation & Dynamic Torque Reversals in Wind Turbines.\n4. Precision Backlash Tolerancing & Additive Manufacturing Compensation.\n5. SolidWorks B-Rep Parametric CAD Modeling & STEP AP214 Data Exchange.\n\n', options: { color: C.slateMuted } },
    { text: 'Academic & Professional Appreciation:\n', options: { bold: true, color: C.maroon } },
    { text: 'Sincere gratitude to my academic supervisors at Universiti Teknologi Malaysia (UTM) and industry mentors for their continuous technical guidance throughout this internship.', options: { color: C.slateMuted } }
  ], {
    x: 7.05, y: 2.45, w: 5.25, h: 3.3,
    fontFace: 'Segoe UI', fontSize: 9.2, lineSpacingMultiple: 1.15
  });

  // Dark Maroon Footer Banner with Candidate Info & Defense Opening
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 6.15, w: 11.733, h: 0.65,
    fill: { color: C.maroon },
    line: { color: C.gold, width: 1 }
  });
  s.addText('Candidate: Ahmed Majdy Ahmed  |  Universiti Teknologi Malaysia (UTM)  |  Faculty of Mechanical Engineering', {
    x: 1.0, y: 6.22, w: 7.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.white,
    valign: 'middle'
  });
  s.addText('Floor Open for Technical Discussion & Examination Q&A  ➔', {
    x: 8.5, y: 6.22, w: 3.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.gold,
    align: 'right', valign: 'middle'
  });

  s.addNotes(`Slide 10: Conclusions, Mechanical Competencies Mastered & Acknowledgments
"In conclusion, this internship provided deep, practical mastery of mechanical machine design and gear engineering:
We derived the mathematics of 7 gear architectures, proved Gleason Zerol axial thrust cancellation, modeled Willis planetary kinematics, and validated safety margins under ISO 6336.
Most importantly, we verified that the synthesized gears can be manufactured and assembled with zero binding.
I want to express my sincere appreciation to Universiti Teknologi Malaysia (UTM), my academic supervisors, and mentors for their guidance.
Thank you for your time. The floor is now open for technical questions and discussion."`);
}

// ==============================================================================
// EXPORT PPTX TO ROOT AND LOCAL DIRECTORY
// ==============================================================================
const rootOutPath = path.join(__dirname, '..', 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');
const localOutPath = path.join(__dirname, 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');

pres.writeFile({ fileName: rootOutPath })
  .then(() => {
    console.log(`Mechanical Engineering PPTX exported successfully to root: ${rootOutPath}`);
    fs.copyFileSync(rootOutPath, localOutPath);
    console.log(`Mechanical Engineering PPTX copy saved to: ${localOutPath}`);
  })
  .catch(err => {
    console.error('Error exporting PPTX:', err);
    process.exit(1);
  });
