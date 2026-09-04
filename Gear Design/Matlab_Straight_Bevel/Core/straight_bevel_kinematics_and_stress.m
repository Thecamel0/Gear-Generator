function calc = straight_bevel_kinematics_and_stress(params)
%STRAIGHT_BEVEL_KINEMATICS_AND_STRESS Complete kinematic, geometric, and stress analysis
%   for a Straight Bevel Gear pitch actuator drive (Orthogonal 90 deg shafts, multi-pinion).
%
%   Follows Gleason Straight Bevel standards and AGMA 2005-D03 / ISO 10300.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1 || isempty(params), params = struct(); end

    % 1. Default Pitch Control System Parameters
    m           = get_field(params, 'm', 3.0);          % Module [mm]
    Np          = get_field(params, 'Np', 16);          % Pinion tooth count
    Ng          = get_field(params, 'Ng', 48);          % Gear tooth count
    phi_deg     = get_field(params, 'phi_deg', 20.0);   % Pressure angle [deg]
    Sigma_deg   = get_field(params, 'Sigma_deg', 90.0); % Shaft angle [deg] (Orthogonal)
    n_pinions   = get_field(params, 'n_pinions', 3);    % Number of driving pinions
    F_in        = get_field(params, 'F', 25.0);         % Face width [mm]

    T_in_ring   = get_field(params, 'T_in_ring', 20.0); % Input torque on ring [N*m]
    n_in_ring   = get_field(params, 'n_in_ring', 100.0);% Input speed [RPM]
    eta         = get_field(params, 'eta', 0.97);       % Mechanical efficiency
    sigma_allow_bend    = get_field(params, 'sigma_allow_bend', 250.0);     % [MPa]
    sigma_allow_contact = get_field(params, 'sigma_allow_contact', 1500.0); % [MPa]

    phi = phi_deg * pi / 180;
    Sigma = Sigma_deg * pi / 180;

    % 2. Kinematic Ratio & Pitch Cone Angles
    i_ratio = Ng / Np;
    gamma_p = atan(sin(Sigma) / (i_ratio + cos(Sigma)));
    gamma_g = Sigma - gamma_p;

    gamma_p_deg = gamma_p * 180 / pi;
    gamma_g_deg = gamma_g * 180 / pi;

    % 3. Pitch Diameters & Outer Cone Distance
    dp = m * Np;            % 48.0 mm
    dg = m * Ng;            % 144.0 mm
    rp_p = dp / 2;          % 24.0 mm
    rp_g = dg / 2;          % 72.0 mm

    Ao = rp_p / sin(gamma_p); % Outer cone distance [mm] (75.895 mm)

    % Recommended face width: F <= min(Ao/3, 10*m)
    F_max = min(Ao / 3, 10 * m);
    F = min(F_in, F_max);

    Ai = Ao - F;            % Inner cone distance [mm]
    Am = Ao - F / 2;        % Mean cone distance [mm]

    % 4. Mean Pitch Diameters
    dmp = dp * (Am / Ao);
    dmg = dg * (Am / Ao);
    rm_p = dmp / 2;
    rm_g = dmg / 2;

    % 5. Gleason Standard Tooth Proportions (Straight Bevel)
    a_p = 1.00 * m;         % Pinion addendum [mm]
    a_g = 1.00 * m;         % Gear addendum [mm]
    b_p = 1.25 * m;         % Pinion dedendum [mm]
    b_g = 1.25 * m;         % Gear dedendum [mm]
    hw  = a_p + a_g;        % Working depth = 2.0*m = 6.0 mm
    ht  = a_p + b_p;        % Whole depth   = 2.25*m = 6.75 mm
    c_std = b_p - a_p;      % Clearance     = 0.25*m = 0.75 mm

    % Circular tooth thickness at pitch circle
    s_p = pi * m / 2;       % 4.712 mm
    s_g = pi * m / 2;       % 4.712 mm

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

    % 6. Tredgold Back Cone & Virtual Equivalent Gears
    % Virtual tooth count: Nv = N / cos(gamma)
    Nvp = Np / cos(gamma_p);
    Nvg = Ng / cos(gamma_g);

    rv_p = rp_p / cos(gamma_p);   % Back cone pitch radius
    rv_g = rp_g / cos(gamma_g);

    rvb_p = rv_p * cos(phi);      % Virtual base radius
    rvb_g = rv_g * cos(phi);

    rva_p = rv_p + a_p;           % Virtual tip radius
    rva_g = rv_g + a_g;

    rvd_p = rv_p - b_p;           % Virtual root radius
    rvd_g = rv_g - b_g;

    % Transverse Contact Ratio (Tredgold formulation)
    pb = pi * m * cos(phi);
    L_contact = sqrt(rva_p^2 - rvb_p^2) + sqrt(rva_g^2 - rvb_g^2) - (rv_p + rv_g) * sin(phi);
    CR = L_contact / pb;

    % 7. Torques, Speeds, and Powers
    P_in_total = T_in_ring * (2 * pi * n_in_ring / 60); % Watts
    n_pinion_out = n_in_ring * i_ratio;                 % Pinion output speed [RPM]

    % Load sharing across multi-pinions
    T_ring_per_mesh = T_in_ring / n_pinions;
    T_pinion_each   = (T_ring_per_mesh / i_ratio) * eta;
    P_out_each      = T_pinion_each * (2 * pi * n_pinion_out / 60);

    % 8. Mesh Forces at Mean Cone Radius (rm_g)
    Ft = T_ring_per_mesh / (rm_g * 1e-3);               % Tangential Force [N]
    Fr_p = Ft * tan(phi) * cos(gamma_p);                % Pinion Radial (Separating) [N]
    Fa_p = Ft * tan(phi) * sin(gamma_p);                % Pinion Thrust (Axial) [N]
    Fr_g = Fa_p;                                        % Gear Radial = Pinion Axial [N]
    Fa_g = Fr_p;                                        % Gear Thrust = Pinion Radial [N]
    F_resultant = sqrt(Ft^2 + Fr_p^2 + Fa_p^2);

    % 9. AGMA / Lewis Bending Stress Calculation
    % Lewis form factor Y based on virtual teeth
    Y_p = 0.154 - 0.912 / Nvp;
    Y_g = 0.154 - 0.912 / Nvg;

    % Bending stress: sigma_b = Ft / (F * m * Y) * (Ao / Am)
    bevel_factor = Ao / Am;
    sigma_b_p = (Ft / (F * m * Y_p)) * bevel_factor;
    sigma_b_g = (Ft / (F * m * Y_g)) * bevel_factor;

    SF_b_p = sigma_allow_bend / max(sigma_b_p, 1e-6);
    SF_b_g = sigma_allow_bend / max(sigma_b_g, 1e-6);

    % 10. Hertzian Contact Stress Calculation (AGMA Bevel Contact)
    E_mod = 206000; % Steel Elastic Modulus [MPa]
    nu = 0.30;
    E_star = E_mod / (2 * (1 - nu^2));

    rho_p = rvb_p * tan(phi);
    rho_g = rvb_g * tan(phi);
    rho_eq = (rho_p * rho_g) / (rho_p + rho_g);

    sigma_H = sqrt((Ft / (pi * F * cos(phi))) * (E_star / rho_eq) * bevel_factor);
    SF_contact = sigma_allow_contact / max(sigma_H, 1e-6);

    % 11. Package Output Struct
    calc = struct();
    calc.gear_type      = 'straight_bevel';
    calc.m              = m;
    calc.Np             = Np;
    calc.Ng             = Ng;
    calc.phi_deg        = phi_deg;
    calc.phi            = phi;
    calc.Sigma_deg      = Sigma_deg;
    calc.Sigma          = Sigma;
    calc.n_pinions      = n_pinions;
    calc.i_ratio        = i_ratio;

    calc.gamma_p_deg    = gamma_p_deg;
    calc.gamma_g_deg    = gamma_g_deg;
    calc.gamma_p        = gamma_p;
    calc.gamma_g        = gamma_g;

    calc.dp             = dp;
    calc.dg             = dg;
    calc.rp_p           = rp_p;
    calc.rp_g           = rp_g;
    calc.Ao             = Ao;
    calc.F              = F;
    calc.Ai             = Ai;
    calc.Am             = Am;
    calc.dmp            = dmp;
    calc.dmg            = dmg;
    calc.rm_p           = rm_p;
    calc.rm_g           = rm_g;

    calc.a_p            = a_p;
    calc.a_g            = a_g;
    calc.b_p            = b_p;
    calc.b_g            = b_g;
    calc.hw             = hw;
    calc.ht             = ht;
    calc.c_std          = c_std;
    calc.s_p            = s_p;
    calc.s_g            = s_g;

    calc.delta_ap       = delta_ap;
    calc.delta_ag       = delta_ag;
    calc.delta_dp       = delta_dp;
    calc.delta_dg       = delta_dg;
    calc.gamma_ap       = gamma_ap;
    calc.gamma_ag       = gamma_ag;
    calc.gamma_dp       = gamma_dp;
    calc.gamma_dg       = gamma_dg;

    calc.da_p           = da_p;
    calc.da_g           = da_g;
    calc.ra_p           = ra_p;
    calc.ra_g           = ra_g;
    calc.dd_p           = dd_p;
    calc.dd_g           = dd_g;
    calc.rd_p           = rd_p;
    calc.rd_g           = rd_g;

    calc.Nvp            = Nvp;
    calc.Nvg            = Nvg;
    calc.rv_p           = rv_p;
    calc.rv_g           = rv_g;
    calc.rvb_p          = rvb_p;
    calc.rvb_g          = rvb_g;
    calc.rva_p          = rva_p;
    calc.rva_g          = rva_g;
    calc.rvd_p          = rvd_p;
    calc.rvd_g          = rvd_g;

    calc.CR             = CR;
    calc.L_contact      = L_contact;
    calc.pb             = pb;

    calc.T_in_ring      = T_in_ring;
    calc.n_in_ring      = n_in_ring;
    calc.n_pinion_out   = n_pinion_out;
    calc.T_ring_per_mesh= T_ring_per_mesh;
    calc.T_pinion_each  = T_pinion_each;
    calc.P_in_total     = P_in_total;
    calc.P_out_each     = P_out_each;

    calc.Ft             = Ft;
    calc.Fr_p           = Fr_p;
    calc.Fa_p           = Fa_p;
    calc.Fr_g           = Fr_g;
    calc.Fa_g           = Fa_g;
    calc.F_resultant    = F_resultant;

    calc.sigma_b_p      = sigma_b_p;
    calc.sigma_b_g      = sigma_b_g;
    calc.SF_b_p         = SF_b_p;
    calc.SF_b_g         = SF_b_g;
    calc.sigma_H        = sigma_H;
    calc.SF_contact     = SF_contact;
end

function val = get_field(s, field, default_val)
    if isfield(s, field) && ~isempty(s.(field))
        val = s.(field);
    else
        val = default_val;
    end
end
