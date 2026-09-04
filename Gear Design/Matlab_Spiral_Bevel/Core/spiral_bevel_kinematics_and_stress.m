function calc = spiral_bevel_kinematics_and_stress(params)
%SPIRAL_BEVEL_KINEMATICS_AND_STRESS Complete kinematic, geometric, and stress analysis
%   for a Spiral Bevel Gear pitch actuator drive (Orthogonal 90 deg shafts, multi-pinion).
%
%   Standards:
%     - AGMA 2005-D03 / ISO 23509 (Bevel and Hypoid Gear Geometry)
%     - Gleason Spiral Bevel Gear System (Standard 35 deg Mean Spiral Angle)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 1 || isempty(params), params = struct(); end

    % 1. Primary Design Parameters (Directives: eta & sigma_allow removed from inputs)
    m               = get_field(params, 'm', 3.0);                 % Module [mm]
    Np              = get_field(params, 'Np', 16);                 % Pinion tooth count
    Ng              = get_field(params, 'Ng', 48);                 % Gear tooth count (1:3 ratio)
    phi_n_deg       = get_field(params, 'phi_n_deg', 20.0);        % Normal pressure angle [deg]
    tooth_angle_deg = get_field(params, 'tooth_angle_deg', 35.0);  % Mean spiral angle beta_m [deg]
    Sigma_deg       = get_field(params, 'Sigma_deg', 90.0);        % Shaft angle [deg] (Orthogonal)
    n_pinions       = get_field(params, 'n_pinions', 3);           % Number of driving pinions (120 deg spacing)
    F_in            = get_field(params, 'F', 25.0);                % Face width [mm]
    r_cutter_in     = get_field(params, 'r_cutter', []);           % Cutter radius [mm]
    hand_pinion     = get_field(params, 'hand_pinion', 1);         % +1: Right-Hand (RH), -1: Left-Hand (LH)

    T_in_ring       = get_field(params, 'T_in_ring', 20.0);        % Input torque on ring [N*m]
    n_in_ring       = get_field(params, 'n_in_ring', 100.0);       % Input speed [RPM]

    % Standard internal engineering constants (not exposed in user parameter struct)
    eta_internal         = 0.97;    % Mechanical mesh efficiency
    sigma_allow_bend     = 250.0;   % Allowable bending fatigue strength [MPa] (Carburized/Alloy Steel)
    sigma_allow_contact  = 1500.0;  % Allowable surface contact fatigue limit [MPa]

    phi_n = phi_n_deg * pi / 180;
    beta_m = tooth_angle_deg * pi / 180;
    Sigma = Sigma_deg * pi / 180;

    % 2. Kinematic Ratio & Pitch Cone Angles
    i_ratio = Ng / Np;
    gamma_p = atan(sin(Sigma) / (i_ratio + cos(Sigma)));
    gamma_g = Sigma - gamma_p;

    gamma_p_deg = gamma_p * 180 / pi;
    gamma_g_deg = gamma_g * 180 / pi;

    % 3. Pitch Diameters & Cone Distances
    dp = m * Np;            % 48.0 mm (Pinion outer pitch diameter)
    dg = m * Ng;            % 144.0 mm (Gear outer pitch diameter)
    rp_p = dp / 2;          % 24.0 mm
    rp_g = dg / 2;          % 72.0 mm

    Ao = rp_p / sin(gamma_p); % Outer cone distance [mm] (75.895 mm)

    % Recommended Gleason face width: F <= min(Ao/3, 10*m)
    F_max = min(Ao / 3, 10 * m);
    F = min(F_in, F_max);

    Ai = Ao - F;            % Inner cone distance [mm]
    Am = Ao - F / 2;        % Mean cone distance [mm]

    % Mean Pitch Diameters
    dmp = dp * (Am / Ao);
    dmg = dg * (Am / Ao);
    rm_p = dmp / 2;
    rm_g = dmg / 2;

    % Spiral Angles across face width (Gleason relation)
    % tan(beta) = tan(beta_m) * (A / Am)
    beta_o = atan(tan(beta_m) * (Ao / Am));
    beta_i = atan(tan(beta_m) * (Ai / Am));
    beta_o_deg = beta_o * 180 / pi;
    beta_i_deg = beta_i * 180 / pi;

    % Transverse pressure angle at mean cone
    tan_phi_t = tan(phi_n) / cos(beta_m);
    phi_t = atan(tan_phi_t);
    phi_t_deg = phi_t * 180 / pi;

    % Mean normal and transverse module
    mt_m = m * (Am / Ao);
    mn_m = mt_m * cos(beta_m);

    % Nominal Gleason cutter radius
    if isempty(r_cutter_in) || r_cutter_in <= 0
        % Gleason standard nominal cutter radius based on mean cone distance
        r_cutter = 1.10 * Am * sin(beta_m);
        if r_cutter < 30.0, r_cutter = 40.0; end
        if r_cutter > 100.0, r_cutter = 75.0; end
    else
        r_cutter = r_cutter_in;
    end

    % 4. Gleason Standard Tooth Proportions (Spiral Bevel System)
    % Full depth proportions:
    hw  = 1.700 * m;        % Working depth [mm]
    ht  = 1.888 * m;        % Whole depth [mm]
    c_std = ht - hw;        % Clearance [mm] = 0.188*m

    % Gleason long-and-short addendum for 1:3 ratio
    a_p = 0.54 * hw;        % Pinion addendum [mm]
    a_g = hw - a_p;         % Gear addendum [mm]
    b_p = ht - a_p;         % Pinion dedendum [mm]
    b_g = ht - a_g;         % Gear dedendum [mm]

    % Mean addendums & dedendums
    a_mp = a_p * (Am / Ao);
    a_mg = a_g * (Am / Ao);
    b_mp = b_p * (Am / Ao);
    b_mg = b_g * (Am / Ao);

    % Circular tooth thickness at mean cone (normal and transverse)
    sn_mp = (pi * mn_m / 2) + (a_mp - a_mg) * tan(phi_n);
    sn_mg = pi * mn_m - sn_mp;
    st_mp = sn_mp / cos(beta_m);
    st_mg = sn_mg / cos(beta_m);

    % Outer tooth thickness
    s_p = st_mp * (Ao / Am);
    s_g = st_mg * (Ao / Am);

    % Addendum and Dedendum angles
    delta_ap = atan(a_p / Ao);
    delta_ag = atan(a_g / Ao);
    delta_dp = atan(b_p / Ao);
    delta_dg = atan(b_g / Ao);

    % Face Cone Angles (Tip) and Root Cone Angles
    gamma_ap = gamma_p + delta_ap;
    gamma_ag = gamma_g + delta_ag;
    gamma_dp = gamma_p - delta_dp;
    gamma_dg = gamma_g - delta_dg;

    gamma_ap_deg = gamma_ap * 180 / pi;
    gamma_ag_deg = gamma_ag * 180 / pi;
    gamma_dp_deg = gamma_dp * 180 / pi;
    gamma_dg_deg = gamma_dg * 180 / pi;

    % Outer Tip Diameters (Heel)
    da_p = dp + 2 * a_p * cos(gamma_p);
    da_g = dg + 2 * a_g * cos(gamma_g);
    ra_p = da_p / 2;
    ra_g = da_g / 2;

    % Outer Root Diameters (Heel)
    dd_p = dp - 2 * b_p * cos(gamma_p);
    dd_g = dg - 2 * b_g * cos(gamma_g);
    rd_p = dd_p / 2;
    rd_g = dd_g / 2;

    % 5. Tredgold Back Cone & Virtual Equivalent Gears
    % Virtual tooth count for spiral bevel: Nv = N / (cos(gamma) * cos^3(beta_m))
    Nvp = Np / (cos(gamma_p) * cos(beta_m)^3);
    Nvg = Ng / (cos(gamma_g) * cos(beta_m)^3);

    rv_p = rm_p / cos(gamma_p);     % Back cone pitch radius
    rv_g = rm_g / cos(gamma_g);

    rvb_p = rv_p * cos(phi_t);      % Virtual base radius
    rvb_g = rv_g * cos(phi_t);

    rva_p = rv_p + a_mp;            % Virtual tip radius
    rva_g = rv_g + a_mg;

    rvd_p = rv_p - b_mp;            % Virtual root radius
    rvd_g = rv_g - b_mg;

    % 6. Contact Ratios (AGMA 2005-D03 / ISO 23509)
    % Transverse Contact Ratio (Involute action)
    p_bt = pi * mt_m * cos(phi_t);
    L_contact = sqrt(max(0, rva_p^2 - rvb_p^2)) + sqrt(max(0, rva_g^2 - rvb_g^2)) - (rv_p + rv_g) * sin(phi_t);
    eps_alpha = L_contact / p_bt;

    % Face Overlap Ratio (Spiral action): eps_beta = F * sin(beta_m) / (pi * mn_m)
    eps_beta = (F * sin(beta_m)) / (pi * mn_m);

    % Total Contact Ratio (Spiral bevel standard): eps_gamma = sqrt(eps_alpha^2 + eps_beta^2)
    eps_gamma = sqrt(eps_alpha^2 + eps_beta^2);
    CR = eps_gamma;

    % 7. Multi-Pinion Kinematics & Torques
    n_pinion_out = n_in_ring * i_ratio;                     % Pinion speed = 300 RPM
    T_ring_per_mesh = T_in_ring / n_pinions;                % 6.67 N*m per mesh
    T_pinion_each = T_ring_per_mesh / (i_ratio * eta_internal); % Pinion driving torque = 2.29 N*m

    P_in_total = (2 * pi * n_in_ring * T_in_ring) / 60;     % Total input power [W]
    P_out_each = (P_in_total * eta_internal) / n_pinions;   % Output power per pinion [W]

    % 8. 3D Gear Mesh Forces (AGMA 2005-D03 for Spiral Bevel Gears)
    % Tangential load at mean pitch diameter
    Ft = (2000 * T_pinion_each) / dmp;                      % [N]

    % For driving pinion (RH, counter-clockwise forward rotation):
    % Thrust (Axial) force:
    Fa_p = (Ft / cos(beta_m)) * (tan(phi_n) * sin(gamma_p) - hand_pinion * sin(beta_m) * cos(gamma_p));
    % Separating (Radial) force:
    Fr_p = (Ft / cos(beta_m)) * (tan(phi_n) * cos(gamma_p) + hand_pinion * sin(beta_m) * sin(gamma_p));

    % Driven gear forces (Orthogonal 90 deg mesh: gear axial = pinion radial, gear radial = pinion axial)
    Fa_g = Fr_p;
    Fr_g = Fa_p;

    % Resultant tooth mesh force
    F_resultant = sqrt(Ft^2 + Fr_p^2 + Fa_p^2);

    % 9. AGMA Bending & Contact Stress Analysis
    % AGMA Lewis Form Factors for virtual teeth
    yp = 0.154 - 0.912 / Nvp;
    yg = 0.154 - 0.912 / Nvg;
    Yp = pi * yp;
    Yg = pi * yg;

    Kv = 1.15;  % Dynamic factor (High precision ground spiral bevel)
    Ko = 1.25;  % Overload factor (Wind turbine pitch actuation duty cycle)
    Km = 1.30;  % Load distribution factor

    % Tooth bending stress [MPa]
    sigma_b_p = (Ft / (F * mt_m * Yp)) * Kv * Ko * Km;
    sigma_b_g = (Ft / (F * mt_m * Yg)) * Kv * Ko * Km;

    SF_b_p = sigma_allow_bend / max(sigma_b_p, 1e-6);
    SF_b_g = sigma_allow_bend / max(sigma_b_g, 1e-6);

    % Hertzian Surface Contact Stress [MPa]
    E_steel = 206000;   % [MPa]
    nu_steel = 0.30;
    ZE = sqrt(E_steel / (2 * pi * (1 - nu_steel^2))); % Elastic coefficient = 189.8 MPa^0.5

    I_factor = (sin(phi_t) * cos(phi_t) / 2) * (i_ratio / (i_ratio + 1));
    sigma_H = ZE * sqrt((Ft / (dmp * F * I_factor)) * Kv * Ko * Km);

    SF_contact = sigma_allow_contact / max(sigma_H, 1e-6);

    % 10. Package Output Struct
    calc = struct();
    calc.gear_type       = 'spiral-bevel';
    calc.m               = m;
    calc.Np              = Np;
    calc.Ng              = Ng;
    calc.phi_n_deg       = phi_n_deg;
    calc.phi_n           = phi_n;
    calc.phi_t_deg       = phi_t_deg;
    calc.phi_t           = phi_t;
    calc.tooth_angle_deg = tooth_angle_deg;
    calc.beta_m_deg      = tooth_angle_deg;
    calc.beta_m          = beta_m;
    calc.beta_o_deg      = beta_o_deg;
    calc.beta_i_deg      = beta_i_deg;
    calc.hand_pinion     = hand_pinion;
    calc.Sigma_deg       = Sigma_deg;
    calc.Sigma           = Sigma;
    calc.n_pinions       = n_pinions;
    calc.i_ratio         = i_ratio;
    calc.r_cutter        = r_cutter;

    calc.dp              = dp;
    calc.dg              = dg;
    calc.rp_p            = rp_p;
    calc.rp_g            = rp_g;
    calc.dmp             = dmp;
    calc.dmg             = dmg;
    calc.rm_p            = rm_p;
    calc.rm_g            = rm_g;

    calc.Ao              = Ao;
    calc.Ai              = Ai;
    calc.Am              = Am;
    calc.F               = F;

    calc.gamma_p         = gamma_p;
    calc.gamma_g         = gamma_g;
    calc.gamma_p_deg     = gamma_p_deg;
    calc.gamma_g_deg     = gamma_g_deg;

    calc.gamma_ap_deg    = gamma_ap_deg;
    calc.gamma_ag_deg    = gamma_ag_deg;
    calc.gamma_dp_deg    = gamma_dp_deg;
    calc.gamma_dg_deg    = gamma_dg_deg;

    calc.hw              = hw;
    calc.ht              = ht;
    calc.c_std           = c_std;

    calc.a_p             = a_p;
    calc.a_g             = a_g;
    calc.b_p             = b_p;
    calc.b_g             = b_g;

    calc.da_p            = da_p;
    calc.da_g            = da_g;
    calc.ra_p            = ra_p;
    calc.ra_g            = ra_g;
    calc.dd_p            = dd_p;
    calc.dd_g            = dd_g;
    calc.rd_p            = rd_p;
    calc.rd_g            = rd_g;

    calc.s_p             = s_p;
    calc.s_g             = s_g;
    calc.st_mp           = st_mp;
    calc.st_mg           = st_mg;

    calc.Nvp             = Nvp;
    calc.Nvg             = Nvg;
    calc.rv_p            = rv_p;
    calc.rv_g            = rv_g;
    calc.rvb_p           = rvb_p;
    calc.rvb_g           = rvb_g;
    calc.rva_p           = rva_p;
    calc.rva_g           = rva_g;
    calc.rvd_p           = rvd_p;
    calc.rvd_g           = rvd_g;

    calc.eps_alpha       = eps_alpha;
    calc.eps_beta        = eps_beta;
    calc.eps_gamma       = eps_gamma;
    calc.CR              = CR;
    calc.L_contact       = L_contact;
    calc.p_bt            = p_bt;

    calc.T_in_ring       = T_in_ring;
    calc.n_in_ring       = n_in_ring;
    calc.n_pinion_out    = n_pinion_out;
    calc.T_ring_per_mesh = T_ring_per_mesh;
    calc.T_pinion_each   = T_pinion_each;
    calc.P_in_total      = P_in_total;
    calc.P_out_each      = P_out_each;

    calc.Ft              = Ft;
    calc.Fr_p            = Fr_p;
    calc.Fa_p            = Fa_p;
    calc.Fr_g            = Fr_g;
    calc.Fa_g            = Fa_g;
    calc.F_resultant     = F_resultant;

    calc.sigma_b_p       = sigma_b_p;
    calc.sigma_b_g       = sigma_b_g;
    calc.SF_b_p          = SF_b_p;
    calc.SF_b_g          = SF_b_g;
    calc.sigma_H         = sigma_H;
    calc.SF_contact      = SF_contact;
end

function val = get_field(s, fname, default_val)
    if isfield(s, fname) && ~isempty(s.(fname))
        val = s.(fname);
    else
        val = default_val;
    end
end
