function fig2 = plot_helical_mesh_2d(calc)
%PLOT_HELICAL_MESH_2D Generates publication-grade 2D contact analysis diagrams
%   for an external Helical Gear drive in the transverse engagement plane.
%
%   - Subplot 1: Full 2D Engagement Overview with Pitch, Base, Tip Circles & Line of Action
%   - Subplot 2: High-Magnification Meshing Zone with Transverse Line of Action & HUD Card
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1
        error('plot_helical_mesh_2d requires calc struct');
    end

    fig2 = figure('Name', 'Helical Gear Suite — 2D Transverse Engagement & Contact Mechanics', ...
        'NumberTitle', 'off', ...
        'Position', [60, 60, 1500, 750], ...
        'Color', [0.07 0.07 0.10]);

    mn       = calc.mn;
    mt       = calc.mt;
    Np       = calc.Np;
    Ng       = calc.Ng;
    beta_deg = calc.beta_deg;
    phi_t    = calc.phi_t;
    C        = calc.center_dist;
    rp_p     = calc.rp_p;
    rp_g     = calc.rp_g;
    rb_p     = calc.rb_p;
    rb_g     = calc.rb_g;
    ra_p     = calc.ra_p;
    ra_g     = calc.ra_g;
    rd_p     = calc.rd_p;
    rd_g     = calc.rd_g;

    %% ====================================================================
    %  SUBPLOT 1: Full 2D Engagement Overview (Left Pane)
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig2);
    hold(ax1, 'on');

    th = linspace(0, 2*pi, 360);

    % 1. Pitch Circles (Touching at Pitch Point P [rp_p, 0])
    plot(ax1, rp_p * cos(th), rp_p * sin(th), 'y--', 'LineWidth', 1.5);
    plot(ax1, C + rp_g * cos(th), rp_g * sin(th), 'y--', 'LineWidth', 1.5);

    % 2. Base Circles
    plot(ax1, rb_p * cos(th), rb_p * sin(th), ':', 'Color', [0.5 0.8 1.0], 'LineWidth', 1.0);
    plot(ax1, C + rb_g * cos(th), rb_g * sin(th), ':', 'Color', [1.0 0.7 0.4], 'LineWidth', 1.0);

    % 3. Tip (Addendum) Circles
    plot(ax1, ra_p * cos(th), ra_p * sin(th), '-', 'Color', [0.3 0.6 0.9], 'LineWidth', 1.2);
    plot(ax1, C + ra_g * cos(th), ra_g * sin(th), '-', 'Color', [0.9 0.6 0.2], 'LineWidth', 1.2);

    % 4. Root (Dedendum) Circles
    plot(ax1, rd_p * cos(th), rd_p * sin(th), '-.', 'Color', [0.2 0.4 0.6], 'LineWidth', 0.8);
    plot(ax1, C + rd_g * cos(th), rd_g * sin(th), '-.', 'Color', [0.6 0.4 0.2], 'LineWidth', 0.8);

    % 5. Line of Action (passes through pitch point [rp_p, 0] at transverse angle phi_t)
    loa_len = 28;
    loa_p1 = [rp_p - loa_len * sin(phi_t), -loa_len * cos(phi_t)];
    loa_p2 = [rp_p + loa_len * sin(phi_t),  loa_len * cos(phi_t)];
    plot(ax1, [loa_p1(1), loa_p2(1)], [loa_p1(2), loa_p2(2)], 'r-', 'LineWidth', 2.0);

    % Pitch Point P
    plot(ax1, rp_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    text(ax1, rp_p + 2, 5, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Shaft Centers & Line of Centers
    plot(ax1, [0, C], [0, 0], 'w-.', 'LineWidth', 1.0);
    plot(ax1, 0, 0, 'c+', 'MarkerSize', 10, 'LineWidth', 1.5);
    plot(ax1, C, 0, 'm+', 'MarkerSize', 10, 'LineWidth', 1.5);
    text(ax1, 0, -8, 'Pinion Center', 'Color', 'c', 'FontSize', 9, 'HorizontalAlignment', 'center');
    text(ax1, C, -8, 'Gear Center', 'Color', 'm', 'FontSize', 9, 'HorizontalAlignment', 'center');

    % Center Distance Dimension
    dim_y = -ra_p - 14;
    plot(ax1, [0, C], [dim_y, dim_y], 'w-', 'LineWidth', 1.0);
    plot(ax1, [0, 0], [dim_y - 3, dim_y + 3], 'w-', 'LineWidth', 1.0);
    plot(ax1, [C, C], [dim_y - 3, dim_y + 3], 'w-', 'LineWidth', 1.0);
    text(ax1, C / 2, dim_y - 6, sprintf('Center Distance C = %.2f mm', C), ...
        'Color', 'w', 'FontSize', 9, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

    % Subplot 1 Labels & Styling
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlim(ax1, [-ra_p - 10, C + ra_g + 10]);
    ylim(ax1, [-ra_g - 15, ra_g + 15]);
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]');
    title(ax1, sprintf('2D Overview: Helical Engagement (%dT/%dT), \\beta = %g^\\circ, mn = %g mm', ...
        Np, Ng, beta_deg, mn), 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax1, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Detailed Meshing Zone & Line of Action (Right Pane)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    % Generate accurate transverse gear tooth polygons
    [px, py] = generate_transverse_gear_polygon(calc.Np, calc.mt, calc.phi_t, calc.a_p, calc.b_p, calc.st_p, 250);
    [gx, gy] = generate_transverse_gear_polygon(calc.Ng, calc.mt, calc.phi_t, calc.a_g, calc.b_g, calc.st_g, 250);

    % Rotate gear to mesh with pinion at pitch point (rp_p, 0)
    half_pitch_g = pi / calc.Ng;
    rot_angle = pi + half_pitch_g;
    gx_r = gx * cos(rot_angle) - gy * sin(rot_angle) + C;
    gy_r = gx * sin(rot_angle) + gy * cos(rot_angle);

    % Fill Pinion Teeth (Steel Blue)
    patch(ax2, px, py, [0.45 0.58 0.78], 'FaceAlpha', 0.65, 'EdgeColor', [0.25 0.38 0.58], 'LineWidth', 1.2);

    % Fill Central Gear Teeth (Golden Bronze)
    patch(ax2, gx_r, gy_r, [0.78 0.52 0.28], 'FaceAlpha', 0.65, 'EdgeColor', [0.55 0.35 0.18], 'LineWidth', 1.2);

    % Pitch Circles Zoom
    th_zoom = linspace(-0.4, 0.4, 100);
    plot(ax2, rp_p * cos(th_zoom), rp_p * sin(th_zoom), 'y--', 'LineWidth', 1.5);
    plot(ax2, C - rp_g * cos(th_zoom), rp_g * sin(th_zoom), 'y--', 'LineWidth', 1.5);

    % Line of Action in Contact Zone
    plot(ax2, [loa_p1(1), loa_p2(1)], [loa_p1(2), loa_p2(2)], 'r-', 'LineWidth', 2.5);
    text(ax2, loa_p2(1) + 1, loa_p2(2), sprintf('Line of Action (\\phi_t = %.2f^\\circ)', calc.phi_t_deg), ...
        'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Transverse Base Pitch vector along Line of Action
    pbt_v1 = [rp_p, 0];
    pbt_v2 = [rp_p + calc.p_bt * sin(phi_t), calc.p_bt * cos(phi_t)];
    plot(ax2, [pbt_v1(1), pbt_v2(1)], [pbt_v1(2), pbt_v2(2)], 'g-', 'LineWidth', 3.0);
    text(ax2, (pbt_v1(1) + pbt_v2(1))/2 + 1, (pbt_v1(2) + pbt_v2(2))/2 - 1, ...
        sprintf('p_{bt} = %.2f mm', calc.p_bt), 'Color', [0.4 1.0 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Pitch Point P
    plot(ax2, rp_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % Contact HUD Card (Top Left)
    hud_x = rp_p - 11.5;
    hud_y = 6.0;
    hud_w = 11.0;
    hud_h = 5.2;

    rectangle(ax2, 'Position', [hud_x, hud_y, hud_w, hud_h], ...
        'Curvature', 0.15, 'FaceColor', [0.15 0.15 0.22], ...
        'EdgeColor', [0.35 0.35 0.45], 'LineWidth', 1.2);

    text(ax2, hud_x + 0.5, hud_y + 4.3, sprintf('Working Depth: hw = %.2f mm', calc.hw), ...
        'Color', 'w', 'FontSize', 8.5);
    text(ax2, hud_x + 0.5, hud_y + 3.4, sprintf('Whole Depth: ht = %.3f mm', calc.ht), ...
        'Color', 'w', 'FontSize', 8.5);
    text(ax2, hud_x + 0.5, hud_y + 2.5, sprintf('Clearance: c = %.3f mm', calc.c_std), ...
        'Color', 'w', 'FontSize', 8.5);
    text(ax2, hud_x + 0.5, hud_y + 1.6, sprintf('Transverse CR: \\epsilon_\\alpha = %.3f', calc.eps_alpha), ...
        'Color', 'w', 'FontSize', 8.5);
    text(ax2, hud_x + 0.5, hud_y + 0.7, sprintf('Total CR: \\epsilon_\\gamma = %.3f (Overlap \\epsilon_\\beta = %.2f)', ...
        calc.eps_gamma, calc.eps_beta), 'Color', [0.3 1.0 0.4], 'FontSize', 8.5, 'FontWeight', 'bold');

    % Subplot 2 Labels & Styling
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlim(ax2, [rp_p - 12, rp_p + 14]);
    ylim(ax2, [-12, 12]);
    xlabel(ax2, 'Transverse X [mm]'); ylabel(ax2, 'Transverse Y [mm]');
    title(ax2, 'Detailed Meshing Zone (Transverse Contact & Line of Action)', ...
        'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax2, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);
end

%% ========================================================================
%  Local Helper: generate_transverse_gear_polygon
%  ========================================================================
function [px, py] = generate_transverse_gear_polygon(N, mt, phi_t, a, b, s_thick_t, n_inv)
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

    tooth_r = [];
    tooth_t = [];

    % Left root
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_d, r_b, nr);
        tooth_r = [tooth_r, rr(1:end-1)];
        tooth_t = [tooth_t, repmat(-tau - inv_phi, 1, nr-1)];
    end

    % Left involute
    rr = linspace(r_inv_start, r_a, n_inv);
    for i = 1:n_inv
        alpha_i = acos(min(r_b / rr(i), 1));
        inv_alpha = tan(alpha_i) - alpha_i;
        tooth_r(end+1) = rr(i);
        tooth_t(end+1) = -(tau + inv_phi - inv_alpha);
    end

    % Tip
    tooth_r(end+1) = r_a;
    tooth_t(end+1) = theta_tip;

    % Right involute
    rr = linspace(r_a, r_inv_start, n_inv);
    for i = 1:n_inv
        alpha_i = acos(min(r_b / rr(i), 1));
        inv_alpha = tan(alpha_i) - alpha_i;
        tooth_r(end+1) = rr(i);
        tooth_t(end+1) = tau + inv_phi - inv_alpha;
    end

    % Right root
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_b, r_d, nr);
        tooth_r = [tooth_r, rr(2:end)];
        tooth_t = [tooth_t, repmat(tau + inv_phi, 1, nr-1)];
    end

    % Root land
    tt_root = linspace(theta_root, theta_next_root, 4);
    tooth_r = [tooth_r, repmat(r_d, 1, 2)];
    tooth_t = [tooth_t, tt_root(2:3)];

    % Replicate for all N teeth
    M_single = length(tooth_r);
    px = zeros(1, N * M_single);
    py = zeros(1, N * M_single);

    for t = 1:N
        offset = (t - 1) * (2 * pi / N);
        idx = (t - 1) * M_single + (1:M_single);
        angles = tooth_t + offset;
        px(idx) = tooth_r .* cos(angles);
        py(idx) = tooth_r .* sin(angles);
    end
end
