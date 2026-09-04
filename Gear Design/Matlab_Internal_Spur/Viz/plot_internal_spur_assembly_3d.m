function fig1 = plot_internal_spur_assembly_3d(ring_mesh, pinion_mesh, calc)
%PLOT_INTERNAL_SPUR_ASSEMBLY_3D Generates 3D CAD Assembly and Single-Pair Exploded View
%   for an Internal Spur Ring Gear and Mating Pinions.
%
%   - Subplot 1: Full 3D CAD Assembly (Internal Ring Gear + 3 Multi-Pinions inside)
%   - Subplot 2: Exploded View with SINGLE PAIR (1 Pinion + 1 Ring Gear)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3
        error('plot_internal_spur_assembly_3d requires ring_mesh, pinion_mesh, and calc');
    end

    n_pinions = calc.n_pinions;
    C = calc.center_dist; % 48.0 mm
    Np = calc.Np;
    Ng = calc.Ng;
    m = calc.m;

    fig1 = figure('Name', 'Internal Spur Suite — 3D CAD Assembly & Exploded View', ...
        'NumberTitle', 'off', ...
        'Position', [50, 50, 1400, 850], ...
        'Color', [0.08 0.08 0.11]);

    %% ====================================================================
    %  SUBPLOT 1: Full 3D CAD Assembly (Ring Gear + 3 Pinions Inside)
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig1);
    hold(ax1, 'on');

    % 1. Internal Ring Gear (Golden Bronze) with dedicated flat normals
    patch(ax1, 'Vertices', ring_mesh.vertices, ...
        'Faces', ring_mesh.faces, ...
        'VertexNormals', ring_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.40, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.35);

    % 2. Multi-Pinions INSIDE Ring Gear at Radius C = 48 mm
    pinion_colors = [0.45 0.58 0.78;   % Steel Blue
                     0.55 0.75 0.55;   % Sage Green
                     0.72 0.48 0.65;   % Dusty Lavender
                     0.78 0.68 0.45;   % Warm Ochre
                     0.50 0.70 0.75;   % Cyan Teal
                     0.70 0.55 0.55];  % Terra Cotta

    for p = 1:n_pinions
        th_p = (p - 1) * 2 * pi / n_pinions;
        c_p = cos(th_p);
        s_p = sin(th_p);

        % Rotational clocking for internal mesh:
        % Ring and pinion rotate in same sense.
        rot_phase = th_p + th_p * (Ng / Np);
        c_rot = cos(rot_phase);
        s_rot = sin(rot_phase);
        Rz_pin = [c_rot -s_rot 0; s_rot c_rot 0; 0 0 1];

        pin_verts = (Rz_pin * pinion_mesh.vertices')';
        pin_verts(:, 1) = pin_verts(:, 1) + C * c_p;
        pin_verts(:, 2) = pin_verts(:, 2) + C * s_p;

        pin_normals = (Rz_pin * pinion_mesh.normals')';

        color_idx = mod(p - 1, size(pinion_colors, 1)) + 1;
        patch(ax1, 'Vertices', pin_verts, ...
            'Faces', pinion_mesh.faces, ...
            'VertexNormals', pin_normals, ...
            'FaceColor', pinion_colors(color_idx, :), ...
            'EdgeColor', 'none', ...
            'FaceAlpha', 0.95, ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.40, ...
            'DiffuseStrength', 0.65, ...
            'SpecularStrength', 0.35);
    end

    % Lighting & Styling for Subplot 1
    light(ax1, 'Position', [1 1 1.5], 'Style', 'infinite');
    light(ax1, 'Position', [-1 -1 1.0], 'Style', 'infinite');
    light(ax1, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax1, 'equal'); grid(ax1, 'on');
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]'); zlabel(ax1, 'Z [mm]');
    title(ax1, sprintf('3D Internal Assembly: %d Pinions + Ring Gear (m = %g mm, C = %.1f mm)', ...
        n_pinions, m, C), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax1, [-40 30]);
    set(ax1, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);

    %% ====================================================================
    %  SUBPLOT 2: Exploded View (SINGLE PAIR: 1 Pinion + 1 Ring Gear)
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig1);
    hold(ax2, 'on');

    sep = 35; % Separation distance [mm]

    % 1. Ring Gear displaced axially along -Z
    ring_exp_verts = ring_mesh.vertices;
    ring_exp_verts(:, 3) = ring_exp_verts(:, 3) - sep;

    patch(ax2, 'Vertices', ring_exp_verts, ...
        'Faces', ring_mesh.faces, ...
        'VertexNormals', ring_mesh.normals, ...
        'FaceColor', [0.78 0.52 0.28], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.40, 'DiffuseStrength', 0.65);

    % 2. ONLY ONE PINION (Pinion 1) displaced axially along +Z
    pin1_exp_verts = pinion_mesh.vertices;
    pin1_exp_verts(:, 1) = pin1_exp_verts(:, 1) + C;
    pin1_exp_verts(:, 3) = pin1_exp_verts(:, 3) + sep;

    patch(ax2, 'Vertices', pin1_exp_verts, ...
        'Faces', pinion_mesh.faces, ...
        'VertexNormals', pinion_mesh.normals, ...
        'FaceColor', [0.45 0.58 0.78], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.95, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.40, 'DiffuseStrength', 0.65);

    % Lighting & Styling for Subplot 2
    light(ax2, 'Position', [1 0.5 1.5], 'Style', 'infinite');
    light(ax2, 'Position', [-0.5 -1 1.0], 'Style', 'infinite');
    light(ax2, 'Position', [0 0 -1.5], 'Style', 'infinite');
    axis(ax2, 'equal'); grid(ax2, 'on');
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]'); zlabel(ax2, 'Z [mm]');
    title(ax2, 'Exploded View (Single Pair Engagement)', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    view(ax2, [-35 25]);
    set(ax2, 'Color', [0.12 0.12 0.16], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'ZColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);

    rotate3d(fig1, 'on');

    %% Save exported PNGs
    script_folder = fileparts(mfilename('fullpath'));
    matlab_dir = fileparts(script_folder);
    gear_design_dir = fileparts(matlab_dir);

    exportgraphics(fig1, fullfile(script_folder, 'internal_spur_cad_assembly.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.08 0.08 0.11]);

    fig_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Internal_Spur');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    exportgraphics(fig1, fullfile(fig_dir, 'internal_spur_cad_assembly.png'), ...
        'Resolution', 300, 'BackgroundColor', [0.08 0.08 0.11]);
end
