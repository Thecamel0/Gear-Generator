function fig2 = plot_spur_mesh_2d(m, Np, Ng, phi_deg, khw_factor, c_factor, s_p, s_g, hw, ht, a_p, a_g, b_p, b_g, CR)
%PLOT_SPUR_MESH_2D Generate 2D tooth mesh and contact analysis figures for spur gears
%
%   Creates Figure 2 with dual subplots:
%     - Subplot 1: Full 2D Pitch Engagement Overview (Engineering Axes, Ticks, Grid, Centerline)
%     - Subplot 2: Close-up High-Magnification Zoom of Active Tooth Mesh Zone
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 1
        % Defaults if run standalone
        m = 3.0; Np = 16; Ng = 48; phi_deg = 20;
        khw_factor = 2.00; c_factor = 0.188;
        hw = khw_factor * m; ht = hw + c_factor * m;
        a_p = 0.600 * hw; a_g = 0.400 * hw;
        b_p = ht - a_p; b_g = ht - a_g;
        s_nom = pi * m / 2; s_shift = 0.180 * m;
        s_p = s_nom + s_shift; s_g = s_nom - s_shift;
        CR = 1.642;
    end

    phi = deg2rad(phi_deg);
    rp_p = m * Np / 2;   % Pinion pitch radius = 24 mm
    rp_g = m * Ng / 2;   % Gear pitch radius   = 72 mm
    center_dist = rp_p + rp_g;  % 96 mm

    % Circles
    rb_p = rp_p * cos(phi); ra_p = rp_p + a_p; rd_p = rp_p - b_p;
    rb_g = rp_g * cos(phi); ra_g = rp_g + a_g; rd_g = rp_g - b_g;

    % Generate high-resolution profiles
    n_pts = 300;
    [px, py] = generate_spur_profile_2d(Np, m, phi, a_p, b_p, s_p, n_pts);
    [gx, gy] = generate_spur_profile_2d(Ng, m, phi, a_g, b_g, s_g, n_pts);

    % Rotate gear to mesh with pinion at pitch point (rp_p, 0)
    half_pitch_g = pi / Ng;
    rot_angle = pi + half_pitch_g;
    cos_r = cos(rot_angle); sin_r = sin(rot_angle);
    gx_r = gx * cos_r - gy * sin_r + center_dist;
    gy_r = gx * sin_r + gy * cos_r;

    % Line of Action
    pitch_pt = [rp_p, 0];
    loa_len = 25;
    loa_dir = [sin(phi), cos(phi)];
    loa_x = [pitch_pt(1) - loa_len*loa_dir(1), pitch_pt(1) + loa_len*loa_dir(1)];
    loa_y = [pitch_pt(2) - loa_len*loa_dir(2), pitch_pt(2) + loa_len*loa_dir(2)];

    % Create Figure 2
    fig2 = figure('Name', 'Spur Gear Suite — 2D Tooth Mesh & Contact Analysis', ...
        'NumberTitle', 'off', ...
        'Position', [60, 60, 1500, 750], ...
        'Color', [0.07 0.07 0.10]);

    %% ====================================================================
    %  SUBPLOT 1: Full 2D Gear Engagement Overview
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig2);
    hold(ax1, 'on');

    % Pinion (Steel Blue: [0.32 0.52 0.78])
    fill(ax1, px, py, [0.32 0.52 0.78], ...
        'EdgeColor', [0.20 0.35 0.55], 'LineWidth', 0.8, 'FaceAlpha', 0.88);

    % Gear (Golden Bronze: [0.78 0.52 0.28])
    fill(ax1, gx_r, gy_r, [0.78 0.52 0.28], ...
        'EdgeColor', [0.55 0.35 0.18], 'LineWidth', 0.8, 'FaceAlpha', 0.88);

    % Full Circles
    theta_c = linspace(0, 2*pi, 400);
    plot(ax1, rp_p*cos(theta_c), rp_p*sin(theta_c), '--', 'Color', [0.5 0.75 1.0], 'LineWidth', 1.2);
    plot(ax1, rb_p*cos(theta_c), rb_p*sin(theta_c), ':', 'Color', [0.4 0.6 0.9], 'LineWidth', 0.8);
    plot(ax1, ra_p*cos(theta_c), ra_p*sin(theta_c), '-', 'Color', [0.3 0.5 0.8 0.4], 'LineWidth', 0.5);

    plot(ax1, center_dist + rp_g*cos(theta_c), rp_g*sin(theta_c), '--', 'Color', [1.0 0.75 0.4], 'LineWidth', 1.2);
    plot(ax1, center_dist + rb_g*cos(theta_c), rb_g*sin(theta_c), ':', 'Color', [0.9 0.6 0.3], 'LineWidth', 0.8);
    plot(ax1, center_dist + ra_g*cos(theta_c), ra_g*sin(theta_c), '-', 'Color', [0.8 0.5 0.2 0.4], 'LineWidth', 0.5);

    % Centers & Center Line
    plot(ax1, [0, center_dist], [0, 0], '-.', 'Color', [0.5 0.5 0.55], 'LineWidth', 0.8);
    plot(ax1, 0, 0, '+', 'Color', [0.5 0.75 1.0], 'MarkerSize', 12, 'LineWidth', 2);
    plot(ax1, center_dist, 0, '+', 'Color', [1.0 0.75 0.4], 'MarkerSize', 12, 'LineWidth', 2);

    % Pitch Point & Line of Action
    plot(ax1, loa_x, loa_y, '-', 'Color', [1.0 0.3 0.3], 'LineWidth', 1.8);
    plot(ax1, rp_p, 0, 'o', 'Color', [1 0.2 0.2], 'MarkerSize', 8, ...
        'LineWidth', 2, 'MarkerFaceColor', [1 0.2 0.2]);

    % Labels on Subplot 1
    text(ax1, -2, -8, sprintf('Pinion (%dT)\nPD = %.0f mm', Np, 2*rp_p), ...
        'Color', [0.5 0.75 1.0], 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(ax1, center_dist, -8, sprintf('Spur Gear (%dT)\nPD = %.0f mm', Ng, 2*rp_g), ...
        'Color', [1.0 0.75 0.4], 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(ax1, rp_p + 2, -4, 'Pitch Point (P)', 'Color', [1 0.4 0.4], 'FontSize', 9, 'FontWeight', 'bold');

    % Center distance dimension line
    dim_y = -35;
    plot(ax1, [0, center_dist], [dim_y, dim_y], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
    plot(ax1, [0 0], [dim_y-2, dim_y+2], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
    plot(ax1, [center_dist center_dist], [dim_y-2, dim_y+2], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
    text(ax1, center_dist/2, dim_y - 4, sprintf('Center Distance C = %.1f mm', center_dist), ...
        'Color', [0.8 0.8 0.8], 'FontSize', 9, 'HorizontalAlignment', 'center');

    title(ax1, sprintf('2D Overview: %dT / %dT (Ratio 1:%.0f, Module = %g mm)', Np, Ng, Ng/Np, m), ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(ax1, 'X [mm]', 'Color', [0.7 0.7 0.7]); ylabel(ax1, 'Y [mm]', 'Color', [0.7 0.7 0.7]);
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlim(ax1, [-ra_p - 5, center_dist + ra_g + 10]);
    ylim(ax1, [-48, 48]);
    set(ax1, 'Color', [0.11 0.11 0.15], 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: High-Magnification Close-up on Meshing Teeth
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    % Fill gears in close-up
    fill(ax2, px, py, [0.32 0.52 0.78], ...
        'EdgeColor', [0.20 0.35 0.55], 'LineWidth', 1.2, 'FaceAlpha', 0.90);
    fill(ax2, gx_r, gy_r, [0.78 0.52 0.28], ...
        'EdgeColor', [0.55 0.35 0.18], 'LineWidth', 1.2, 'FaceAlpha', 0.90);

    % Arc circles in zoomed zone
    theta_z = linspace(-0.6, 0.6, 200);
    plot(ax2, rp_p*cos(theta_z), rp_p*sin(theta_z), '--', 'Color', [0.5 0.75 1.0], 'LineWidth', 1.5);
    plot(ax2, ra_p*cos(theta_z), ra_p*sin(theta_z), ':', 'Color', [0.3 0.6 0.9], 'LineWidth', 1.0);
    plot(ax2, rd_p*cos(theta_z), rd_p*sin(theta_z), ':', 'Color', [0.3 0.6 0.9], 'LineWidth', 1.0);

    theta_zg = linspace(pi-0.3, pi+0.3, 200);
    plot(ax2, center_dist + rp_g*cos(theta_zg), rp_g*sin(theta_zg), '--', 'Color', [1.0 0.75 0.4], 'LineWidth', 1.5);
    plot(ax2, center_dist + ra_g*cos(theta_zg), ra_g*sin(theta_zg), ':', 'Color', [0.9 0.6 0.3], 'LineWidth', 1.0);
    plot(ax2, center_dist + rd_g*cos(theta_zg), rd_g*sin(theta_zg), ':', 'Color', [0.9 0.6 0.3], 'LineWidth', 1.0);

    % Pitch Point & Line of Action in zoom
    plot(ax2, loa_x, loa_y, '-', 'Color', [1.0 0.25 0.25], 'LineWidth', 2.0);
    plot(ax2, rp_p, 0, 'o', 'Color', [1 0.1 0.1], 'MarkerSize', 10, ...
        'LineWidth', 2, 'MarkerFaceColor', [1 0.2 0.2]);

    % Pressure angle arc
    arc_r = 5;
    arc_t = linspace(0, phi, 50);
    plot(ax2, rp_p + arc_r*cos(arc_t + pi/2), arc_r*sin(arc_t + pi/2), ...
        '-', 'Color', [1 0.6 0.6], 'LineWidth', 1.5);
    text(ax2, rp_p + 1.2, arc_r*0.7, sprintf('\\phi = %.1f°', phi_deg), ...
        'Color', [1 0.6 0.6], 'FontSize', 10, 'FontWeight', 'bold');

    % Text annotations for tooth dimensions
    text(ax2, rp_p + 1.2, -1.8, 'Pitch Point (P)', ...
        'Color', [1 0.3 0.3], 'FontSize', 10, 'FontWeight', 'bold');
    text(ax2, rp_p + loa_len*loa_dir(1)*0.35, loa_len*loa_dir(2)*0.35 + 1.2, ...
        'Line of Action', 'Color', [1 0.35 0.35], 'FontSize', 9, ...
        'FontAngle', 'italic', 'Rotation', rad2deg(atan2(loa_dir(2), loa_dir(1))));

    % Dimension labels card in top-left
    text(ax2, 17.5, 12, sprintf('Working Depth: h_w = %.2f mm\nWhole Depth: h_t = %.3f mm\nClearance: c = %.3f mm\nContact Ratio: CR = %.3f', ...
        hw, ht, c_factor*m, CR), ...
        'Color', 'w', 'FontSize', 9, 'BackgroundColor', [0.14 0.14 0.20], ...
        'EdgeColor', [0.35 0.35 0.45], 'Margin', 6);

    title(ax2, 'Detailed Meshing Zone (Tooth Contact & Line of Action)', ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(ax2, 'X [mm]', 'Color', [0.7 0.7 0.7]); ylabel(ax2, 'Y [mm]', 'Color', [0.7 0.7 0.7]);
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlim(ax2, [rp_p - 10, rp_p + 12]);
    ylim(ax2, [-12, 14]);
    set(ax2, 'Color', [0.11 0.11 0.15], 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6], ...
        'GridColor', [0.22 0.22 0.28], 'GridAlpha', 0.5);

    %% Save exported PNGs
    script_folder = fileparts(mfilename('fullpath')); % .../Matlab_Spur/Viz
    matlab_spur_dir = fileparts(script_folder);       % .../Matlab_Spur
    gear_design_dir = fileparts(matlab_spur_dir);     % .../Gear Design

    % Save in Matlab_Spur/Viz
    exportgraphics(fig2, fullfile(script_folder, 'spur_mesh_2d_diagram.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.07 0.07 0.10]);

    % Save in Solidworks/Exported_Models_Spur
    fig_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Spur');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    exportgraphics(fig2, fullfile(fig_dir, 'spur_mesh_2d_diagram.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.07 0.07 0.10]);
end
