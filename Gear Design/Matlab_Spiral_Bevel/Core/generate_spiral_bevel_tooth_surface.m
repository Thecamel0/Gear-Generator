function [verts_3d, n_pts_per_sec, n_sections] = generate_spiral_bevel_tooth_surface(...
        N, m, phi_n, a, b, gamma, Ao, F, beta_m, r_cutter, hand, s_thick, ...
        n_inv, n_sec, n_top, n_root)
%GENERATE_SPIRAL_BEVEL_TOOTH_SURFACE Constructs exact 3D tooth surface for Spiral Bevel Gear
%   following Gleason circular arc cutter kinematics and Tredgold spherical back-cone projection.
%
%   Inputs:
%       N           - Number of teeth
%       m           - Outer module [mm]
%       phi_n       - Normal pressure angle [rad]
%       a           - Outer addendum [mm]
%       b           - Outer dedendum [mm]
%       gamma       - Pitch cone angle [rad]
%       Ao          - Outer cone distance [mm]
%       F           - Face width [mm]
%       beta_m      - Mean spiral angle [rad]
%       r_cutter    - Cutter radius [mm]
%       hand        - Hand of spiral (+1 for RH, -1 for LH)
%       s_thick     - Outer circular tooth thickness [mm]
%       n_inv       - Points per involute curve (default 16)
%       n_sec       - Cross-sections along face width (default 18)
%       n_top       - Points on tooth tip arc (default 4)
%       n_root      - Points on root fillet arc (default 4)
%
%   Outputs:
%       verts_3d       - [n_sec*M x 3] matrix of 3D coordinates [X, Y, Z]
%       n_pts_per_sec  - Points per cross-section (M)
%       n_sections     - Number of cross-sections along face width (n_sec)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 13 || isempty(n_inv),  n_inv  = 16; end
    if nargin < 14 || isempty(n_sec),  n_sec  = 18; end
    if nargin < 15 || isempty(n_top),  n_top  = 4;  end
    if nargin < 16 || isempty(n_root), n_root = 4;  end
    if nargin < 11 || isempty(hand),   hand   = 1;  end

    % Cone distances
    Ai = Ao - F;            % Inner cone distance (Toe)
    Am = Ao - F / 2;        % Mean cone distance

    cone_dists = linspace(Ai, Ao, n_sec);

    % Transverse pressure angle at outer cone
    tan_phi_t = tan(phi_n) / cos(beta_m);
    phi_t = atan(tan_phi_t);

    % 1. Reference 2D profile at the outer cone (Tredgold back-cone plane)
    [ref_angles, ref_radii] = generate_2d_involute_profile(N, m, phi_t, a, b, ...
                                                           n_inv, n_top, n_root, s_thick);
    M = length(ref_angles);

    verts_3d = zeros(n_sec * M, 3);
    r_pitch_outer = m * N / 2;

    % Gleason circular cutter center in developed crown/pitch plane:
    % At mean cone distance Am, the tangent makes angle beta_m with cone ray.
    % Center of circular cutter arc:
    u_c = Am - r_cutter * sin(beta_m);
    v_c = r_cutter * cos(beta_m);

    for s = 1:n_sec
        A = cone_dists(s);

        % Scale factor (teeth taper linearly toward cone apex)
        sf = A / Ao;

        % Circular cutter trajectory offset along spiral arc:
        % Equation of cutter circle: (A - u_c)^2 + (v - v_c)^2 = r_cutter^2
        arg = r_cutter^2 - (A - u_c)^2;
        if arg > 0
            v_spiral = v_c - sqrt(arg);
        else
            % Linear Taylor fallback if cutter radius too small
            v_spiral = (A - Am) * tan(beta_m);
        end

        % Angular rotation around gear axis: delta_theta = hand * v_spiral / r_cone(A)
        r_cone = A * sin(gamma);
        if r_cone > 1e-4
            delta_theta = hand * (v_spiral / r_cone);
        else
            delta_theta = 0;
        end

        % Scaled 2D profile
        scaled_radii = ref_radii * sf;
        scaled_angles = ref_angles + delta_theta;

        % Project profile normal to the pitch cone surface:
        % Radial distance from axis: r_3d = r_cone + delta_r * cos(gamma)
        % Axial coordinate:          z_3d = z_cone - delta_r * sin(gamma)
        r_pitch_local = r_pitch_outer * sf;
        z_cone = A * cos(gamma);

        delta_r = scaled_radii - r_pitch_local;

        r_3d = r_cone + delta_r * cos(gamma);
        z_3d = z_cone - delta_r * sin(gamma);

        % Convert cylindrical (r_3d, scaled_angles, z_3d) to Cartesian (X, Y, Z)
        idx = (s - 1) * M + (1:M);
        verts_3d(idx, 1) = r_3d .* cos(scaled_angles);
        verts_3d(idx, 2) = r_3d .* sin(scaled_angles);
        verts_3d(idx, 3) = z_3d;
    end

    n_pts_per_sec = M;
    n_sections = n_sec;
end

function [angles, radii] = generate_2d_involute_profile(N, m, phi, a, b, ...
                                                        n_inv, n_top, n_root, tooth_thick)
    r_p = m * N / 2;
    r_b = r_p * cos(phi);
    r_a = r_p + a;
    r_d = max(r_p - b, 0.25 * r_b);

    tau = tooth_thick / (2 * r_p);
    inv_phi = tan(phi) - phi;

    root_below_base = (r_d < r_b);
    r_inv_start = max(r_b, r_d);

    alpha_tip = acos(min(r_b / r_a, 1));
    theta_tip = tau + inv_phi - (tan(alpha_tip) - alpha_tip);

    if root_below_base
        theta_root = tau + inv_phi;
    else
        alpha_root = acos(min(r_b / r_d, 1));
        theta_root = tau + inv_phi - (tan(alpha_root) - alpha_root);
    end

    theta_next_root = 2 * pi / N - theta_root;

    tooth_r = [];
    tooth_t = [];

    % 1. Left root transition
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_d, r_b, nr);
        tt = -(tau + inv_phi) * ones(1, nr);
        tooth_r = [tooth_r, rr(1:end-1)];
        tooth_t = [tooth_t, tt(1:end-1)];
    end

    % 2. Left involute flank
    rr = linspace(r_inv_start, r_a, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = -(tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr(1:end-1)];
    tooth_t = [tooth_t, tt(1:end-1)];

    % 3. Tip land arc
    if n_top > 0
        tt_top = linspace(-theta_tip, theta_tip, n_top);
        rr_top = r_a * ones(1, n_top);
        tooth_r = [tooth_r, rr_top(1:end-1)];
        tooth_t = [tooth_t, tt_top(1:end-1)];
    end

    % 4. Right involute flank
    rr = linspace(r_a, r_inv_start, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = (tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr(1:end-1)];
    tooth_t = [tooth_t, tt(1:end-1)];

    % 5. Right root transition
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_b, r_d, nr);
        tt = (tau + inv_phi) * ones(1, nr);
        tooth_r = [tooth_r, rr(1:end-1)];
        tooth_t = [tooth_t, tt(1:end-1)];
    end

    % 6. Root land arc
    n_root_pts = max(n_root, 3);
    tt_root = linspace(theta_root, theta_next_root, n_root_pts);
    rr_root = r_d * ones(1, n_root_pts);
    tooth_r = [tooth_r, rr_root(1:end-1)];
    tooth_t = [tooth_t, tt_root(1:end-1)];

    % Replicate for all N teeth
    M_tooth = length(tooth_r);
    M_total = N * M_tooth;

    angles = zeros(1, M_total);
    radii  = zeros(1, M_total);

    for t = 0:(N - 1)
        offset = t * 2 * pi / N;
        idx = t * M_tooth + (1:M_tooth);
        angles(idx) = tooth_t + offset;
        radii(idx)  = tooth_r;
    end
end
