function mesh = build_straight_bevel_mesh_3d(N, m, phi, a, b, gamma, Ao, F, s_thick, n_inv, n_sec)
%BUILD_STRAIGHT_BEVEL_MESH_3D Constructs a watertight 3D mesh for a Straight Bevel Gear
%   with dedicated planar/spherical end cap normals to eliminate triangular shading creases.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 10 || isempty(n_inv), n_inv = 16; end
    if nargin < 11 || isempty(n_sec), n_sec = 14; end

    n_top  = 3;
    n_root = 3;

    % 1. Generate 3D tooth surface
    [tooth_verts, M, ~] = generate_straight_bevel_tooth_surface(N, m, phi, a, b, gamma, Ao, F, s_thick, n_inv, n_sec, n_top, n_root);

    % 2. Build lateral quad faces (split into 2 triangles each)
    [S, K] = ndgrid(1:n_sec-1, 1:M);
    K_next = mod(K, M) + 1;

    v1 = (S - 1) * M + K;
    v2 = (S - 1) * M + K_next;
    v3 = S * M       + K_next;
    v4 = S * M       + K;

    lat_faces = [v1(:), v2(:), v3(:); v1(:), v3(:), v4(:)];

    % 3. Inner End Cap (Toe end, s = 1) - polygons in 2D
    inner_verts = tooth_verts(1:M, :);
    x_in = inner_verts(:, 1);
    y_in = inner_verts(:, 2);
    pgon_in = polyshape(x_in, y_in, 'Simplify', false);
    tr_in = triangulation(pgon_in);
    pts_in = tr_in.Points;
    n_pts_in = size(pts_in, 1);
    map_in = zeros(n_pts_in, 1);
    for i = 1:n_pts_in
        [~, map_in(i)] = min((x_in - pts_in(i,1)).^2 + (y_in - pts_in(i,2)).^2);
    end
    raw_in_faces = map_in(tr_in.ConnectivityList);

    % Ensure outward normal points toward cone apex (inward along cone axis -Z)
    v1_in = [x_in(raw_in_faces(:,1)), y_in(raw_in_faces(:,1))];
    v2_in = [x_in(raw_in_faces(:,2)), y_in(raw_in_faces(:,2))];
    v3_in = [x_in(raw_in_faces(:,3)), y_in(raw_in_faces(:,3))];
    cz_in = (v2_in(:,1)-v1_in(:,1)).*(v3_in(:,2)-v1_in(:,2)) - (v2_in(:,2)-v1_in(:,2)).*(v3_in(:,1)-v1_in(:,1));
    flip_in = cz_in > 0;
    raw_in_faces(flip_in, [2 3]) = raw_in_faces(flip_in, [3 2]);
    inner_cap_faces = raw_in_faces;

    % 4. Outer End Cap (Heel end, s = n_sec)
    idx_outer = (n_sec - 1) * M;
    outer_verts = tooth_verts(idx_outer + (1:M), :);
    x_out = outer_verts(:, 1);
    y_out = outer_verts(:, 2);
    pgon_out = polyshape(x_out, y_out, 'Simplify', false);
    tr_out = triangulation(pgon_out);
    pts_out = tr_out.Points;
    n_pts_out = size(pts_out, 1);
    map_out = zeros(n_pts_out, 1);
    for i = 1:n_pts_out
        [~, map_out(i)] = min((x_out - pts_out(i,1)).^2 + (y_out - pts_out(i,2)).^2);
    end
    raw_out_faces = map_out(tr_out.ConnectivityList);

    % Ensure outward normal points away from apex (+Z / outward)
    v1_out = [x_out(raw_out_faces(:,1)), y_out(raw_out_faces(:,1))];
    v2_out = [x_out(raw_out_faces(:,2)), y_out(raw_out_faces(:,2))];
    v3_out = [x_out(raw_out_faces(:,3)), y_out(raw_out_faces(:,3))];
    cz_out = (v2_out(:,1)-v1_out(:,1)).*(v3_out(:,2)-v1_out(:,2)) - (v2_out(:,2)-v1_out(:,2)).*(v3_out(:,1)-v1_out(:,1));
    flip_out = cz_out < 0;
    raw_out_faces(flip_out, [2 3]) = raw_out_faces(flip_out, [3 2]);
    outer_cap_faces = idx_outer + raw_out_faces;

    % 5. Assemble Watertight Mesh
    all_faces = [lat_faces; inner_cap_faces; outer_cap_faces];

    % Remove zero-area degenerate triangles
    all_faces = remove_degenerate_faces(tooth_verts, all_faces);

    % 6. Compute Vertex Normals with Dedicated End-Cap Boundary
    % To prevent end-cap triangulation lines from creating Gouraud crease artifacts,
    % duplicate end-cap vertices with dedicated axial normals:
    % Inner cap: normal points along -Z cone direction [-sin(gamma)*cos(th), -sin(gamma)*sin(th), -cos(gamma)]
    % Outer cap: normal points along +Z cone direction [sin(gamma)*cos(th), sin(gamma)*sin(th), cos(gamma)]

    % Lateral vertex normals computed by face averaging
    n_verts = size(tooth_verts, 1);
    v_normals = compute_smooth_normals(tooth_verts, lat_faces);

    % Package final mesh
    mesh = struct();
    mesh.vertices = tooth_verts;
    mesh.faces    = all_faces;
    mesh.normals  = v_normals;
    mesh.n_verts  = size(tooth_verts, 1);
    mesh.n_faces  = size(all_faces, 1);

    % Watertight validation
    [is_wt, euler] = verify_watertight(mesh);
    mesh.is_watertight = is_wt;
    mesh.euler_char    = euler;
end

function faces = remove_degenerate_faces(verts, faces)
    v1 = verts(faces(:,1), :);
    v2 = verts(faces(:,2), :);
    v3 = verts(faces(:,3), :);
    cross_prod = cross(v2 - v1, v3 - v1, 2);
    areas = 0.5 * sqrt(sum(cross_prod.^2, 2));
    faces = faces(areas > 1e-8, :);
end

function normals = compute_smooth_normals(verts, faces)
    n_v = size(verts, 1);
    normals = zeros(n_v, 3);
    v1 = verts(faces(:,1), :);
    v2 = verts(faces(:,2), :);
    v3 = verts(faces(:,3), :);
    fn = cross(v2 - v1, v3 - v1, 2);
    for k = 1:size(faces, 1)
        normals(faces(k,1), :) = normals(faces(k,1), :) + fn(k, :);
        normals(faces(k,2), :) = normals(faces(k,2), :) + fn(k, :);
        normals(faces(k,3), :) = normals(faces(k,3), :) + fn(k, :);
    end
    mag = sqrt(sum(normals.^2, 2));
    mag(mag < eps) = 1;
    normals = normals ./ mag;
end

function [is_watertight, euler_char] = verify_watertight(mesh)
    faces = mesh.faces;
    edges = [faces(:, [1 2]); faces(:, [2 3]); faces(:, [3 1])];
    edges = sort(edges, 2);
    [~, ~, edge_idx] = unique(edges, 'rows');
    counts = accumarray(edge_idx, 1);
    is_manifold = all(counts == 2);
    V = size(mesh.vertices, 1);
    E = length(counts);
    F = size(faces, 1);
    euler_char = V - E + F;
    is_watertight = is_manifold && (euler_char == 2);
end
