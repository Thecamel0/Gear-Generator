/**
 * Generate UTM Mechanical Engineering Pitch Control Gear Presentation (.pptx)
 * 
 * Focus: Mechanical Engineering, Kinematics, Gear Geometry, ISO 6336 Stress & Manufacturing
 * Branding: Universiti Teknologi Malaysia (UTM) Modern Technical Deck
 * Author: Ahmed Majdy Ahmed
 * Target Audience: Academic Evaluators, Industry Mentors & Mechanical Engineering Leads
 * Total Slides: 11 (including Internship Timeline & Roadmap)
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
  cardAlt: 'F8FAFC',          // Light Slate-50 Container (Platinum)
  slateDark: '0F172A',        // Primary Engineering Typography (30%)
  slateMuted: '475569',       // Secondary Technical Text / Body
  slateDim: '64748B',         // Annotations, Captions & Metadata
  borderSlate: 'CBD5E1',      // Precise Technical Borders (1px)
  borderLight: 'E2E8F0',      // Light subtle component border
  maroon: '721422',           // UTM Primary Brand (10% Accent)
  maroonTint: 'F8EEF0',       // Light Maroon Pill Background
  maroonBorder: 'D89EA7',     // Pill & Box Border
  gold: 'D49B23',             // UTM Warm Gold Accent
  goldLight: 'FDF8EB',        // Light Gold Pill Background
  goldBorder: 'E6C77B',       // Gold Border
  emerald: '059669',          // Verified / Pass indicator
  navyCode: '0B192C'          // Formula Block Background
};

const ASSETS = {
  planetaryAssembly: path.join(__dirname, 'assets', 'planetary_assembly.png'),
  planetaryMesh2d: path.join(__dirname, 'assets', 'planetary_mesh2d.png'),
  planetaryOverview: path.join(__dirname, 'assets', 'planetary_overview.png'),
  planetarySun: path.join(__dirname, 'assets', 'planetary_sun_isolated.png'),
  planetaryPlanet: path.join(__dirname, 'assets', 'planetary_planet_isolated.png'),
  zerolMesh2d: path.join(__dirname, 'assets', 'zerol_mesh2d.png'),
  zerolBevel: path.join(__dirname, 'assets', 'zerol_bevel_3d.png'),
  straightBevelAssembly: path.join(__dirname, 'assets', 'straight_bevel_assembly.png'),
  straightMesh2d: path.join(__dirname, 'assets', 'straight_bevel_mesh2d.png'),
  helicalAssembly: path.join(__dirname, 'assets', 'helical_assembly.png'),
  spurAssembly: path.join(__dirname, 'assets', 'spur_assembly.png'),
  spiralBevelAssembly: path.join(__dirname, 'assets', 'spiral_bevel_assembly.png'),
  cadToast: path.join(__dirname, 'assets', 'cad_export_toast.png')
};

// Helper: Standard UTM Mechanical Engineering Slide Header & Footer
function setupMechanicalSlide(slide, slideNum, sectionTag, title, subtitle) {
  slide.background = { color: C.white };

  // Section Tag Pill (UTM Maroon Border & Text)
  slide.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 0.42, w: 3.6, h: 0.26, rectRadius: 0.05,
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
    line: { color: C.borderLight, width: 0.8 }
  });

  slide.addText('Universiti Teknologi Malaysia (UTM)  |  Faculty of Mechanical Engineering', {
    x: 0.8, y: 6.96, w: 5.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9, color: C.slateDim,
    valign: 'middle'
  });

  slide.addText('Ahmed Majdy Ahmed  —  Wind Turbine Blade Pitch Control Drivetrain', {
    x: 5.5, y: 6.96, w: 5.0, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9, color: C.slateDim,
    align: 'center', valign: 'middle'
  });

  slide.addText(`Slide ${String(slideNum).padStart(2, '0')} / 11`, {
    x: 10.7, y: 6.96, w: 1.833, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, color: C.maroon, bold: true,
    align: 'right', valign: 'middle'
  });
}

// ==============================================================================
// SLIDE 01: Title & Project Identification (Full Maroon Cover)
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
  s.addShape(pres.ShapeType.roundRect, {
    x: 1.2, y: 0.85, w: 5.2, h: 0.32, rectRadius: 0.04,
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
  s.addText('Multi-Architecture Gear Kinematics, Gleason Theory & Manufacturing', {
    x: 1.2, y: 2.1, w: 10.8, h: 0.55,
    fontFace: 'Segoe UI', fontSize: 24, bold: true, color: C.gold
  });

  // Subtitle
  s.addText('Final Internship Technical Defense  —  Mechanical Drive Systems & Precision Gearing', {
    x: 1.2, y: 2.78, w: 10.8, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, color: 'E2E8F0'
  });

  // Divider Line
  s.addShape(pres.ShapeType.line, {
    x: 1.2, y: 3.25, w: 11.3, h: 0,
    line: { color: '8B1E2E', width: 1 }
  });

  // Candidate & Academic Info Box
  s.addShape(pres.ShapeType.roundRect, {
    x: 1.2, y: 3.55, w: 5.8, h: 3.0, rectRadius: 0.08,
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
    { text: 'Host Organization: ', options: { bold: true, color: C.white } },
    { text: '[Host Company / Research Group]  |  Mentors: [Supervisor / Mentors]\n', options: { color: 'F1F5F9' } },
    { text: 'Key Standards: ', options: { bold: true, color: C.white } },
    { text: 'Gleason Bevel Standards, Willis Epicyclic Theory, Tredgold Approximation\n', options: { color: 'F1F5F9' } },
    { text: 'Core Deliverables: ', options: { bold: true, color: C.white } },
    { text: 'MATLAB Kinematic Suites, SolidWorks B-Rep CAD Models, Web Design Suite', options: { color: 'F1F5F9' } }
  ], {
    x: 1.4, y: 4.05, w: 5.4, h: 2.35,
    fontFace: 'Segoe UI', fontSize: 9.5, lineSpacingMultiple: 1.15
  });

  // Right Side Preview Container: Real Planetary 3D Gear Assembly
  s.addShape(pres.ShapeType.roundRect, {
    x: 7.3, y: 3.55, w: 5.2, h: 3.0, rectRadius: 0.08,
    fill: { color: '000000' },
    line: { color: C.gold, width: 1.2 }
  });
  if (fs.existsSync(ASSETS.planetaryAssembly)) {
    s.addImage({
      path: ASSETS.planetaryAssembly,
      x: 7.32, y: 3.57, w: 5.16, h: 2.65,
      sizing: { type: 'contain', w: 5.16, h: 2.65 }
    });
  }
  s.addText('Figure 1.1: Epicyclic Pitch Reducer Assembly (Coaxial 5:1 Planetary Mechanism)', {
    x: 7.32, y: 6.27, w: 5.16, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 1: Title & Project Identification
"Good morning, respected academic supervisors and mentors.
My name is Ahmed Majdy Ahmed from the Faculty of Mechanical Engineering at Universiti Teknologi Malaysia.
Today, I present the engineering accomplishments of my internship: the design, kinematic modeling, and manufacturing preparation of a precision pitch control drivetrain for wind turbine blades.
Throughout this presentation, I focus on core mechanical engineering principles: conjugate tooth kinematics, Gleason cutter geometry, Willis planetary velocity ratios, bending safety factors, and manufacturing backlash tolerancing."`);
}

// ==============================================================================
// SLIDE 02: Executive Summary & Internship Scope (3-Column Cards)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 2, 'EXECUTIVE SUMMARY', 'Executive Summary: Engineering Scope & Core Contributions', 'High-level synthesis of machine design objectives, technical deliverables, and measurable outcomes');

  const execCards = [
    {
      title: 'Core Engineering Mission',
      badge: 'MISSION & OBJECTIVES',
      bullets: [
        'Formulated precision gear kinematics for synchronous 3-blade pitch adjustment under aerodynamic moments.',
        'Eliminated axial thrust on blade root bearings by implementing Gleason Zerol bevel tooth curves (beta_m = 0°).',
        'Prevented pinion undercutting on 16T pinions by applying a Gleason 60/40 unequal addendum system.'
      ]
    },
    {
      title: 'Delivered Technical Artifacts',
      badge: 'DELIVERED ARTIFACTS',
      bullets: [
        'Developed parametric kinematic solvers in MATLAB for 7 distinct industrial gear architectures.',
        'Generated automated SolidWorks CAD models with verified B-Rep solids and direct STEP AP214 export.',
        'Engineered an interactive engineering software tool for instant gear configuration and SolidWorks export.'
      ]
    },
    {
      title: 'Engineering & Physical Impact',
      badge: 'MEASURABLE OUTCOMES',
      bullets: [
        'Achieved contact ratio CR = 1.642, exceeding the 1.20 minimum threshold for continuous quiet conjugate action.',
        'Verified bending safety factor SF = 46.4 under rated torque, ensuring robust fatigue durability.',
        'Resolved 68% tooth depth distortion via True Cone Projection, producing 100% watertight printable meshes.'
      ]
    }
  ];

  execCards.forEach((c, i) => {
    const cx = 0.8 + i * 4.0;
    
    // White Card Container
    s.addShape(pres.ShapeType.roundRect, {
      x: cx, y: 1.82, w: 3.75, h: 4.8, rectRadius: 0.08,
      fill: { color: C.cardBg },
      line: { color: C.borderLight, width: 1 }
    });

    // 2px Top Accent Stripe
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.82, w: 3.75, h: 0.04,
      fill: { color: i === 0 ? C.maroon : (i === 1 ? C.gold : C.slateDark) },
      line: { color: C.white, width: 0 }
    });

    s.addText(c.title, {
      x: cx + 0.25, y: 2.05, w: 3.25, h: 0.4,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.slateDark
    });

    // Badge Pill
    s.addShape(pres.ShapeType.roundRect, {
      x: cx + 0.25, y: 2.5, w: 2.0, h: 0.24, rectRadius: 0.04,
      fill: { color: C.cardAlt },
      line: { color: C.borderLight, width: 0.8 }
    });
    s.addText(c.badge, {
      x: cx + 0.25, y: 2.5, w: 2.0, h: 0.24,
      fontFace: 'Consolas', fontSize: 7.5, bold: true, color: C.maroon,
      align: 'center', valign: 'middle'
    });

    // Bullets (Google X-Y-Z formula)
    const bulletContent = c.bullets.map(b => ({
      text: `• ${b}\n\n`,
      options: { fontFace: 'Segoe UI', fontSize: 10, color: C.slateMuted }
    }));

    s.addText(bulletContent, {
      x: cx + 0.25, y: 2.95, w: 3.25, h: 3.5,
      lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 2: Executive Summary: Scope & Key Contributions
"Slide 2 outlines the scope of my internship work:
1. Core Mission: We set out to design a robust mechanical pitch drive that synchronizes all three blades while eliminating bearing-damaging axial thrust.
2. Delivered Artifacts: I developed complete parametric kinematic solvers in MATLAB for 7 gear architectures, automated SolidWorks CAD macros, and an interactive engineering design suite.
3. Measurable Impact: The design achieves a contact ratio of 1.642, a high bending safety margin, and successfully fixed a critical 68% tooth depth distortion on conical meshes to deliver 100% watertight models ready for physical manufacturing."`);
}

// ==============================================================================
// SLIDE 03: Internship Engineering Progression (Chronological Timeline)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 3, 'INTERNSHIP ROADMAP & MILESTONES', 'Internship Engineering Progression: Hands-On Tooling to Software Deployment', 'Chronological journey across rapid prototyping, enclosure CAD, drivetrain research, kinematic algorithms, and universal software');

  // Connecting Horizontal Timeline Track
  s.addShape(pres.ShapeType.line, {
    x: 0.8, y: 2.1, w: 11.733, h: 0,
    line: { color: C.borderLight, width: 2 }
  });

  const timelineSteps = [
    {
      num: '01',
      title: '3D Printer Tooling',
      phase: 'RAPID TOOLING',
      xyz: 'Mastered 3D printer calibration and FDM slicing parameters, achieving sub-0.2mm tolerance across PLA and PETG materials.',
      pill: 'FDM Slicing / Calibration'
    },
    {
      num: '02',
      title: 'Aero-Leaf Enclosure',
      phase: 'MECHANICAL CAD',
      xyz: 'Designed custom motor casing for Aero-Leaf wind turbine, ensuring weather sealing and thermal venting in SolidWorks.',
      pill: 'SolidWorks Part & Enclosure'
    },
    {
      num: '03',
      title: 'Gearbox Research',
      phase: 'DRIVETRAIN RESEARCH',
      xyz: 'Investigated wind turbine pitch failure modes, identifying root causes of backlash binding and excessive axial thrust.',
      pill: 'Gleason / AGMA Standards'
    },
    {
      num: '04',
      title: 'Zerol Bevel Solver',
      phase: 'MATLAB FORMULATION',
      xyz: 'Formulated mathematical kinematic model in MATLAB for Zerol bevels, eliminating axial thrust (Fa = 0) with curved teeth.',
      pill: 'Curved Gleason Kinematics'
    },
    {
      num: '05',
      title: 'Multi-Gear Engine',
      phase: '7 GEAR ARCHITECTURES',
      xyz: 'Expanded solvers to 7 gear types with 2D contact roll, 3D simulations, and automated SolidWorks B-Rep export.',
      pill: '2D/3D Kinematics & SolidWorks'
    },
    {
      num: '06',
      title: 'Universal CAD Suite',
      phase: 'FINAL SOFTWARE',
      xyz: 'Deployed interactive engineering software allowing any engineer to configure custom gears and export directly to SolidWorks.',
      pill: 'Deployable Design Tool'
    }
  ];

  timelineSteps.forEach((step, i) => {
    const cx = 0.8 + i * 1.98;
    const cardW = 1.82;

    // Node Circle on Track Line
    s.addShape(pres.ShapeType.ellipse, {
      x: cx + cardW / 2 - 0.18, y: 1.92, w: 0.36, h: 0.36,
      fill: { color: i === 5 ? C.gold : C.maroon },
      line: { color: C.white, width: 2 }
    });
    s.addText(step.num, {
      x: cx + cardW / 2 - 0.18, y: 1.92, w: 0.36, h: 0.36,
      fontFace: 'Consolas', fontSize: 9, bold: true, color: C.white,
      align: 'center', valign: 'middle'
    });

    // Timeline Card Container
    s.addShape(pres.ShapeType.roundRect, {
      x: cx, y: 2.45, w: cardW, h: 4.25, rectRadius: 0.08,
      fill: { color: C.cardBg },
      line: { color: C.borderLight, width: 1 }
    });

    // Top Accent Stripe
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 2.45, w: cardW, h: 0.03,
      fill: { color: i === 5 ? C.gold : C.maroon },
      line: { color: C.white, width: 0 }
    });

    // Phase Pill
    s.addShape(pres.ShapeType.roundRect, {
      x: cx + 0.1, y: 2.6, w: cardW - 0.2, h: 0.22, rectRadius: 0.04,
      fill: { color: C.maroonTint },
      line: { color: C.maroonBorder, width: 0.6 }
    });
    s.addText(step.phase, {
      x: cx + 0.1, y: 2.6, w: cardW - 0.2, h: 0.22,
      fontFace: 'Consolas', fontSize: 6.8, bold: true, color: C.maroon,
      align: 'center', valign: 'middle'
    });

    // Milestone Title
    s.addText(step.title, {
      x: cx + 0.1, y: 2.9, w: cardW - 0.2, h: 0.45,
      fontFace: 'Segoe UI', fontSize: 10.5, bold: true, color: C.slateDark,
      align: 'center'
    });

    // X-Y-Z Description
    s.addText(step.xyz, {
      x: cx + 0.1, y: 3.4, w: cardW - 0.2, h: 2.5,
      fontFace: 'Segoe UI', fontSize: 8.8, color: C.slateMuted,
      lineSpacingMultiple: 1.15
    });

    // Bottom Tech Badge Pill
    s.addShape(pres.ShapeType.roundRect, {
      x: cx + 0.08, y: 6.2, w: cardW - 0.16, h: 0.35, rectRadius: 0.04,
      fill: { color: C.cardAlt },
      line: { color: C.borderSlate, width: 0.8 }
    });
    s.addText(step.pill, {
      x: cx + 0.08, y: 6.2, w: cardW - 0.16, h: 0.35,
      fontFace: 'Consolas', fontSize: 7, color: C.slateDark, bold: true,
      align: 'center', valign: 'middle'
    });
  });

  s.addNotes(`Slide 3: Internship Engineering Progression
"This timeline captures the technical journey of my internship across six structured milestones:
1. I began in the mechanical prototyping lab, mastering 3D printer calibration, slicer settings, and polymer shrinkage control.
2. I applied CAD modeling to design the motor casing and weather-sealed housing for the Aero-Leaf micro-wind turbine project.
3. Next, I researched drivetrain failure modes to solve pitch gearbox backlash and axial wear issues in fluctuating wind conditions.
4. I then developed the mathematical kinematics in MATLAB for a Gleason Zerol bevel gear pair, successfully eliminating axial thrust forces.
5. Seeing the power of this analytical approach, I expanded the algorithms to 7 distinct gear types with 2D contact simulations and SolidWorks B-Rep generation.
6. Finally, I synthesized these engineering capabilities into a universal software tool, allowing any engineer to generate custom CAD models and export them directly to SolidWorks in seconds."`);
}

// ==============================================================================
// SLIDE 04: Problem Statement & Engineering Objectives (Split 50/50 Comparison)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 4, 'PROBLEM STATEMENT', 'The Problem: Bridging the Gap in Wind Turbine Pitch Drivetrains', 'Operational pitch control challenges, legacy drafting limitations, and the target kinematic solution');

  // Left Column: Legacy Limitations / Challenges (Slate Gray Container)
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 0.04,
    fill: { color: '475569' },
    line: { color: C.white, width: 0 }
  });
  s.addText('CURRENT STATE & OPERATIONAL CHALLENGES', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12.5, bold: true, color: C.slateDark
  });

  const legacyPoints = [
    {
      label: 'Manual CAD Drafting Bottlenecks',
      desc: 'Standard CAD tools lack native Gleason bevel curves. Engineers manually approximate tooth forms with 2D lofting, causing flank profile errors up to 0.4 mm.'
    },
    {
      label: 'Pinion Undercutting Risk (z < 17)',
      desc: 'Pitch pinions with 16 teeth suffer severe root undercutting under standard 20° involute proportions, dramatically reducing tooth bending fatigue strength.'
    },
    {
      label: 'Axial Thrust on Blade Bearings',
      desc: 'Spiral bevel gears generate substantial axial forces, requiring heavy duplex thrust bearings inside compact blade root enclosures and increasing nacelle mass.'
    },
    {
      label: '3D Print Binding & Thermal Contraction',
      desc: 'Direct CAD exports fail during physical manufacturing: polymer cooling shrinkage (0.3%–0.6%) causes tooth flank interference and tight bore binding.'
    }
  ];

  let ly = 2.45;
  legacyPoints.forEach(p => {
    s.addText(`• ${p.label}:`, {
      x: 1.05, y: ly, w: 5.25, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: '8B1E2E'
    });
    s.addText(p.desc, {
      x: 1.25, y: ly + 0.22, w: 5.05, h: 0.55,
      fontFace: 'Segoe UI', fontSize: 9.2, color: C.slateMuted, lineSpacingMultiple: 1.15
    });
    ly += 0.85;
  });

  // Right Column: Target Solution (Crisp White Container with Maroon Accent)
  s.addShape(pres.ShapeType.roundRect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.maroonBorder, width: 1.2 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.82, w: 5.75, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.white, width: 0 }
  });
  s.addText('TARGET SOLUTION: INTEGRATED GEAR ARCHITECTURE', {
    x: 7.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12.5, bold: true, color: C.maroon
  });

  const targetPoints = [
    {
      label: 'Parametric Gleason Zerol Generation',
      desc: 'Synthesized exact curved flank coordinates (beta_m = 0°) directly from Gleason face-cutter kinematics, eliminating manual drafting inaccuracies.'
    },
    {
      label: 'Gleason 60/40 Addendum System',
      desc: 'Shifted addendum proportions (pinion 3.60 mm / gear 2.40 mm) to completely eliminate pinion root undercutting and equalize specific sliding.'
    },
    {
      label: 'Zero Net Axial Bearing Thrust',
      desc: 'Zerol curved geometry eliminates thrust forces (Fa = 0), reducing bearing size, reducing hub weight, and extending blade root operating lifespan.'
    },
    {
      label: 'Automated PrintComp Tolerancing',
      desc: 'Embedded calibrated shrinkage offsets (+0.3%) and flank thinning (0.15 mm backlash) for guaranteed smooth, non-binding physical 3D assembly.'
    }
  ];

  let ry = 2.45;
  targetPoints.forEach(p => {
    s.addText(`✔ ${p.label}:`, {
      x: 7.05, y: ry, w: 5.25, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.emerald
    });
    s.addText(p.desc, {
      x: 7.25, y: ry + 0.22, w: 5.05, h: 0.55,
      fontFace: 'Segoe UI', fontSize: 9.2, color: C.slateMuted, lineSpacingMultiple: 1.15
    });
    ry += 0.85;
  });

  s.addNotes(`Slide 4: Problem Statement & Engineering Objectives
"Slide 4 highlights the core engineering challenge:
In wind turbine blade pitch mechanisms, conventional gear design poses four major issues:
First, standard CAD software cannot accurately model Gleason spiral or Zerol bevel curves, forcing designers to use coarse approximations.
Second, a 16-tooth pinion experiences root undercutting under standard proportions, threatening tooth shear.
Third, standard spiral bevel gears produce heavy axial thrust that loads blade root bearings.
Finally, uncompensated CAD models bind tightly when 3D printed due to polymer cooling shrinkage.
Our solution addresses each point: exact Gleason equations, a 60/40 addendum shift, zero axial thrust geometry, and automated PrintComp tolerancing."`);
}

// ==============================================================================
// SLIDE 05: Pitch Drivetrain Topology & Kinematic Architecture
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 5, 'DRIVETRAIN TOPOLOGY', 'System Architecture: Central Ring to 3-Blade Pitch Pinions', 'End-to-end mechanical transmission topology, 120° spatial load sharing, and categorized technology stack');

  // Top Half: Block Flow Diagram Container
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 11.733, h: 2.5, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
  });
  s.addText('MECHANICAL POWER FLOW & 3-BLADE LOAD-SHARING TOPOLOGY', {
    x: 1.05, y: 1.98, w: 11.2, h: 0.25,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.maroon
  });

  // 4 Horizontal Block Stages
  const blocks = [
    { title: 'Actuation Motor', sub: 'Input Prime Mover', desc: '100 RPM\nT_in = 20.0 N·m\nP = 209.4 W' },
    { title: 'Central Ring Gear', sub: 'Master Driver (Ng = 48)', desc: '100 RPM, m = 3.0 mm\nd_g = 144.0 mm\nTorque = 20.0 N·m' },
    { title: '3x Zerol Pinions', sub: '120° Spatial Mesh (Np = 16)', desc: '300 RPM (Ratio 1:3)\nT_mesh = 6.67 N·m\nT_pinion = 2.16 N·m' },
    { title: 'Blade Pitch Shafts', sub: 'Synchronous Blade Roots', desc: 'Blade 1 (0°)\nBlade 2 (120°)\nBlade 3 (240°)' }
  ];

  blocks.forEach((b, i) => {
    const bx = 1.05 + i * 2.85;
    s.addShape(pres.ShapeType.roundRect, {
      x: bx, y: 2.3, w: 2.45, h: 1.8, rectRadius: 0.06,
      fill: { color: C.cardAlt },
      line: { color: C.maroon, width: 1.2 }
    });
    s.addText(b.title, {
      x: bx, y: 2.4, w: 2.45, h: 0.28,
      fontFace: 'Segoe UI', fontSize: 11, bold: true, color: C.slateDark,
      align: 'center'
    });
    s.addText(b.sub, {
      x: bx, y: 2.68, w: 2.45, h: 0.22,
      fontFace: 'Consolas', fontSize: 8, bold: true, color: C.maroon,
      align: 'center'
    });
    s.addText(b.desc, {
      x: bx, y: 2.95, w: 2.45, h: 1.05,
      fontFace: 'Segoe UI', fontSize: 9, color: C.slateMuted,
      align: 'center', lineSpacingMultiple: 1.15
    });

    // Connecting Arrow (except last)
    if (i < 3) {
      s.addShape(pres.ShapeType.line, {
        x: bx + 2.45, y: 3.2, w: 0.4, h: 0,
        line: { color: C.maroon, width: 2, endArrowType: 'triangle' }
      });
    }
  });

  // Bottom Half: Categorized Tech Stack Pills
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 4.45, w: 11.733, h: 2.2, rectRadius: 0.08,
    fill: { color: C.cardAlt },
    line: { color: C.borderLight, width: 1 }
  });
  s.addText('ENGINEERING TOOLCHAIN, STANDARDS & FABRICATION PIPELINE', {
    x: 1.05, y: 4.6, w: 11.2, h: 0.25,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.slateDark
  });

  const categories = [
    { cat: 'Kinematic Theory', pills: ['Gleason Bevel Standards', 'Willis Epicyclic Theory', 'Tredgold Back-Cone Approximation'] },
    { cat: 'Computation & CAD', pills: ['MATLAB Mathematical Engine', 'SolidWorks VBA API', 'STEP AP214 / IGES 5.3 Export'] },
    { cat: 'Analysis & Standards', pills: ['Lewis Tooth Bending Stress', 'AGMA 6123-B06 Load Sharing', 'Watertight Euler Verification (V-E+F=2)'] },
    { cat: 'Prototyping & Mfg', pills: ['PrintComp Thermal Offsetting', '0.15 mm Backlash Allocation', 'Direct FDM 3D Prototyping'] }
  ];

  categories.forEach((c, idx) => {
    const colX = 1.05 + idx * 2.85;
    s.addText(c.cat, {
      x: colX, y: 4.95, w: 2.65, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.maroon
    });

    c.pills.forEach((p, pIdx) => {
      const py = 5.25 + pIdx * 0.42;
      s.addShape(pres.ShapeType.roundRect, {
        x: colX, y: py, w: 2.65, h: 0.32, rectRadius: 0.04,
        fill: { color: C.white },
        line: { color: C.borderSlate, width: 0.8 }
      });
      s.addText(p, {
        x: colX, y: py, w: 2.65, h: 0.32,
        fontFace: 'Segoe UI', fontSize: 8.5, color: C.slateDark,
        align: 'center', valign: 'middle'
      });
    });
  });

  s.addNotes(`Slide 5: System Architecture & Technology Stack
"Slide 5 illustrates the physical drivetrain topology and engineering toolchain:
Looking at the power flow at the top:
A central ring gear (48 teeth, 144 mm pitch diameter) driven by the actuation motor meshes simultaneously with three 16-tooth driven pinions placed at 120-degree intervals.
Each pinion connects directly to one wind turbine blade pitch shaft.
This load-sharing architecture divides total motor torque into three equal parallel branches (6.67 N·m per mesh interface), drastically cutting tooth bending stress while ensuring all 3 blades pitch in perfect angular synchronization.
At the bottom, our toolchain pairs rigorous Gleason and Willis theory with MATLAB numerical algorithms, SolidWorks CAD macros, and PrintComp additive manufacturing compensation."`);
}

// ==============================================================================
// SLIDE 06: Core Mechanism 1: Gleason Zerol Bevel Kinematics (60/40 Split)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 6, 'CORE MECHANISM 1', 'Zerol Bevel Mechanics: Axial Thrust Elimination & High Contact Ratio', 'Gleason face-milling kinematics, zero mean spiral angle, contact ratio CR = 1.642, and localized contact patch');

  // Left Side (55%): High-Resolution MATLAB 2D Mesh Diagram
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 6.5, h: 4.8, rectRadius: 0.08,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.zerolMesh2d)) {
    s.addImage({
      path: ASSETS.zerolMesh2d,
      x: 0.82, y: 1.84, w: 6.46, h: 4.4,
      sizing: { type: 'contain', w: 6.46, h: 4.4 }
    });
  }
  s.addText('Figure 6.1: MATLAB 2D Conjugate Meshing: Pitch Circles, Base Circles & Contact Line (CR = 1.642)', {
    x: 0.82, y: 6.3, w: 6.46, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Right Side (45%): 3 Structured Points (Design, Implementation, Validation)
  s.addShape(pres.ShapeType.roundRect, {
    x: 7.5, y: 1.82, w: 5.033, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 7.5, y: 1.82, w: 5.033, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.white, width: 0 }
  });
  s.addText('MECHANICAL DEEP DIVE: ZEROL BEVEL PAIR', {
    x: 7.75, y: 2.05, w: 4.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });

  const deepPoints = [
    {
      tag: 'DESIGN',
      title: 'Curved Flank Kinematics (beta_m = 0°)',
      desc: 'Teeth are curved along circular arcs generated by a Gleason face cutter of radius rc = 65.3 mm (~ Am). Setting spiral angle to zero at midface cancels axial thrust forces while providing localized elliptical contact.'
    },
    {
      tag: 'IMPLEMENTATION',
      title: 'Resolved 3-Axis Force Decomposition',
      desc: 'At mean cone distance Am = 65.27 mm under 6.67 N·m mesh torque: Tangential force Ft = 107.7 N, separating radial force Fr = 37.2 N, and axial thrust Fa = 12.4 N. Zero spiral component eliminates excessive thrust bearing preload.'
    },
    {
      tag: 'VALIDATION',
      title: 'Conjugate Roll & Contact Ratio CR = 1.642',
      desc: 'Simulated 2D line of action tracking via Tredgold virtual spur transformation (Nv_p = 16.88, Nv_g = 151.79). Contact ratio of 1.642 comfortably exceeds the 1.20 threshold, ensuring quiet and uninterrupted meshing.'
    }
  ];

  let dy = 2.45;
  deepPoints.forEach(p => {
    s.addShape(pres.ShapeType.roundRect, {
      x: 7.75, y: dy, w: 1.3, h: 0.22, rectRadius: 0.04,
      fill: { color: C.maroonTint },
      line: { color: C.maroonBorder, width: 0.6 }
    });
    s.addText(p.tag, {
      x: 7.75, y: dy, w: 1.3, h: 0.22,
      fontFace: 'Consolas', fontSize: 7.5, bold: true, color: C.maroon,
      align: 'center', valign: 'middle'
    });
    s.addText(p.title, {
      x: 9.15, y: dy - 0.02, w: 3.2, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.slateDark
    });
    s.addText(p.desc, {
      x: 7.75, y: dy + 0.25, w: 4.5, h: 0.85,
      fontFace: 'Segoe UI', fontSize: 8.8, color: C.slateMuted, lineSpacingMultiple: 1.15
    });
    dy += 1.25;
  });

  s.addNotes(`Slide 6: Core Mechanism 1: Gleason Zerol Bevel Kinematics
"Slide 6 presents our deep dive into the primary pitch transmission: the Gleason Zerol Bevel Gear.
Look at the high-resolution MATLAB visualization on the left:
Figure 6.1 shows the full 2D conjugate meshing zone. The line of action is drawn tangent to the base circles, giving a calculated contact ratio of 1.642, well above the 1.20 required for continuous tooth engagement.
On the right, we highlight three critical engineering achievements:
1. Design: The circular tooth curve produced by a 65.3 mm Gleason cutter localizes contact at the center, accommodating hub deflections.
2. Implementation: At 6.67 N·m torque per mesh, tangential force is 107.7 N, while the zero midface spiral angle eliminates bearing-destroying axial thrust.
3. Validation: Tredgold virtual teeth (16.88 and 151.79) prove flawless conjugate action with zero tip interference."`);
}

// ==============================================================================
// SLIDE 07: Gleason Unequal Addendum System & Tooth Geometry
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 7, 'GEAR TOOTH GEOMETRY', 'Gleason Unequal Addendum System: Eliminating Pinion Undercutting', '60/40 working depth allocation, tooth thickness modification (0.180·m shift), and balanced specific sliding');

  // Left Column: Kinematic Principle & Formulation
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
  });
  s.addText('THE KINEMATIC PROBLEM: PINION UNDERCUTTING (z = 16 < 17)', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 11.5, bold: true, color: C.maroon
  });
  s.addText([
    { text: 'Root Weakening Mechanism:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Standard 20° full-depth involute cutters dig into the tooth root when tooth count is below 17. For our 16-tooth pitch pinion, standard proportions would severely undercut the trochoid fillet, reducing bending strength by over 30%.\n\n', options: { color: C.slateMuted } },
    { text: 'Gleason 60/40 Addendum Modification Solution:\n', options: { bold: true, color: C.slateDark } },
    { text: 'We allocate 60% of working depth (hw = 6.000 mm) to the pinion and 40% to the gear:\n', options: { color: C.slateMuted } },
    { text: '• Pinion Addendum:   a_p = 0.60 · hw = 3.600 mm  (Dedendum b_p = 2.964 mm)\n• Gear Addendum:     a_g = 0.40 · hw = 2.400 mm  (Dedendum b_g = 4.164 mm)\n• Clearance:         c   = 0.188 · m = 0.564 mm  (Whole depth ht = 6.564 mm)\n\n', options: { fontFace: 'Consolas', color: C.maroon, bold: true } },
    { text: 'Tooth Thickness Modification (0.180 · m Shift):\n', options: { bold: true, color: C.slateDark } },
    { text: '• Pinion Circular Thickness: s_p = 5.252 mm (thickened at root)\n• Gear Circular Thickness:   s_g = 4.172 mm (nominal = 4.712 mm)\n\n', options: { fontFace: 'Consolas', color: C.slateDark } },
    { text: 'Result: Complete elimination of undercutting and equalization of maximum specific sliding velocities between approach and recess.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.42, w: 5.25, h: 4.05,
    fontFace: 'Segoe UI', fontSize: 9.3, lineSpacingMultiple: 1.15
  });

  // Right Column: Derived Gear Parameters Table
  s.addShape(pres.ShapeType.roundRect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardAlt },
    line: { color: C.borderLight, width: 1 }
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
      { text: 'm · N', options: { fontFace: 'Consolas' } },
      { text: '48.00 mm', options: { fontFace: 'Consolas', bold: true } },
      { text: '144.00 mm', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Pitch Cone Angle (gamma)', options: { bold: true } },
      { text: 'atan(Np / Ng)', options: { fontFace: 'Consolas' } },
      { text: '18.435°', options: { fontFace: 'Consolas', bold: true } },
      { text: '71.565°', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Outer Cone Distance (Ao)', options: { bold: true } },
      { text: 'd / (2·sin(gamma))', options: { fontFace: 'Consolas' } },
      { text: '75.895 mm', options: { fontFace: 'Consolas' } },
      { text: '75.895 mm', options: { fontFace: 'Consolas' } }
    ],
    [
      { text: 'Face Width (F)', options: { bold: true } },
      { text: '0.28 · Ao', options: { fontFace: 'Consolas' } },
      { text: '21.25 mm', options: { fontFace: 'Consolas', bold: true } },
      { text: '21.25 mm', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Mean Cone Distance (Am)', options: { bold: true } },
      { text: 'Ao - F / 2', options: { fontFace: 'Consolas' } },
      { text: '65.27 mm', options: { fontFace: 'Consolas' } },
      { text: '65.27 mm', options: { fontFace: 'Consolas' } }
    ],
    [
      { text: 'Tredgold Virtual Teeth (Nv)', options: { bold: true } },
      { text: 'N / cos(gamma)', options: { fontFace: 'Consolas' } },
      { text: '16.88', options: { fontFace: 'Consolas', bold: true } },
      { text: '151.79', options: { fontFace: 'Consolas', bold: true } }
    ],
    [
      { text: 'Mounting Distance (M)', options: { bold: true } },
      { text: 'Ao · cos(gamma)', options: { fontFace: 'Consolas' } },
      { text: '70.86 mm', options: { fontFace: 'Consolas' } },
      { text: '21.72 mm', options: { fontFace: 'Consolas' } }
    ]
  ];

  s.addTable(geomTable, {
    x: 7.05, y: 2.45, w: 5.25, h: 3.9,
    colW: [1.65, 1.4, 1.1, 1.1],
    fill: C.white,
    border: { pt: 0.8, color: C.borderLight },
    fontFace: 'Segoe UI', fontSize: 8.5,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 7: Gleason Unequal Addendum System & Tooth Geometry
"In standard gear design, a 16-tooth pinion would suffer severe undercutting because 16 is below the critical threshold of 17 teeth.
To solve this, we applied the Gleason Unequal Addendum system:
The pinion receives 60% of the 6.0 mm working depth (3.60 mm addendum), while the gear gets 40% (2.40 mm addendum).
Furthermore, we applied a tooth thickness shift of 0.180*m, giving the pinion a thicker root thickness of 5.252 mm compared to the gear's 4.172 mm.
This shifts the active contact line away from the pinion root, completely eliminates undercutting, balances approach and recess sliding velocities, and bolsters tooth bending resistance without changing center distance."`);
}

// ==============================================================================
// SLIDE 08: Core Mechanism 2: Epicyclic Planetary Reducer (60/40 Split)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 8, 'CORE MECHANISM 2', 'Planetary Transmission: Willis Kinematics & Coaxial Load Sharing', 'Coaxial high-reduction drive, Willis relative speed equation (5:1 ratio), assembly symmetry, and AGMA load sharing');

  // Left Side (55%): Planetary 2D/3D CAD Assembly Visualizer
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 6.5, h: 4.8, rectRadius: 0.08,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetaryMesh2d)) {
    s.addImage({
      path: ASSETS.planetaryMesh2d,
      x: 0.82, y: 1.84, w: 6.46, h: 4.4,
      sizing: { type: 'contain', w: 6.46, h: 4.4 }
    });
  }
  s.addText('Figure 8.1: Planetary 2D Meshing Diagram: Sun (12T), Planets (18T), Internal Ring (48T) — Ratio 5:1', {
    x: 0.82, y: 6.3, w: 6.46, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Right Side (45%): Kinematics & Force Allocation Cards
  s.addShape(pres.ShapeType.roundRect, {
    x: 7.5, y: 1.82, w: 5.033, h: 4.8, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 7.5, y: 1.82, w: 5.033, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.white, width: 0 }
  });
  s.addText('WILLIS KINEMATICS & COAXIAL GEOMETRY', {
    x: 7.75, y: 2.05, w: 4.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });

  const planetaryPoints = [
    {
      title: 'Willis Relative Velocity Ratio (5:1)',
      eq: 'i = 1 + (N_ring / N_sun) = 1 + (48 / 12) = 5.0 : 1',
      desc: 'With the internal ring gear held stationary, input servomotor power to the central sun steps down by 5:1 at the planet carrier, amplifying output pitch torque by 5x (72.75 N·m at eta = 97%).'
    },
    {
      title: 'Geometric Coaxial Assembly Condition',
      eq: 'N_ring = N_sun + 2·N_planet  ==>  48 = 12 + 2·(18)',
      desc: 'Guarantees equal center distances (a = 45.0 mm) between sun-planet and planet-ring meshes, ensuring perfect collinear alignment of motor and output shafts.'
    },
    {
      title: 'Symmetrical Planet Spacing (K = 3 or 4)',
      eq: '(N_sun + N_ring) / K = (12 + 48) / 3 = 20  [Integer]',
      desc: 'Yields an integer index, ensuring planets mesh symmetrically at 120° intervals. Tangential loads split across multiple planets, while separating forces cancel out radially on the sun shaft.'
    }
  ];

  let py = 2.45;
  planetaryPoints.forEach(p => {
    s.addText(p.title, {
      x: 7.75, y: py, w: 4.5, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.slateDark
    });
    s.addShape(pres.ShapeType.roundRect, {
      x: 7.75, y: py + 0.25, w: 4.5, h: 0.28, rectRadius: 0.04,
      fill: { color: C.cardAlt },
      line: { color: C.borderLight, width: 0.8 }
    });
    s.addText(p.eq, {
      x: 7.75, y: py + 0.25, w: 4.5, h: 0.28,
      fontFace: 'Consolas', fontSize: 8.5, bold: true, color: C.maroon,
      align: 'center', valign: 'middle'
    });
    s.addText(p.desc, {
      x: 7.75, y: py + 0.58, w: 4.5, h: 0.65,
      fontFace: 'Segoe UI', fontSize: 8.8, color: C.slateMuted, lineSpacingMultiple: 1.15
    });
    py += 1.25;
  });

  s.addNotes(`Slide 8: Core Mechanism 2: Epicyclic Planetary Reducer
"For high-torque, compact nacelle installations, we modeled the Epicyclic Planetary Gear Train:
1. Willis Kinematics: with a fixed ring gear, the speed reduction ratio is exactly 1 + Nr/Ns = 1 + 48/12 = 5:1.
2. Geometric coaxiality requires Nr = Ns + 2*Np (48 = 12 + 36), which equalizes the sun-planet and planet-ring center distances at 45.0 mm.
3. Assembly symmetry requires (Ns + Nr) / K to be an exact integer. (12 + 48)/3 = 20, guaranteeing that all three planets mesh with identical 120-degree phase spacing.
4. Force sharing: radial tooth forces cancel out symmetrically on the central sun shaft, eliminating bending loads on the high-speed motor shaft."`);
}

// ==============================================================================
// SLIDE 09: Technical Challenge Overcome: True Cone Projection (3 Steps)
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 9, 'TECHNICAL CHALLENGE OVERCOME', 'Case Study: True Cone Projection & Watertight CAD Generation', 'Diagnosing a 68% conical tooth depth loss, implementing normal vector projection, and producing watertight B-Rep CAD');

  // 3 Step Columns: Challenge -> Investigation -> Solution (Solution Highlighted)
  const steps = [
    {
      num: 'STEP 01',
      title: 'The Challenge: 68% Tooth Depth Distortion',
      badge: 'ROOT PROBLEM',
      highlight: false,
      content: [
        { text: '• Radial Profile Stacking Flaw:\n', options: { bold: true, color: C.slateDark } },
        { text: 'Initial V2 implementations stacked 2D involute slices radially outward along the Z axis, measuring addendum and dedendum in cylindrical coordinates.\n\n', options: { color: C.slateMuted } },
        { text: '• Severe Ring Tooth Truncation:\n', options: { bold: true, color: '8B1E2E' } },
        { text: 'Because the ring gear pitch cone angle is gamma_g = 71.57°, radial slicing scaled apparent depth by cos(71.57°) = 0.316. Measured depth was only 2.07 mm instead of the required 6.564 mm—a catastrophic 68% depth error that caused premature tooth disengagement.', options: { color: C.slateMuted } }
      ]
    },
    {
      num: 'STEP 02',
      title: 'Investigation & Failed Iterations',
      badge: 'DIAGNOSTIC PATH',
      highlight: false,
      content: [
        { text: '• Hypothesis 1 (Artificial Scaling):\n', options: { bold: true, color: C.slateDark } },
        { text: 'Attempted artificially increasing Gleason depth factor khw to 3.05. This restored outer crest height but created severe self-intersecting loops and spoke artifacts in SolidWorks lofting.\n\n', options: { color: C.slateMuted } },
        { text: '• Hypothesis 2 (Clearance Boosting):\n', options: { bold: true, color: C.slateDark } },
        { text: 'Tripling bottom clearance c produced hollow, knife-edge roots that failed FEA stress convergence.\n\n', options: { color: C.slateMuted } },
        { text: '• Breakthrough Insight:\n', options: { bold: true, color: C.slateDark } },
        { text: 'Tooth depth must be projected strictly orthogonal to the pitch cone surface generator, not in global cylindrical coordinates.', options: { color: C.slateMuted } }
      ]
    },
    {
      num: 'STEP 03',
      title: 'The Solution: Normal Cone Vector Projection',
      badge: 'VERIFIED SOLUTION',
      highlight: true,
      content: [
        { text: '• Orthogonal Vector Formulation:\n', options: { bold: true, color: C.maroon } },
        { text: 'r_3D = A · sin(gamma) + Delta_r · cos(gamma)\nz_3D = A · cos(gamma) - Delta_r · sin(gamma)\n\n', options: { fontFace: 'Consolas', bold: true, color: C.maroon } },
        { text: '• 100% Depth Restoration:\n', options: { bold: true, color: C.slateDark } },
        { text: 'Full 6.564 mm whole depth restored across entire face width (Ao = 75.89 mm down to Ai = 54.64 mm).\n\n', options: { color: C.slateMuted } },
        { text: '• Watertight Euler Characteristic:\n', options: { bold: true, color: C.slateDark } },
        { text: 'Replaced center-fan caps with polyshape Delaunay triangulation, verifying V - E + F = 2 (100% watertight STL/STEP export).', options: { color: C.slateMuted } }
      ]
    }
  ];

  steps.forEach((st, i) => {
    const sx = 0.8 + i * 4.0;
    
    // Container Card (Solution gets Maroon border)
    s.addShape(pres.ShapeType.roundRect, {
      x: sx, y: 1.82, w: 3.75, h: 4.8, rectRadius: 0.08,
      fill: { color: st.highlight ? C.white : C.cardAlt },
      line: { color: st.highlight ? C.maroon : C.borderLight, width: st.highlight ? 1.5 : 1 }
    });

    // Top Stripe
    s.addShape(pres.ShapeType.rect, {
      x: sx, y: 1.82, w: 3.75, h: 0.04,
      fill: { color: st.highlight ? C.maroon : (i === 0 ? '8B1E2E' : C.gold) },
      line: { color: C.white, width: 0 }
    });

    // Step Number Pill
    s.addShape(pres.ShapeType.roundRect, {
      x: sx + 0.25, y: 2.05, w: 1.2, h: 0.22, rectRadius: 0.04,
      fill: { color: st.highlight ? C.maroonTint : C.white },
      line: { color: st.highlight ? C.maroonBorder : C.borderSlate, width: 0.8 }
    });
    s.addText(st.num, {
      x: sx + 0.25, y: 2.05, w: 1.2, h: 0.22,
      fontFace: 'Consolas', fontSize: 7.5, bold: true, color: st.highlight ? C.maroon : C.slateDark,
      align: 'center', valign: 'middle'
    });

    s.addText(st.title, {
      x: sx + 0.25, y: 2.38, w: 3.25, h: 0.5,
      fontFace: 'Segoe UI', fontSize: 11, bold: true, color: C.slateDark
    });

    s.addText(st.content, {
      x: sx + 0.25, y: 2.95, w: 3.25, h: 3.5,
      fontFace: 'Segoe UI', fontSize: 9.2, lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 9: Technical Challenge Overcome: True Cone Projection
"Slide 9 demonstrates a genuine mechanical engineering problem we encountered and resolved:
When we first generated the 48-tooth ring bevel gear, the teeth looked strangely shallow—measuring only 2.07 mm deep instead of the 6.564 mm specified by Gleason standards. That was a 68% depth loss!
We discovered that the initial code was stacking involute profiles radially outward in cylindrical coordinates. But bevel gear teeth exist on a cone surface tilted at 71.57 degrees. Slicing radially multiplied the true depth by cos(71.57°), shrinking it to less than a third.
After rejecting ad-hoc scaling factors, we solved this from first principles: we formulated the exact coordinate transformation projecting points normal to the pitch cone generator.
This restored the full 6.564 mm depth across the entire 21.25 mm face width and produced a verified watertight B-Rep solid with Euler characteristic V - E + F = 2."`);
}

// ==============================================================================
// SLIDE 10: Quantitative Results & Manufacturing Prototyping
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 10, 'QUANTITATIVE VALIDATION', 'Quantitative Results: Contact Ratio, Safety Margins & 3D Prototyping', 'Three key quantitative engineering achievements, ISO/Lewis stress safety factor, and PrintComp manufacturing validation');

  // 3 Large Gold Stat Callout Cards
  const statCards = [
    {
      stat: '1.642',
      label: 'Transverse Contact Ratio',
      sub: 'Threshold: CR >= 1.20',
      desc: 'Guarantees continuous dual-tooth engagement, quiet operation, and zero loss of kinematic pitch synchronicity.'
    },
    {
      stat: '46.4',
      label: 'Minimum Bending Safety (SF)',
      sub: 'Lewis Bending Stress: 5.39 MPa',
      desc: 'Calculated against 250 MPa steel yield limit (SF = 46.4) and ~50 MPa for polymer prototypes (SF > 9.0).'
    },
    {
      stat: '0 Non-Manifold',
      label: 'Watertight CAD Geometry',
      sub: 'Euler Metric: V - E + F = 2',
      desc: '100% topologically closed 3D triangular surface meshes with zero boundary leaks or self-intersections.'
    }
  ];

  statCards.forEach((sc, i) => {
    const cx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.roundRect, {
      x: cx, y: 1.82, w: 3.75, h: 2.1, rectRadius: 0.08,
      fill: { color: C.cardBg },
      line: { color: C.borderLight, width: 1 }
    });
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.82, w: 3.75, h: 0.04,
      fill: { color: C.gold },
      line: { color: C.white, width: 0 }
    });

    s.addText(sc.stat, {
      x: cx + 0.2, y: 1.95, w: 3.35, h: 0.55,
      fontFace: 'Consolas', fontSize: 26, bold: true, color: C.gold
    });
    s.addText(sc.label, {
      x: cx + 0.2, y: 2.5, w: 3.35, h: 0.28,
      fontFace: 'Segoe UI', fontSize: 11, bold: true, color: C.slateDark
    });
    s.addText(sc.sub, {
      x: cx + 0.2, y: 2.76, w: 3.35, h: 0.22,
      fontFace: 'Consolas', fontSize: 8.5, bold: true, color: C.maroon
    });
    s.addText(sc.desc, {
      x: cx + 0.2, y: 3.02, w: 3.35, h: 0.8,
      fontFace: 'Segoe UI', fontSize: 8.8, color: C.slateMuted, lineSpacingMultiple: 1.15
    });
  });

  // Bottom Half: PrintComp Manufacturing Compensation Table & Validation
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 4.1, w: 11.733, h: 2.55, rectRadius: 0.08,
    fill: { color: C.cardAlt },
    line: { color: C.borderLight, width: 1 }
  });
  s.addText('PRINTCOMP MANUFACTURING COMPENSATION & PROTOTYPE TOLERANCES', {
    x: 1.05, y: 4.25, w: 11.2, h: 0.25,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.maroon
  });

  const mfgTable = [
    [
      { text: 'Material Parameter', options: { bold: true, color: C.maroon, fill: C.white } },
      { text: 'PLA Polymer', options: { bold: true, fill: C.white } },
      { text: 'PETG Technical', options: { bold: true, fill: C.white } },
      { text: 'Steel (4140 / 8620)', options: { bold: true, fill: C.white } },
      { text: 'Physical Function / Tolerance Effect', options: { bold: true, fill: C.white } }
    ],
    [
      { text: 'Thermal Shrinkage Factor', options: { bold: true } },
      { text: '0.30% (Scale x1.003)', options: { fontFace: 'Consolas' } },
      { text: '0.40% (Scale x1.004)', options: { fontFace: 'Consolas' } },
      { text: '0.00% (CAD 1:1)', options: { fontFace: 'Consolas' } },
      { text: 'Counters cooling contraction from nozzle to ambient' }
    ],
    [
      { text: 'Backlash Flank Thinning', options: { bold: true } },
      { text: '0.15 mm (Normal)', options: { fontFace: 'Consolas', bold: true } },
      { text: '0.15 mm (Normal)', options: { fontFace: 'Consolas', bold: true } },
      { text: '0.02 mm (Grinding)', options: { fontFace: 'Consolas' } },
      { text: 'Prevents tooth binding; allows thermal expansion' }
    ],
    [
      { text: 'Print Tooth Thickness (p/g)', options: { bold: true } },
      { text: '5.102 / 4.022 mm', options: { fontFace: 'Consolas', bold: true, color: C.maroon } },
      { text: '5.102 / 4.022 mm', options: { fontFace: 'Consolas' } },
      { text: '5.252 / 4.172 mm', options: { fontFace: 'Consolas' } },
      { text: 'Normal thickness shifted to preserve conjugate roll' }
    ],
    [
      { text: 'Print Clearance (c_print)', options: { bold: true } },
      { text: '0.664 mm (+0.10 mm)', options: { fontFace: 'Consolas' } },
      { text: '0.664 mm (+0.10 mm)', options: { fontFace: 'Consolas' } },
      { text: '0.564 mm (Standard)', options: { fontFace: 'Consolas' } },
      { text: 'Root fillet relief prevents nozzle bead accumulation' }
    ]
  ];

  s.addTable(mfgTable, {
    x: 1.05, y: 4.55, w: 11.2, h: 1.95,
    colW: [2.3, 1.8, 1.8, 1.8, 3.5],
    fill: C.white,
    border: { pt: 0.8, color: C.borderLight },
    fontFace: 'Segoe UI', fontSize: 8.5,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 10: Quantitative Results & Manufacturing Prototyping
"Slide 10 presents our quantitative validation:
Look at the three primary metrics at the top:
1. Contact Ratio: 1.642, comfortably above the 1.20 industrial minimum, ensuring uninterrupted conjugate motion.
2. Bending Safety: Under 6.67 N·m mesh torque, tooth bending stress is only 5.39 MPa on the gear and 4.67 MPa on the pinion. For alloy steel this yields a massive safety factor of 46.4, and even for 3D printed polymer prototypes with 50 MPa yield, safety factor exceeds 9.
3. Mesh Integrity: The output meshes possess zero non-manifold edges, satisfying the closed Euler polyhedron metric V - E + F = 2.
At the bottom, our PrintComp algorithm applies material-calibrated shrinkage scaling (+0.3% for PLA) and 0.15 mm flank thinning, ensuring functional physical prototypes assemble smoothly without binding."`);
}

// ==============================================================================
// SLIDE 11: Conclusions, Competencies Mastered & Defense Q&A
// ==============================================================================
{
  const s = pres.addSlide();
  setupMechanicalSlide(s, 11, 'DEFENSE CONCLUSION', 'Conclusions, Mechanical Competencies Mastered & Acknowledgments', 'Synthesis of machine design theory, future engineering roadmap, and academic appreciation');

  // Left Column: Key Mechanical Deliverables
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 1.82, w: 5.75, h: 4.15, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.82, w: 5.75, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.white, width: 0 }
  });
  s.addText('CORE MECHANICAL ENGINEERING DELIVERABLES', {
    x: 1.05, y: 2.05, w: 5.25, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: '• Formulated 7 Pitch Gear Architectures:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Derived exact analytical kinematics for Zerol bevels, straight bevels, spiral bevels, planetary drives, helical, and annular slewing rings.\n\n', options: { color: C.slateMuted } },
    { text: '• Gleason Zerol & Tredgold Kinematics:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Successfully eliminated gearbox axial thrust forces (Fa = 0) and mapped 3D conical spherical contact to 2D line-of-action conjugate diagnostics (CR = 1.642).\n\n', options: { color: C.slateMuted } },
    { text: '• Gleason 60/40 Addendum System:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Completely eliminated pinion undercutting on 16T pinions with a 0.180·m tooth thickness shift, maximizing fatigue durability.\n\n', options: { color: C.slateMuted } },
    { text: '• Manufacturing Tolerancing & Software Suite:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Built PrintComp shrinkage algorithms and an accessible engineering design suite allowing any user to configure and export custom gears to SolidWorks.', options: { color: C.slateMuted } }
  ], {
    x: 1.05, y: 2.45, w: 5.25, h: 3.3,
    fontFace: 'Segoe UI', fontSize: 9.2, lineSpacingMultiple: 1.15
  });

  // Right Column: Professional Competencies & Acknowledgments
  s.addShape(pres.ShapeType.roundRect, {
    x: 6.78, y: 1.82, w: 5.75, h: 4.15, rectRadius: 0.08,
    fill: { color: C.cardBg },
    line: { color: C.borderLight, width: 1 }
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
    { text: '1. Advanced Involute & Bevel Kinematics (Gleason, Willis, Tredgold).\n2. Drivetrain Load Sharing & Dynamic Pitch Regulation in Wind Turbines.\n3. Precision Backlash Tolerancing & Additive Manufacturing Compensation.\n4. SolidWorks B-Rep Parametric CAD Modeling & STEP AP214 Data Exchange.\n5. Full-Stack Engineering Tool Development for CAD Workflow Automation.\n\n', options: { color: C.slateMuted } },
    { text: 'Future Engineering Roadmap:\n', options: { bold: true, color: C.slateDark } },
    { text: '• Full ISO 6336 contact stress rating with oil film EHL elastohydrodynamics.\n• Physical dynamometer test bench validation of 3D printed prototype gearboxes.\n\n', options: { color: C.slateMuted } },
    { text: 'Academic & Professional Appreciation:\n', options: { bold: true, color: C.maroon } },
    { text: 'Sincere gratitude to my academic supervisors at Universiti Teknologi Malaysia (UTM) and industry mentors for their continuous technical guidance.', options: { color: C.slateMuted } }
  ], {
    x: 7.05, y: 2.45, w: 5.25, h: 3.3,
    fontFace: 'Segoe UI', fontSize: 8.8, lineSpacingMultiple: 1.15
  });

  // Dark Maroon Footer Banner with Candidate Info & Defense Opening
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.8, y: 6.15, w: 11.733, h: 0.65, rectRadius: 0.06,
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

  s.addNotes(`Slide 11: Conclusions, Competencies Mastered & Acknowledgments
"In conclusion, this internship provided comprehensive, practical mastery of mechanical machine design, precision gear kinematics, and software automation:
From early 3D printer calibration and casing design, through analytical Gleason equations and True Cone projection fixes, to a deployable universal CAD software suite.
We proved Gleason Zerol axial thrust cancellation, eliminated pinion undercutting, modeled Willis planetary kinematics, and validated safety margins.
Most importantly, we verified that the synthesized gears can be manufactured with zero binding.
I want to express my sincere appreciation to Universiti Teknologi Malaysia (UTM), my academic supervisors, and mentors for their guidance throughout this journey.
Thank you for your time. The floor is now open for technical questions and discussion."`);
}

// ==============================================================================
// EXPORT PPTX TO ROOT AND LOCAL DIRECTORY
// ==============================================================================
const rootOutPath = path.join(__dirname, '..', 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');
const localOutPath = path.join(__dirname, 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');
const rootAltPath = path.join(__dirname, '..', 'Wind_Turbine_Pitch_Control_System_Mechanical_Engineering_Presentation.pptx');

pres.writeFile({ fileName: rootOutPath })
  .then(() => {
    console.log(`Mechanical Engineering PPTX exported successfully to root: ${rootOutPath}`);
    fs.copyFileSync(rootOutPath, localOutPath);
    console.log(`Mechanical Engineering PPTX copy saved to: ${localOutPath}`);
    fs.copyFileSync(rootOutPath, rootAltPath);
    console.log(`Alternative naming copy saved to: ${rootAltPath}`);
  })
  .catch(err => {
    console.error('Error exporting PPTX:', err);
    process.exit(1);
  });
