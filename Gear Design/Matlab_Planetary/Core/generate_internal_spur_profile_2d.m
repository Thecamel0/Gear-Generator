function [xc_ring, yc_ring, x_rim, y_rim] = generate_internal_spur_profile_2d(calc, n_pts)
%GENERATE_INTERNAL_SPUR_PROFILE_2D Generates precision 2D closed boundaries for Internal Ring Gear
%   Internal teeth: Counter-Clockwise closed boundary, points inward towards center.
%   Outer rim: Circular boundary of radius r_rim.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-11

    if nargin < 2 || isempty(n_pts), n_pts = 40; end

    Ng    = calc.Nr;
    phi   = calc.phi;
    r_pg  = calc.rp_r;
    r_bg  = calc.rb_r;
    r_ai  = calc.ra_r_int; % Inner crest circle (tip, smaller radius)
    r_di  = calc.rd_r_int; % Inner trough circle (root, larger radius)
    r_rim = calc.r_rim;    % Outer solid rim cylinder

    if isfield(calc, 's_r')
        s_g = calc.s_r;
    else
        s_g = (pi * calc.m) / 2;
    end

    tau_g = s_g / (2 * r_pg);
    inv_phi = tan(phi) - phi;

    % Angle at internal tip (crest, smaller radius r_ai)
    % For internal gear, tooth is thinner at tip and thicker at root:
    % theta(r) = tau_g - inv_phi + inv_alpha(r)
    alpha_ai = acos(min(r_bg / r_ai, 1.0));
    inv_ai = tan(alpha_ai) - alpha_ai;
    theta_tip = tau_g - inv_phi + inv_ai;

    % Angle at internal root (trough, larger radius r_di)
    alpha_di = acos(min(r_bg / r_di, 1.0));
    inv_di = tan(alpha_di) - alpha_di;
    theta_root = tau_g - inv_phi + inv_di;
    theta_next_root = 2 * pi / Ng - theta_root;

    xc_single = [];
    yc_single = [];

    % 1.1 Left internal involute flank (from root r_di down to tip r_ai)
    rr_down = linspace(r_di, r_ai, n_pts);
    rr_down(end) = [];
    a_down = acos(min(r_bg ./ rr_down, 1.0));
    inv_d = tan(a_down) - a_down;
    tt_left = -(tau_g - inv_phi + inv_d);
    xc_single = [xc_single, rr_down .* cos(tt_left)];
    yc_single = [yc_single, rr_down .* sin(tt_left)];

    % 1.2 Internal Tip land arc at r_ai (-theta_tip -> +theta_tip)
    n_tip = max(6, round(n_pts * 0.15));
    tt_tip = linspace(-theta_tip, theta_tip, n_tip);
    tt_tip(end) = [];
    xc_single = [xc_single, r_ai * cos(tt_tip)];
    yc_single = [yc_single, r_ai * sin(tt_tip)];

    % 1.3 Right internal involute flank (from tip r_ai up to root r_di)
    rr_up = linspace(r_ai, r_di, n_pts);
    rr_up(end) = [];
    a_up = acos(min(r_bg ./ rr_up, 1.0));
    inv_u = tan(a_up) - a_up;
    tt_right = (tau_g - inv_phi + inv_u);
    xc_single = [xc_single, rr_up .* cos(tt_right)];
    yc_single = [yc_single, rr_up .* sin(tt_right)];

    % 1.4 Internal Root land / trough arc at r_di (theta_root -> theta_next_root)
    n_root = max(6, round(n_pts * 0.15));
    tt_root = linspace(theta_root, theta_next_root, n_root);
    tt_root(end) = [];
    xc_single = [xc_single, r_di * cos(tt_root)];
    yc_single = [yc_single, r_di * sin(tt_root)];

    % Replicate across all Ng teeth around 360 degrees
    M_single = length(xc_single);
    xc_ring = zeros(1, Ng * M_single);
    yc_ring = zeros(1, Ng * M_single);

    % Shift by -pi/Ng so that a tooth space is centered at angle 0 (aligned with planet on X axis)
    rot_shift = -pi / Ng;
    c_shift = cos(rot_shift);
    s_shift = sin(rot_shift);

    for t = 0:(Ng-1)
        angle = t * 2 * pi / Ng;
        c = cos(angle);
        s = sin(angle);
        idx = t * M_single + (1:M_single);
        xt = xc_single * c - yc_single * s;
        yt = xc_single * s + yc_single * c;
        xc_ring(idx) = xt * c_shift - yt * s_shift;
        yc_ring(idx) = xt * s_shift + yt * c_shift;
    end

    % Outer circular rim boundary (Counter-Clockwise)
    n_rim = max(180, round(Ng * 4));
    th_rim = linspace(0, 2 * pi, n_rim + 1);
    th_rim(end) = [];
    x_rim = r_rim * cos(th_rim);
    y_rim = r_rim * sin(th_rim);
end
