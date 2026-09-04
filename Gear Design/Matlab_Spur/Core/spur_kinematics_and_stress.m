function calc = spur_kinematics_and_stress(m, Np, Ng, phi_deg, F, T_in_gear, n_in_gear, n_pinions, sigma_allow_bend, sigma_allow_contact)
%SPUR_KINEMATICS_AND_STRESS Calculates complete kinematic, force, and stress parameters
%
%   Inputs:
%       m                   - Module [mm]
%       Np                  - Pinion tooth count
%       Ng                  - Gear tooth count
%       phi_deg             - Pressure angle [deg]
%       F                   - Face width [mm]
%       T_in_gear           - Input torque to central gear [N·m]
%       n_in_gear           - Input rotational speed of central gear [RPM]
%       n_pinions           - Number of driven pinions (e.g. 1 or 3)
%       sigma_allow_bend    - Allowable bending stress [MPa] (default: 250)
%       sigma_allow_contact - Allowable contact stress [MPa] (default: 1500)
%
%   Output:
%       calc - Comprehensive struct of all geometric, kinematic, and stress data
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 6 || isempty(T_in_gear),           T_in_gear = 20;           end
    if nargin < 7 || isempty(n_in_gear),           n_in_gear = 100;          end
    if nargin < 8 || isempty(n_pinions),           n_pinions = 3;            end
    if nargin < 9 || isempty(sigma_allow_bend),    sigma_allow_bend = 250;   end
    if nargin < 10 || isempty(sigma_allow_contact), sigma_allow_contact = 1500; end

    phi = deg2rad(phi_deg);
    eta = 0.97; % Mesh efficiency per pair

    % Pitch and Base Diameters
    dp = m * Np;
    dg = m * Ng;
    rp_p = dp / 2;
    rp_g = dg / 2;

    rb_p = rp_p * cos(phi);
    rb_g = rp_g * cos(phi);

    center_dist = rp_p + rp_g; % C = (dp + dg)/2
    i_ratio = Ng / Np;

    % Standard Proportions (ISO / AGMA with standard addendum shift option)
    khw_factor = 2.00;
    c_factor   = 0.188;
    hw = khw_factor * m;
    ht = hw + c_factor * m;
    c  = c_factor * m;

    % Gleason/AGMA balanced addendum allocation (prevents pinion undercut)
    a_p = 0.600 * hw; % 3.60 mm for m=3
    a_g = 0.400 * hw; % 2.40 mm for m=3
    b_p = ht - a_p;   % 2.964 mm for m=3
    b_g = ht - a_g;   % 4.164 mm for m=3

    % Circular tooth thickness
    s_nom = pi * m / 2;
    s_shift = 0.180 * m;
    s_p = s_nom + s_shift;
    s_g = s_nom - s_shift;

    ra_p = rp_p + a_p;
    ra_g = rp_g + a_g;
    rd_p = rp_p - b_p;
    rd_g = rp_g - b_g;

    % Transverse Contact Ratio (CR)
    L_contact = sqrt(ra_p^2 - rb_p^2) + sqrt(ra_g^2 - rb_g^2) - center_dist * sin(phi);
    pb = pi * m * cos(phi); % Base pitch
    CR = L_contact / pb;

    % Kinematics
    n_pinion_out = n_in_gear * i_ratio;
    T_gear_per_mesh = T_in_gear / n_pinions;
    T_pinion_each = (T_gear_per_mesh / i_ratio) * eta;
    P_in_total = (T_in_gear * 2 * pi * n_in_gear) / 60;
    P_out_each = (T_pinion_each * 2 * pi * n_pinion_out) / 60;

    % Mesh Forces (at pitch line)
    Ft = (2 * T_gear_per_mesh * 1000) / dg;
    Fr = Ft * tan(phi);
    F_resultant = sqrt(Ft^2 + Fr^2);

    % Lewis Bending Stress (AGMA simplified)
    Y_p = (0.484 - 2.87 / Np) * (s_p / s_nom)^2;
    Y_g = (0.484 - 2.87 / Ng) * (s_g / s_nom)^2;

    sigma_b_p = Ft / (F * m * Y_p);
    sigma_b_g = Ft / (F * m * Y_g);

    SF_b_p = sigma_allow_bend / max(sigma_b_p, 1e-6);
    SF_b_g = sigma_allow_bend / max(sigma_b_g, 1e-6);

    % Hertzian Contact Stress (Surface Durability)
    E_mod = 206000; % Steel Young's modulus [MPa]
    nu = 0.30;
    E_star = E_mod / (2 * (1 - nu^2));

    rho_p = rb_p * tan(phi);
    rho_g = rb_g * tan(phi);
    rho_eq = (rho_p * rho_g) / (rho_p + rho_g);

    sigma_H = sqrt((Ft / (pi * F * cos(phi))) * (E_star / rho_eq));
    SF_contact = sigma_allow_contact / max(sigma_H, 1e-6);

    % Output Struct Assembly
    calc.m                   = m;
    calc.Np                  = Np;
    calc.Ng                  = Ng;
    calc.phi_deg             = phi_deg;
    calc.phi                 = phi;
    calc.F                   = F;
    calc.n_pinions           = n_pinions;
    calc.i_ratio             = i_ratio;
    calc.dp                  = dp;
    calc.dg                  = dg;
    calc.rp_p                = rp_p;
    calc.rp_g                = rp_g;
    calc.rb_p                = rb_p;
    calc.rb_g                = rb_g;
    calc.ra_p                = ra_p;
    calc.ra_g                = ra_g;
    calc.rd_p                = rd_p;
    calc.rd_g                = rd_g;
    calc.center_dist         = center_dist;
    calc.hw                  = hw;
    calc.ht                  = ht;
    calc.c                   = c;
    calc.a_p                 = a_p;
    calc.a_g                 = a_g;
    calc.b_p                 = b_p;
    calc.b_g                 = b_g;
    calc.s_p                 = s_p;
    calc.s_g                 = s_g;
    calc.CR                  = CR;
    calc.L_contact           = L_contact;
    calc.pb                  = pb;
    calc.T_in_gear           = T_in_gear;
    calc.n_in_gear           = n_in_gear;
    calc.n_pinion_out        = n_pinion_out;
    calc.T_gear_per_mesh     = T_gear_per_mesh;
    calc.T_pinion_each       = T_pinion_each;
    calc.P_in_total          = P_in_total;
    calc.P_out_each          = P_out_each;
    calc.Ft                  = Ft;
    calc.Fr                  = Fr;
    calc.F_resultant         = F_resultant;
    calc.sigma_b_p           = sigma_b_p;
    calc.sigma_b_g           = sigma_b_g;
    calc.SF_b_p              = SF_b_p;
    calc.SF_b_g              = SF_b_g;
    calc.sigma_H             = sigma_H;
    calc.SF_contact          = SF_contact;
    calc.sigma_allow_bend    = sigma_allow_bend;
    calc.sigma_allow_contact = sigma_allow_contact;
end
