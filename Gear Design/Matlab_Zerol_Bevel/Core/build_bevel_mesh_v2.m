function mesh = build_bevel_mesh_v2(N, m, phi, a, b, gamma, Ao, F, ...
        r_cutter, n_inv, n_sec, n_top, n_root, tooth_thick, crowning)
%BUILD_BEVEL_MESH_V2 Build a 3D mesh for a Zerol bevel gear (TRUE CONE)
%
%   Uses gleason_tooth_surface() to generate tooth geometry placed
%   directly on the pitch cone surface, with addendum/dedendum projected
%   normal to the cone. Then applies optional crowning and constructs
%   the triangle mesh with end caps.
%
%   Inputs:
%       N, m, phi, a, b, gamma, Ao, F, r_cutter — gear geometry
%       n_inv, n_sec, n_top, n_root — mesh resolution
%       tooth_thick — circular tooth thickness [mm]
%       crowning    — struct with optional fields:
%           .lengthwise  — lengthwise crown amount [mm] (default 0)
%           .profile     — profile crown amount [mm] (default 0)
%           .tip_relief  — tip relief amount [mm] (default 0)
%           .tip_relief_start — start of relief as fraction of addendum (default 0.85)
%
%   Output:
%       mesh — struct with .vertices (Vx3) and .faces (Fx3)
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-26

    if nargin < 15 || isempty(crowning)
        crowning = struct();
    end

    % Default crowning values
    C_L = 0;    % Lengthwise crowning [mm]
    C_P = 0;    % Profile crowning [mm]
    C_tip = 0;  % Tip relief [mm]
    tip_start = 0.85;  % Relief starts at 85% of addendum height

    if isfield(crowning, 'lengthwise'), C_L = crowning.lengthwise; end
    if isfield(crowning, 'profile'),    C_P = crowning.profile; end
    if isfield(crowning, 'tip_relief'), C_tip = crowning.tip_relief; end
    if isfield(crowning, 'tip_relief_start'), tip_start = crowning.tip_relief_start; end

    % --- Generate 3D tooth surface (true cone geometry) ---
    [tooth_verts, M, ~] = gleason_tooth_surface(N, m, phi, ...
        a, b, gamma, Ao, F, r_cutter, n_inv, n_sec, n_top, n_root, tooth_thick);

    % --- Apply crowning modifications ---
    % Crowning is applied as displacement along the cone normal direction.
    % The cone outward normal at the pitch point is:
    %   n_cone = [sin(gamma)*cos(theta), sin(gamma)*sin(theta), cos(gamma)]
    % But crowning is a small radial/normal perturbation, so we apply it
    % as a displacement along the local outward normal of the cone.

    Ai = Ao - F;
    Am = Ao - F/2;
    r_p = m * N / 2;            % Pitch radius at outer
    r_a = r_p + a;              % Tip radius at outer (in 2D profile)

    for s = 1:n_sec
        A_s = Ai + (s-1) * F / (n_sec - 1);
        sf = A_s / Ao;

        % Get the vertices for this section
        idx = (s-1)*M + (1:M);
        verts_s = tooth_verts(idx, :);

        % Compute radial distance from axis for each vertex
        r_vert = sqrt(verts_s(:,1).^2 + verts_s(:,2).^2);

        % Pitch radius on the cone surface at this section
        r_cone_pitch = A_s * sin(gamma);

        % Lengthwise crowning: parabolic inward at toe and heel
        t_norm = 2 * (s - 1) / (n_sec - 1) - 1;  % [-1, 1]
        delta_L = C_L * t_norm^2;

        % Apply lengthwise crowning along cone normal (inward)
        % Inward normal = [-sin(gamma)*cos(theta), -sin(gamma)*sin(theta), -cos(gamma)]
        if delta_L > 0
            theta_v = atan2(verts_s(:,2), verts_s(:,1));
            verts_s(:,1) = verts_s(:,1) - delta_L * cos(gamma) * cos(theta_v);
            verts_s(:,2) = verts_s(:,2) - delta_L * cos(gamma) * sin(theta_v);
            verts_s(:,3) = verts_s(:,3) + delta_L * sin(gamma);
        end

        % Profile crowning: parabolic along tooth height
        if C_P > 0
            r_d_local = max((r_p - b) * sf, 0);
            r_a_local = r_a * sf;
            h_range = r_a_local - r_d_local;
            if h_range > 0
                % Use deviation from pitch as proxy for height position
                delta_from_pitch = r_vert - r_cone_pitch;
                h_frac = (delta_from_pitch + b*sf) / (h_range);
                h_frac = max(0, min(1, h_frac));
                delta_P = C_P * (2*h_frac - 1).^2;

                theta_v = atan2(verts_s(:,2), verts_s(:,1));
                verts_s(:,1) = verts_s(:,1) - delta_P .* cos(gamma) .* cos(theta_v);
                verts_s(:,2) = verts_s(:,2) - delta_P .* cos(gamma) .* sin(theta_v);
                verts_s(:,3) = verts_s(:,3) + delta_P .* sin(gamma);
            end
        end

        % Tip relief: reduce height near the tip
        if C_tip > 0
            r_relief_start = r_cone_pitch + a * sf * tip_start * cos(gamma);
            above_relief = r_vert > r_relief_start;
            if any(above_relief)
                r_a_cone = r_cone_pitch + a * sf * cos(gamma);
                frac = (r_vert(above_relief) - r_relief_start) / ...
                       (r_a_cone - r_relief_start + eps);
                frac = min(1, max(0, frac));
                theta_v = atan2(verts_s(above_relief,2), verts_s(above_relief,1));
                verts_s(above_relief,1) = verts_s(above_relief,1) - C_tip * frac .* cos(gamma) .* cos(theta_v);
                verts_s(above_relief,2) = verts_s(above_relief,2) - C_tip * frac .* cos(gamma) .* sin(theta_v);
                verts_s(above_relief,3) = verts_s(above_relief,3) + C_tip * frac .* sin(gamma);
            end
        end

        tooth_verts(idx, :) = verts_s;
    end

    % --- Build lateral faces (connecting adjacent cross-sections) ---
    [S, K] = ndgrid(1:n_sec-1, 1:M);
    K_next = mod(K, M) + 1;

    v1 = (S-1).*M + K;
    v2 = (S-1).*M + K_next;
    v3 = S.*M     + K_next;
    v4 = S.*M     + K;

    v1 = v1(:);  v2 = v2(:);  v3 = v3(:);  v4 = v4(:);
    lat_faces = [v1 v2 v3; v1 v3 v4];

    % --- Build end caps (radial star-fan triangulation to center vertices) ---
    % Guarantees zero ear-clipping diagonal slicing chords and strict 2-manifold Euler = 2

    % Inner cap (toe end, section s = 1)
    z_c_toe = mean(tooth_verts(1:M, 3));
    idx_c_toe = size(tooth_verts, 1) + 1;
    tooth_verts(idx_c_toe, :) = [0, 0, z_c_toe];

    % Toe cap triangles: outward normal points toward apex (-Z)
    % Lateral face at s=1 has edge K -> mod(K, M) + 1; cap traverses in reverse
    K_arr = (1:M)';
    K_next_arr = mod(K_arr, M) + 1;
    inner_cap_faces = [repmat(idx_c_toe, M, 1), K_next_arr, K_arr];

    % Outer cap (heel end, section s = n_sec)
    idx_tooth_outer = (n_sec - 1) * M;
    z_c_heel = mean(tooth_verts(idx_tooth_outer + (1:M), 3));
    idx_c_heel = size(tooth_verts, 1) + 1;
    tooth_verts(idx_c_heel, :) = [0, 0, z_c_heel];

    % Heel cap triangles: outward normal points away from apex (+Z)
    heel_K = idx_tooth_outer + K_arr;
    heel_K_next = idx_tooth_outer + K_next_arr;
    outer_cap_faces = [repmat(idx_c_heel, M, 1), heel_K, heel_K_next];

    vertices = tooth_verts;

    % --- Remove degenerate triangles (zero area) ---
    all_faces = [lat_faces; inner_cap_faces; outer_cap_faces];
    all_faces = remove_degenerate_faces(vertices, all_faces);

    % --- Assemble mesh ---
    mesh.vertices = vertices;
    mesh.faces    = all_faces;

    % --- Verify watertight (Euler formula) ---
    [is_watertight, euler_char] = check_watertight(mesh);
    if ~is_watertight
        fprintf('  WARNING: Mesh is not watertight (Euler = %d, expected 2)\n', euler_char);
    end
end


function faces = remove_degenerate_faces(vertices, faces)
%REMOVE_DEGENERATE_FACES Remove triangles with zero or near-zero area
    v1 = vertices(faces(:,1), :);
    v2 = vertices(faces(:,2), :);
    v3 = vertices(faces(:,3), :);

    edge1 = v2 - v1;
    edge2 = v3 - v1;
    cross_prod = cross(edge1, edge2, 2);
    areas = 0.5 * sqrt(sum(cross_prod.^2, 2));

    min_area = 1e-10;  % Threshold for degenerate
    valid = areas > min_area;
    faces = faces(valid, :);
end


function [is_watertight, euler_char] = check_watertight(mesh)
%CHECK_WATERTIGHT Verify mesh is watertight using Euler formula V-E+F=2
    V = size(mesh.vertices, 1);
    F = size(mesh.faces, 1);

    % Count unique edges
    edges = [mesh.faces(:,[1 2]); mesh.faces(:,[2 3]); mesh.faces(:,[3 1])];
    edges = sort(edges, 2);
    E = size(unique(edges, 'rows'), 1);

    euler_char = V - E + F;
    is_watertight = (euler_char == 2);
end
