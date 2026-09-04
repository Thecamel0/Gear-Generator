function mesh = build_spur_mesh_3d(N, m, phi, a, b, tooth_thick, F, n_sec, r_bore, n_pts)
%BUILD_SPUR_MESH_3D Generates a watertight 3D solid mesh with flat smooth end caps
%   Uses duplicate vertices with planar normals [0 0 1] and [0 0 -1] for top/bottom caps.
%   Completely eliminates triangular crease lines and radial artifacts.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 8 || isempty(n_sec),  n_sec = 4;   end
    if nargin < 10 || isempty(n_pts), n_pts = 60;  end

    % 1. Generate 2D Profile (Zero duplicate points)
    [xc, yc, rp, ~, ~, rd] = generate_spur_profile_2d(N, m, phi, a, b, tooth_thick, n_pts);
    M_outer = length(xc);

    if nargin < 9 || isempty(r_bore)
        r_bore = 0; % Solid gear body by default
    end

    has_bore = (r_bore > 1.0 && r_bore < rd * 0.85);
    if has_bore
        n_bore = max(36, round(N * 4));
        th_bore = linspace(0, 2*pi, n_bore + 1);
        th_bore(end) = [];
        xb = r_bore * cos(th_bore);
        yb = r_bore * sin(th_bore);
        M_inner = n_bore;
    else
        xb = [];
        yb = [];
        M_inner = 0;
    end

    % 2. 3D Side Walls Extrusion (-F/2 to +F/2)
    z_levels = linspace(-F/2, F/2, n_sec);
    n_slice_verts = M_outer + M_inner;
    n_side_verts = n_slice_verts * n_sec;

    side_verts = zeros(n_side_verts, 3);
    side_normals = zeros(n_side_verts, 3);

    % Compute 2D outward unit normals for outer contour
    xc_next = [xc(2:end), xc(1)];
    xc_prev = [xc(end), xc(1:end-1)];
    yc_next = [yc(2:end), yc(1)];
    yc_prev = [yc(end), yc(1:end-1)];
    dx = xc_next - xc_prev;
    dy = yc_next - yc_prev;
    mag_d = hypot(dx, dy);
    mag_d(mag_d < eps) = 1;
    nx_out = dy ./ mag_d;
    ny_out = -dx ./ mag_d;

    % Inward normals for inner bore
    if has_bore
        nx_in = -cos(th_bore);
        ny_in = -sin(th_bore);
    end

    for s = 1:n_sec
        z_curr = z_levels(s);
        offset = (s - 1) * n_slice_verts;

        % Outer boundary
        side_verts(offset + (1:M_outer), 1) = xc(:);
        side_verts(offset + (1:M_outer), 2) = yc(:);
        side_verts(offset + (1:M_outer), 3) = z_curr;
        side_normals(offset + (1:M_outer), 1) = nx_out(:);
        side_normals(offset + (1:M_outer), 2) = ny_out(:);
        side_normals(offset + (1:M_outer), 3) = 0;

        % Inner bore
        if has_bore
            side_verts(offset + M_outer + (1:M_inner), 1) = xb(:);
            side_verts(offset + M_outer + (1:M_inner), 2) = yb(:);
            side_verts(offset + M_outer + (1:M_inner), 3) = z_curr;
            side_normals(offset + M_outer + (1:M_inner), 1) = nx_in(:);
            side_normals(offset + M_outer + (1:M_inner), 2) = ny_in(:);
            side_normals(offset + M_outer + (1:M_inner), 3) = 0;
        end
    end

    % 3. Lateral Side Faces
    n_outer_quads = (n_sec - 1) * M_outer;
    outer_faces = zeros(n_outer_quads * 2, 3);
    q_idx = 1;

    for s = 1:(n_sec - 1)
        b1 = (s - 1) * n_slice_verts;
        b2 = s * n_slice_verts;
        for k = 1:M_outer
            kn = mod(k, M_outer) + 1;
            outer_faces(q_idx,   :) = [b1 + k, b1 + kn, b2 + kn];
            outer_faces(q_idx+1, :) = [b1 + k, b2 + kn, b2 + k];
            q_idx = q_idx + 2;
        end
    end

    inner_faces = [];
    if has_bore
        n_inner_quads = (n_sec - 1) * M_inner;
        inner_faces = zeros(n_inner_quads * 2, 3);
        qi_idx = 1;
        for s = 1:(n_sec - 1)
            b1 = (s - 1) * n_slice_verts + M_outer;
            b2 = s * n_slice_verts + M_outer;
            for k = 1:M_inner
                kn = mod(k, M_inner) + 1;
                inner_faces(qi_idx,   :) = [b1 + k, b2 + kn, b1 + kn];
                inner_faces(qi_idx+1, :) = [b1 + k, b2 + k,  b2 + kn];
                qi_idx = qi_idx + 2;
            end
        end
    end

    % 4. Planar End Caps with Dedicated Vertices (Guarantees 100% Flat Shading)
    if has_bore
        th_hole_cw = linspace(2*pi, 0, M_inner + 1);
        th_hole_cw(end) = [];
        xb_cw = r_bore * cos(th_hole_cw);
        yb_cw = r_bore * sin(th_hole_cw);
        pgon = polyshape({xc, xb_cw}, {yc, yb_cw}, 'Simplify', false);
    else
        pgon = polyshape(xc, yc, 'Simplify', false);
    end

    tr = triangulation(pgon);
    pts_cap = tr.Points;
    cl_cap = tr.ConnectivityList;
    n_cap_pts = size(pts_cap, 1);

    % Bottom Cap Vertices at Z = -F/2
    bot_verts = [pts_cap, -F/2 * ones(n_cap_pts, 1)];
    bot_normals = repmat([0, 0, -1], n_cap_pts, 1);

    % Ensure bottom cap faces have normal pointing in -Z
    v1_b = pts_cap(cl_cap(:,1), :);
    v2_b = pts_cap(cl_cap(:,2), :);
    v3_b = pts_cap(cl_cap(:,3), :);
    cz_b = (v2_b(:,1)-v1_b(:,1)).*(v3_b(:,2)-v1_b(:,2)) - (v2_b(:,2)-v1_b(:,2)).*(v3_b(:,1)-v1_b(:,1));

    bot_cl = cl_cap;
    flip_b = cz_b > 0;
    bot_cl(flip_b, [2 3]) = bot_cl(flip_b, [3 2]);
    bot_faces = n_side_verts + bot_cl;

    % Top Cap Vertices at Z = +F/2
    top_verts = [pts_cap, +F/2 * ones(n_cap_pts, 1)];
    top_normals = repmat([0, 0, 1], n_cap_pts, 1);

    top_cl = cl_cap;
    flip_t = cz_b < 0;
    top_cl(flip_t, [2 3]) = top_cl(flip_t, [3 2]);
    top_faces = n_side_verts + n_cap_pts + top_cl;

    % 5. Combine Vertices, Normals, and Faces
    all_verts = [side_verts; bot_verts; top_verts];
    all_normals = [side_normals; bot_normals; top_normals];
    all_faces = [outer_faces; inner_faces; bot_faces; top_faces];

    mesh.vertices = all_verts;
    mesh.normals  = all_normals;
    mesh.faces    = all_faces;
    mesh.n_verts  = size(all_verts, 1);
    mesh.n_faces  = size(all_faces, 1);
    mesh.r_pitch  = rp;
    mesh.r_root   = rd;
    mesh.r_bore   = r_bore;
    mesh.F        = F;
end
