function [verts_3d, M_pts, n_sec, ref_prof] = generate_helical_tooth_surface(N, mn, beta_deg, phi_n_deg, a, b, s_thick_t, F, hand, n_inv, n_sec, n_top, n_root)
%GENERATE_HELICAL_TOOTH_SURFACE Generates true 3D helical gear tooth surfaces
%   by sweeping the transverse involute profile along the axial face width Z
%   with continuous helical twist angle: theta(Z) = hand * (Z * tan(beta)) / rp.
%
%   Parameters:
%     N          - Number of teeth
%     mn         - Normal module [mm]
%     beta_deg   - Helix angle [deg]
%     phi_n_deg  - Normal pressure angle [deg]
%     a          - Addendum [mm]
%     b          - Dedendum [mm]
%     s_thick_t  - Transverse tooth thickness at pitch circle [mm]
%     F          - Face width [mm]
%     hand       - Helix hand: +1 for Right-Hand (RH), -1 for Left-Hand (LH)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 10 || isempty(n_inv),  n_inv  = 20; end
    if nargin < 11 || isempty(n_sec),  n_sec  = 20; end
    if nargin < 12 || isempty(n_top),  n_top  = 4;  end
    if nargin < 13 || isempty(n_root), n_root = 4;  end

    beta  = deg2rad(beta_deg);
    phi_n = deg2rad(phi_n_deg);
    phi_t = atan(tan(phi_n) / cos(beta));
    mt    = mn / cos(beta);

    z_sections = linspace(-F/2, F/2, n_sec);

    % 1. Reference 2D Transverse Involute Profile
    [ref_angles, ref_radii, ref_prof] = build_transverse_involute_profile(N, mt, phi_t, a, b, s_thick_t, n_inv, n_top, n_root);
    M_pts = length(ref_angles);

    % Pitch radius in transverse plane
    rp = (mt * N) / 2;

    % 2. Sweep across Z sections with continuous helical twist
    verts_3d = zeros(n_sec * M_pts, 3);

    for s = 1:n_sec
        z_s = z_sections(s);

        % Helical lead angle offset
        delta_theta = hand * (z_s * tan(beta)) / rp;

        angles_s = ref_angles + delta_theta;
        idx = (s - 1) * M_pts + (1:M_pts);

        verts_3d(idx, 1) = ref_radii .* cos(angles_s);
        verts_3d(idx, 2) = ref_radii .* sin(angles_s);
        verts_3d(idx, 3) = z_s;
    end
end

%% ========================================================================
%  Local Helper: build_transverse_involute_profile
%  ========================================================================
function [angles, radii, prof] = build_transverse_involute_profile(N, mt, phi_t, a, b, s_thick_t, n_inv, n_top, n_root)
    r_p = (mt * N) / 2;
    r_b = r_p * cos(phi_t);
    r_a = r_p + a;
    r_d = max(r_p - b, 0.3 * r_b);

    tau = s_thick_t / (2 * r_p);
    inv_phi = tan(phi_t) - phi_t;

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
    theta_next_root = (2 * pi / N) - theta_root;

    % Single Tooth Profile Construction
    tooth_r = [];
    tooth_t = [];

    % 1. Left root-to-base transition
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_d, r_b, nr);
        tooth_r = [tooth_r, rr(1:end-1)];
        tooth_t = [tooth_t, repmat(-tau - inv_phi, 1, nr-1)];
    end

    % 2. Left involute flank (root/base -> tip)
    rr = linspace(r_inv_start, r_a, n_inv);
    for i = 1:n_inv
        alpha_i = acos(min(r_b / rr(i), 1));
        inv_alpha = tan(alpha_i) - alpha_i;
        tooth_r(end+1) = rr(i);
        tooth_t(end+1) = -(tau + inv_phi - inv_alpha);
    end

    % 3. Tooth tip land
    tt = linspace(tooth_t(end), theta_tip, max(n_top, 2));
    tooth_r = [tooth_r, repmat(r_a, 1, length(tt)-2)];
    tooth_t = [tooth_t, tt(2:end-1)];

    % 4. Right involute flank (tip -> base/root)
    rr = linspace(r_a, r_inv_start, n_inv);
    for i = 1:n_inv
        alpha_i = acos(min(r_b / rr(i), 1));
        inv_alpha = tan(alpha_i) - alpha_i;
        tooth_r(end+1) = rr(i);
        tooth_t(end+1) = tau + inv_phi - inv_alpha;
    end

    % 5. Right base-to-root transition
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_b, r_d, nr);
        tooth_r = [tooth_r, rr(2:end)];
        tooth_t = [tooth_t, repmat(tau + inv_phi, 1, nr-1)];
    end

    % 6. Root land between teeth
    n_root_pts = max(n_root, 2);
    tt_root = linspace(theta_root, theta_next_root, n_root_pts + 2);
    tooth_r = [tooth_r, repmat(r_d, 1, n_root_pts)];
    tooth_t = [tooth_t, tt_root(2:end-1)];

    % Replicate for all N teeth around the circumference
    M_single = length(tooth_r);
    radii  = zeros(1, N * M_single);
    angles = zeros(1, N * M_single);

    for t = 1:N
        pitch_offset = (t - 1) * (2 * pi / N);
        idx = (t - 1) * M_single + (1:M_single);
        radii(idx)  = tooth_r;
        angles(idx) = tooth_t + pitch_offset;
    end

    prof = struct('tooth_r', tooth_r, 'tooth_t', tooth_t, 'M_single', M_single);
end
