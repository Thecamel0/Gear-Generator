function fig2 = plot_internal_spur_mesh_2d(calc)
%PLOT_INTERNAL_SPUR_MESH_2D Generates publication-grade 2D contact analysis diagrams
%   for an Internal Ring Gear mating with an External Pinion.
%
%   - Subplot 1: Full 2D Engagement Overview (Pinion meshing inside Ring Gear)
%   - Subplot 2: High-Magnification Meshing Zone (Concave-Convex contact & Line of Action)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1
        error('plot_internal_spur_mesh_2d requires calc struct');
    end

    fig2 = figure('Name', 'Internal Spur Suite — 2D Engagement & Contact Mechanics', ...
        'NumberTitle', 'off', ...
        'Position', [80, 80, 1400, 750], ...
        'Color', [0.07 0.07 0.10]);

    % Kinematics & Radii
    m = calc.m;
    Np = calc.Np;
    Ng = calc.Ng;
    phi = calc.phi;
    C = calc.center_dist;   % 48.0 mm (Pinion center at X = +C)

    rp_p = calc.rp_p;       % 24.0 mm
    rb_p = calc.rb_p;
    ra_p = calc.ra_p;
    rd_p = calc.rd_p;

    rp_g = calc.rp_g;       % 72.0 mm (Ring gear centered at 0, 0)
    rb_g = calc.rb_g;
    ra_g = calc.ra_g_int;   % 69.6 mm (inner tip)
    rd_g = calc.rd_g_int;   % 76.16 mm (inner root)
    r_rim = calc.r_rim;     % 88.16 mm

    % Generate accurate closed polygons
    [xc_ring, yc_ring, x_rim, y_rim, xc_pin, yc_pin] = generate_internal_spur_profile_2d(calc, 60);

    % Pinion center is at (C, 0) = (48, 0).
    % Pinion tooth 0 is centered at 0 deg (pointing along +X towards pitch point at 72, 0).
    % Ring gear has tooth space centered at 0 deg (pitch point at 72, 0).
    px_m = xc_pin + C;
    py_m = yc_pin;

    % Line of Action (passes through pitch point (rp_g, 0) at angle phi)
    loa_len = 22;
    loa_dir = [sin(phi), cos(phi)];
    px_pt = rp_g; % 72.0 mm
    py_pt = 0;
    loa_p1 = [px_pt - loa_len * loa_dir(1), py_pt - loa_len * loa_dir(2)];
    loa_p2 = [px_pt + loa_len * loa_dir(1), py_pt + loa_len * loa_dir(2)];

    %% ====================================================================
    %  SUBPLOT 1: Full 2D Engagement Overview (Left Pane)
    %  ===================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig2);
    hold(ax1, 'on');

    % 1. Internal Ring Gear (Bronze filled annular polygon)
    xc_teeth_cw = fliplr(xc_ring);
    yc_teeth_cw = fliplr(yc_ring);
    pgon_ring = polyshape({x_rim, xc_teeth_cw}, {y_rim, yc_teeth_cw}, 'Simplify', false);
    plot(pgon_ring, 'FaceColor', [0.78 0.52 0.28], 'FaceAlpha', 0.65, ...
        'EdgeColor', [0.65 0.40 0.20], 'LineWidth', 1.0, 'Parent', ax1);

    % 2. Mating External Pinion (Steel Blue filled polygon)
    fill(ax1, px_m, py_m, [0.45 0.58 0.78], 'FaceAlpha', 0.85, ...
        'EdgeColor', [0.28 0.36 0.48], 'LineWidth', 1.0);

    % 3. Pitch Circles (Dashed lines)
    th_c = linspace(0, 2*pi, 360);
    plot(ax1, rp_g * cos(th_c), rp_g * sin(th_c), '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);
    plot(ax1, C + rp_p * cos(th_c), rp_p * sin(th_c), '--', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.2);

    % 4. Centerline, Centers & Pitch Point
    plot(ax1, [-10, 100], [0, 0], '-.', 'Color', [0.5 0.5 0.6], 'LineWidth', 0.9);
    plot(ax1, 0, 0, '+', 'Color', [0.95 0.75 0.35], 'MarkerSize', 10, 'LineWidth', 1.5);
    plot(ax1, C, 0, '+', 'Color', [0.55 0.75 0.95], 'MarkerSize', 10, 'LineWidth', 1.5);
    plot(ax1, px_pt, py_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

    % 5. Line of Action segment
    plot(ax1, [loa_p1(1), loa_p2(1)], [loa_p1(2), loa_p2(2)], 'r-', 'LineWidth', 1.5);

    % 6. Dimension Line: Center Distance C = 48.0 mm
    dim_y = -35;
    plot(ax1, [0, C], [dim_y, dim_y], 'w-', 'LineWidth', 1.0);
    plot(ax1, [0, 0], [dim_y - 3, dim_y + 3], 'w-', 'LineWidth', 1.0);
    plot(ax1, [C, C], [dim_y - 3, dim_y + 3], 'w-', 'LineWidth', 1.0);
    text(C / 2, dim_y - 7, sprintf('Center Distance C = %.1f mm', C), ...
        'Color', 'w', 'FontSize', 9, 'HorizontalAlignment', 'center');

    % Text labels
    text(0, 15, sprintf('Ring Gear (%dT)\nPD = %.0f mm', Ng, 2*rp_g), ...
        'Color', [0.95 0.75 0.35], 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C, -15, sprintf('Pinion (%dT)\nPD = %.0f mm', Np, 2*rp_p), ...
        'Color', [0.55 0.75 0.95], 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(px_pt + 4, 6, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 8, 'FontWeight', 'bold');

    % Styling Subplot 1
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlim(ax1, [-95, 105]); ylim(ax1, [-95, 95]);
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]');
    title(ax1, sprintf('2D Overview: Internal Ring (%dT) + Pinion (%dT), Ratio 1:%.0f, m = %g mm', ...
        Ng, Np, calc.i_ratio, m), 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax1, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Detailed Meshing Zone (Right Pane)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    % High zoom around Pitch Point (72, 0)
    fill(ax2, px_m, py_m, [0.45 0.58 0.78], 'FaceAlpha', 0.90, ...
        'EdgeColor', [0.28 0.36 0.48], 'LineWidth', 1.3);
    plot(pgon_ring, 'FaceColor', [0.78 0.52 0.28], 'FaceAlpha', 0.85, ...
        'EdgeColor', [0.65 0.40 0.20], 'LineWidth', 1.3, 'Parent', ax2);

    % Pitch Circles (high zoom)
    plot(ax2, rp_g * cos(th_c), rp_g * sin(th_c), '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.3);
    plot(ax2, C + rp_p * cos(th_c), rp_p * sin(th_c), '--', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.3);

    % Base Circles (dotted)
    plot(ax2, rb_g * cos(th_c), rb_g * sin(th_c), ':', 'Color', [0.75 0.60 0.30], 'LineWidth', 1.1);
    plot(ax2, C + rb_p * cos(th_c), rb_p * sin(th_c), ':', 'Color', [0.40 0.60 0.80], 'LineWidth', 1.1);

    % Tip Circles (solid)
    plot(ax2, ra_g * cos(th_c), ra_g * sin(th_c), '-', 'Color', [0.95 0.85 0.50], 'LineWidth', 1.1);
    plot(ax2, C + ra_p * cos(th_c), ra_p * sin(th_c), '-', 'Color', [0.65 0.85 1.00], 'LineWidth', 1.1);

    % Pitch Point (P)
    plot(ax2, px_pt, py_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % Line of Action
    plot(ax2, [loa_p1(1), loa_p2(1)], [loa_p1(2), loa_p2(2)], 'r-', 'LineWidth', 2.0);

    % Pressure angle arc at pitch point
    th_phi = linspace(pi/2 - phi, pi/2, 20);
    r_arc = 7.0;
    plot(ax2, px_pt - r_arc * cos(th_phi), py_pt + r_arc * sin(th_phi), 'r--', 'LineWidth', 1.2);
    text(px_pt - 4.5, 5.5, sprintf('\\phi = %.1f^\\circ', calc.phi_deg), ...
        'Color', 'r', 'FontSize', 9, 'FontWeight', 'bold');

    % Text on Line of Action
    t_loa = text(px_pt + 3, -4.5, 'Line of Action', ...
        'Color', [1 0.35 0.35], 'FontSize', 9, 'FontAngle', 'italic', 'FontWeight', 'bold');
    set(t_loa, 'Rotation', rad2deg(atan2(loa_dir(2), loa_dir(1))));

    % Contact HUD Card in Top-Left
    info_str = {
        sprintf('Working Depth: hw = %.2f mm', calc.hw), ...
        sprintf('Whole Depth: ht = %.3f mm', calc.ht), ...
        sprintf('Clearance: c = %.3f mm', calc.c_std), ...
        sprintf('Contact Ratio: CR = %.3f', calc.CR)
    };
    annotation(fig2, 'textbox', [0.55 0.72 0.16 0.14], ...
        'String', info_str, ...
        'BackgroundColor', [0.14 0.14 0.20], ...
        'Color', 'w', ...
        'EdgeColor', [0.35 0.35 0.45], ...
        'FontSize', 9, 'FitBoxToText', 'on');

    % Styling Subplot 2
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlim(ax2, [px_pt - 12, px_pt + 14]); % [60, 86] mm
    ylim(ax2, [-14, 16]);
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]');
    title(ax2, 'Detailed Meshing Zone (Internal Tooth Contact & Line of Action)', ...
        'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax2, 'Color', [0.11 0.11 0.15], ...
        'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% Save exported PNGs
    script_folder = fileparts(mfilename('fullpath'));
    matlab_dir = fileparts(script_folder);
    gear_design_dir = fileparts(matlab_dir);

    exportgraphics(fig2, fullfile(script_folder, 'internal_spur_mesh_2d_diagram.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.07 0.07 0.10]);

    fig_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Internal_Spur');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    exportgraphics(fig2, fullfile(fig_dir, 'internal_spur_mesh_2d_diagram.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.07 0.07 0.10]);
end
