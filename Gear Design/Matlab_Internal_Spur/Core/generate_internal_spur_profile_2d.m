function [xc_ring, yc_ring, x_rim, y_rim, xc_pin, yc_pin] = generate_internal_spur_profile_2d(calc, n_pts)
%GENERATE_INTERNAL_SPUR_PROFILE_2D Generates closed 2D profiles for an Internal Ring Gear and Pinion
%
%   Outputs:
%     xc_ring, yc_ring : Closed polygon of inner internal teeth (counter-clockwise)
%     x_rim, y_rim     : Outer solid rim circle coordinates
%     xc_pin, yc_pin   : Closed polygon of external mating pinion
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 2 || isempty(n_pts), n_pts = 40; end

    m = calc.m;
    Np = calc.Np;
    Ng = calc.Ng;
    phi = calc.phi;
    r_rim = calc.r_rim;

    % =====================================================================
    % 1. Internal Ring Gear Tooth Profile (Teeth Point Inward)
    % =====================================================================
    r_pg = calc.rp_g;
    r_bg = calc.rb_g;
    r_ai = calc.ra_g_int;   % Crest (inner tip, smaller radius)
    r_di = calc.rd_g_int;   % Trough (root, larger radius)

    tau_g = calc.s_g / (2 * r_pg);
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

    % 1.1 Left internal involute (from root r_di down to tip r_ai)
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

    % 1.3 Right internal involute (from tip r_ai up to root r_di)
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

    % Replicate across all Ng teeth
    M_single = length(xc_single);
    xc_ring = zeros(1, Ng * M_single);
    yc_ring = zeros(1, Ng * M_single);

    % Shift by -pi/Ng so that a tooth SPACE is centered at angle 0 (pitch point):
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

    % Outer solid rim circle (for annular ring gear body)
    n_rim_pts = max(64, round(Ng * 3));
    th_rim = linspace(0, 2*pi, n_rim_pts + 1);
    th_rim(end) = [];
    x_rim = r_rim * cos(th_rim);
    y_rim = r_rim * sin(th_rim);

    % =====================================================================
    % 2. External Mating Pinion Profile
    % =====================================================================
    rp_p = calc.rp_p;
    rb_p = calc.rb_p;
    ra_p = calc.ra_p;
    rd_p = calc.rd_p;
    tau_p = calc.s_p / (2 * rp_p);

    root_below_base = rd_p < rb_p;
    r_inv_start = max(rb_p, rd_p);

    alpha_tip_p = acos(min(rb_p / ra_p, 1.0));
    theta_tip_p = tau_p + inv_phi - (tan(alpha_tip_p) - alpha_tip_p);

    if root_below_base
        theta_root_p = tau_p + inv_phi;
    else
        alpha_root_p = acos(min(rb_p / rd_p, 1.0));
        theta_root_p = tau_p + inv_phi - (tan(alpha_root_p) - alpha_root_p);
    end
    theta_next_root_p = 2 * pi / Np - theta_root_p;

    xc_ptooth = [];
    yc_ptooth = [];

    if root_below_base
        nr = max(5, round(n_pts * 0.12));
        rr = linspace(rd_p, rb_p, nr);
        rr(end) = [];
        tt = -(tau_p + inv_phi) * ones(size(rr));
        xc_ptooth = [xc_ptooth, rr .* cos(tt)];
        yc_ptooth = [yc_ptooth, rr .* sin(tt)];
    end

    rr = linspace(r_inv_start, ra_p, n_pts);
    rr(end) = [];
    alpha = acos(min(rb_p ./ rr, 1.0));
    inv_alpha = tan(alpha) - alpha;
    tt = -(tau_p + inv_phi - inv_alpha);
    xc_ptooth = [xc_ptooth, rr .* cos(tt)];
    yc_ptooth = [yc_ptooth, rr .* sin(tt)];

    tt_top = linspace(-theta_tip_p, theta_tip_p, n_tip);
    tt_top(end) = [];
    xc_ptooth = [xc_ptooth, ra_p * cos(tt_top)];
    yc_ptooth = [yc_ptooth, ra_p * sin(tt_top)];

    rr = linspace(ra_p, r_inv_start, n_pts);
    rr(end) = [];
    alpha = acos(min(rb_p ./ rr, 1.0));
    inv_alpha = tan(alpha) - alpha;
    tt = (tau_p + inv_phi - inv_alpha);
    xc_ptooth = [xc_ptooth, rr .* cos(tt)];
    yc_ptooth = [yc_ptooth, rr .* sin(tt)];

    if root_below_base
        nr = max(5, round(n_pts * 0.12));
        rr = linspace(rb_p, rd_p, nr);
        rr(end) = [];
        tt = (tau_p + inv_phi) * ones(size(rr));
        xc_ptooth = [xc_ptooth, rr .* cos(tt)];
        yc_ptooth = [yc_ptooth, rr .* sin(tt)];
    end

    tt_root = linspace(theta_root_p, theta_next_root_p, n_root);
    tt_root(end) = [];
    xc_ptooth = [xc_ptooth, rd_p * cos(tt_root)];
    yc_ptooth = [yc_ptooth, rd_p * sin(tt_root)];

    Mp = length(xc_ptooth);
    xc_pin = zeros(1, Np * Mp);
    yc_pin = zeros(1, Np * Mp);

    for t = 0:(Np-1)
        angle = t * 2 * pi / Np;
        c = cos(angle);
        s = sin(angle);
        idx = t * Mp + (1:Mp);
        xc_pin(idx) = xc_ptooth * c - yc_ptooth * s;
        yc_pin(idx) = xc_ptooth * s + yc_ptooth * c;
    end
end
