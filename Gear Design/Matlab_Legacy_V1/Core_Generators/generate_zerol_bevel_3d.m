function [pinion_mesh, gear_mesh] = generate_zerol_bevel_3d(params)
%GENERATE_ZEROL_BEVEL_3D Generate 3D meshes and 3D assembly figure for Zerol bevel gear pair
%
%   [pinion_mesh, gear_mesh] = generate_zerol_bevel_3d(params)
%
%   Inputs:
%       params - struct with gear design and AGMA tolerance parameters
%
%   Outputs:
%       pinion_mesh - struct with .vertices (Vx3) and .faces (Fx3)
%       gear_mesh   - struct with .vertices (Vx3) and .faces (Fx3)
%
%   Creates:
%       Figure 1 - 3D Assembly & Exploded View
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-06

% =====================================================================
%  Resolution Parameters
% =====================================================================
n_inv  = 10;       % Points per involute curve segment per_value = 20
n_sec  = 8;       % Cross-sections along face width per_value = 16
n_top  = 4;        % Interior points on top land arc
n_root = 4;        % Interior points on root arc
n_rad  = 3;        % Points on radial line

% =====================================================================
%  Build Meshes (Supports Gleason Unequal Addendum)
% =====================================================================
if isfield(params, 'a_p') && isfield(params, 'b_p')
    a_p = params.a_p;  b_p = params.b_p;
else
    a_p = params.a;    b_p = params.b;
end

if isfield(params, 'a_g') && isfield(params, 'b_g')
    a_g = params.a_g;  b_g = params.b_g;
else
    a_g = params.a;    b_g = params.b;
end

if isfield(params, 's_p')
    s_p = params.s_p;
else
    s_p = pi * params.m / 2;
end

if isfield(params, 's_g')
    s_g = params.s_g;
else
    s_g = pi * params.m / 2;
end

pinion_mesh = build_bevel_mesh(params.Np, params.m, params.phi, ...
    a_p, b_p, params.gamma_p, params.Ao, params.F, ...
    n_inv, n_sec, n_top, n_root, n_rad, 0, s_p);

gear_mesh = build_bevel_mesh(params.Ng, params.m, params.phi, ...
    a_g, b_g, params.gamma_g, params.Ao, params.F, ...
    n_inv, n_sec, n_top, n_root, n_rad, 0, s_g);

fprintf('  Pinion mesh: %d vertices, %d triangles\n', ...
    size(pinion_mesh.vertices,1), size(pinion_mesh.faces,1));
fprintf('  Gear mesh:   %d vertices, %d triangles\n', ...
    size(gear_mesh.vertices,1), size(gear_mesh.faces,1));

% =====================================================================
%  Figure 1 — 3D Assembly View & Exploded View
% =====================================================================
fig1 = figure('Name', 'Zerol Bevel Gear - 3D Assembly', ...
    'NumberTitle', 'off', ...
    'Position', [50 50 1400 850], ...
    'Color', [0.10 0.10 0.13]);

% --- Left subplot: Full assembly with all pinions ---
ax1 = subplot(1, 2, 1, 'Parent', fig1);
hold(ax1, 'on');

% Ring gear placed naturally on horizontal plane (Z is central gear axis)
patch(ax1, 'Vertices', gear_mesh.vertices, ...
    'Faces', gear_mesh.faces, ...
    'FaceColor', [0.78 0.52 0.28], ...
    'EdgeColor', 'none', ...
    'FaceAlpha', 0.92, ...
    'FaceLighting', 'gouraud', ...
    'AmbientStrength', 0.35, ...
    'DiffuseStrength', 0.65, ...
    'SpecularStrength', 0.4);

n_pinions = params.n_pinions;
pinion_colors = [0.45 0.58 0.78;    % Steel blue
    0.55 0.75 0.55;    % Sage green
    0.72 0.48 0.65;    % Mauve
    0.78 0.68 0.45;    % Gold
    0.50 0.70 0.75;    % Teal
    0.70 0.55 0.55];   % Rose

Ry90 = [0 0 1; 0 1 0; -1 0 0];

% Tooth clocking: rotate pinion by half-pitch (pi/Np = 11.25 deg)
% so pinion teeth drop directly into gear valleys (zero tip-on-tip collision)
phi_clock = pi / params.Np;
R_clock = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];

for p = 1:n_pinions
    angle_offset = (p - 1) * 2 * pi / n_pinions;
    c = cos(angle_offset);
    s = sin(angle_offset);
    Rz = [c -s 0; s c 0; 0 0 1];

    % Phase synchronization for each pinion position around ring gear
    phase_angle = angle_offset * (params.Ng / params.Np);
    R_phase = [cos(phase_angle) -sin(phase_angle) 0; sin(phase_angle) cos(phase_angle) 0; 0 0 1];

    R_pinion = Rz * Ry90 * R_clock * R_phase;

    pinion_verts = (R_pinion * pinion_mesh.vertices')';

    color_idx = mod(p-1, size(pinion_colors,1)) + 1;
    patch(ax1, 'Vertices', pinion_verts, ...
        'Faces', pinion_mesh.faces, ...
        'FaceColor', pinion_colors(color_idx,:), ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.92, ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.35, ...
        'DiffuseStrength', 0.65, ...
        'SpecularStrength', 0.4);
end

light(ax1, 'Position', [1 1 1],    'Style', 'infinite');
light(ax1, 'Position', [-1 -1 0.5], 'Style', 'infinite');

axis(ax1, 'equal');
grid(ax1, 'on');
xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]'); zlabel(ax1, 'Z [mm]');
title(ax1, sprintf('Assembly: %d Pinion(s) + Ring Gear', n_pinions), ...
    'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');
view(ax1, [-40 25]);
set(ax1, 'Color', [0.15 0.15 0.19], ...
    'XColor', [0.7 0.7 0.7], ...
    'YColor', [0.7 0.7 0.7], ...
    'ZColor', [0.7 0.7 0.7], ...
    'GridColor', [0.3 0.3 0.3]);

% --- Right subplot: Exploded view (single pinion + gear) ---
ax2 = subplot(1, 2, 2, 'Parent', fig1);
hold(ax2, 'on');

sep = params.Ao * 0.30;

% Separate gear along -Z axis
patch(ax2, 'Vertices', gear_mesh.vertices - [0 0 sep], ...
    'Faces', gear_mesh.faces, ...
    'FaceColor', [0.78 0.52 0.28], ...
    'EdgeColor', [0.5 0.33 0.18], ...
    'EdgeAlpha', 0.15, ...
    'FaceAlpha', 0.90, ...
    'FaceLighting', 'gouraud', ...
    'AmbientStrength', 0.35);

% Separate pinion along its radial +X axis
pinion1_verts = (Ry90 * pinion_mesh.vertices')';
patch(ax2, 'Vertices', pinion1_verts + [sep 0 0], ...
    'Faces', pinion_mesh.faces, ...
    'FaceColor', [0.45 0.58 0.78], ...
    'EdgeColor', [0.28 0.36 0.48], ...
    'EdgeAlpha', 0.15, ...
    'FaceAlpha', 0.90, ...
    'FaceLighting', 'gouraud', ...
    'AmbientStrength', 0.35);

light(ax2, 'Position', [1 0.5 1], 'Style', 'infinite');
light(ax2, 'Position', [-0.5 -1 0.5], 'Style', 'infinite');

axis(ax2, 'equal');
grid(ax2, 'on');
xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]'); zlabel(ax2, 'Z [mm]');
title(ax2, 'Exploded View (Single Pair)', ...
    'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');
view(ax2, [-30 20]);
set(ax2, 'Color', [0.15 0.15 0.19], ...
    'XColor', [0.7 0.7 0.7], ...
    'YColor', [0.7 0.7 0.7], ...
    'ZColor', [0.7 0.7 0.7], ...
    'GridColor', [0.3 0.3 0.3]);

rotate3d(fig1, 'on');

    fprintf('  Figure generated: 3D Assembly & Exploded View.\n');
end

% =====================================================================
%  Helper Functions
% =====================================================================

function mesh = build_bevel_mesh(N, m, phi, a, b, gamma, Ao, F, ...
    n_inv, n_sec, n_top, n_root, n_rad, r_bore, tooth_thick)
if nargin < 14 || isempty(r_bore)
    r_bore = 0;   % Default: Solid gear (no center hole)
end
if nargin < 15 || isempty(tooth_thick)
    tooth_thick = pi * m / 2;
end

[angles, radii] = gear_profile_polar(N, m, phi, a, b, ...
    n_inv, n_top, n_root, n_rad, [], tooth_thick);
M = length(angles);

Ai = Ao - F;
cone_dists = linspace(Ai, Ao, n_sec);
z_positions = cone_dists * cos(gamma);
scale_factors = cone_dists / Ao;

% 1. Lateral tooth surface vertices
n_tooth_verts = n_sec * M;
tooth_verts = zeros(n_tooth_verts, 3);
for s = 1:n_sec
    sc = scale_factors(s);
    r_s = radii * sc;
    idx = (s-1)*M + (1:M);
    tooth_verts(idx, 1) = r_s .* cos(angles);
    tooth_verts(idx, 2) = r_s .* sin(angles);
    tooth_verts(idx, 3) = z_positions(s);
end

% Lateral tooth faces (outward pointing)
[S, K] = ndgrid(1:n_sec-1, 1:M);
K_next = mod(K, M) + 1;

v1 = (S-1).*M + K;
v2 = (S-1).*M + K_next;
v3 = S.*M     + K_next;
v4 = S.*M     + K;

v1 = v1(:);  v2 = v2(:);  v3 = v3(:);  v4 = v4(:);
lat_faces = [v1 v2 v3; v1 v3 v4];

k_vec = 1:M;
k_next_vec = mod(k_vec, M) + 1;

if r_bore > 0
    % 2. Inner & Outer bore circle vertices
    bore_inner_verts = [r_bore * cos(angles(:)), r_bore * sin(angles(:)), repmat(z_positions(1), M, 1)];
    bore_outer_verts = [r_bore * cos(angles(:)), r_bore * sin(angles(:)), repmat(z_positions(end), M, 1)];
    vertices = [tooth_verts; bore_inner_verts; bore_outer_verts];

    % Inner annular cap (between inner teeth and inner bore)
    idx_bore_inner = n_tooth_verts + (1:M);
    t1 = k_vec(:);
    t2 = k_next_vec(:);
    b1 = idx_bore_inner(k_vec)';
    b2 = idx_bore_inner(k_next_vec)';
    inner_cap_faces = [t1, b2, b1; t1, t2, b2];

    % Outer annular cap (between outer teeth and outer bore)
    idx_tooth_outer = (n_sec - 1) * M;
    idx_bore_outer = n_tooth_verts + M + (1:M);
    t1_o = idx_tooth_outer + k_vec(:);
    t2_o = idx_tooth_outer + k_next_vec(:);
    b1_o = idx_bore_outer(k_vec)';
    b2_o = idx_bore_outer(k_next_vec)';
    outer_cap_faces = [t1_o, b1_o, b2_o; t1_o, b2_o, t2_o];

    % Bore inner cylinder faces
    bore_cyl_faces = [b1, b2_o, b1_o; b1, b2, b2_o];

    mesh.vertices = vertices;
    mesh.faces    = [lat_faces; inner_cap_faces; outer_cap_faces; bore_cyl_faces];
else
    % Solid gear (NO hole) — Cap cleanly to center axis
    c_inner = [0, 0, z_positions(1)];
    c_outer = [0, 0, z_positions(end)];
    vertices = [tooth_verts; c_inner; c_outer];

    idx_c_in  = n_tooth_verts + 1;
    idx_c_out = n_tooth_verts + 2;

    t1 = k_vec(:);
    t2 = k_next_vec(:);
    % Inner cap pointing towards -Z (outward at toe end)
    inner_cap_faces = [t1, repmat(idx_c_in, M, 1), t2];

    % Outer cap pointing towards +Z (outward at heel end)
    idx_tooth_outer = (n_sec - 1) * M;
    t1_o = idx_tooth_outer + k_vec(:);
    t2_o = idx_tooth_outer + k_next_vec(:);
    outer_cap_faces = [t1_o, t2_o, repmat(idx_c_out, M, 1)];

    mesh.vertices = vertices;
    mesh.faces    = [lat_faces; inner_cap_faces; outer_cap_faces];
end
end


function [angles, radii] = gear_profile_polar(N, m, phi, a, b, ...
    n_inv, n_top, n_root, n_rad, backlash, tooth_thick)
if nargin < 10 || isempty(backlash)
    backlash = 0.22; % [mm] AGMA Class 10 standard normal backlash
end
if nargin < 11 || isempty(tooth_thick)
    tooth_thick = pi * m / 2;
end

r_p = m * N / 2;
r_b = r_p * cos(phi);
r_a = r_p + a;
r_d = r_p - b;
if r_d < 0.3 * r_b
    r_d = 0.3 * r_b;
end

% Half-tooth angle with AGMA backlash tooth thinning (widens tooth gap space)
delta_sn = backlash / (2 * cos(phi));
tau = (tooth_thick - delta_sn) / (2 * r_p);
if tau < 0.05 * (pi/N)
    tau = 0.05 * (pi/N);
end

inv_phi = tan(phi) - phi;

root_below_base = (r_d < r_b);
r_inv_start = max(r_b, r_d);

alpha_add = acos(min(r_b / r_a, 1));
theta_tip = tau + inv_phi - (tan(alpha_add) - alpha_add);

if root_below_base
    theta_root_edge = tau + inv_phi;
else
    alpha_ded = acos(min(r_b / r_d, 1));
    theta_root_edge = tau + inv_phi - (tan(alpha_ded) - alpha_ded);
end

theta_next_root = 2*pi/N - theta_root_edge;

tooth_r = [];
tooth_t = [];

if root_below_base
    rr = linspace(r_d, r_b, n_rad);
    tt = -(tau + inv_phi) * ones(1, n_rad);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];
end

rr = linspace(r_inv_start, r_a, n_inv);
alpha = acos(min(r_b ./ rr, 1));
inv_alpha = tan(alpha) - alpha;
tt = -(tau + inv_phi - inv_alpha);
tooth_r = [tooth_r, rr];
tooth_t = [tooth_t, tt];

tt_top = linspace(-theta_tip, theta_tip, n_top + 2);
tt_top = tt_top(2:end-1);
rr_top = r_a * ones(1, n_top);
tooth_r = [tooth_r, rr_top];
tooth_t = [tooth_t, tt_top];

rr = linspace(r_a, r_inv_start, n_inv);
alpha = acos(min(r_b ./ rr, 1));
inv_alpha = tan(alpha) - alpha;
tt = (tau + inv_phi - inv_alpha);
tooth_r = [tooth_r, rr];
tooth_t = [tooth_t, tt];

if root_below_base
    rr = linspace(r_b, r_d, n_rad);
    tt = (tau + inv_phi) * ones(1, n_rad);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];
end

tt_root = linspace(theta_root_edge, theta_next_root, n_root + 2);
tt_root = tt_root(2:end-1);
rr_root = r_d * ones(1, n_root);
tooth_r = [tooth_r, rr_root];
tooth_t = [tooth_t, tt_root];

M_tooth = length(tooth_r);
M_total = N * M_tooth;

angles = zeros(1, M_total);
radii  = zeros(1, M_total);

for t = 0:(N-1)
    offset = t * 2*pi/N;
    idx = t * M_tooth + (1:M_tooth);
    angles(idx) = tooth_t + offset;
    radii(idx)  = tooth_r;
end
end
