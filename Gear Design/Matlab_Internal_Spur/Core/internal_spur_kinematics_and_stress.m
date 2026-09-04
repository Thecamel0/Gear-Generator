function calc = internal_spur_kinematics_and_stress(inputs)
%INTERNAL_SPUR_KINEMATICS_AND_STRESS Computes geometry, kinematics, forces, and stresses
%   for an Internal Spur Gear (Ring Gear / Annulus) mating with External Pinions.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1, inputs = struct(); end

    % 1. Primary Parameters
    m = 3.0;            if isfield(inputs, 'm'),           m = inputs.m; end
    Np = 16;            if isfield(inputs, 'Np'),          Np = inputs.Np; end
    Ng = 48;            if isfield(inputs, 'Ng'),          Ng = inputs.Ng; end
    phi_deg = 20.0;     if isfield(inputs, 'phi_deg'),     phi_deg = inputs.phi_deg; end
    F = 25.0;           if isfield(inputs, 'F'),           F = inputs.F; end
    n_pinions = 3;      if isfield(inputs, 'n_pinions'),   n_pinions = inputs.n_pinions; end

    % Operating conditions
    T_in_gear = 20.0;   if isfield(inputs, 'T_in_ring'),   T_in_gear = inputs.T_in_ring; end
    n_in_gear = 100.0;  if isfield(inputs, 'n_in_ring'),   n_in_gear = inputs.n_in_ring; end
    eta = 0.97;         if isfield(inputs, 'eta'),         eta = inputs.eta; end
    sigma_allow_bend = 250.0;
    sigma_allow_contact = 1500.0;

    phi = deg2rad(phi_deg);

    % 2. Fundamental Pitch, Base, and Center Distance
    dp = m * Np;
    dg = m * Ng;
    rp_p = dp / 2;
    rp_g = dg / 2;
    rb_p = rp_p * cos(phi);
    rb_g = rp_g * cos(phi);

    % Internal gear center distance: C = (dg - dp) / 2
    center_dist = rp_g - rp_p;
    i_ratio = Ng / Np;

    % 3. Standard Proportions (Gleason unequal addenda)
    khw_factor = 2.0;
    c_factor = 0.188;
    hw = khw_factor * m;
    ht = hw + c_factor * m;
    c_std = c_factor * m;

    a_p = 0.6 * hw;     % External pinion addendum
    b_p = ht - a_p;     % External pinion dedendum
    a_g = 0.4 * hw;     % Internal gear addendum (points inward)
    b_g = ht - a_g;     % Internal gear dedendum (points outward)

    s_nom = (pi * m) / 2;
    s_shift = 0.18 * m;
    s_p = s_nom + s_shift;
    s_g = s_nom - s_shift;

    % External Pinion Radii
    ra_p = rp_p + a_p;  % Tip radius
    rd_p = rp_p - b_p;  % Root radius

    % Internal Ring Gear Radii (Teeth point inward!)
    ra_g_int = rp_g - a_g;  % Internal tip radius (crest)
    rd_g_int = rp_g + b_g;  % Internal root radius (trough)
    r_rim = rd_g_int + 12.0; % Outer solid rim radius
    D_outer = 2 * r_rim;

    % 4. Transverse Contact Ratio (Internal Mesh Equation)
    % L_contact = sqrt(ra_p^2 - rb_p^2) - sqrt(ra_g_int^2 - rb_g^2) + C * sin(phi)
    L_p = sqrt(max(0, ra_p^2 - rb_p^2));
    L_g = sqrt(max(0, ra_g_int^2 - rb_g^2));
    L_contact = L_p - L_g + center_dist * sin(phi);
    pb = pi * m * cos(phi);
    CR = L_contact / pb;

    % 5. Kinematics & Operating Loads
    % In internal gearing, both pinion and ring rotate in SAME direction
    n_pinion_out = n_in_gear * i_ratio;
    T_gear_per_mesh = T_in_gear / n_pinions;
    T_pinion_each = (T_gear_per_mesh / i_ratio) * eta;
    P_in_total = (T_in_gear * 2 * pi * n_in_gear) / 60;
    P_out_each = (T_pinion_each * 2 * pi * n_pinion_out) / 60;

    Ft = (2 * T_gear_per_mesh * 1000) / dg;
    Fr = Ft * tan(phi);
    F_resultant = sqrt(Ft^2 + Fr^2);

    % 6. Lewis Bending Stress Checks
    Y_p = (0.484 - 2.87 / Np) * (s_p / s_nom)^2;
    % Internal teeth have broader, stronger root bases
    Y_g = (0.484 + 1.5 / Ng) * (s_g / s_nom)^2;
    sigma_b_p = Ft / (F * m * Y_p);
    sigma_b_g = Ft / (F * m * Y_g);
    SF_b_p = sigma_allow_bend / max(sigma_b_p, 1e-6);
    SF_b_g = sigma_allow_bend / max(sigma_b_g, 1e-6);

    % 7. Hertzian Contact Stress (Concave-Convex Curvature)
    % 1/rho_eq = 1/rho_p - 1/rho_g (Minus sign reduces contact stress!)
    E_mod = 206000;
    nu = 0.30;
    E_star = E_mod / (2 * (1 - nu^2));
    rho_p = rb_p * tan(phi);
    rho_g = rb_g * tan(phi);
    rho_eq = (rho_p * rho_g) / max(rho_g - rho_p, 1e-3);
    sigma_H = sqrt((Ft / (pi * F * cos(phi))) * (E_star / rho_eq));
    SF_contact = sigma_allow_contact / max(sigma_H, 1e-6);

    % 8. Package Results Struct
    calc = struct();
    calc.gear_type      = 'internal_spur';
    calc.m              = m;
    calc.Np             = Np;
    calc.Ng             = Ng;
    calc.phi_deg        = phi_deg;
    calc.phi            = phi;
    calc.F              = F;
    calc.n_pinions      = n_pinions;
    calc.i_ratio        = i_ratio;
    calc.center_dist    = center_dist;
    calc.dp             = dp;
    calc.dg             = dg;
    calc.rp_p           = rp_p;
    calc.rp_g           = rp_g;
    calc.rb_p           = rb_p;
    calc.rb_g           = rb_g;
    calc.ra_p           = ra_p;
    calc.rd_p           = rd_p;
    calc.ra_g_int       = ra_g_int;
    calc.rd_g_int       = rd_g_int;
    calc.r_rim          = r_rim;
    calc.D_outer        = D_outer;
    calc.hw             = hw;
    calc.ht             = ht;
    calc.c_std          = c_std;
    calc.a_p            = a_p;
    calc.a_g            = a_g;
    calc.b_p            = b_p;
    calc.b_g            = b_g;
    calc.s_p            = s_p;
    calc.s_g            = s_g;
    calc.CR             = CR;
    calc.L_contact      = L_contact;
    calc.pb             = pb;
    calc.T_in_ring      = T_in_gear;
    calc.n_in_ring      = n_in_gear;
    calc.n_pinion_out   = n_pinion_out;
    calc.T_ring_per_mesh= T_gear_per_mesh;
    calc.T_pinion_each  = T_pinion_each;
    calc.P_in_total     = P_in_total;
    calc.P_out_each     = P_out_each;
    calc.Ft             = Ft;
    calc.Fr             = Fr;
    calc.F_resultant    = F_resultant;
    calc.sigma_b_p      = sigma_b_p;
    calc.sigma_b_g      = sigma_b_g;
    calc.SF_b_p         = SF_b_p;
    calc.SF_b_g         = SF_b_g;
    calc.sigma_H        = sigma_H;
    calc.SF_contact     = SF_contact;
end
