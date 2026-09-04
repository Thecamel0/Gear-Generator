function fig2 = plot_straight_bevel_mesh_2d(calc)
%PLOT_STRAIGHT_BEVEL_MESH_2D Generates publication-grade 2D contact analysis diagrams
%   for a Straight Bevel Gear drive.
%
%   - Subplot 1: Pitch Cones & 90 deg Orthogonal Shafts Geometry Overview
%   - Subplot 2: High-Magnification Tredgold Meshing Zone & Line of Action Analysis
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1
        error('plot_straight_bevel_mesh_2d requires calc struct');
    end

    fig2 = figure('Name', 'Straight Bevel Suite — 2D Engagement & Contact Mechanics', ...
        'NumberTitle', 'off', ...
        'Position', [60, 60, 1500, 750], ...
        'Color', [0.07 0.07 0.10]);

    m = calc.m;
    Np = calc.Np;
    Ng = calc.Ng;
    phi = calc.phi;
    Ao = calc.Ao;
    F = calc.F;
    Ai = calc.Ai;
    gamma_p = calc.gamma_p;
    gamma_g = calc.gamma_g;
    rp_p = calc.rp_p;
    rp_g = calc.rp_g;

    %% ====================================================================
    %  SUBPLOT 1: Pitch Cones & Geometry Overview (Left Pane)
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig2);
    hold(ax1, 'on');

    % Apex is at (0, 0).
    % Pinion shaft along +X axis (horizontal)
    % Gear shaft along +Y axis (vertical)
    % Pitch contact line is along angle gamma_p from X-axis:
    % (Notice gamma_p + gamma_g = 90 deg)
    px_cone = [0, Ao * cos(gamma_p)];
    py_cone = [0, Ao * sin(gamma_p)];

    % Pinion lower pitch cone generator
    px_p_low = [0, Ao * cos(-gamma_p)];
    py_p_low = [0, Ao * sin(-gamma_p)];

    % Gear outer pitch cone generator
    gx_high = [0, Ao * cos(pi/2 + gamma_g)];
    gy_high = [0, Ao * sin(pi/2 + gamma_g)];

    % Pitch Point P at outer heel:
    px_P = Ao * cos(gamma_p);
    py_P = Ao * sin(gamma_p);

    % Face width segment on pitch line (from Ai to Ao)
    px_face = [Ai * cos(gamma_p), Ao * cos(gamma_p)];
    py_face = [Ai * sin(gamma_p), Ao * sin(gamma_p)];

    % Pinion heel back-cone (perpendicular to pitch line)
    back_len_p = calc.a_p + calc.b_p;
    n_dir_p = [-sin(gamma_p), cos(gamma_p)];
    plot(ax1, [px_P - back_len_p * n_dir_p(1), px_P + back_len_p * n_dir_p(1)], ...
              [py_P - back_len_p * n_dir_p(2), py_P + back_len_p * n_dir_p(2)], ...
              '-', 'Color', [0.55 0.75 0.95], 'LineWidth', 2.0);

    % Pitch Cones (Dashed lines)
    plot(ax1, px_cone, py_cone, 'y-', 'LineWidth', 2.0); % Common pitch line
    plot(ax1, px_p_low, py_p_low, '--', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.2);
    plot(ax1, gx_high, gy_high, '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);

    % Face width active contact band
    plot(ax1, px_face, py_face, 'r-', 'LineWidth', 4.0);

    % Shaft Centerlines
    plot(ax1, [-10, Ao * 1.15], [0, 0], '-.', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.0); % Pinion shaft
    plot(ax1, [0, 0], [-10, Ao * 1.15], '-.', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.0); % Gear shaft

    % Pitch Point P and Apex (0, 0)
    plot(ax1, 0, 0, 'w+', 'MarkerSize', 12, 'LineWidth', 2.0);
    text(ax1, -3, -6, 'Apex (0, 0)', 'Color', 'w', 'FontSize', 9, 'FontWeight', 'bold');

    plot(ax1, px_P, py_P, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    text(ax1, px_P + 3, py_P + 4, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Dimension: Cone Distance Ao
    plot(ax1, [0, px_P], [py_P + 14, py_P + 14], 'w-', 'LineWidth', 0.9);
    plot(ax1, [0, 0], [py_P + 11, py_P + 17], 'w-', 'LineWidth', 0.9);
    plot(ax1, [px_P, px_P], [py_P + 11, py_P + 17], 'w-', 'LineWidth', 0.9);
    text(ax1, px_P / 2, py_P + 20, sprintf('Outer Cone Dist Ao = %.1f mm', Ao), ...
        'Color', 'w', 'FontSize', 9, 'HorizontalAlignment', 'center');

    % Dimension: Face Width F
    dim_fy = -18;
    plot(ax1, [Ai * cos(gamma_p), Ao * cos(gamma_p)], [dim_fy, dim_fy], 'y-', 'LineWidth', 1.2);
    plot(ax1, [Ai * cos(gamma_p), Ai * cos(gamma_p)], [dim_fy - 3, dim_fy + 3], 'y-', 'LineWidth', 1.2);
    plot(ax1, [Ao * cos(gamma_p), Ao * cos(gamma_p)], [dim_fy - 3, dim_fy + 3], 'y-', 'LineWidth', 1.2);
    text(ax1, (Ai + Ao)/2 * cos(gamma_p), dim_fy - 7, sprintf('Face Width F = %.1f mm', F), ...
        'Color', 'y', 'FontSize', 9, 'HorizontalAlignment', 'center');

    % Angle arcs
    th_arc_p = linspace(0, gamma_p, 40);
    plot(ax1, 28 * cos(th_arc_p), 28 * sin(th_arc_p), 'c-', 'LineWidth', 1.2);
    text(ax1, 32 * cos(gamma_p/2), 32 * sin(gamma_p/2), sprintf('\\gamma_p = %.1f^\\circ', calc.gamma_p_deg), ...
        'Color', 'c', 'FontSize', 9, 'FontWeight', 'bold');

    th_arc_g = linspace(gamma_p, pi/2, 40);
    plot(ax1, 28 * cos(th_arc_g), 28 * sin(th_arc_g), '-', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);
    text(ax1, 32 * cos((gamma_p + pi/2)/2), 32 * sin((gamma_p + pi/2)/2), sprintf('\\gamma_g = %.1f^\\circ', calc.gamma_g_deg), ...
        'Color', [0.95 0.75 0.35], 'FontSize', 9, 'FontWeight', 'bold');

    % Subplot 1 Labels & Styling
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlim(ax1, [-15, 95]); ylim(ax1, [-30, 85]);
    xlabel(ax1, 'Pinion Shaft X [mm]'); ylabel(ax1, 'Gear Shaft Y [mm]');
    title(ax1, sprintf('2D Overview: Straight Bevel Cones (%dT/%dT), \\Sigma = 90^\\circ, m = %g mm', ...
        Np, Ng, m), 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax1, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Detailed Tredgold Meshing Zone (Right Pane)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    % Tredgold virtual radii
    rv_p = calc.rv_p;   % 25.30 mm
    rv_g = calc.rv_g;   % 227.68 mm
    center_v = rv_p + rv_g;

    % Generate accurate Tredgold 2D involute polygons
    [px, py] = generate_2d_gear_polygon(calc.Np, calc.m, calc.phi, calc.a_p, calc.b_p, calc.s_p, 250);
    [gx, gy] = generate_2d_gear_polygon(calc.Ng, calc.m, calc.phi, calc.a_g, calc.b_g, calc.s_g, 250);

    % Scale polygons by 1/cos(gamma) for Tredgold back cone plane
    scale_p = 1 / cos(gamma_p);
    scale_g = 1 / cos(gamma_g);
    px_v = px * scale_p;
    py_v = py * scale_p;
    gx_v = gx * scale_g;
    gy_v = gy * scale_g;

    % Clock gear so teeth mesh at pitch point (rv_p, 0)
    half_pitch_g = pi / Ng;
    rot_g = pi + half_pitch_g;
    cg = cos(rot_g); sg = sin(rot_g);
    gx_rot = gx_v * cg - gy_v * sg + center_v;
    gy_rot = gx_v * sg + gy_v * cg;

    % Draw Pinion (Steel Blue)
    fill(ax2, px_v, py_v, [0.45 0.58 0.78], 'FaceAlpha', 0.85, ...
        'EdgeColor', [0.28 0.36 0.48], 'LineWidth', 1.0);

    % Draw Gear (Bronze)
    fill(ax2, gx_rot, gy_rot, [0.78 0.52 0.28], 'FaceAlpha', 0.85, ...
        'EdgeColor', [0.65 0.40 0.20], 'LineWidth', 1.0);

    % Pitch circles (Dashed lines)
    th_c = linspace(0, 2*pi, 400);
    plot(ax2, rv_p * cos(th_c), rv_p * sin(th_c), '--', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.2);
    plot(ax2, center_v + rv_g * cos(th_c), rv_g * sin(th_c), '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);

    % Base circles (Dotted lines)
    plot(ax2, calc.rvb_p * cos(th_c), calc.rvb_p * sin(th_c), ':', 'Color', [0.4 0.6 0.8], 'LineWidth', 0.8);
    plot(ax2, center_v + calc.rvb_g * cos(th_c), calc.rvb_g * sin(th_c), ':', 'Color', [0.8 0.6 0.3], 'LineWidth', 0.8);

    % Pitch Point P at (rv_p, 0)
    plot(ax2, rv_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % Line of Action through pitch point
    loa_len = 16;
    loa_dir = [sin(phi), cos(phi)];
    loa_p1 = [rv_p - loa_len * loa_dir(1), -loa_len * loa_dir(2)];
    loa_p2 = [rv_p + loa_len * loa_dir(1),  loa_len * loa_dir(2)];
    plot(ax2, [loa_p1(1), loa_p2(1)], [loa_p1(2), loa_p2(2)], 'r-', 'LineWidth', 1.8);
    text(ax2, loa_p2(1) + 1, loa_p2(2) - 1, 'Line of Action', 'Color', [1 0.4 0.4], ...
        'FontSize', 8, 'FontAngle', 'italic', 'Rotation', -20);

    % Pressure angle arc
    th_phi = linspace(0, phi, 30);
    r_arc = 8;
    plot(ax2, rv_p + r_arc * sin(th_phi), r_arc * cos(th_phi), 'r--', 'LineWidth', 1.0);
    text(ax2, rv_p + (r_arc + 2) * sin(phi/2), (r_arc + 2) * cos(phi/2), ...
        sprintf('\\phi = %.1f^\\circ', calc.phi_deg), 'Color', [1 0.3 0.3], 'FontSize', 8, 'FontWeight', 'bold');

    % Contact HUD Card (Top Left)
    card_x = rv_p - 11;
    card_y = 6.8;
    card_w = 8.5;
    card_h = 5.2;
    rectangle(ax2, 'Position', [card_x, card_y, card_w, card_h], ...
        'FaceColor', [0.06 0.08 0.12 0.88], 'EdgeColor', [0.3 0.4 0.55], ...
        'LineWidth', 1.0, 'Curvature', 0.15);

    text(ax2, card_x + 0.4, card_y + 4.3, sprintf('Working Depth: hw = %.2f mm', calc.hw), ...
        'Color', [0.85 0.90 1.0], 'FontSize', 8);
    text(ax2, card_x + 0.4, card_y + 3.1, sprintf('Whole Depth: ht = %.3f mm', calc.ht), ...
        'Color', [0.85 0.90 1.0], 'FontSize', 8);
    text(ax2, card_x + 0.4, card_y + 1.9, sprintf('Clearance: c = %.3f mm', calc.c_std), ...
        'Color', [0.85 0.90 1.0], 'FontSize', 8);
    text(ax2, card_x + 0.4, card_y + 0.7, sprintf('Contact Ratio: CR = %.3f', calc.CR), ...
        'Color', [0.4 1.0 0.5], 'FontSize', 8, 'FontWeight', 'bold');

    % Subplot 2 Styling (Zoomed into Contact Point)
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlim(ax2, [rv_p - 12, rv_p + 12]);
    ylim(ax2, [-12, 13]);
    xlabel(ax2, 'Tredgold Plane X [mm]'); ylabel(ax2, 'Tredgold Plane Y [mm]');
    title(ax2, 'Detailed Meshing Zone (Tredgold Equivalent Contact & Line of Action)', ...
        'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax2, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% Save 300 DPI Exported Image
    script_folder = fileparts(mfilename('fullpath'));
    matlab_dir = fileparts(script_folder);
    parent_dir = fileparts(matlab_dir);
    export_dir = fullfile(parent_dir, 'Solidworks', 'Exported_Models_Straight_Bevel');
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    out_png = fullfile(export_dir, 'straight_bevel_mesh_2d_diagram.png');
    print(fig2, out_png, '-dpng', '-r300');
    fprintf('   [x] Exported 2D Mesh Diagram:   %s\n', out_png);
end

function [x, y] = generate_2d_gear_polygon(N, m, phi, a, b, s, n_pts)
    rp = m * N / 2;
    rb = rp * cos(phi);
    ra = rp + a;
    rd = max(rp - b, 0.3 * rb);
    tau = s / (2 * rp);
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

    n_flank = max(10, round(n_pts / 4));
    rr_up = linspace(r_inv_start, ra, n_flank);
    alpha_up = acos(min(rb ./ rr_up, 1.0));
    inv_u = tan(alpha_up) - alpha_up;
    tt_up = -(tau + inv_phi - inv_u);

    n_tip = max(4, round(n_pts / 8));
    tt_tip = linspace(-theta_tip, theta_tip, n_tip);

    rr_dn = linspace(ra, r_inv_start, n_flank);
    alpha_dn = acos(min(rb ./ rr_dn, 1.0));
    inv_d = tan(alpha_dn) - alpha_dn;
    tt_dn = (tau + inv_phi - inv_d);

    n_root = max(4, round(n_pts / 8));
    tt_root = linspace(theta_root, theta_next_root, n_root);

    % Single tooth
    t_r = [rr_up, ra * ones(1, n_tip), rr_dn, rd * ones(1, n_root)];
    t_t = [tt_up, tt_tip, tt_dn, tt_root];

    % Replicate all teeth
    M = length(t_r);
    tot = N * M;
    x = zeros(1, tot);
    y = zeros(1, tot);
    for k = 0:(N-1)
        th = k * 2 * pi / N;
        c = cos(th); s = sin(th);
        idx = k * M + (1:M);
        cur_x = t_r .* cos(t_t);
        cur_y = t_r .* sin(t_t);
        x(idx) = cur_x * c - cur_y * s;
        y(idx) = cur_x * s + cur_y * c;
    end
end
