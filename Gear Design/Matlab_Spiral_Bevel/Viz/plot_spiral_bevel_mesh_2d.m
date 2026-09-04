function fig2 = plot_spiral_bevel_mesh_2d(calc)
%PLOT_SPIRAL_BEVEL_MESH_2D Generates publication-grade 2D contact analysis diagrams
%   for a Spiral Bevel Gear drive.
%
%   - Subplot 1: Pitch Cones & 90 deg Orthogonal Shafts Geometry Overview
%   - Subplot 2: High-Magnification Tredgold Meshing Zone & Spiral Contact Analysis
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 1
        error('plot_spiral_bevel_mesh_2d requires calc struct');
    end

    fig2 = figure('Name', 'Spiral Bevel Suite — 2D Engagement & Contact Mechanics', ...
        'NumberTitle', 'off', ...
        'Position', [60, 60, 1500, 750], ...
        'Color', [0.07 0.07 0.10], ...
        'MenuBar', 'figure', ...
        'ToolBar', 'figure');

    m = calc.m;
    Np = calc.Np;
    Ng = calc.Ng;
    phi_n = calc.phi_n;
    phi_t = calc.phi_t;
    beta_m = calc.beta_m;
    beta_m_deg = calc.beta_m_deg;
    Ao = calc.Ao;
    Am = calc.Am;
    Ai = calc.Ai;
    F = calc.F;
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
    % Pitch contact line along angle gamma_p from X-axis
    px_cone = [0, Ao * cos(gamma_p)];
    py_cone = [0, Ao * sin(gamma_p)];

    % Pinion lower pitch cone generator
    px_p_low = [0, Ao * cos(-gamma_p)];
    py_p_low = [0, Ao * sin(-gamma_p)];

    % Gear outer pitch cone generator
    gx_high = [0, Ao * cos(pi/2 + gamma_g)];
    gy_high = [0, Ao * sin(pi/2 + gamma_g)];

    % Pitch Point P at outer heel
    px_P = Ao * cos(gamma_p);
    py_P = Ao * sin(gamma_p);

    % Mean point Pm
    px_Pm = Am * cos(gamma_p);
    py_Pm = Am * sin(gamma_p);

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

    % Mean spiral angle indicator line at Pm
    tang_len = 16;
    tang_angle = gamma_p + beta_m;
    plot(ax1, [px_Pm - tang_len*cos(tang_angle), px_Pm + tang_len*cos(tang_angle)], ...
              [py_Pm - tang_len*sin(tang_angle), py_Pm + tang_len*sin(tang_angle)], ...
              '-', 'Color', [0.3 1.0 0.4], 'LineWidth', 2.0);
    text(ax1, px_Pm + 3, py_Pm - 6, sprintf('Spiral \\beta_m = %.1f^\\circ', beta_m_deg), ...
        'Color', [0.3 1.0 0.4], 'FontSize', 8.5, 'FontWeight', 'bold');

    % Shaft Centerlines
    plot(ax1, [-10, Ao * 1.15], [0, 0], '-.', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.0);
    plot(ax1, [0, 0], [-10, Ao * 1.15], '-.', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.0);

    % Apex and Pitch Points
    plot(ax1, 0, 0, 'w+', 'MarkerSize', 12, 'LineWidth', 2.0);
    text(ax1, -3, -6, 'Apex (0, 0)', 'Color', 'w', 'FontSize', 9, 'FontWeight', 'bold');

    plot(ax1, px_P, py_P, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    text(ax1, px_P + 3, py_P + 4, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    plot(ax1, px_Pm, py_Pm, 'gs', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
    text(ax1, px_Pm + 3, py_Pm + 4, 'Mean Pt (Pm)', 'Color', [0.4 1.0 0.4], 'FontSize', 8.5);

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

    axis(ax1, 'equal'); grid(ax1, 'on');
    xlim(ax1, [-15, Ao * 1.25]); ylim(ax1, [-35, Ao * 1.25]);
    xlabel(ax1, 'X [mm] (Pinion Shaft)'); ylabel(ax1, 'Y [mm] (Gear Shaft)');
    title(ax1, sprintf('2D Overview: Pitch Cones & Geometry (\\Sigma = %.0f^\\circ, \\beta_m = %.0f^\\circ)', ...
        calc.Sigma_deg, beta_m_deg), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    set(ax1, 'Color', [0.10 0.10 0.14], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.32], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Tredgold Meshing Zone & Spiral Contact (Right Pane)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    rv_p  = calc.rv_p;
    rv_g  = calc.rv_g;
    rvb_p = calc.rvb_p;
    rvb_g = calc.rvb_g;
    rva_p = calc.rva_p;
    rva_g = calc.rva_g;
    rvd_p = calc.rvd_p;
    rvd_g = calc.rvd_g;

    % Virtual pitch point is at (rv_p, 0).
    % Pinion center at (0, 0), Gear center at (rv_p + rv_g, 0)
    C_v = rv_p + rv_g;

    th = linspace(-0.25, 0.25, 300);

    % 1. Pitch circles (Yellow dashed)
    plot(ax2, rv_p * cos(th), rv_p * sin(th), 'y--', 'LineWidth', 1.5);
    plot(ax2, C_v - rv_g * cos(th), rv_g * sin(th), 'y--', 'LineWidth', 1.5);

    % 2. Base circles (Dotted)
    plot(ax2, rvb_p * cos(th), rvb_p * sin(th), ':', 'Color', [0.4 0.7 1.0], 'LineWidth', 1.2);
    plot(ax2, C_v - rvb_g * cos(th), rvb_g * sin(th), ':', 'Color', [1.0 0.7 0.3], 'LineWidth', 1.2);

    % 3. Tip circles (Solid)
    plot(ax2, rva_p * cos(th), rva_p * sin(th), '-', 'Color', [0.3 0.8 1.0], 'LineWidth', 1.5);
    plot(ax2, C_v - rva_g * cos(th), rva_g * sin(th), '-', 'Color', [1.0 0.6 0.2], 'LineWidth', 1.5);

    % 4. Root circles (Dash-dot)
    plot(ax2, rvd_p * cos(th), rvd_p * sin(th), '-.', 'Color', [0.2 0.5 0.8], 'LineWidth', 1.0);
    plot(ax2, C_v - rvd_g * cos(th), rvd_g * sin(th), '-.', 'Color', [0.8 0.4 0.1], 'LineWidth', 1.0);

    % 5. Line of Action inclined at transverse pressure angle phi_t
    loa_len = 22;
    loa_x1 = rv_p - loa_len * sin(phi_t);
    loa_y1 = 0 - loa_len * cos(phi_t);
    loa_x2 = rv_p + loa_len * sin(phi_t);
    loa_y2 = 0 + loa_len * cos(phi_t);

    plot(ax2, [loa_x1, loa_x2], [loa_y1, loa_y2], 'r-', 'LineWidth', 2.0);

    % Pitch Point P at (rv_p, 0)
    plot(ax2, rv_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
    text(ax2, rv_p + 1.5, -2, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Line of Action Label
    text(ax2, loa_x2 - 8, loa_y2 + 2, sprintf('Line of Action (\\phi_t = %.1f^\\circ)', calc.phi_t_deg), ...
        'Color', [1 0.3 0.3], 'FontSize', 8.5, 'FontWeight', 'bold');

    % Contact HUD Card
    hud_str = sprintf([ ...
        '\\bfSPIRAL TOOTH ENGAGEMENT\\rm\n' ...
        'Working Depth hw: %.2f mm\n' ...
        'Whole Depth ht: %.2f mm\n' ...
        'Clearance c: %.3f mm\n' ...
        'Transverse CR \\epsilon_\\alpha: %.3f\n' ...
        'Face Overlap \\epsilon_\\beta: %.3f\n' ...
        '\\color[rgb]{0.3,1.0,0.4}Total Contact Ratio \\epsilon_\\gamma: %.3f\\color{white}'], ...
        calc.hw, calc.ht, calc.c_std, calc.eps_alpha, calc.eps_beta, calc.CR);

    text(ax2, rv_p - 18, 12, hud_str, 'Color', 'w', ...
        'BackgroundColor', [0.15 0.15 0.22], 'EdgeColor', [0.35 0.35 0.50], ...
        'FontSize', 8.5, 'Margin', 6, 'HitTest', 'off');

    axis(ax2, 'equal'); grid(ax2, 'on');
    xlim(ax2, [rv_p - 22, rv_p + 22]);
    ylim(ax2, [-18, 18]);
    xlabel(ax2, 'Transverse X [mm]'); ylabel(ax2, 'Transverse Y [mm]');
    title(ax2, sprintf('Tredgold Meshing Zone: \\epsilon_\\gamma = %.3f (\\epsilon_\\alpha = %.2f + \\epsilon_\\beta = %.2f)', ...
        calc.CR, calc.eps_alpha, calc.eps_beta), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    set(ax2, 'Color', [0.10 0.10 0.14], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.32], 'GridAlpha', 0.5);

    drawnow;
end
