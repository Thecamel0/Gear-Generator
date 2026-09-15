function calc = planetary_kinematics_and_stress(inputs)
%PLANETARY_KINEMATICS_AND_STRESS Computes geometry, kinematics, forces, and stresses
%   for a complete Epicyclic (Planetary) Gear Train: Sun Gear, K Planets, Internal Ring Gear, and Carrier.
%
%   Standard Arrangement: Stationary Ring Gear, Input Sun, Output Carrier.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-11

    if nargin < 1, inputs = struct(); end

    % 1. Primary Parameters
    m = 3.0;            if isfield(inputs, 'm'),           m = inputs.m; end
    Ns = 12;            if isfield(inputs, 'Ns'),          Ns = inputs.Ns; end
    Np = 18;            if isfield(inputs, 'Np'),          Np = inputs.Np; end
    K = 3;              if isfield(inputs, 'K'),           K = inputs.K; end
    if isfield(inputs, 'n_pinions'), K = inputs.n_pinions; end
    if isfield(inputs, 'n_planets'), K = inputs.n_planets; end
    phi_deg = 20.0;     if isfield(inputs, 'phi_deg'),     phi_deg = inputs.phi_deg; end
    F = 25.0;           if isfield(inputs, 'F'),           F = inputs.F; end

    % Operating conditions
    T_in_sun = 15.0;    if isfield(inputs, 'T_in_sun'),    T_in_sun = inputs.T_in_sun; end
    n_in_sun = 500.0;   if isfield(inputs, 'n_in_sun'),    n_in_sun = inputs.n_in_sun; end
    eta = 0.97;         if isfield(inputs, 'eta'),         eta = inputs.eta; end
    sigma_allow_bend = 250.0;
    sigma_allow_contact = 1500.0;

    phi = deg2rad(phi_deg);

    % 2. Kinematic Sizing Constraint: Nr = Ns + 2*Np
    Nr = Ns + 2 * Np;
    if isfield(inputs, 'Nr') && inputs.Nr ~= Nr
        warning('User specified Nr = %d, but coaxiality requires Nr = Ns + 2*Np = %d. Using %d.', ...
            inputs.Nr, Nr, Nr);
    end

    % 3. Pitch, Base, and Orbit Dimensions
    ds = m * Ns;        rp_s = ds / 2;
    dp = m * Np;        rp_p = dp / 2;
    dr = m * Nr;        rp_r = dr / 2;

    rb_s = rp_s * cos(phi);
    rb_p = rp_p * cos(phi);
    rb_r = rp_r * cos(phi);

    % Center distance / Carrier pin orbit radius
    C = (ds + dp) / 2;  % Center distance = rp_s + rp_p = (dr - dp)/2

    % 4. Assembly & Interference Conditions
    is_symmetric = (mod(Ns + Nr, K) == 0);
    assembly_index = (Ns + Nr) / K;

    % Adjacent planet tip clearance
    dist_planet_centers = 2 * C * sin(pi / K);

    % Standard Proportions
    a_s = 1.0 * m;      b_s = 1.25 * m;     % Sun addendum & dedendum
    a_p = 1.0 * m;      b_p = 1.25 * m;     % Planet addendum & dedendum
    a_r = 1.0 * m;      b_r = 1.25 * m;     % Ring internal addendum & dedendum

    ra_s = rp_s + a_s;  rd_s = max(rp_s - b_s, 0.25 * rb_s);
    ra_p = rp_p + a_p;  rd_p = max(rp_p - b_p, 0.25 * rb_p);
    ra_r_int = rp_r - a_r; % Ring crest (inner tip)
    rd_r_int = rp_r + b_r; % Ring trough (inner root)

    s_nom = (pi * m) / 2;
    s_s = s_nom;
    s_p = s_nom;
    s_r = s_nom;

    if isfield(inputs, 'ring_wall_thickness') && ~isempty(inputs.ring_wall_thickness)
        r_rim = rd_r_int + inputs.ring_wall_thickness;
    else
        r_rim = rd_r_int + 12.0; % Outer solid rim radius
    end
    D_outer = 2 * r_rim;

    % Carrier & Pin Dimensions
    r_pin = (rd_p * 0.45);            % Carrier pin radius fitting planet bore
    d_pin = 2 * r_pin;
    r_bore_planet = r_pin + 0.15;     % Clearance for pin bearing
    r_bore_sun = rp_s * 0.35;         % Central drive shaft bore
    if isfield(inputs, 'carrier_diameter') && ~isempty(inputs.carrier_diameter)
        r_carrier_disc = inputs.carrier_diameter / 2;
    else
        r_carrier_disc = C + rp_p * 0.65; % Carrier disc radius
    end
    if isfield(inputs, 'carrier_thickness') && ~isempty(inputs.carrier_thickness)
        carrier_thickness = inputs.carrier_thickness;
    else
        carrier_thickness = max(8.0, F * 0.35);
    end

    % Planet adjacent clearance
    da_p = 2 * ra_p;
    clearance_adjacent_planets = dist_planet_centers - da_p;
    has_clearance = (clearance_adjacent_planets > 0);

    % 5. Willis Transmission Kinematics (Stationary Ring: omega_r = 0)
    % Ratio i = omega_sun / omega_carrier = 1 + Nr / Ns
    i_ratio = 1 + (Nr / Ns);
    n_carrier_out = n_in_sun / i_ratio;
    
    % Planet relative rotation on carrier pin: omega_p/c = -omega_c * (Nr / Np)
    n_planet_relative = -n_carrier_out * (Nr / Np);
    n_planet_absolute = n_carrier_out + n_planet_relative;

    % 6. Torque, Power, & Force Distribution
    P_in_total = (T_in_sun * 2 * pi * n_in_sun) / 60;   % Watts
    T_carrier_out = T_in_sun * i_ratio * eta;           % N*m
    P_out_carrier = (T_carrier_out * 2 * pi * n_carrier_out) / 60;

    % AGMA 6123-B06 Load Sharing Factor K_gamma
    if K == 3
        K_gamma = 1.10;
    elseif K == 4
        K_gamma = 1.18;
    else
        K_gamma = 1.05 + 0.03 * K;
    end

    % Tangential tooth load at Sun-Planet mesh
    Ft = (2 * T_in_sun * 1000 / (ds * K)) * K_gamma;    % N
    Fr = Ft * tan(phi);                                 % N
    F_resultant = hypot(Ft, Fr);                        % N

    % 7. Transverse Contact Ratios
    pb = pi * m * cos(phi);

    % External mesh (Sun - Planet)
    L_sp = sqrt(max(0, ra_s^2 - rb_s^2)) + sqrt(max(0, ra_p^2 - rb_p^2)) - C * sin(phi);
    CR_sp = L_sp / pb;

    % Internal mesh (Planet - Ring)
    L_pr = sqrt(max(0, ra_p^2 - rb_p^2)) - sqrt(max(0, ra_r_int^2 - rb_r^2)) + C * sin(phi);
    CR_pr = L_pr / pb;

    % 8. Lewis Bending Stresses
    s_nom = (pi * m) / 2;
    Y_s = 0.484 - 2.87 / Ns;
    Y_p = 0.484 - 2.87 / Np;
    Y_r = 0.484 + 1.50 / Nr; % Internal tooth broader root

    sigma_b_s = Ft / (F * m * Y_s);
    % Planet is an idler experiencing fully reversed bending (+/- sigma)
    % Factor 1.4 applied to account for reversed fatigue stress
    sigma_b_p = (Ft * 1.4) / (F * m * Y_p);
    sigma_b_r = Ft / (F * m * Y_r);

    SF_b_s = sigma_allow_bend / max(sigma_b_s, 1e-6);
    SF_b_p = sigma_allow_bend / max(sigma_b_p, 1e-6);
    SF_b_r = sigma_allow_bend / max(sigma_b_r, 1e-6);

    % 9. Hertzian Contact Stresses
    E_mod = 206000; nu = 0.30;
    E_star = E_mod / (2 * (1 - nu^2));

    % Sun-Planet (External convex-convex)
    rho_s = rb_s * tan(phi);
    rho_p = rb_p * tan(phi);
    rho_sp_eq = (rho_s * rho_p) / (rho_s + rho_p);
    sigma_H_sp = sqrt((Ft / (pi * F * cos(phi))) * (E_star / rho_sp_eq));
    SF_contact_sp = sigma_allow_contact / max(sigma_H_sp, 1e-6);

    % Planet-Ring (Internal concave-convex)
    rho_r = rb_r * tan(phi);
    rho_pr_eq = (rho_p * rho_r) / max(rho_r - rho_p, 1e-3);
    sigma_H_pr = sqrt((Ft / (pi * F * cos(phi))) * (E_star / rho_pr_eq));
    SF_contact_pr = sigma_allow_contact / max(sigma_H_pr, 1e-6);

    % 10. Pack Output Structure
    calc = struct();
    calc.gear_type = 'planetary';
    calc.m = m;
    calc.Ns = Ns;
    calc.Np = Np;
    calc.Nr = Nr;
    calc.K = K;
    calc.n_planets = K;
    calc.n_pinions = K;
    calc.phi_deg = phi_deg;
    calc.phi = phi;
    calc.F = F;
    calc.i_ratio = i_ratio;
    calc.center_dist = C;
    calc.C = C;

    % Radii and Diameters
    calc.ds = ds;       calc.dp = dp;       calc.dr = dr;
    calc.rp_s = rp_s;   calc.rp_p = rp_p;   calc.rp_r = rp_r;
    calc.rb_s = rb_s;   calc.rb_p = rb_p;   calc.rb_r = rb_r;
    calc.ra_s = ra_s;   calc.ra_p = ra_p;   calc.ra_r_int = ra_r_int;
    calc.rd_s = rd_s;   calc.rd_p = rd_p;   calc.rd_r_int = rd_r_int;
    calc.a_s = a_s;     calc.b_s = b_s;
    calc.a_p = a_p;     calc.b_p = b_p;
    calc.a_r = a_r;     calc.b_r = b_r;
    calc.s_s = s_s;     calc.s_p = s_p;     calc.s_r = s_r;
    calc.r_rim = r_rim; calc.D_outer = D_outer;

    % Carrier & Pin Dimensions
    calc.r_pin = r_pin;
    calc.d_pin = d_pin;
    calc.r_bore_planet = r_bore_planet;
    calc.r_bore_sun = r_bore_sun;
    calc.r_carrier_disc = r_carrier_disc;
    calc.carrier_thickness = carrier_thickness;

    % Assembly and Clearance Checks
    calc.is_symmetric = is_symmetric;
    calc.assembly_index = assembly_index;
    calc.dist_planet_centers = dist_planet_centers;
    calc.clearance_adjacent_planets = clearance_adjacent_planets;
    calc.has_clearance = has_clearance;

    % Contact Ratios
    calc.CR_sp = CR_sp;
    calc.CR_pr = CR_pr;
    calc.L_sp = L_sp;
    calc.L_pr = L_pr;
    calc.pb = pb;

    % Kinematics & Operating Loads
    calc.T_in_sun = T_in_sun;
    calc.n_in_sun = n_in_sun;
    calc.n_carrier_out = n_carrier_out;
    calc.n_planet_relative = n_planet_relative;
    calc.n_planet_absolute = n_planet_absolute;
    calc.T_carrier_out = T_carrier_out;
    calc.P_in_total = P_in_total;
    calc.P_out_carrier = P_out_carrier;
    calc.K_gamma = K_gamma;
    calc.Ft = Ft;
    calc.Fr = Fr;
    calc.F_resultant = F_resultant;

    % Stresses & Safety Factors
    calc.sigma_b_s = sigma_b_s;
    calc.sigma_b_p = sigma_b_p;
    calc.sigma_b_r = sigma_b_r;
    calc.SF_b_s = SF_b_s;
    calc.SF_b_p = SF_b_p;
    calc.SF_b_r = SF_b_r;
    calc.sigma_H_sp = sigma_H_sp;
    calc.sigma_H_pr = sigma_H_pr;
    calc.SF_contact_sp = SF_contact_sp;
    calc.SF_contact_pr = SF_contact_pr;
    calc.eta = eta;
end
