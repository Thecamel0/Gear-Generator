/**
 * Generate UTM Branded Formal, Clean & Modern PowerPoint Presentation (.pptx)
 * Design Guide: Universiti Teknologi Malaysia (UTM) Modern Technical Deck
 * Candidate: Ahmed Majdy Ahmed
 * Institution: Universiti Teknologi Malaysia (UTM)
 * Target Audience: Academic Evaluators (UTM), Industry Mentors, Engineering Leads
 */

const pptxgen = require('pptxgenjs');
const path = require('path');
const fs = require('fs');

const pres = new pptxgen();

// Set 16:9 Modern Widescreen Layout (13.333" x 7.5")
pres.defineLayout({ name: 'WIDE_16_9', width: 13.333, height: 7.5 });
pres.layout = 'WIDE_16_9';

// 60-30-10 UTM Visual Identity Color Palette
const C = {
  canvasWhite: 'FFFFFF',      // 60% Canvas
  cardBg: 'FFFFFF',           // Crisp White Card Container
  canvasAlt: 'F8FAFC',        // Slate-50 Alternate Canvas
  slateDark: '0F172A',        // 30% Structure - Slide Titles, Headlines
  slateMuted: '475569',       // Body Text, Captions, Secondary Notes
  slateDim: '64748B',         // Subtle labels & footer
  borderSlate: 'E2E8F0',      // Subtle 1px component borders
  maroon: '721422',           // 10% Accents - UTM Primary Brand
  maroonTint: 'F8EEF0',       // Light Maroon 5% for pill badges
  maroonBorder: 'E8C5CA',     // Soft maroon border
  gold: 'D49B23',             // UTM Secondary Accent - Stat callouts, badges
  goldLight: 'FDF8EB',       // Soft gold background
  emerald: '059669',          // Success metrics
  white: 'FFFFFF'
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

// Helper: Setup Standard UTM Technical Deck Chrome (Header & Footer)
function setupSlideChrome(slide, slideNum, categoryTag, title, subtitle) {
  slide.background = { color: C.canvasWhite };

  // Category Tag Pill (Light Maroon with Maroon Text)
  slide.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.45, w: 3.2, h: 0.28,
    fill: { color: C.maroonTint },
    line: { color: C.maroonBorder, width: 1 }
  });
  slide.addText(categoryTag.toUpperCase(), {
    x: 0.8, y: 0.45, w: 3.2, h: 0.28,
    fontFace: 'Consolas', fontSize: 8.5, bold: true, color: C.maroon,
    align: 'center', valign: 'middle'
  });

  // Slide Headline (30-34pt Bold, Slate Dark)
  slide.addText(title, {
    x: 0.8, y: 0.78, w: 11.5, h: 0.48,
    fontFace: 'Segoe UI', fontSize: 23, bold: true, color: C.slateDark,
    valign: 'middle'
  });

  // Slide Subtitle (12-13pt, Slate Muted)
  slide.addText(subtitle, {
    x: 0.8, y: 1.28, w: 11.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 11.5, color: C.slateMuted,
    valign: 'top'
  });

  // Accent Gradient Line under header (Maroon to Gold)
  slide.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.62, w: 11.733, h: 0.03,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });

  // Slide Footer
  slide.addShape(pres.ShapeType.line, {
    x: 0.8, y: 6.9, w: 11.733, h: 0,
    line: { color: C.borderSlate, width: 1 }
  });

  slide.addText('Universiti Teknologi Malaysia (UTM)  |  Wind Turbine Pitch Control System', {
    x: 0.8, y: 6.98, w: 5.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, color: C.slateDim,
    valign: 'middle'
  });

  slide.addText('Ahmed Majdy Ahmed  —  Final Internship Milestone Review', {
    x: 5.8, y: 6.98, w: 4.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, color: C.slateDim,
    align: 'center', valign: 'middle'
  });

  slide.addText(`Slide ${String(slideNum).padStart(2, '0')} / 10`, {
    x: 10.6, y: 6.98, w: 1.933, h: 0.3,
    fontFace: 'Consolas', fontSize: 9.5, color: C.maroon, bold: true,
    align: 'right', valign: 'middle'
  });
}

// ==============================================================================
// SLIDE 01: Title & Project Identification
// ==============================================================================
{
  const s = pres.addSlide();
  // Deep Maroon Cover Background per UTM Guidelines
  s.background = { color: C.maroon };

  // Left Gold Accent Stripe
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 0.8, w: 0.15, h: 5.9,
    fill: { color: C.gold },
    line: { color: C.gold, width: 0 }
  });

  // Institution & Faculty Banner
  s.addShape(pres.ShapeType.rect, {
    x: 1.2, y: 0.85, w: 4.8, h: 0.35,
    fill: { color: '5A0E1A' },
    line: { color: C.gold, width: 1 }
  });
  s.addText('UNIVERSITI TEKNOLOGI MALAYSIA (UTM)', {
    x: 1.2, y: 0.85, w: 4.8, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.gold,
    align: 'center', valign: 'middle'
  });

  // Main Headline
  s.addText('Wind Turbine Pitch Control System:', {
    x: 1.2, y: 1.45, w: 10.8, h: 0.65,
    fontFace: 'Segoe UI', fontSize: 32, bold: true, color: C.white
  });
  s.addText('Precision Gear CAD & Kinematics Studio', {
    x: 1.2, y: 2.15, w: 10.8, h: 0.65,
    fontFace: 'Segoe UI', fontSize: 30, bold: true, color: C.gold
  });

  // Subtitle
  s.addText('Final Internship Milestone Presentation — Academic & Industrial Engineering Defense', {
    x: 1.2, y: 2.9, w: 10.8, h: 0.4,
    fontFace: 'Segoe UI', fontSize: 13, color: 'E2E8F0'
  });

  // Divider Line
  s.addShape(pres.ShapeType.line, {
    x: 1.2, y: 3.4, w: 11.3, h: 0,
    line: { color: '8B1E2E', width: 1 }
  });

  // Candidate Info Card
  s.addShape(pres.ShapeType.rect, {
    x: 1.2, y: 3.65, w: 5.8, h: 2.8,
    fill: { color: '5A0E1A' },
    line: { color: '8B1E2E', width: 1 }
  });
  s.addText('CANDIDATE & EVALUATION METADATA', {
    x: 1.4, y: 3.8, w: 5.4, h: 0.3,
    fontFace: 'Consolas', fontSize: 9.5, bold: true, color: C.gold
  });
  s.addText([
    { text: 'Candidate: ', options: { bold: true, color: C.white } },
    { text: 'Ahmed Majdy Ahmed\n', options: { color: 'F1F5F9' } },
    { text: 'Institution: ', options: { bold: true, color: C.white } },
    { text: 'Universiti Teknologi Malaysia (UTM)\n', options: { color: 'F1F5F9' } },
    { text: 'Program: ', options: { bold: true, color: C.white } },
    { text: 'Mechanical Engineering / Drive Systems Specialization\n', options: { color: 'F1F5F9' } },
    { text: 'Evaluation: ', options: { bold: true, color: C.white } },
    { text: 'End-of-Internship Review (Academic Supervisors & Mentors)', options: { color: 'F1F5F9' } }
  ], {
    x: 1.4, y: 4.2, w: 5.4, h: 2.1,
    fontFace: 'Segoe UI', fontSize: 10.5, lineSpacingMultiple: 1.25
  });

  // Right Side Preview Container
  s.addShape(pres.ShapeType.rect, {
    x: 7.3, y: 3.65, w: 5.2, h: 2.8,
    fill: { color: '000000' },
    line: { color: C.gold, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.planetaryOverview)) {
    s.addImage({
      path: ASSETS.planetaryOverview,
      x: 7.32, y: 3.67, w: 5.16, h: 2.5
    });
  }
  s.addText('Delivered Software: 100% Client-Side WebGL CAD Studio & MATLAB ISO Suite', {
    x: 7.32, y: 6.2, w: 5.16, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addNotes(`Slide 1: Title & Project Identification (00:00 - 00:45)
"Good morning, respected UTM academic supervisors, industry mentors, and engineering leads.
My name is Ahmed Majdy Ahmed from Universiti Teknologi Malaysia. Today, I am proud to present the final milestone of my internship: the Wind Turbine Pitch Control System — Precision Gear CAD and Kinematics Studio.
This project integrates advanced gear kinematics, ISO 6336 stress validation, and modern WebGL computer graphics into an end-to-end engineering platform."`);
}

// ==============================================================================
// SLIDE 02: Executive Summary & Internship Scope
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 2, 'EXECUTIVE SUMMARY', 'Executive Summary: Scope & Key Contributions', 'High-level overview of core mission, delivered software artifacts, and quantifiable engineering impact');

  const cards = [
    {
      title: 'Core Mission',
      accent: C.maroon,
      bullets: [
        'Solved pitch drive bottleneck by replacing multi-day manual CAD drafting with real-time synthesis.',
        'Engineered exact kinematics for high-reduction (50:1–150:1) compact wind turbine nacelle gearboxes.',
        'Mitigated cyclic fatigue and flutter by enforcing < 0.05 mm backlash and ISO safety margins.'
      ]
    },
    {
      title: 'Delivered Artifacts',
      accent: C.gold,
      bullets: [
        'Formulated analytical geometries for 7 distinct pitch gear architectures (Zerol, Bevel, Spur, Planetary).',
        'Built modular MATLAB computational suites with live stress dials and App Designer GUI.',
        'Engineered 100% client-side Three.js WebGL CAD Studio with real-time 3D multi-body kinematics.',
        'Authored in-browser ISO 10303-21 STEP AP214 B-Rep and IEEE 754 binary STL exporters.'
      ]
    },
    {
      title: 'Business & Technical Impact',
      accent: C.emerald,
      bullets: [
        'Accelerated design iteration ~1000x (reducing calculation cycle from 3 hours to < 100ms).',
        'Eliminated cloud server costs (100% client-side execution, $0 backend cloud bill).',
        'Delivered complete cross-platform portability across modern browsers with zero installation.'
      ]
    }
  ];

  cards.forEach((c, i) => {
    const cx = 0.8 + i * 4.0;
    // Card Container
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.85, w: 3.75, h: 4.75,
      fill: { color: C.cardBg },
      line: { color: C.borderSlate, width: 1 }
    });

    // Top 2px Accent Stripe
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 1.85, w: 3.75, h: 0.04,
      fill: { color: c.accent },
      line: { color: c.accent, width: 0 }
    });

    // Header
    s.addText(c.title, {
      x: cx + 0.25, y: 2.05, w: 3.25, h: 0.35,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.maroon
    });

    // Bullets (Google X-Y-Z formula, max 2 lines per bullet)
    const bulletContent = c.bullets.map(b => ({
      text: `• ${b}\n\n`,
      options: { color: C.slateMuted }
    }));

    s.addText(bulletContent, {
      x: cx + 0.25, y: 2.55, w: 3.25, h: 3.85,
      fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.2
    });
  });

  s.addNotes(`Slide 2: Executive Summary & Internship Scope (00:45 - 02:00)
"Our executive summary centers on three pillars:
First, our Core Mission: wind turbine blades require continuous micro-pitching to optimize power coefficient Cp and emergency feathering within 5 seconds.
Second, Delivered Artifacts: seven mathematically validated gear architectures, an ISO 6336 MATLAB calculation suite, a Three.js WebGL CAD Studio, and client-side STEP B-Rep exporters.
Third, Impact: we accelerated design iteration by approximately 1000x—reducing hours of manual spreadsheet work into sub-100ms real-time synthesis."`);
}

// ==============================================================================
// SLIDE 03: Problem Statement & Engineering Objectives
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 3, 'PROBLEM FORMULATION', 'The Problem: Bridging the Gap in Pitch Drive Design', 'Contrasting legacy mechanical design limitations against our unified automated engineering solution');

  // Left Column: Legacy State / Challenges (Slate Gray Background)
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.canvasAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('CURRENT STATE & INDUSTRY BOTTLENECK', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.slateDark
  });
  s.addText([
    { text: '• Fragmented Design Workflows:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Engineers manually transcribe math equations between spreadsheets, MATLAB, and CAD tools.\n\n', options: { color: C.slateMuted } },
    { text: '• Costly Desktop Software Barriers:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Proprietary CAD/FEA packages require expensive $5,000+/seat licenses, locking models to local workstations.\n\n', options: { color: C.slateMuted } },
    { text: '• Sluggish Design Iteration Latency:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Drafting complex tooth flanks (Gleason Zerol, hypoid curves) takes 1–3 days per trial.\n\n', options: { color: C.slateMuted } },
    { text: '• Human Error & Lack of Stress Checks:\n', options: { bold: true, color: C.slateDark } },
    { text: 'CAD geometries are frequently drafted without synchronized ISO 6336 bending or contact stress validation.', options: { color: C.slateMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  // Right Column: Target Solution (Crisp White with Maroon Top Stripe)
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.maroonBorder, width: 1.5 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });
  s.addText('OUR TARGET SOLUTION & DELIVERABLE', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: '• Unified Automated Gear Pipeline:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Instantaneously synthesizes tooth coordinates directly from input module and tooth count sliders.\n\n', options: { color: C.slateMuted } },
    { text: '• Zero-Install Web-Based Accessibility:\n', options: { bold: true, color: C.slateDark } },
    { text: '100% client-side WebGL platform accessible from any modern browser with zero licensing fees.\n\n', options: { color: C.slateMuted } },
    { text: '• Sub-Second CAD & Kinematic Synthesis:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Generates 3D multi-body assemblies and manufacturing STEP/STL files in under 2 seconds.\n\n', options: { color: C.slateMuted } },
    { text: '• Strict ISO 6336 & AGMA Compliance:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Automatic evaluation of bending safety (S_F >= 1.4) and contact endurance (S_H >= 1.2).', options: { color: C.slateMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.8,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.15
  });

  s.addNotes(`Slide 3: Problem Statement & Engineering Objectives (02:00 - 03:00)
"Why is building this app valuable to industry and academia?
On the left, notice the traditional industry bottleneck: manual spreadsheet calculations taking hours, disconnected from 3D CAD drafting that takes days, requiring expensive licenses.
On the right is our solution: an automated pipeline where mathematical synthesis, ISO stress validation, 3D kinematic visualization, and STEP CAD export are synchronized in real time."`);
}

// ==============================================================================
// SLIDE 04: System Architecture & Technology Stack
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 4, 'SYSTEM ARCHITECTURE', 'System Architecture & Technical Topology', 'End-to-end client-side execution topology connecting mathematical models to manufacturing files');

  // Top Half: Block Flow Diagram
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 11.733, h: 2.3,
    fill: { color: C.canvasAlt },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addText('END-TO-END DATA & EXECUTION TOPOLOGY (ZERO-BACKEND CLIENT PIPELINE)', {
    x: 1.05, y: 1.95, w: 11.2, h: 0.3,
    fontFace: 'Consolas', fontSize: 9, bold: true, color: C.maroon
  });

  const blocks = [
    { title: '1. Mathematical Core', desc: 'ISO 6336 Stress & Gleason Algorithms' },
    { title: '2. Three.js WebGL', desc: 'Parametric 3D Buffer Mesh Synthesis' },
    { title: '3. 2D Diagnostic Canvas', desc: 'Tredgold Line-of-Action Projection' },
    { title: '4. Direct CAD Exporter', desc: 'STEP B-Rep, STL & SolidWorks Macros' }
  ];

  blocks.forEach((b, i) => {
    const bx = 1.05 + i * 2.85;
    s.addShape(pres.ShapeType.rect, {
      x: bx, y: 2.4, w: 2.5, h: 1.45,
      fill: { color: C.white },
      line: { color: C.maroonBorder, width: 1.2 }
    });
    // Top maroon bar
    s.addShape(pres.ShapeType.rect, {
      x: bx, y: 2.4, w: 2.5, h: 0.04,
      fill: { color: C.maroon },
      line: { color: C.maroon, width: 0 }
    });
    s.addText(b.title, {
      x: bx + 0.1, y: 2.55, w: 2.3, h: 0.35,
      fontFace: 'Segoe UI', fontSize: 10.5, bold: true, color: C.slateDark,
      align: 'center'
    });
    s.addText(b.desc, {
      x: bx + 0.1, y: 2.95, w: 2.3, h: 0.75,
      fontFace: 'Segoe UI', fontSize: 9, color: C.slateMuted,
      align: 'center'
    });

    // Arrow to next block
    if (i < 3) {
      s.addText('➔', {
        x: bx + 2.52, y: 2.85, w: 0.32, h: 0.4,
        fontFace: 'Segoe UI', fontSize: 14, color: C.maroon,
        align: 'center', valign: 'middle'
      });
    }
  });

  // Bottom Half: Categorized Tech Stack Pill Badges
  const categories = [
    {
      category: 'Frontend & 3D WebGL',
      pills: ['Three.js (WebGL)', 'HTML5 2D Canvas', 'Vanilla JS ES Modules', 'Responsive CSS3']
    },
    {
      category: 'Mathematical & Solvers',
      pills: ['MATLAB App Designer', 'ISO 6336 Method B', 'Gleason Cutter Math', 'Willis Kinematics']
    },
    {
      category: 'Tooling & Build Pipeline',
      pills: ['Vite Build System', 'Node.js Runtime', 'JSZip Compression', 'Git Version Control']
    },
    {
      category: 'CAD & Manufacturing',
      pills: ['ISO 10303-21 STEP', 'Binary IEEE 754 STL', 'SolidWorks VBA .bas', 'PrintComp Slicing']
    }
  ];

  categories.forEach((cat, idx) => {
    const colX = 0.8 + idx * 3.0;
    s.addShape(pres.ShapeType.rect, {
      x: colX, y: 4.35, w: 2.75, h: 2.25,
      fill: { color: C.white },
      line: { color: C.borderSlate, width: 1 }
    });
    s.addText(cat.category, {
      x: colX + 0.15, y: 4.45, w: 2.45, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.maroon
    });

    cat.pills.forEach((p, pIdx) => {
      const py = 4.8 + pIdx * 0.42;
      s.addShape(pres.ShapeType.rect, {
        x: colX + 0.15, y: py, w: 2.45, h: 0.32,
        fill: { color: C.canvasAlt },
        line: { color: C.borderSlate, width: 1 }
      });
      s.addText(p, {
        x: colX + 0.15, y: py, w: 2.45, h: 0.32,
        fontFace: 'Consolas', fontSize: 8.5, color: C.slateDark,
        align: 'center', valign: 'middle'
      });
    });
  });

  s.addNotes(`Slide 4: System Architecture & Technology Stack (03:00 - 04:00)
"Our software architecture is built on a 100% client-side topology.
At the top, follow our four-stage execution pipeline: from analytical mathematical modeling to Three.js WebGL mesh generation, 2D line-of-action verification, and client-side STEP/STL CAD serialization.
At the bottom, our stack combines Three.js and HTML5 Canvas with MATLAB App Designer solvers, packaged via Vite and exporting ISO 10303-21 standard CAD files."`);
}

// ==============================================================================
// SLIDE 05: Core Feature 1 — Real-Time 3D Kinematics & WebGL CAD Studio
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 5, 'PRIMARY FEATURE DEEP DIVE', 'Core Feature 1: Real-Time 3D Kinematics & WebGL Studio', 'Parametric mesh synthesis, true Willis planetary motion, and multi-pinion synchronization');

  // Left (60%): High-Resolution UI Mockup inside clean frame
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 7.2, h: 4.75,
    fill: { color: '000000' },
    line: { color: C.maroonBorder, width: 1.5 }
  });
  if (fs.existsSync(ASSETS.zerolBevel)) {
    s.addImage({
      path: ASSETS.zerolBevel,
      x: 0.82, y: 1.87, w: 7.16, h: 4.35
    });
  }
  s.addText('Figure 5.1: 3D Orthogonal Zerol Bevel Meshing Assembly in Three.js (Sigma = 90°)', {
    x: 0.82, y: 6.25, w: 7.16, h: 0.3,
    fontFace: 'Consolas', fontSize: 8.5, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Right (40%): 3 Structured Accomplishment Points (Google X-Y-Z formula)
  s.addShape(pres.ShapeType.rect, {
    x: 8.2, y: 1.85, w: 4.333, h: 4.75,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 8.2, y: 1.85, w: 4.333, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });
  s.addText('ENGINEERING ACCOMPLISHMENTS', {
    x: 8.45, y: 2.1, w: 3.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });

  const deepPoints = [
    {
      tag: '1. Parametric Mesh Synthesis',
      desc: 'Accomplished zero-latency 3D mesh rendering in < 200ms by deriving analytical vertex normal matrices directly from Gleason cone equations.'
    },
    {
      tag: '2. Synchronized Willis Kinematics',
      desc: 'Simulated true epicyclic multi-body kinematics by coupling planet needle-bearing spin with carrier orbit speed (omega_c = omega_s / (1 + Nr/Ns)).'
    },
    {
      tag: '3. Multi-Mode Shader Diagnostics',
      desc: 'Validated tooth engagement by implementing PBR metallic shading, wireframe triangulation checks, and transparent pitch cone ghosting.'
    }
  ];

  deepPoints.forEach((dp, i) => {
    const dy = 2.5 + i * 1.35;
    s.addText(dp.tag, {
      x: 8.45, y: dy, w: 3.8, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 10.5, bold: true, color: C.slateDark
    });
    s.addText(dp.desc, {
      x: 8.45, y: dy + 0.32, w: 3.8, h: 0.95,
      fontFace: 'Segoe UI', fontSize: 9.5, color: C.slateMuted,
      lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 5: Core Feature 1 — Real-Time 3D Kinematics & WebGL Studio (04:00 - 05:00)
"Our primary feature deep dive focuses on our 3D WebGL kinematics engine.
Notice in Figure 5.1 how the Zerol bevel gear pair meshes orthogonally at 90 degrees with Gleason curvature.
Using the Google X-Y-Z formula:
First, we synthesized 3D buffer geometries in under 200 milliseconds by computing vertex normal buffers directly from analytical formulas.
Second, we implemented true Willis planetary kinematics where planets orbit the sun on the carrier arm while counter-rotating.
Third, we validated conjugate action with multi-mode shaders including wireframe and pitch-cone ghosting."`);
}

// ==============================================================================
// SLIDE 06: Core Feature 2 — Zero-Kernel CAD Generation & Component Isolation
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 6, 'CAD PIPELINE DEEP DIVE', 'Core Feature 2: In-Browser CAD Exporters & Component Isolation', 'Client-side ISO 10303-21 STEP B-Rep serialization and isolated planetary manufacturing downloads');

  // Left Side: 2 Images (Dropdown options + Isolated parts)
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 2.3,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetaryDropdown)) {
    s.addImage({
      path: ASSETS.planetaryDropdown,
      x: 0.82, y: 1.87, w: 5.71, h: 1.95
    });
  }
  s.addText('Figure 6.1: Multi-Format & Component Isolation CAD Exporter Menu', {
    x: 0.82, y: 3.85, w: 5.71, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 4.3, w: 5.75, h: 2.3,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.planetarySun)) {
    s.addImage({
      path: ASSETS.planetarySun,
      x: 0.82, y: 4.32, w: 2.8, h: 1.95
    });
  }
  if (fs.existsSync(ASSETS.planetaryPlanet)) {
    s.addImage({
      path: ASSETS.planetaryPlanet,
      x: 3.65, y: 4.32, w: 2.86, h: 1.95
    });
  }
  s.addText('Figure 6.2: Isolated Sun Gear (Left) & Planet Gear (Right) for CNC/3D Print', {
    x: 0.82, y: 6.3, w: 5.71, h: 0.25,
    fontFace: 'Consolas', fontSize: 8, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // Right Side: 3 Highlight Cards
  const cadCards = [
    {
      title: 'STEP AP214 B-Rep Serializer',
      desc: 'Constructs ISO 10303-21 topological entities (MANIFOLD_SOLID_BREP, ADVANCED_FACE) in pure JavaScript, importing as native solid bodies in SolidWorks and CATIA.'
    },
    {
      title: 'Granular Component Isolation',
      desc: 'Enables independent fabrication downloads: Sun gear alone (motor spline bore), Planet gear alone (needle bearing fit), or complete assembly ZIP archive.'
    },
    {
      title: 'PrintComp Tolerance Offsets',
      desc: 'Applies programmatic tooth thinning (0.08–0.15 mm) and bore expansion (+0.15 mm) to compensate for FDM/SLA thermal shrinkage and prevent gear binding.'
    }
  ];

  cadCards.forEach((cc, i) => {
    const cy = 1.85 + i * 1.62;
    s.addShape(pres.ShapeType.rect, {
      x: 6.78, y: cy, w: 5.75, h: 1.45,
      fill: { color: C.cardBg },
      line: { color: C.borderSlate, width: 1 }
    });
    s.addShape(pres.ShapeType.rect, {
      x: 6.78, y: cy, w: 5.75, h: 0.03,
      fill: { color: C.maroon },
      line: { color: C.maroon, width: 0 }
    });
    s.addText(cc.title, {
      x: 7.05, y: cy + 0.15, w: 5.25, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 11, bold: true, color: C.maroon
    });
    s.addText(cc.desc, {
      x: 7.05, y: cy + 0.48, w: 5.25, h: 0.85,
      fontFace: 'Segoe UI', fontSize: 9.5, color: C.slateMuted,
      lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 6: Core Feature 2 — In-Browser CAD Exporters & Component Isolation (05:00 - 06:00)
"Our second core feature addresses manufacturing readiness:
In Figures 6.1 and 6.2, notice our granular download selector. Machine shops cannot machine an assembled planetary drive as one monolithic block.
We engineered pure JavaScript serializers that generate ISO 10303-21 STEP B-Rep solid bodies directly in RAM, with isolated options for Sun, Planet, and Ring gears.
Furthermore, our PrintComp algorithm applies calibrated tooth thinning and bore offsets for functional 3D printing."`);
}

// ==============================================================================
// SLIDE 07: Key Technical Challenge & Engineering Solution
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 7, 'ARCHITECTURAL HURDLE', 'Overcoming Architectural & Geometric Hurdles', 'Case study in debugging, mathematical transformation, and conjugate contact resolution');

  // 3-Step Progressive Chevron / Card Flow
  const steps = [
    {
      num: 'STEP 01',
      title: 'The Challenge',
      subtitle: 'Conical Tooth 2D Projection Distortion',
      content: 'Bevel gear teeth mesh in 3D along intersecting cones. Directly projecting 3D conical geometry onto a flat 2D viewport skewed tooth profiles, creating false optical interpenetration and preventing kinematic clearance diagnostics.',
      highlight: false
    },
    {
      num: 'STEP 02',
      title: 'Investigation & Alternatives',
      subtitle: 'Evaluated Conical Unrolling vs. Cameras',
      content: 'Tested direct orthogonal camera projections (failed due to conical perspective distortion) and planar conical unrolling (failed because intersecting bevel cones are non-developable surfaces without pitch distortion).',
      highlight: false
    },
    {
      num: 'STEP 03',
      title: 'The Solution & Outcome',
      subtitle: 'Tredgold Virtual Back-Cone Transformation',
      content: 'Implemented Tredgold spherical back-cone equations in plot2d.js: virtual teeth zv = z / cos(delta) and virtual radius rv = r / cos(delta). Transformed 3D spherical contact into an exact equivalent planar conjugate rack pair, achieving 100% accurate line-of-action tracking.',
      highlight: true
    }
  ];

  steps.forEach((st, i) => {
    const sx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: sx, y: 1.85, w: 3.75, h: 4.75,
      fill: { color: st.highlight ? C.cardBg : C.canvasAlt },
      line: { color: st.highlight ? C.maroon : C.borderSlate, width: st.highlight ? 2 : 1 }
    });

    // Step Number Pill
    s.addShape(pres.ShapeType.rect, {
      x: sx + 0.25, y: 2.1, w: 1.2, h: 0.28,
      fill: { color: st.highlight ? C.maroonTint : C.white },
      line: { color: st.highlight ? C.maroonBorder : C.borderSlate, width: 1 }
    });
    s.addText(st.num, {
      x: sx + 0.25, y: 2.1, w: 1.2, h: 0.28,
      fontFace: 'Consolas', fontSize: 9, bold: true, color: st.highlight ? C.maroon : C.slateDark,
      align: 'center', valign: 'middle'
    });

    // Gold Corner Badge for Step 3
    if (st.highlight) {
      s.addShape(pres.ShapeType.rect, {
        x: sx + 2.4, y: 2.1, w: 1.1, h: 0.28,
        fill: { color: C.goldLight },
        line: { color: C.gold, width: 1 }
      });
      s.addText('RESOLVED', {
        x: sx + 2.4, y: 2.1, w: 1.1, h: 0.28,
        fontFace: 'Consolas', fontSize: 8.5, bold: true, color: C.gold,
        align: 'center', valign: 'middle'
      });
    }

    s.addText(st.title, {
      x: sx + 0.25, y: 2.55, w: 3.25, h: 0.35,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: st.highlight ? C.maroon : C.slateDark
    });
    s.addText(st.subtitle, {
      x: sx + 0.25, y: 2.9, w: 3.25, h: 0.3,
      fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.slateMuted
    });

    s.addText(st.content, {
      x: sx + 0.25, y: 3.3, w: 3.25, h: 3.1,
      fontFace: 'Segoe UI', fontSize: 10, color: C.slateMuted,
      lineSpacingMultiple: 1.2
    });
  });

  s.addNotes(`Slide 7: Key Technical Challenge & Engineering Solution (06:00 - 07:00)
"Every real engineering project encounters architectural hurdles.
Our biggest challenge was representing 3D conical bevel meshing on a 2D diagnostic screen. Because conical teeth converge toward the apex, simple projections caused optical distortion and false collisions.
In Step 2, we investigated unrolling and orthogonal cameras, finding them mathematically flawed for non-developable cones.
In Step 3, we solved this by implementing Tredgold's Virtual Back-Cone Approximation in plot2d.js. By transforming bevel cones into equivalent virtual spur gears, we achieved true 2D conjugate meshing diagnostics."`);
}

// ==============================================================================
// SLIDE 08: Live Demonstration / Application Walkthrough
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 8, 'APPLICATION IN ACTION', 'Application in Action: Walkthrough & Workflows', 'End-to-end demonstration of user journeys, dynamic reactivity, and CAD generation');

  // Center Mockup Screen Flow (2 Images Side-by-Side)
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 3.4,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.straightMesh2d)) {
    s.addImage({
      path: ASSETS.straightMesh2d,
      x: 0.82, y: 1.87, w: 5.71, h: 3.0
    });
  }
  s.addText('Live 2D Contact Mechanics & Line-of-Action Engagement Tracking (alpha = 20°)', {
    x: 0.82, y: 4.95, w: 5.71, h: 0.25,
    fontFace: 'Consolas', fontSize: 8.5, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 3.4,
    fill: { color: '000000' },
    line: { color: C.borderSlate, width: 1 }
  });
  if (fs.existsSync(ASSETS.cadToast)) {
    s.addImage({
      path: ASSETS.cadToast,
      x: 6.8, y: 1.87, w: 5.71, h: 3.0
    });
  }
  s.addText('Real-Time Parameter Sliders & Instant STEP/STL CAD Export Toast Notification', {
    x: 6.8, y: 4.95, w: 5.71, h: 0.25,
    fontFace: 'Consolas', fontSize: 8.5, color: 'CBD5E1',
    align: 'center', valign: 'middle'
  });

  // 3 Bulleted Takeaway Cues at Bottom
  const cues = [
    {
      cue: 'Cue 1: Interactive Parameter Tuning',
      desc: 'Moving module and tooth sliders updates 3D geometry and stress safety factors in < 100 milliseconds.'
    },
    {
      cue: 'Cue 2: Kinematic Engagement Loop',
      desc: 'Animated contact point moves along the line of action tangent to base circles, verifying conjugate motion.'
    },
    {
      cue: 'Cue 3: 1-Click CAD Download',
      desc: 'Selecting STEP AP214 triggers in-browser B-Rep serialization, downloading solid CAD models instantly.'
    }
  ];

  cues.forEach((cu, i) => {
    const cx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: cx, y: 5.45, w: 3.75, h: 1.15,
      fill: { color: C.canvasAlt },
      line: { color: C.borderSlate, width: 1 }
    });
    s.addText(cu.cue, {
      x: cx + 0.15, y: 5.55, w: 3.45, h: 0.25,
      fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.maroon
    });
    s.addText(cu.desc, {
      x: cx + 0.15, y: 5.82, w: 3.45, h: 0.7,
      fontFace: 'Segoe UI', fontSize: 8.5, color: C.slateMuted,
      lineSpacingMultiple: 1.15
    });
  });

  s.addNotes(`Slide 8: Live Demonstration / Application Walkthrough (07:00 - 08:00)
"Now, let us examine the application in action across three core workflow cues:
First, parameter tuning: moving module, ratio, or tooth sliders recalculates geometry in under 100 milliseconds.
Second, kinematic tracking: the 2D canvas displays the traveling contact point along the pressure line of action, proving smooth conjugate motion.
Third, instant manufacturing export: one click compiles an ISO 10303-21 STEP B-Rep file in memory, ready for SolidWorks or 3D printing."`);
}

// ==============================================================================
// SLIDE 09: Quantifiable Results & Business Impact
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 9, 'PERFORMANCE METRICS', 'Measurable Outcomes & Engineering Impact', 'Validation against project objectives, performance KPIs, and industrial cost metrics');

  // 3 Prominent Metric Callout Stat Cards per UTM Design Guidelines
  const stats = [
    {
      num: '~1000x',
      label: 'Design Iteration Acceleration',
      detail: 'Reduced calculation and parameter re-tuning latency from 2–4 hours of spreadsheet work down to < 100ms.'
    },
    {
      num: '< 2s',
      label: 'Instantaneous CAD Generation',
      detail: 'Eliminated 1–3 days of manual 3D drafting by synthesizing verified STEP AP214 B-Rep files directly in browser.'
    },
    {
      num: '100%',
      label: 'Licensing & Cloud Cost Reduction',
      detail: 'Operates with zero backend cloud GPU servers and zero proprietary CAD desktop seat dependencies ($5,000+ saved).'
    }
  ];

  stats.forEach((st, i) => {
    const sx = 0.8 + i * 4.0;
    s.addShape(pres.ShapeType.rect, {
      x: sx, y: 1.85, w: 3.75, h: 2.9,
      fill: { color: C.cardBg },
      line: { color: C.borderSlate, width: 1 }
    });

    // Top 2px Accent Stripe
    s.addShape(pres.ShapeType.rect, {
      x: sx, y: 1.85, w: 3.75, h: 0.04,
      fill: { color: C.gold },
      line: { color: C.gold, width: 0 }
    });

    // Large Stat Number (44pt Bold, UTM Warm Gold #D49B23)
    s.addText(st.num, {
      x: sx + 0.2, y: 2.1, w: 3.35, h: 0.85,
      fontFace: 'Consolas', fontSize: 44, bold: true, color: C.gold,
      align: 'center'
    });

    // Metric Label (14pt SemiBold, Slate Dark)
    s.addText(st.label, {
      x: sx + 0.2, y: 3.0, w: 3.35, h: 0.45,
      fontFace: 'Segoe UI', fontSize: 13, bold: true, color: C.slateDark,
      align: 'center'
    });

    // Metric Detail (10pt, Slate Muted)
    s.addText(st.detail, {
      x: sx + 0.2, y: 3.5, w: 3.35, h: 1.1,
      fontFace: 'Segoe UI', fontSize: 9.5, color: C.slateMuted,
      align: 'center', lineSpacingMultiple: 1.15
    });
  });

  // Summary Table of Impact
  const summaryRows = [
    [
      { text: 'Benchmarking Metric', options: { bold: true, color: C.maroon, fill: C.maroonTint } },
      { text: 'Traditional Engineering Workflow', options: { bold: true, color: C.slateDark, fill: C.maroonTint } },
      { text: 'Delivered UTM Gear Studio', options: { bold: true, color: C.slateDark, fill: C.maroonTint } },
      { text: 'Measured Outcome', options: { bold: true, color: C.emerald, fill: C.maroonTint } }
    ],
    [
      { text: 'Supported Architectures', options: { bold: true, color: C.slateDark } },
      { text: '1–2 gear types per software package', options: { color: C.slateMuted } },
      { text: '7 complete wind turbine architectures', options: { color: C.slateDark, bold: true } },
      { text: 'Unified Platform', options: { color: C.emerald, bold: true } }
    ],
    [
      { text: 'Stress Compliance Rating', options: { bold: true, color: C.slateDark } },
      { text: 'Manual post-processing in FEA software', options: { color: C.slateMuted } },
      { text: 'Automatic ISO 6336 bending & contact check', options: { color: C.slateDark, bold: true } },
      { text: 'Real-Time Safety Factor', options: { color: C.emerald, bold: true } }
    ],
    [
      { text: 'Physical 3D Prototyping', options: { bold: true, color: C.slateDark } },
      { text: 'Severe tooth binding due to thermal shrinkage', options: { color: C.slateMuted } },
      { text: 'Automated PrintComp backlash compensation', options: { color: C.slateDark, bold: true } },
      { text: 'Watertight Manifold Fit', options: { color: C.emerald, bold: true } }
    ]
  ];

  s.addTable(summaryRows, {
    x: 0.8, y: 5.0, w: 11.733, h: 1.6,
    colW: [2.5, 3.5, 3.5, 2.233],
    fill: C.cardBg,
    border: { pt: 1, color: C.borderSlate },
    fontFace: 'Segoe UI', fontSize: 9.5,
    align: 'left', valign: 'middle'
  });

  s.addNotes(`Slide 9: Measurable Outcomes & Engineering Impact (08:00 - 09:30)
"On Slide 9, we quantify the business and engineering ROI:
Stat 1: ~1000x faster design iteration—reducing what used to take 2 to 4 hours into under 100 milliseconds.
Stat 2: under 2 seconds for CAD generation—generating solid STEP B-Rep files in browser RAM instead of 1 to 3 days of manual drafting.
Stat 3: 100% cost reduction in cloud compute and specialized software licensing.
The bottom table confirms unified support across 7 architectures, synchronized ISO 6336 stress evaluation, and physical 3D print compensation."`);
}

// ==============================================================================
// SLIDE 10: Learnings, Future Roadmap & Acknowledgments
// ==============================================================================
{
  const s = pres.addSlide();
  setupSlideChrome(s, 10, 'PROFESSIONAL GROWTH', 'Professional Growth, System Roadmap & Acknowledgments', 'Competencies developed, future technical expansions, and academic appreciation');

  // Left Column: Future Roadmap
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 4.15,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 1.85, w: 5.75, h: 0.04,
    fill: { color: C.maroon },
    line: { color: C.maroon, width: 0 }
  });
  s.addText('FUTURE TECHNICAL ROADMAP', {
    x: 1.1, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.maroon
  });
  s.addText([
    { text: '• WebAssembly FEA Stress Solver Integration:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Compile C++ finite element meshing solvers to WASM for in-browser visual von Mises stress contours.\n\n', options: { color: C.slateMuted } },
    { text: '• Dynamic Multi-Body Gear Slap Simulation:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Simulate torsional rattle and wind gust dynamic torque reversals on blade pitch gearboxes.\n\n', options: { color: C.slateMuted } },
    { text: '• Industrial Cloud Presets & Collaboration:\n', options: { bold: true, color: C.slateDark } },
    { text: 'Enable teams to share standardized pitch drive configurations (NREL 5MW, Vestas V90, Siemens Gamesa) with encrypted URL tokens.', options: { color: C.slateMuted } }
  ], {
    x: 1.1, y: 2.55, w: 5.15, h: 3.2,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.2
  });

  // Right Column: Professional Growth & Thanks
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 4.15,
    fill: { color: C.cardBg },
    line: { color: C.borderSlate, width: 1 }
  });
  s.addShape(pres.ShapeType.rect, {
    x: 6.78, y: 1.85, w: 5.75, h: 0.04,
    fill: { color: C.gold },
    line: { color: C.gold, width: 0 }
  });
  s.addText('COMPETENCIES MASTERED & ACKNOWLEDGMENTS', {
    x: 7.08, y: 2.1, w: 5.15, h: 0.35,
    fontFace: 'Segoe UI', fontSize: 12, bold: true, color: C.slateDark
  });
  s.addText([
    { text: '• Technical Competencies Mastered:\n', options: { bold: true, color: C.maroon } },
    { text: 'Advanced gear kinematics, ISO 6336 standards, 3D WebGL computer graphics, low-level STEP B-Rep file serialization, and full-stack software architecture.\n\n', options: { color: C.slateMuted } },
    { text: '• Academic & Professional Gratitude:\n', options: { bold: true, color: C.maroon } },
    { text: 'Sincere appreciation to Universiti Teknologi Malaysia (UTM) academic supervisors and industry mentors for continuous guidance, technical feedback, and support throughout this internship.', options: { color: C.slateMuted } }
  ], {
    x: 7.08, y: 2.55, w: 5.15, h: 3.2,
    fontFace: 'Segoe UI', fontSize: 10, lineSpacingMultiple: 1.2
  });

  // Dark Maroon Footer Bar with Contact & Affiliation Info
  s.addShape(pres.ShapeType.rect, {
    x: 0.8, y: 6.15, w: 11.733, h: 0.65,
    fill: { color: C.maroon },
    line: { color: C.gold, width: 1 }
  });
  s.addText('Candidate: Ahmed Majdy Ahmed  |  Universiti Teknologi Malaysia (UTM)  |  Wind Turbine Pitch Drive Systems', {
    x: 1.0, y: 6.22, w: 7.5, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 10, bold: true, color: C.white,
    valign: 'middle'
  });
  s.addText('Floor Open for Evaluator Discussion & Live Demo Q&A  ➔', {
    x: 8.5, y: 6.22, w: 3.8, h: 0.3,
    fontFace: 'Segoe UI', fontSize: 9.5, bold: true, color: C.gold,
    align: 'right', valign: 'middle'
  });

  s.addNotes(`Slide 10: Learnings, Future Roadmap & Acknowledgments (09:30 - 11:00)
"In conclusion, this internship has enabled me to synthesize advanced mechanical gear theory with computer graphics and software engineering.
On the left is our roadmap: WebAssembly FEA stress solvers and dynamic torsional vibration modeling.
On the right, my sincere thanks to Universiti Teknologi Malaysia (UTM) and my mentors for their invaluable leadership throughout this project.
Thank you very much. I welcome your questions, feedback, and discussion."`);
}

// ==============================================================================
// WRITE PPTX TO DISK
// ==============================================================================
const rootOutPath = path.join(__dirname, '..', 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');
const localOutPath = path.join(__dirname, 'Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx');

pres.writeFile({ fileName: rootOutPath })
  .then(() => {
    console.log(`UTM Deck exported successfully to root: ${rootOutPath}`);
    fs.copyFileSync(rootOutPath, localOutPath);
    console.log(`UTM Deck copy saved to: ${localOutPath}`);
  })
  .catch(err => {
    console.error('Error exporting PPTX:', err);
    process.exit(1);
  });
