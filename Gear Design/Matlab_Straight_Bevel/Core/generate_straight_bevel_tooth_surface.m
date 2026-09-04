function [verts_3d, M_pts, n_sec, ref_prof] = generate_straight_bevel_tooth_surface(N, m, phi, a, b, gamma, Ao, F, s_thick, n_inv, n_sec, n_top, n_root)
%GENERATE_STRAIGHT_BEVEL_TOOTH_SURFACE Generates true 3D straight bevel tooth surfaces
%   converging strictly to the pitch cone apex (0, 0, 0).
%
%   - Generates Tredgold spherical back-cone 2D involute profile.
%   - Scales each cross-section linearly by sf = A / Ao along cone distance A in [Ai, Ao].
%   - Straight tooth elements: zero curve offset (delta_theta = 0).
%   - Projects addendum and dedendum normal to the conical pitch surface.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 10 || isempty(n_inv),  n_inv  = 20; end
    if nargin < 11 || isempty(n_sec),  n_sec  = 16; end
    if nargin < 12 || isempty(n_top),  n_top  = 4;  end
    if nargin < 13 || isempty(n_root), n_root = 4;  end

    Ai = Ao - F;
    cone_dists = linspace(Ai, Ao, n_sec);

    % 1. Reference 2D Involute Profile in Tredgold Back-Cone Plane
    [ref_angles, ref_radii, ref_prof] = build_involute_profile(N, m, phi, a, b, s_thick, n_inv, n_top, n_root);
    M_pts = length(ref_angles);

    % 2. Generate 3D Vertex Coordinates for All Cross-Sections
    verts_3d = zeros(n_sec * M_pts, 3);
    r_pitch_outer = m * N / 2;

    for s = 1:n_sec
        A = cone_dists(s);
        sf = A / Ao; % Linear scale factor toward cone apex (0, 0, 0)

        % Pitch cone surface reference coordinates
        r_cone_pitch = A * sin(gamma);
        z_cone_pitch = A * cos(gamma);

        % Local pitch radius in 2D Tredgold plane
        r_pitch_local = r_pitch_outer * sf;

        % Scale 2D radii and angles (Straight bevel: delta_theta = 0)
        scaled_radii = ref_radii * sf;
        scaled_angles = ref_angles; % Pure radial ray to apex

        % Deviation from pitch circle
        delta_r = scaled_radii - r_pitch_local;

        % Project normal to pitch cone:
        % Outward cone normal in (R, Z) plane: [cos(gamma), -sin(gamma)]
        r_3d = r_cone_pitch + delta_r * cos(gamma);
        z_3d = z_cone_pitch - delta_r * sin(gamma);

        % 3D Cartesian coordinates
        idx = (s - 1) * M_pts + (1:M_pts);
        verts_3d(idx, 1) = r_3d .* cos(scaled_angles);
        verts_3d(idx, 2) = r_3d .* sin(scaled_angles);
        verts_3d(idx, 3) = z_3d;
    end
end

function [angles, radii, prof_2d] = build_involute_profile(N, m, phi, a, b, s_thick, n_inv, n_top, n_root)
%BUILD_INVOLUTE_PROFILE Builds 2D involute tooth profile in back-cone plane for all N teeth

    rp = m * N / 2;
    rb = rp * cos(phi);
    ra = rp + a;
    rd = max(rp - b, 0.3 * rb);

    tau = s_thick / (2 * rp);
    inv_phi = tan(phi) - phi;

    root_below_base = (rd < rb);
    r_inv_start = max(rb, rd);

    alpha_tip = acos(min(rb / ra, 1.0));
    theta_tip = tau + inv_phi - (tan(alpha_tip) - alpha_tip);

    if root_below_base
        theta_root = tau + inv_phi;
    else
        alpha_root = acos(min(rb / rd, 1.0));
        theta_root = tau + inv_phi - (tan(alpha_root) - alpha_root);
    end
    theta_next_root = 2 * pi / N - theta_root;

    % Build single tooth
    tooth_r = [];
    tooth_t = [];

    % 1. Left flank: root up to tip
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(rd, rb, nr);
        rr(end) = [];
        tt = -(tau + inv_phi) * ones(1, length(rr));
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    rr = linspace(r_inv_start, ra, n_inv);
    rr(end) = [];
    alpha = acos(min(rb ./ rr, 1.0));
    inv_a = tan(alpha) - alpha;
    tt = -(tau + inv_phi - inv_a);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    % 2. Tip land arc
    if n_top > 0
        tt_top = linspace(-theta_tip, theta_tip, n_top + 2);
        tt_top = tt_top(2:end-1);
        rr_top = ra * ones(1, length(tt_top));
        tooth_r = [tooth_r, rr_top];
        tooth_t = [tooth_t, tt_top];
    end

    % 3. Right flank: tip down to root
    rr = linspace(ra, r_inv_start, n_inv);
    rr(end) = [];
    alpha = acos(min(rb ./ rr, 1.0));
    inv_a = tan(alpha) - alpha;
    tt = (tau + inv_phi - inv_a);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(rb, rd, nr);
        rr(end) = [];
        tt = (tau + inv_phi) * ones(1, length(rr));
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    % 4. Root land arc
    n_root_pts = max(n_root, 3);
    tt_root = linspace(theta_root, theta_next_root, n_root_pts + 1);
    tt_root(end) = [];
    rr_root = rd * ones(1, length(tt_root));
    tooth_r = [tooth_r, rr_root];
    tooth_t = [tooth_t, tt_root];

    % Replicate for all N teeth
    M_single = length(tooth_r);
    M_total = N * M_single;

    angles = zeros(1, M_total);
    radii  = zeros(1, M_total);

    for t = 0:(N - 1)
        offset = t * 2 * pi / N;
        idx = t * M_single + (1:M_single);
        angles(idx) = tooth_t + offset;
        radii(idx)  = tooth_r;
    end

    prof_2d = struct('tooth_r', tooth_r, 'tooth_t', tooth_t, 'ra', ra, 'rd', rd, 'rp', rp, 'rb', rb);
end
