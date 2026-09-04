function fig1 = plot_straight_bevel_assembly_3d(gear_mesh, pinion_mesh, calc)
%PLOT_STRAIGHT_BEVEL_ASSEMBLY_3D Generates publication-grade 3D CAD assembly
%   and single-pair exploded view for a Straight Bevel Gear drive.
%
%   - Subplot 1: Full 3D CAD Assembly (Central Gear + 3 Multi-Pinions on 90 deg shafts)
%   - Subplot 2: Single-Pair Exploded View (1 Pinion + 1 Gear separated along shafts)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3
        error('plot_straight_bevel_assembly_3d requires gear_mesh, pinion_mesh, and calc');
    end

    n_pinions = calc.n_pinions;
    Ao = calc.Ao;
    Np = calc.Np;
    Ng = calc.Ng;
    m = calc.m;

    fig1 = figure('Name', 'Straight Bevel Suite — 3D CAD Assembly & Exploded View', ...
        'NumberTitle', 'off', ...
        'Position', [50, 50, 1400, 850], ...
        'Color', [0.08 0.08 0.11], ...
        'MenuBar', 'figure', ...
        'ToolBar', 'figure');

    %% ====================================================================
    %  SUBPLOT 1: Full 3D CAD Assembly (Central Gear + 3 Pinions at 120 deg)
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig1);
    hold(ax1, 'on');

    % 1. Central Straight Bevel Gear (Golden Bronze [0.78 0.52 0.28])
    patch(ax1, 'Vertices', gear_mesh.vertices, ...
        'Faces', gear_mesh.faces, ...
        'VertexNormals', gear_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % 2. 3 Multi-Pinions arranged at 120 deg on 90 deg orthogonal shafts
    pinion_colors = [0.45 0.58 0.78;   % Pinion 1: Steel Blue
                     0.55 0.75 0.55;   % Pinion 2: Sage Green
                     0.72 0.48 0.65;   % Pinion 3: Dusty Lavender
                     0.78 0.68 0.45;   % Warm Ochre
                     0.50 0.70 0.75;   % Cyan Teal
                     0.70 0.55 0.55];  % Terra Cotta

    Ry90 = [0 0 1; 0 1 0; -1 0 0];
    phi_clock = pi / Np;
    R_clock = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];

    for p = 1:n_pinions
        angle_offset = (p - 1) * 2 * pi / n_pinions;
        c_a = cos(angle_offset);
        s_a = sin(angle_offset);
        Rz = [c_a -s_a 0; s_a c_a 0; 0 0 1];

        phase_angle = angle_offset * (Ng / Np);
        R_phase = [cos(phase_angle) -sin(phase_angle) 0; sin(phase_angle) cos(phase_angle) 0; 0 0 1];
        R_pinion = Rz * Ry90 * R_clock * R_phase;

        pin_verts = (R_pinion * pinion_mesh.vertices')';
        pin_normals = (R_pinion * pinion_mesh.normals')';

        color_idx = mod(p - 1, size(pinion_colors, 1)) + 1;
        patch(ax1, 'Vertices', pin_verts, ...
            'Faces', pinion_mesh.faces, ...
            'VertexNormals', pin_normals, ...
            'FaceColor', pinion_colors(color_idx, :), ...
            'EdgeColor', 'none', ...
            'FaceAlpha', 0.95, ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.38, ...
            'DiffuseStrength', 0.65, ...
            'SpecularStrength', 0.35);
    end

    % Lighting & Styling for Subplot 1
    light(ax1, 'Position', [1 1 1.5], 'Style', 'infinite');
    light(ax1, 'Position', [-1 -1 0.8], 'Style', 'infinite');
    light(ax1, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]'); zlabel(ax1, 'Z [mm]');
    title(ax1, sprintf('3D Straight Bevel Assembly: %d Pinions + Gear (m = %g mm, Ao = %.1f mm)', ...
        n_pinions, m, Ao), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax1, [-40 30]);
    set(ax1, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Exploded View (SINGLE PAIR: 1 Pinion + 1 Central Gear)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig1);
    hold(ax2, 'on');

    sep = Ao * 0.35; % Axial separation distance along shafts [mm]

    % 1. Central Gear displaced along -Z
    gear_exp_verts = gear_mesh.vertices;
    gear_exp_verts(:, 3) = gear_exp_verts(:, 3) - sep;

    patch(ax2, 'Vertices', gear_exp_verts, ...
        'Faces', gear_mesh.faces, ...
        'VertexNormals', gear_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % 2. ONLY ONE PINION (Pinion 1) displaced along its shaft axis +X
    R_pin1 = Ry90 * R_clock;
    pin1_exp_verts = (R_pin1 * pinion_mesh.vertices')';
    pin1_exp_verts(:, 1) = pin1_exp_verts(:, 1) + sep;
    pin1_normals = (R_pin1 * pinion_mesh.normals')';

    patch(ax2, 'Vertices', pin1_exp_verts, ...
        'Faces', pinion_mesh.faces, ...
        'VertexNormals', pin1_normals, ...
        'FaceColor', [0.45 0.58 0.78], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.38, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % Separation guide arrows / dashed centerlines
    plot3(ax2, [0, 0], [0, 0], [0, -sep], 'w--', 'LineWidth', 1.2);
    plot3(ax2, [0, sep], [0, 0], [0, 0], 'c--', 'LineWidth', 1.2);

    % Lighting & Styling for Subplot 2
    light(ax2, 'Position', [1 0.5 1.5], 'Style', 'infinite');
    light(ax2, 'Position', [-0.5 -1 0.8], 'Style', 'infinite');
    light(ax2, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]'); zlabel(ax2, 'Z [mm]');
    title(ax2, 'Exploded View (Single Pair Engagement)', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax2, [-35 25]);
    set(ax2, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);

    rotate3d(fig1, 'on');

    %% Save 300 DPI Exported Image
    script_folder = fileparts(mfilename('fullpath'));
    matlab_dir = fileparts(script_folder);
    parent_dir = fileparts(matlab_dir);
    export_dir = fullfile(parent_dir, 'Solidworks', 'Exported_Models_Straight_Bevel');
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    out_png = fullfile(export_dir, 'straight_bevel_cad_assembly.png');
    print(fig1, out_png, '-dpng', '-r300');
    fprintf('   [x] Exported 3D Assembly Figure: %s\n', out_png);
end
