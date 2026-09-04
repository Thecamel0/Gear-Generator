function fig1 = plot_helical_assembly_3d(gear_mesh, pinion_mesh, calc)
%PLOT_HELICAL_ASSEMBLY_3D Visualizes the 3D Helical Gear Assembly
%   and a clean single-pair exploded view in dark CAD theme.
%
%   - Subplot 1: 3D CAD Assembly with 3 Pinions at 120 deg on parallel shafts.
%   - Subplot 2: Single-Pair Exploded View along axial shaft lines.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3
        error('plot_helical_assembly_3d requires gear_mesh, pinion_mesh, and calc');
    end

    fig1 = figure('Name', 'Helical Gear Suite — 3D CAD Assembly & Exploded View', ...
        'NumberTitle', 'off', ...
        'Position', [50, 50, 1550, 750], ...
        'Color', [0.07 0.07 0.10]);

    C         = calc.center_dist;
    Np        = calc.Np;
    Ng        = calc.Ng;
    mn        = calc.mn;
    beta_deg  = calc.beta_deg;
    n_pinions = calc.n_pinions;

    %% ====================================================================
    %  SUBPLOT 1: 3D CAD Multi-Pinion Assembly (Left Pane)
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig1);
    hold(ax1, 'on');

    % 1. Central Helical Gear (Golden Bronze, LH)
    patch(ax1, 'Vertices', gear_mesh.vertices, ...
        'Faces', gear_mesh.faces, ...
        'VertexNormals', gear_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.96, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % 2. 3 Driving Pinions arranged at 120 deg (Parallel Shafts, RH)
    pinion_colors = [0.45 0.58 0.78;   % Pinion 1: Steel Blue
                     0.55 0.75 0.55;   % Pinion 2: Sage Green
                     0.72 0.48 0.65;   % Pinion 3: Dusty Lavender
                     0.78 0.68 0.45;
                     0.50 0.70 0.75];

    phi_clock = pi + (pi / Np);

    for p = 1:n_pinions
        theta_p = (p - 1) * (2 * pi / n_pinions);

        % Conjugate meshing rotation
        rot_pin = theta_p + theta_p * (Ng / Np) + phi_clock;
        Rz_pin = [cos(rot_pin) -sin(rot_pin) 0; sin(rot_pin) cos(rot_pin) 0; 0 0 1];

        pin_verts_rot = (Rz_pin * pinion_mesh.vertices')';
        pin_normals_rot = (Rz_pin * pinion_mesh.normals')';

        % Position at center distance C along theta_p
        pos_p = [C * cos(theta_p), C * sin(theta_p), 0];
        pin_verts_pos = pin_verts_rot + pos_p;

        color_idx = mod(p - 1, size(pinion_colors, 1)) + 1;
        patch(ax1, 'Vertices', pin_verts_pos, ...
            'Faces', pinion_mesh.faces, ...
            'VertexNormals', pin_normals_rot, ...
            'FaceColor', pinion_colors(color_idx, :), ...
            'EdgeColor', 'none', ...
            'FaceAlpha', 0.96, ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.38, ...
            'DiffuseStrength', 0.65, ...
            'SpecularStrength', 0.35);
    end

    % Lighting & Styling for Subplot 1
    light(ax1, 'Position', [1 1 1.8], 'Style', 'infinite');
    light(ax1, 'Position', [-1 -1 0.8], 'Style', 'infinite');
    light(ax1, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]'); zlabel(ax1, 'Z [mm]');
    title(ax1, sprintf('3D Helical Assembly: %d Pinions + Gear (mn = %g mm, \\beta = %g^\\circ, C = %.1f mm)', ...
        n_pinions, mn, beta_deg, C), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax1, [-35 32]);
    set(ax1, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Single-Pair Exploded View (Right Pane)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig1);
    hold(ax2, 'on');

    sep_z = 28;  % Axial separation along Z
    sep_x = 18;  % Radial separation along X

    % Displace central gear downwards along -Z
    gear_verts_exp = gear_mesh.vertices;
    gear_verts_exp(:, 3) = gear_verts_exp(:, 3) - sep_z;

    patch(ax2, 'Vertices', gear_verts_exp, ...
        'Faces', gear_mesh.faces, ...
        'VertexNormals', gear_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.96, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % Displace strictly 1 Pinion upwards along +Z and outwards along +X
    Rz_single = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];
    pin_single_rot = (Rz_single * pinion_mesh.vertices')';
    pin_single_norm = (Rz_single * pinion_mesh.normals')';

    pin_single_pos = pin_single_rot + [C + sep_x, 0, sep_z];

    patch(ax2, 'Vertices', pin_single_pos, ...
        'Faces', pinion_mesh.faces, ...
        'VertexNormals', pin_single_norm, ...
        'FaceColor', [0.45 0.58 0.78], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.96, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % Shaft Axis & Explode Lines
    plot3(ax2, [0 0], [0 0], [-calc.F/2 - sep_z - 15, calc.F/2 + 10], 'c-.', 'LineWidth', 1.2);
    plot3(ax2, [C C], [0 0], [-10, calc.F/2 + sep_z + 15], 'm-.', 'LineWidth', 1.2);
    plot3(ax2, [C, C + sep_x], [0, 0], [sep_z, sep_z], 'y--', 'LineWidth', 1.0);

    text(ax2, 0, 0, calc.F/2 + 15, 'Gear Axis', 'Color', 'c', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(ax2, C + sep_x, 0, calc.F/2 + sep_z + 20, 'Pinion Axis', 'Color', 'm', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % Lighting & Styling for Subplot 2
    light(ax2, 'Position', [1 1 1.8], 'Style', 'infinite');
    light(ax2, 'Position', [-1 -1 0.8], 'Style', 'infinite');
    light(ax2, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]'); zlabel(ax2, 'Z [mm]');
    title(ax2, 'Exploded View (Single Pair Engagement)', ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax2, [-35 32]);
    set(ax2, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);
end
