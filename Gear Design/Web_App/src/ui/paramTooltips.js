/**
 * =========================================================================
 * GEAR MASTER — Interactive Parameter Tooltips & Engineering Guidance System
 * Provides rich, context-aware descriptions of what each parameter is
 * and how it affects gear mechanics, kinematics, and durability.
 * =========================================================================
 */

export const PARAM_TOOLTIPS = {
  'module': {
    name: 'Module (m)',
    symbol: 'm',
    formula: 'm = d / N = p / \u03C0',
    whatItIs: (g) => g === 'helical'
      ? 'Normal module (mn) defining the fundamental metric tooth size measured on the normal plane perpendicular to tooth helix.'
      : 'The fundamental metric scale factor for gear teeth, defined as the pitch diameter (mm) divided by the number of teeth.',
    whatItAffects: [
      'Bending Strength: Root load capacity scales quadratically with module (larger m = much stronger teeth).',
      'Tooth Proportions: Directly scales addendum (1.0\u00B7m), dedendum (1.25\u00B7m), and whole tooth depth (2.25\u00B7m).',
      'Physical Size: Pitch diameter expands linearly (d = m\u00B7N), increasing machine envelope.'
    ],
    impactTags: ['Tooth Strength', 'Overall Size', 'Tooth Height']
  },

  'pinion-teeth': {
    name: (g) => g === 'planetary' ? 'Sun Teeth (Ns)' : 'Pinion Teeth (Np)',
    symbol: (g) => g === 'planetary' ? 'Ns' : 'Np',
    formula: (g) => g === 'planetary' ? 'ds = m \u00B7 Ns' : 'dp = m \u00B7 Np',
    whatItIs: (g) => g === 'planetary'
      ? 'The number of external involute teeth on the central driving sun gear.'
      : 'The number of teeth on the driving pinion (the smaller, driving gear of the reduction stage).',
    whatItAffects: [
      'Reduction Ratio: Inversely controls gear ratio (fewer sun/pinion teeth yield higher torque multiplication).',
      'Undercutting Limit: Pinions with Np < 14 (at 20\u00B0 pressure angle) suffer profile undercutting, weakening the tooth root.',
      'Planet Clearance (Planetary): Larger sun teeth expand the carrier orbit radius C, enabling more planets to fit without colliding.'
    ],
    impactTags: ['Gear Ratio', 'Undercutting', 'Orbit Radius']
  },

  'gear-teeth': {
    name: (g) => g === 'planetary' ? 'Planet Teeth (Np)' : 'Gear Teeth (Ng)',
    symbol: (g) => g === 'planetary' ? 'Np' : 'Ng',
    formula: (g) => g === 'planetary' ? 'C = m(Ns + Np)/2' : 'dg = m \u00B7 Ng',
    whatItIs: (g) => g === 'planetary'
      ? 'The number of external teeth on each orbiting planet gear that meshes simultaneously with both the Sun and Ring gear.'
      : 'The number of teeth on the driven gear (bull gear) that receives motion from the pinion.',
    whatItAffects: [
      'Kinematic Speed & Ratio: Sets output reduction ratio and torque capacity.',
      'Center Distance: Determines the axis-to-axis spacing (or carrier orbit radius C in planetary drives).',
      'Coaxial Assembly (Planetary): Directly locks the ring gear teeth count via the coaxial condition Nr = Ns + 2\u00B7Np.'
    ],
    impactTags: ['Reduction Ratio', 'Center Distance', 'Coaxial Fit']
  },

  'ring-teeth': {
    name: 'Ring Teeth (Nr)',
    symbol: 'Nr',
    formula: 'Nr = Ns + 2\u00B7Np  \u27FA  Np = (Nr \u2212 Ns)/2',
    whatItIs: 'The number of internal involute teeth on the stationary outer ring gear (annulus) surrounding the planetary train.',
    whatItAffects: [
      'Willis Speed Ratio: Determines total epicyclic ratio (i = 1 + Nr / Ns with fixed ring).',
      'Housing Bore Diameter: Sets internal pitch diameter (dr = m\u00B7Nr) and overall gearbox outer envelope.',
      'Planet Gear Sizing: Auto-calculates planet tooth count Np = (Nr \u2212 Ns)/2 to preserve coaxial shaft alignment.'
    ],
    impactTags: ['Willis Ratio', 'Housing Size', 'Coaxial Alignment']
  },

  'pressure-angle': {
    name: 'Pressure Angle (\u03C6)',
    symbol: '\u03C6',
    formula: 'rb = rp \u00B7 cos(\u03C6)',
    whatItIs: 'The angle between the tooth profile tangent and the normal line of action passing through the pitch point (typically 20\u00B0).',
    whatItAffects: [
      'Root Bending Strength: Higher pressure angles (e.g. 25\u00B0) broaden the tooth root, increasing beam load capacity by 15\u201320%.',
      'Radial Separating Force: Increases bearing separating push (Fr = Ft \u00B7 tan \u03C6), requiring stiffer bearing supports.',
      'Contact Ratio: Lower pressure angles increase active contact ratio, providing quieter and smoother tooth handoff.'
    ],
    impactTags: ['Tooth Strength', 'Radial Thrust', 'Contact Ratio']
  },

  'helix-angle': {
    name: 'Tooth Angle / Helix Angle (\u03B2)',
    symbol: '\u03B2',
    formula: 'mt = mn / cos(\u03B2) \u2022 \u03B5\u03B2 = (F \u00B7 sin\u03B2) / (\u03C0 \u00B7 mn)',
    whatItIs: 'The inclination angle of the tooth flank relative to the shaft axis along the pitch cylinder or cone surface.',
    whatItAffects: [
      'Acoustic Noise & Vibration: Helical overlap creates progressive tooth contact, dramatically smoothing dynamic meshing.',
      'Axial Thrust Force: Generates an axial thrust force (Fa = Ft \u00B7 tan \u03B2) along the shaft that must be absorbed by thrust bearings.',
      'Effective Tooth Count: Increases virtual tooth count (Nv = N / cos\u00B3\u03B2), reducing risk of undercutting on small pinions.'
    ],
    impactTags: ['Noise & Vibration', 'Axial Thrust', 'Load Sharing']
  },

  'shaft-angle': {
    name: 'Shaft Angle (\u03A3)',
    symbol: '\u03A3',
    formula: 'tan(\u03B3p) = sin(\u03A3) / ((Ng/Np) + cos(\u03A3))',
    whatItIs: 'The intersection angle between the driving pinion shaft and driven gear shaft axes (nominally 90\u00B0 for standard bevel drives).',
    whatItAffects: [
      'Pitch Cone Angles: Dictates the pitch cone angles \u03B3p and \u03B3g for both bevel gears (\u03B3p + \u03B3g = \u03A3).',
      'Packaging Orientation: Governs whether drive delivers inline (0\u00B0), perpendicular (90\u00B0), or custom angular power transfer.'
    ],
    impactTags: ['Cone Angles', 'Shaft Layout', 'Bevel Geometry']
  },

  'face-width-ratio': {
    name: 'Face Width Ratio (F / Ao)',
    symbol: 'F / Ao',
    formula: 'F = (F / Ao) \u00B7 Ao',
    whatItIs: 'Standard Gleason proportion relating active tooth face width F to the outer cone distance Ao in bevel gears.',
    whatItAffects: [
      'Bevel Standards Compliance: Enforces standard AGMA limit (F \u2264 0.30\u00B7Ao or 10\u00B7m) to avoid severe inner toe pinching.',
      'Tooth Taper: Controls how rapidly the tooth height and thickness diminish from heel to toe.'
    ],
    impactTags: ['Gleason Standard', 'Tooth Taper', 'Toe Clearance']
  },

  'face-width': {
    name: 'Face Width (F)',
    symbol: 'F',
    formula: '\u03C3b = (Ft \u00B7 Kv \u00B7 Ko \u00B7 Km) / (F \u00B7 m \u00B7 J)',
    whatItIs: 'The active axial length of tooth engagement measured along the pitch line.',
    whatItAffects: [
      'Transmittable Torque: Spreads tooth contact forces over more area; doubling F approximately cuts root bending stress in half.',
      'Structural Mass: Directly increases the axial width and mass of the gear components.',
      'Load Distribution: Extremely wide gears (F > 10\u00B7m) become vulnerable to uneven edge-loading if shafts flex.'
    ],
    impactTags: ['Torque Capacity', 'Bending Stress', 'Weight']
  },

  'carrier-thickness': {
    name: 'Carrier Plate Thickness (tc)',
    symbol: 'tc',
    formula: 'tc \u2265 0.35 \u00B7 F (recommended)',
    whatItIs: 'The axial thickness of the solid planet carrier disc that holds and supports all cantilevered planet pins.',
    whatItAffects: [
      'Pin Rigidity & Alignment: Resists twisting moments from planet gear tooth reactions, keeping planet axes strictly parallel.',
      'Torsional Output Capacity: Transmits the full multiplied output torque (Tc = i \u00B7 Tin) to the central output hub without twist.',
      'Axial Package Envelope: Determines the overall axial profile thickness of the assembled planetary gearbox.'
    ],
    impactTags: ['Pin Rigidity', 'Output Torque', 'Axial Profile']
  },

  'carrier-diameter': {
    name: 'Carrier Disc Diameter (Dc)',
    symbol: 'Dc',
    formula: 'Dc = 2(C + 0.65\u00B7rp) (Auto)',
    whatItIs: 'The outer circular boundary diameter of the planet carrier mounting plate.',
    whatItAffects: [
      'Radial Coverage: Controls whether the carrier plate shields the entire planet orbital sweep or maintains a compact profile.',
      'Rotational Inertia: Influences the moment of inertia and rotational acceleration response of the output assembly.'
    ],
    impactTags: ['Radial Envelope', 'Inertia', 'Carrier Disc']
  },

  'ring-wall': {
    name: 'Ring Wall Thickness (trim)',
    symbol: 'trim',
    formula: 'D_outer = 2(rd_r + trim)',
    whatItIs: 'The radial thickness of solid structural material in the outer ring gear cylinder beyond the tooth root dedendum.',
    whatItAffects: [
      'Hoop Stress Resistance: Resists radial bursting hoop stresses generated by the planetary separation forces.',
      'Housing Rigidity & Noise: Prevents ring gear ovalization under heavy multi-planet loads, suppressing gear whine.',
      'Mounting Interface: Provides structural meat for exterior casing bolts, dowel pins, or clamping flanges.'
    ],
    impactTags: ['Hoop Stress', 'Housing Rigidity', 'Outer Diameter']
  },

  'planets-pinions': {
    name: (g) => g === 'planetary' ? 'Planets Count (K)' : 'Multi-Pinions (n)',
    symbol: (g) => g === 'planetary' ? 'K' : 'n',
    formula: (g) => g === 'planetary' ? 'Ft,planet = Ft / K \u2022 K_max = \u230A\u03C0 / arcsin(rap/C)\u230B' : 'Ft,pinion = Ft / n',
    whatItIs: (g) => g === 'planetary'
      ? 'The total number of planet gears arrayed in parallel on the carrier orbit circle.'
      : 'The number of driving pinions arrayed symmetrically around the bull gear for multi-motor power sharing.',
    whatItAffects: [
      'Load Sharing & Torque: Splits transmitted tangential force across K paths (divides tooth bending stress by K).',
      'Physical Clearance: Geometrically capped by K_max = \u230A\u03C0 / arcsin(rap/C)\u230B to prevent adjacent planet tips from colliding.',
      'Assembly Symmetry: Requires (Ns + Nr) / K to be an integer for uniform, symmetric angular spacing.'
    ],
    impactTags: ['Power Density', 'Adjacent Clearance', 'Assembly Condition']
  },

  'material': {
    name: 'Manufacturing Material & Grade',
    symbol: 'Mat',
    formula: 'SFb = \u03C3_allow / \u03C3b \u2022 SFc = \u03C3H_allow / \u03C3H',
    whatItIs: 'Material specification defining tensile yield, bending fatigue strength, surface hardness, and elasticity.',
    whatItAffects: [
      'Allowable Bending Fatigue: Sets safe stress limit (40\u201380 MPa for polymers, 250+ MPa for heat-treated steel).',
      'Safety Factor: Directly governs safety margins against tooth breakage (SF \u2265 1.5 recommended for wind turbine pitch drives).',
      'Deflection & Tooth Contact: Elastic modulus (E) influences tooth compliance and load distribution under peak wind gusts.'
    ],
    impactTags: ['Fatigue Limit', 'Safety Margin', 'Yield Strength']
  },

  'cutter-radius': {
    name: 'Cutter Radius (rc)',
    symbol: 'rc',
    formula: 'rc \u2248 1.1 \u00B7 Ao \u00B7 sin(\u03B2m)',
    whatItIs: 'The tool radius of the circular face-milling cutter head used in Gleason spiral and zerol bevel generation.',
    whatItAffects: [
      'Longitudinal Tooth Curvature: Controls the circular arc radius of the spiral tooth curve along the face width.',
      'Tooth Contact Patch: Influences localized crowning, reducing sensitivity to shaft deflections and misalignment.'
    ],
    impactTags: ['Gleason Tooling', 'Tooth Curvature', 'Crowning']
  },

  'working-depth': {
    name: 'Working Depth Factor (khw)',
    symbol: 'khw',
    formula: 'hk = khw \u00B7 m',
    whatItIs: 'Multiplier defining the total radial engagement depth of meshing teeth (standard = 2.00 for full-depth teeth).',
    whatItAffects: [
      'Contact Ratio: Higher working depth extends profile engagement, increasing transverse contact ratio.',
      'Tooth Height: Slightly increases tooth bending moment arm; stub teeth (khw = 1.6\u20131.8) are stockier for extreme shock loads.'
    ],
    impactTags: ['Tooth Depth', 'Contact Ratio', 'Shock Resistance']
  },

  'clearance-factor': {
    name: 'Clearance Factor (c*)',
    symbol: 'c*',
    formula: 'c = c* \u00B7 m',
    whatItIs: 'Radial clearance factor at the tooth bottom trough between the mating gear tip and root fillet (nominally 0.188\u20130.25).',
    whatItAffects: [
      'Root Clearance: Prevents mating tooth tips from bottoming out under thermal expansion or shaft deflection.',
      'Lubrication Flow: Provides space for lubricant drainage during high-speed tooth meshing.'
    ],
    impactTags: ['Tip Clearance', 'Fillet Safety', 'Lubrication']
  },

  'torque': {
    name: 'Input Operating Torque (Tin)',
    symbol: 'Tin',
    formula: 'Ft = 2000 \u00B7 Tin / dp',
    whatItIs: 'The nominal driving torque delivered to the input pinion or sun gear shaft (in N\u00B7m).',
    whatItAffects: [
      'Tooth Mesh Forces: Directly scales tangential mesh force (Ft) transmitted between mating gear teeth.',
      'Root Bending Stress: Bending stress (\u03C3b) and Hertzian contact pressure (\u03C3H) scale with torque, reducing safety factors.'
    ],
    impactTags: ['Tangential Force', 'Bending Stress', 'Load Rating']
  },

  'speed-rpm': {
    name: 'Input Operating Speed (nin)',
    symbol: 'nin',
    formula: 'v = (\u03C0 \u00B7 d \u00B7 n) / 60000 (m/s)',
    whatItIs: 'The rotational speed of the driving shaft in revolutions per minute (RPM).',
    whatItAffects: [
      'Pitch Line Velocity: Dictates surface velocity (v in m/s) at the pitch point.',
      'Dynamic Factor (Kv): Higher speeds generate dynamic inertial impacts from microscopic tooth deviations.',
      'Mechanical Power: Governs transmitted power (P = Tin \u00B7 nin / 9549 kW).'
    ],
    impactTags: ['Mesh Velocity', 'Dynamic Load', 'Transmitted Power']
  },

  'efficiency': {
    name: 'Mechanical Efficiency (\u03B7)',
    symbol: '\u03B7',
    formula: 'P_out = \u03B7 \u00B7 P_in \u2022 P_loss = (1 \u2212 \u03B7) \u00B7 P_in',
    whatItIs: 'The ratio of net delivered mechanical output power to input power after tooth sliding friction and bearing drag.',
    whatItAffects: [
      'Delivered Output Torque: Directly scales the available torque delivered to the pitch blade drive.',
      'Thermal Dissipation: The lost power fraction (1 \u2212 \u03B7) turns into heat, defining cooling requirements.'
    ],
    impactTags: ['Power Loss', 'Output Torque', 'Heat Generation']
  },

  'sigma-allow': {
    name: 'Allowable Bending Stress (\u03C3_allow)',
    symbol: '\u03C3_allow',
    formula: 'SFb = \u03C3_allow / \u03C3b',
    whatItIs: 'The maximum permissible cyclic tensile stress at the tooth root fillet before fatigue failure occurs (in MPa).',
    whatItAffects: [
      'Bending Safety Factor (SFb): Defines the structural safety margin against tooth root cracking (target \u2265 1.5).',
      'Allowable Operating Load: Directly establishes the maximum safe torque before permanent deformation or fatigue.'
    ],
    impactTags: ['Safety Margin', 'Fatigue Life', 'Design Limit']
  },

  'involute-points': {
    name: 'Involute Resolution Points (n_pts)',
    symbol: 'n_pts',
    formula: 'Spline sample vertices per flank',
    whatItIs: 'The number of coordinate evaluation vertices calculated along each involute flank curve from base radius to tip.',
    whatItAffects: [
      'Profile Accuracy: Higher point counts ensure mathematically precise involute profiles for 3D printing and 5-axis CNC.',
      'Model File Size: Denser point arrays increase STL triangle count and SolidWorks macro point arrays.'
    ],
    impactTags: ['CAD Precision', 'Mesh Density', 'STL File Size']
  },

  'face-sections': {
    name: 'Face Sections (n_sec)',
    symbol: 'n_sec',
    formula: 'Loft slices along face width F',
    whatItIs: 'The number of cross-sectional slices computed along the gear face width to loft the 3D tooth volume.',
    whatItAffects: [
      'Spiral Twist Smoothness: Accurately captures longitudinal tooth curvature and taper along the cone for spiral/zerol bevels.',
      'Export Triangle Count: Directly multiplies face count in exported STL and STEP CAD files.'
    ],
    impactTags: ['Spiral Lofting', 'Mesh Smoothness', 'CAD Export']
  },

  // Results Table Items
  'res-pitch-dia': {
    name: 'Pitch Diameters (dp / dg / ds / dr)',
    symbol: 'd = m \u00B7 N',
    formula: 'd = m \u00B7 N',
    whatItIs: 'The diameter of the imaginary rolling cylinders that transmit motion by pure rolling without slipping.',
    whatItAffects: [
      'Kinematic Speed Ratio: Ratio of pitch diameters directly dictates the mechanical reduction ratio.',
      'Tangential Velocity: Sets linear speed at the mesh (v = \u03C0\u00B7d\u00B7n / 60000).',
      'Gearbox Envelope: Establishes overall machine diameter and radial space requirements.'
    ],
    impactTags: ['Kinematic Rolling', 'Reduction Ratio', 'Dimensions']
  },

  'res-angles': {
    name: 'Kinematic & Cone Angles',
    symbol: '\u03B3p / \u03B3g (or \u03B2)',
    formula: '\u03B3p + \u03B3g = \u03A3 = 90\u00B0',
    whatItIs: 'Pitch cone apex angles for bevel gears (or helix angle \u03B2 for parallel helical gears).',
    whatItAffects: [
      'Cone Geometry: Defines the angular orientation of tooth blanks toward the central apex.',
      'Force Decomposition: Decomposes tangential force into axial thrust and radial separating forces.'
    ],
    impactTags: ['Cone Angles', 'Force Decomposition', 'Bevel Layout']
  },

  'res-center-dist': {
    name: 'Center Distance (C) / Cone Distance (Ao)',
    symbol: 'C or Ao',
    formula: 'C = m(Np + Ng)/2 (or Ao = dp / (2\u00B7sin\u03B3p))',
    whatItIs: 'The exact distance between shaft axes (for cylindrical/planetary gears) or distance from pitch circle to apex (for bevels).',
    whatItAffects: [
      'Shaft Center Spacing: Defines the precise mounting distance for gearbox casing bores.',
      'Planet Orbit Envelope (Planetary): Carrier pin orbit radius (C) governing adjacent planet clearance.'
    ],
    impactTags: ['Shaft Spacing', 'Mounting Center', 'Orbit Radius']
  },

  'res-contact-ratio': {
    name: 'Transverse Contact Ratio (CR)',
    symbol: 'CR (\u03B5\u03B1)',
    formula: 'CR = L_action / pb \u2265 1.4',
    whatItIs: 'The average number of tooth pairs in contact simultaneously along the line of action.',
    whatItAffects: [
      'Load Sharing: When CR > 1.0, consecutive teeth overlap during engagement so a new tooth enters mesh before the previous leaves.',
      'Quiet Operation: High contact ratio (CR \u2265 1.5) eliminates impact shock, suppressing gear whine and tooth chipping.'
    ],
    impactTags: ['Smooth Meshing', 'Quiet Operation', 'Load Handoff']
  },

  'res-forces': {
    name: 'Mesh Reaction Forces (Ft / Fr / Fa)',
    symbol: 'Ft, Fr, Fa',
    formula: 'Ft = 2000\u00B7Tin / d \u2022 Fr = Ft\u00B7tan\u03C6 \u2022 Fa = Ft\u00B7tan\u03B2',
    whatItIs: 'The 3D vector components of mechanical force transmitted across meshing gear teeth under operating torque (Tangential, Radial separating, and Axial thrust).',
    whatItAffects: [
      'Bearing Sizing: Directly specifies the dynamic radial and axial thrust ratings required for shaft support bearings.',
      'Shaft Bending & Deflection: Radial separating force (Fr) pushes shafts apart, requiring adequate shaft rigidity to prevent edge contact.',
      'Gearbox Housing: Reaction forces must be sustained by casing walls, carrier pins, and mounting flanges.'
    ],
    impactTags: ['Bearing Sizing', 'Radial Push', 'Thrust Force']
  },

  'res-safety-factor': {
    name: 'Bending & Contact Safety Factors (SF)',
    symbol: 'SF_b / SF_c',
    formula: 'SF = \u03C3_allow / \u03C3_actual \u2265 1.5',
    whatItIs: 'The structural margin of safety comparing material fatigue limits against calculated tooth root and contact stresses.',
    whatItAffects: [
      'Design Reliability: SF \u2265 1.5 is standard for wind turbine pitch drives subject to turbulent wind gust spikes.',
      'Failure Protection: Values < 1.0 predict imminent tooth fatigue fracture or pitting spalling.'
    ],
    impactTags: ['Safety Margin', 'Fatigue Life', 'Reliability']
  }
};

/**
 * Singleton Tooltip Controller
 */
class ParamTooltipController {
  constructor() {
    this.tooltipEl = null;
    this.arrowEl = null;
    this.showTimer = null;
    this.activeKey = null;
    this.activeElement = null;
    this.isInitialized = false;
  }

  init() {
    if (this.isInitialized) return;
    this.createTooltipDOM();
    this.bindEvents();
    this.isInitialized = true;
  }

  createTooltipDOM() {
    this.tooltipEl = document.createElement('div');
    this.tooltipEl.id = 'gear-param-tooltip';
    this.tooltipEl.className = 'gear-param-tooltip';
    this.tooltipEl.setAttribute('role', 'tooltip');
    this.tooltipEl.setAttribute('aria-hidden', 'true');

    this.arrowEl = document.createElement('div');
    this.arrowEl.className = 'tooltip-arrow';
    this.tooltipEl.appendChild(this.arrowEl);

    const contentWrap = document.createElement('div');
    contentWrap.className = 'tooltip-content';
    this.tooltipEl.appendChild(contentWrap);

    document.body.appendChild(this.tooltipEl);
  }

  bindEvents() {
    document.addEventListener('mouseover', (e) => {
      const target = e.target.closest('[data-param-tip]');
      if (!target) return;
      const tipKey = target.getAttribute('data-param-tip');
      if (tipKey) {
        this.queueShow(tipKey, target);
      }
    });

    document.addEventListener('mouseout', (e) => {
      const target = e.target.closest('[data-param-tip]');
      if (target) {
        this.hide();
      }
    });

    window.addEventListener('scroll', () => this.hide(), true);
  }

  getGearType() {
    return document.getElementById('sel-gear-type')?.value || 'zerol-bevel';
  }

  queueShow(tipKey, element) {
    clearTimeout(this.showTimer);
    this.activeKey = tipKey;
    this.activeElement = element;

    this.showTimer = setTimeout(() => {
      this.render(tipKey, element);
    }, 120); // 120ms pleasant hover debounce
  }

  render(tipKey, element) {
    const data = PARAM_TOOLTIPS[tipKey];
    if (!data || !this.tooltipEl) return;

    const gearType = this.getGearType();

    const title = typeof data.name === 'function' ? data.name(gearType) : data.name;
    const symbol = typeof data.symbol === 'function' ? data.symbol(gearType) : data.symbol;
    const formula = typeof data.formula === 'function' ? data.formula(gearType) : data.formula;
    const whatItIs = typeof data.whatItIs === 'function' ? data.whatItIs(gearType) : data.whatItIs;

    const affectsArr = typeof data.whatItAffects === 'function' ? data.whatItAffects(gearType) : data.whatItAffects;
    let affectsHtml = '';
    if (Array.isArray(affectsArr)) {
      affectsHtml = affectsArr.map(item => {
        const parts = item.split(':');
        if (parts.length > 1) {
          return `<li><span class="affects-highlight">${parts[0]}:</span>${parts.slice(1).join(':')}</li>`;
        }
        return `<li>${item}</li>`;
      }).join('');
    }

    const tagsArr = typeof data.impactTags === 'function' ? data.impactTags(gearType) : data.impactTags;
    let tagsHtml = '';
    if (Array.isArray(tagsArr)) {
      tagsHtml = tagsArr.map(tag => `<span class="tip-pill-tag">${tag}</span>`).join('');
    }

    const contentWrap = this.tooltipEl.querySelector('.tooltip-content');
    contentWrap.innerHTML = `
      <div class="tip-header">
        <div class="tip-title-wrap">
          <span class="tip-icon">ℹ</span>
          <span class="tip-title">${title}</span>
        </div>
        ${formula ? `<span class="tip-formula-badge">${formula}</span>` : ''}
      </div>

      <div class="tip-body">
        <div class="tip-section">
          <div class="tip-section-heading">WHAT IT IS</div>
          <div class="tip-section-text">${whatItIs}</div>
        </div>

        <div class="tip-section">
          <div class="tip-section-heading">WHAT IT AFFECTS</div>
          <ul class="tip-affects-list">
            ${affectsHtml}
          </ul>
        </div>
      </div>

      ${tagsHtml ? `
      <div class="tip-footer">
        <span class="tip-footer-label">IMPACTS:</span>
        <div class="tip-tags-row">${tagsHtml}</div>
      </div>
      ` : ''}
    `;

    this.position(element);
    this.tooltipEl.classList.add('visible');
    this.tooltipEl.setAttribute('aria-hidden', 'false');
  }

  position(element) {
    const rect = element.getBoundingClientRect();
    const tip = this.tooltipEl;

    tip.style.display = 'block';
    const tipRect = tip.getBoundingClientRect();

    const margin = 12;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    let top = rect.top + (rect.height / 2) - (tipRect.height / 2);
    let left = rect.right + margin;
    let placeOnLeft = false;

    // Flip to left if overflowing right viewport
    if (left + tipRect.width > viewportWidth - 10) {
      left = rect.left - tipRect.width - margin;
      placeOnLeft = true;
    }

    // Keep within vertical bounds
    if (top < 10) {
      top = 10;
    } else if (top + tipRect.height > viewportHeight - 10) {
      top = viewportHeight - tipRect.height - 10;
    }

    tip.style.top = `${Math.round(top)}px`;
    tip.style.left = `${Math.round(left)}px`;

    // Position arrow pointing at the center of the hovered element
    const arrowTop = Math.max(14, Math.min(tipRect.height - 14, (rect.top + rect.height / 2) - top));
    this.arrowEl.style.top = `${Math.round(arrowTop)}px`;

    if (placeOnLeft) {
      this.tooltipEl.classList.add('on-left');
      this.tooltipEl.classList.remove('on-right');
    } else {
      this.tooltipEl.classList.add('on-right');
      this.tooltipEl.classList.remove('on-left');
    }
  }

  hide() {
    clearTimeout(this.showTimer);
    if (!this.tooltipEl) return;
    this.tooltipEl.classList.remove('visible');
    this.tooltipEl.setAttribute('aria-hidden', 'true');
    this.activeKey = null;
    this.activeElement = null;
  }
}

export const paramTooltipController = new ParamTooltipController();

export function initParamTooltips() {
  paramTooltipController.init();
}
