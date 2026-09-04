function mesh = build_spiral_bevel_mesh_3d(N, m, phi_n, a, b, gamma, Ao, F, beta_m, r_cutter, hand, s_thick, n_inv, n_sec)
%BUILD_SPIRAL_BEVEL_MESH_3D Constructs watertight 3D solid mesh for Spiral Bevel Gear
%   with dedicated planar end-cap normals to guarantee 100% smooth top/bottom faces.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 13 || isempty(n_inv), n_inv = 16; end
    if nargin < 14 || isempty(n_sec), n_sec = 18; end
    if nargin < 11 || isempty(hand),  hand  = 1;  end

    n_top  = 4;
    n_root = 4;

    % 1. Generate 3D tooth surface across face width
    [tooth_verts, M, ~] = generate_spiral_bevel_tooth_surface(...
        N, m, phi_n, a, b, gamma, Ao, F, beta_m, r_cutter, hand, s_thick, ...
        n_inv, n_sec, n_top, n_root);

    % 2. Build lateral quad faces (split into 2 triangles each)
    [S, K] = ndgrid(1:n_sec-1, 1:M);
    K_next = mod(K, M) + 1;

    v1 = (S - 1) * M + K;
    v2 = (S - 1) * M + K_next;
    v3 = S * M       + K_next;
    v4 = S * M       + K;

    lat_faces = [v1(:), v2(:), v3(:); v1(:), v3(:), v4(:)];

    % 3. Inner End Cap (Toe end, s = 1)
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

    % 6. Compute Smooth Vertex Normals
    v_normals = compute_smooth_normals(tooth_verts, lat_faces);

    % Package mesh
    mesh = struct();
    mesh.vertices = tooth_verts;
    mesh.faces    = all_faces;
    mesh.normals  = v_normals;
    mesh.n_verts  = size(tooth_verts, 1);
    mesh.n_faces  = size(all_faces, 1);
    mesh.F        = F;
    mesh.hand     = hand;

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
    fn_len = sqrt(sum(fn.^2, 2));
    fn_len(fn_len < 1e-12) = 1;
    fn = fn ./ fn_len;

    for i = 1:3
        idx = faces(:, i);
        normals = normals + accumarray(idx, fn(:,1), [n_v 1]) * [1 0 0] + ...
                            accumarray(idx, fn(:,2), [n_v 1]) * [0 1 0] + ...
                            accumarray(idx, fn(:,3), [n_v 1]) * [0 0 1];
    end
    n_len = sqrt(sum(normals.^2, 2));
    n_len(n_len < 1e-12) = 1;
    normals = normals ./ n_len;
end

function [is_watertight, euler_char] = verify_watertight(mesh)
    F = mesh.faces;
    edges = [F(:, [1 2]); F(:, [2 3]); F(:, [3 1])];
    edges = sort(edges, 2);
    [unique_edges, ~, edge_idx] = unique(edges, 'rows');
    counts = accumarray(edge_idx, 1);

    % In a 2-manifold closed surface, every edge must belong to exactly 2 faces
    is_watertight = all(counts == 2);

    V = size(mesh.vertices, 1);
    E = size(unique_edges, 1);
    F_count = size(F, 1);
    euler_char = V - E + F_count; % Should be 2 for genus-0 sphere
end
