function calc = helical_kinematics_and_stress(params)
%HELICAL_KINEMATICS_AND_STRESS Complete kinematic, geometric, and stress
%   analysis for an external Helical Gear drive in a multi-pinion pitch drive.
%
%   Standards: AGMA 2001-D04 / ISO 6336
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1
        error('helical_kinematics_and_stress requires params struct');
    end

    %% 1. Unpack Design Inputs
    mn          = params.mn;            % Normal module [mm]
    Np          = params.Np;            % Pinion tooth count
    Ng          = params.Ng;            % Central gear tooth count
    
    % Tooth angle (Helix angle beta)
    if isfield(params, 'tooth_angle_deg')
        beta_deg = params.tooth_angle_deg;
    elseif isfield(params, 'helix_angle_deg')
        beta_deg = params.helix_angle_deg;
    elseif isfield(params, 'beta_deg')
        beta_deg = params.beta_deg;
    else
        beta_deg = 15.0;
    end

    phi_n_deg   = params.phi_n_deg;     % Normal pressure angle [deg]
    n_pinions   = params.n_pinions;     % Number of driving pinions around ring
    F           = params.F;             % Face width [mm]

    T_in_ring   = params.T_in_ring;     % Ring input torque [N*m]
    n_in_ring   = params.n_in_ring;     % Ring speed [RPM]

    if isfield(params, 'eta')
        eta = params.eta;
    else
        eta = 1.0;                      % Direct nominal transmission
    end

    %% 2. Basic Angles & Modules
    beta        = deg2rad(beta_deg);
    phi_n       = deg2rad(phi_n_deg);

    % Transverse module
    mt          = mn / cos(beta);

    % Transverse pressure angle
    tan_phi_t   = tan(phi_n) / cos(beta);
    phi_t       = atan(tan_phi_t);
    phi_t_deg   = rad2deg(phi_t);

    i_ratio     = Ng / Np;

    %% 3. Pitch & Reference Cylinders
    dp          = mt * Np;              % Pinion pitch diameter [mm]
    dg          = mt * Ng;              % Central gear pitch diameter [mm]
    rp_p        = dp / 2;
    rp_g        = dg / 2;

    % Center distance (parallel shafts)
    C           = (dp + dg) / 2;

    % Base diameters
    db_p        = dp * cos(phi_t);
    db_g        = dg * cos(phi_t);
    rb_p        = db_p / 2;
    rb_g        = db_g / 2;

    %% 4. Standard Tooth Proportions (Normal Plane)
    % Full-depth standard ISO / AGMA
    a_p         = 1.00 * mn;
    a_g         = 1.00 * mn;
    b_p         = 1.25 * mn;
    b_g         = 1.25 * mn;
    hw          = a_p + a_g;            % Working depth = 2.0 * mn
    ht          = a_p + b_p;            % Whole depth = 2.25 * mn
    c_std       = b_p - a_p;            % Clearance = 0.25 * mn

    % Standard tooth thickness (normal plane)
    sn_p        = (pi * mn) / 2;
    sn_g        = (pi * mn) / 2;

    % Transverse tooth thickness
    st_p        = sn_p / cos(beta);
    st_g        = sn_g / cos(beta);

    % Outside (tip) and root diameters
    da_p        = dp + 2 * a_p;
    da_g        = dg + 2 * a_g;
    ra_p        = da_p / 2;
    ra_g        = da_g / 2;

    dd_p        = dp - 2 * b_p;
    dd_g        = dg - 2 * b_g;
    rd_p        = dd_p / 2;
    rd_g        = dd_g / 2;

    %% 5. Virtual Teeth & Equivalent Cylinders (Normal Plane)
    Nvn_p       = Np / (cos(beta)^3);
    Nvn_g       = Ng / (cos(beta)^3);

    %% 6. Contact Ratios (Transverse, Face, and Total)
    % Transverse base pitch
    p_bt        = pi * mt * cos(phi_t);

    % Transverse length of action
    g_alpha     = sqrt(ra_p^2 - rb_p^2) + sqrt(ra_g^2 - rb_g^2) - C * sin(phi_t);
    eps_alpha   = g_alpha / p_bt;       % Transverse contact ratio

    % Axial pitch and Face contact ratio (overlap ratio)
    p_x         = (pi * mn) / sin(beta);
    eps_beta    = (F * sin(beta)) / (pi * mn); % Overlap ratio

    % Total contact ratio
    eps_gamma   = eps_alpha + eps_beta;

    %% 7. Drivetrain Kinematics & Torques
    n_pinion_out    = n_in_ring * i_ratio;
    T_ring_per_mesh = T_in_ring / n_pinions;
    T_pinion_each   = (T_ring_per_mesh / i_ratio) * eta;
    P_in_total      = (T_in_ring * 2 * pi * n_in_ring) / 60;
    P_out_each      = (T_pinion_each * 2 * pi * n_pinion_out) / 60;

    %% 8. Mesh Forces (3D Components)
    % Tangential force on pitch cylinder
    Ft          = (2 * T_ring_per_mesh * 1000) / dg; % [N]
    % Radial separating force
    Fr          = Ft * tan(phi_t);                   % [N]
    % Axial thrust force due to tooth angle
    Fa          = Ft * tan(beta);                    % [N]
    % Resultant 3D vector force
    F_resultant = sqrt(Ft^2 + Fr^2 + Fa^2);

    %% 9. AGMA / ISO 6336 Bending Stress Analysis
    % Form factor based on virtual teeth
    Y_F_p       = 0.154 - 0.912 / Nvn_p;
    Y_F_g       = 0.154 - 0.912 / Nvn_g;

    % Helix angle factor for bending
    Y_beta      = 1 - (beta_deg / 120);

    sigma_b_p   = (Ft / (F * mn * Y_F_p)) * Y_beta;
    sigma_b_g   = (Ft / (F * mn * Y_F_g)) * Y_beta;

    %% 10. AGMA / ISO 6336 Contact (Hertzian) Stress Analysis
    E_mod       = 206000; % Steel [MPa]
    nu          = 0.30;
    Z_E         = sqrt(E_mod / (2 * pi * (1 - nu^2))); % Elasticity factor ~ 189.8

    % Zone factor
    Z_H         = sqrt((2 * cos(beta)) / (cos(phi_t)^2 * sin(phi_t)));

    % Helix factor for contact stress
    Z_beta      = sqrt(cos(beta));

    % Contact ratio factor
    Z_eps       = sqrt((4 - eps_alpha) / 3);

    u           = i_ratio;
    sigma_H     = Z_H * Z_E * Z_eps * Z_beta * sqrt((Ft / (dp * F)) * ((u + 1) / u));

    %% 11. Pack Results Structure
    calc = struct();
    calc.gear_type      = 'helical';
    calc.mn             = mn;
    calc.Np             = Np;
    calc.Ng             = Ng;
    calc.tooth_angle_deg= beta_deg;
    calc.beta_deg       = beta_deg;
    calc.beta           = beta;
    calc.phi_n_deg      = phi_n_deg;
    calc.phi_n          = phi_n;
    calc.phi_t_deg      = phi_t_deg;
    calc.phi_t          = phi_t;
    calc.mt             = mt;
    calc.n_pinions      = n_pinions;
    calc.i_ratio        = i_ratio;
    calc.F              = F;
    calc.center_dist    = C;

    calc.dp             = dp;
    calc.dg             = dg;
    calc.rp_p           = rp_p;
    calc.rp_g           = rp_g;
    calc.db_p           = db_p;
    calc.db_g           = db_g;
    calc.rb_p           = rb_p;
    calc.rb_g           = rb_g;

    calc.a_p            = a_p;
    calc.a_g            = a_g;
    calc.b_p            = b_p;
    calc.b_g            = b_g;
    calc.hw             = hw;
    calc.ht             = ht;
    calc.c_std          = c_std;

    calc.sn_p           = sn_p;
    calc.sn_g           = sn_g;
    calc.st_p           = st_p;
    calc.st_g           = st_g;

    calc.da_p           = da_p;
    calc.da_g           = da_g;
    calc.ra_p           = ra_p;
    calc.ra_g           = ra_g;
    calc.dd_p           = dd_p;
    calc.dd_g           = dd_g;
    calc.rd_p           = rd_p;
    calc.rd_g           = rd_g;

    calc.Nvn_p          = Nvn_p;
    calc.Nvn_g          = Nvn_g;

    calc.p_bt           = p_bt;
    calc.g_alpha        = g_alpha;
    calc.eps_alpha      = eps_alpha;
    calc.p_x            = p_x;
    calc.eps_beta       = eps_beta;
    calc.eps_gamma      = eps_gamma;

    calc.T_in_ring      = T_in_ring;
    calc.n_in_ring      = n_in_ring;
    calc.n_pinion_out   = n_pinion_out;
    calc.T_ring_per_mesh= T_ring_per_mesh;
    calc.T_pinion_each  = T_pinion_each;
    calc.P_in_total     = P_in_total;
    calc.P_out_each     = P_out_each;

    calc.Ft             = Ft;
    calc.Fr             = Fr;
    calc.Fa             = Fa;
    calc.F_resultant    = F_resultant;

    calc.sigma_b_p      = sigma_b_p;
    calc.sigma_b_g      = sigma_b_g;
    calc.sigma_H        = sigma_H;
end
