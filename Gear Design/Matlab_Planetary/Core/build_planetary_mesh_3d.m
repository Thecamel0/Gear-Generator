function [sun_mesh, planet_mesh, ring_mesh, carrier_mesh] = build_planetary_mesh_3d(calc, n_sec, n_pts)
%BUILD_PLANETARY_MESH_3D Generates watertight 3D solid meshes for a complete Epicyclic Gear Train:
%   1. Sun Gear (with central drive bore)
%   2. Planet Gear (with central pin bore)
%   3. Internal Ring Gear (with outer rim)
%   4. Planet Carrier (spider disc with K precision pins at radius C)
%
%   Employs dedicated planar cap normals [0 0 1] and [0 0 -1] for 100% flat silky-smooth caps.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-11

    if nargin < 2 || isempty(n_sec), n_sec = 4;  end
    if nargin < 3 || isempty(n_pts), n_pts = 36; end

    F = calc.F;
    s_nom = (pi * calc.m) / 2;

    %% ====================================================================
    %  1. SUN GEAR 3D MESH
    %  ====================================================================
    [xc_sun, yc_sun] = generate_spur_profile_2d(calc.Ns, calc.m, calc.phi, calc.m, 1.25*calc.m, s_nom, n_pts);
    sun_mesh = build_cylindrical_gear_mesh(xc_sun, yc_sun, calc.r_bore_sun, F, n_sec, calc.rp_s);

    %% ====================================================================
    %  2. PLANET GEAR 3D MESH (Single Base Planet)
    %  ====================================================================
    [xc_plan, yc_plan] = generate_spur_profile_2d(calc.Np, calc.m, calc.phi, calc.m, 1.25*calc.m, s_nom, n_pts);
    planet_mesh = build_cylindrical_gear_mesh(xc_plan, yc_plan, calc.r_bore_planet, F, n_sec, calc.rp_p);

    %% ====================================================================
    %  3. INTERNAL RING GEAR 3D MESH
    %  ====================================================================
    [xc_ring, yc_ring, x_rim, y_rim] = generate_internal_spur_profile_2d(calc, n_pts);
    ring_mesh = build_internal_ring_mesh(xc_ring, yc_ring, x_rim, y_rim, calc.r_rim, F, n_sec, calc.rp_r);

    %% ====================================================================
    %  4. PLANET CARRIER (SPIDER DISC & PINS) 3D MESH
    %  ====================================================================
    carrier_mesh = build_carrier_mesh(calc);
end

%% ========================================================================
%  Helper: Build External Cylindrical Spur Gear Mesh with Central Bore
%  ========================================================================
function gear_mesh = build_cylindrical_gear_mesh(xc, yc, r_bore, F, n_sec, r_pitch)
    M = length(xc);
    has_bore = (r_bore > 0.5);

    if has_bore
        n_bore = max(32, round(M / 6));
        th_b = linspace(0, 2*pi, n_bore + 1);
        th_b(end) = [];
        xb = r_bore * cos(th_b);
        yb = r_bore * sin(th_b);
        M_bore = n_bore;
    else
        xb = []; yb = []; M_bore = 0;
    end

    z_levels = linspace(-F/2, F/2, n_sec);
    n_slice = M + M_bore;
    n_side = n_slice * n_sec;

    side_verts   = zeros(n_side, 3);
    side_normals = zeros(n_side, 3);

    % Outward 2D normals for teeth
    dx = [xc(2:end), xc(1)] - [xc(end), xc(1:end-1)];
    dy = [yc(2:end), yc(1)] - [yc(end), yc(1:end-1)];
    mag = hypot(dx, dy); mag(mag < eps) = 1;
    nx_out = dy ./ mag;
    ny_out = -dx ./ mag;

    for s = 1:n_sec
        z_curr = z_levels(s);
        offset = (s - 1) * n_slice;

        side_verts(offset + (1:M), 1) = xc(:);
        side_verts(offset + (1:M), 2) = yc(:);
        side_verts(offset + (1:M), 3) = z_curr;
        side_normals(offset + (1:M), 1) = nx_out(:);
        side_normals(offset + (1:M), 2) = ny_out(:);
        side_normals(offset + (1:M), 3) = 0;

        if has_bore
            side_verts(offset + M + (1:M_bore), 1) = xb(:);
            side_verts(offset + M + (1:M_bore), 2) = yb(:);
            side_verts(offset + M + (1:M_bore), 3) = z_curr;
            side_normals(offset + M + (1:M_bore), 1) = -cos(th_b(:));
            side_normals(offset + M + (1:M_bore), 2) = -sin(th_b(:));
            side_normals(offset + M + (1:M_bore), 3) = 0;
        end
    end

    % Tooth quads
    n_teeth_quads = (n_sec - 1) * M;
    teeth_faces = zeros(n_teeth_quads * 2, 3);
    q_idx = 1;
    for s = 1:(n_sec - 1)
        b1 = (s - 1) * n_slice;
        b2 = s * n_slice;
        for k = 1:M
            kn = mod(k, M) + 1;
            teeth_faces(q_idx,   :) = [b1 + k, b1 + kn, b2 + kn];
            teeth_faces(q_idx+1, :) = [b1 + k, b2 + kn, b2 + k];
            q_idx = q_idx + 2;
        end
    end

    % Bore quads
    bore_faces = [];
    if has_bore
        n_bore_quads = (n_sec - 1) * M_bore;
        bore_faces = zeros(n_bore_quads * 2, 3);
        qb_idx = 1;
        for s = 1:(n_sec - 1)
            b1 = (s - 1) * n_slice + M;
            b2 = s * n_slice + M;
            for k = 1:M_bore
                kn = mod(k, M_bore) + 1;
                bore_faces(qb_idx,   :) = [b1 + k, b2 + kn, b1 + kn];
                bore_faces(qb_idx+1, :) = [b1 + k, b2 + k,  b2 + kn];
                qb_idx = qb_idx + 2;
            end
        end
    end

    % Planar End Caps
    if has_bore
        xb_cw = fliplr(xb);
        yb_cw = fliplr(yb);
        pgon = polyshape({xc, xb_cw}, {yc, yb_cw}, 'Simplify', false);
    else
        pgon = polyshape(xc, yc, 'Simplify', false);
    end
    tr = triangulation(pgon);
    pts_cap = tr.Points;
    cl_cap  = tr.ConnectivityList;
    n_cap_pts = size(pts_cap, 1);

    % Bottom Cap (-Z)
    bot_verts   = [pts_cap, -F/2 * ones(n_cap_pts, 1)];
    bot_normals = repmat([0, 0, -1], n_cap_pts, 1);

    v1 = pts_cap(cl_cap(:,1), :);
    v2 = pts_cap(cl_cap(:,2), :);
    v3 = pts_cap(cl_cap(:,3), :);
    cz = (v2(:,1)-v1(:,1)).*(v3(:,2)-v1(:,2)) - (v2(:,2)-v1(:,2)).*(v3(:,1)-v1(:,1));

    bot_cl = cl_cap;
    bot_cl(cz > 0, [2 3]) = bot_cl(cz > 0, [3 2]);
    bot_faces = n_side + bot_cl;

    % Top Cap (+Z)
    top_verts   = [pts_cap, +F/2 * ones(n_cap_pts, 1)];
    top_normals = repmat([0, 0, 1], n_cap_pts, 1);

    top_cl = cl_cap;
    top_cl(cz < 0, [2 3]) = top_cl(cz < 0, [3 2]);
    top_faces = n_side + n_cap_pts + top_cl;

    gear_mesh = struct();
    gear_mesh.vertices = [side_verts; bot_verts; top_verts];
    gear_mesh.normals  = [side_normals; bot_normals; top_normals];
    gear_mesh.faces    = [teeth_faces; bore_faces; bot_faces; top_faces];
    gear_mesh.n_verts  = size(gear_mesh.vertices, 1);
    gear_mesh.n_faces  = size(gear_mesh.faces, 1);
    gear_mesh.r_pitch  = r_pitch;
    gear_mesh.F        = F;
end

%% ========================================================================
%  Helper: Build Internal Ring Gear Mesh with Outer Solid Rim
%  ========================================================================
function ring_mesh = build_internal_ring_mesh(xc_ring, yc_ring, x_rim, y_rim, r_rim, F, n_sec, r_pitch)
    M_teeth = length(xc_ring);
    M_rim   = length(x_rim);
    z_levels = linspace(-F/2, F/2, n_sec);

    n_slice_ring = M_teeth + M_rim;
    n_side_ring = n_slice_ring * n_sec;

    ring_side_verts   = zeros(n_side_ring, 3);
    ring_side_normals = zeros(n_side_ring, 3);

    % Inner teeth 2D normals (pointing inward)
    xc_next = [xc_ring(2:end), xc_ring(1)];
    xc_prev = [xc_ring(end), xc_ring(1:end-1)];
    yc_next = [yc_ring(2:end), yc_ring(1)];
    yc_prev = [yc_ring(end), yc_ring(1:end-1)];
    dx = xc_next - xc_prev;
    dy = yc_next - yc_prev;
    mag_d = hypot(dx, dy); mag_d(mag_d < eps) = 1;
    nx_teeth = -dy ./ mag_d;
    ny_teeth = dx ./ mag_d;

    % Outward normals for outer rim
    nx_rim = x_rim ./ r_rim;
    ny_rim = y_rim ./ r_rim;

    for s = 1:n_sec
        z_curr = z_levels(s);
        offset = (s - 1) * n_slice_ring;

        % Inner teeth
        ring_side_verts(offset + (1:M_teeth), 1) = xc_ring(:);
        ring_side_verts(offset + (1:M_teeth), 2) = yc_ring(:);
        ring_side_verts(offset + (1:M_teeth), 3) = z_curr;
        ring_side_normals(offset + (1:M_teeth), 1) = nx_teeth(:);
        ring_side_normals(offset + (1:M_teeth), 2) = ny_teeth(:);
        ring_side_normals(offset + (1:M_teeth), 3) = 0;

        % Outer rim
        ring_side_verts(offset + M_teeth + (1:M_rim), 1) = x_rim(:);
        ring_side_verts(offset + M_teeth + (1:M_rim), 2) = y_rim(:);
        ring_side_verts(offset + M_teeth + (1:M_rim), 3) = z_curr;
        ring_side_normals(offset + M_teeth + (1:M_rim), 1) = nx_rim(:);
        ring_side_normals(offset + M_teeth + (1:M_rim), 2) = ny_rim(:);
        ring_side_normals(offset + M_teeth + (1:M_rim), 3) = 0;
    end

    % Quads for inner teeth
    n_teeth_quads = (n_sec - 1) * M_teeth;
    teeth_faces = zeros(n_teeth_quads * 2, 3);
    q_idx = 1;
    for s = 1:(n_sec - 1)
        b1 = (s - 1) * n_slice_ring;
        b2 = s * n_slice_ring;
        for k = 1:M_teeth
            kn = mod(k, M_teeth) + 1;
            teeth_faces(q_idx,   :) = [b1 + k, b2 + kn, b1 + kn];
            teeth_faces(q_idx+1, :) = [b1 + k, b2 + k,  b2 + kn];
            q_idx = q_idx + 2;
        end
    end

    % Quads for outer rim
    n_rim_quads = (n_sec - 1) * M_rim;
    rim_faces = zeros(n_rim_quads * 2, 3);
    qr_idx = 1;
    for s = 1:(n_sec - 1)
        b1 = (s - 1) * n_slice_ring + M_teeth;
        b2 = s * n_slice_ring + M_teeth;
        for k = 1:M_rim
            kn = mod(k, M_rim) + 1;
            rim_faces(qr_idx,   :) = [b1 + k, b1 + kn, b2 + kn];
            rim_faces(qr_idx+1, :) = [b1 + k, b2 + kn, b2 + k];
            qr_idx = qr_idx + 2;
        end
    end

    % Planar End Caps (Polyshape: Outer rim CCW, inner teeth CW)
    xc_teeth_cw = fliplr(xc_ring);
    yc_teeth_cw = fliplr(yc_ring);
    pgon_ring = polyshape({x_rim, xc_teeth_cw}, {y_rim, yc_teeth_cw}, 'Simplify', false);
    tr_ring = triangulation(pgon_ring);

    pts_cap_ring = tr_ring.Points;
    cl_cap_ring  = tr_ring.ConnectivityList;
    n_cap_pts_ring = size(pts_cap_ring, 1);

    % Bottom Cap (-Z)
    ring_bot_verts   = [pts_cap_ring, -F/2 * ones(n_cap_pts_ring, 1)];
    ring_bot_normals = repmat([0, 0, -1], n_cap_pts_ring, 1);

    v1 = pts_cap_ring(cl_cap_ring(:,1), :);
    v2 = pts_cap_ring(cl_cap_ring(:,2), :);
    v3 = pts_cap_ring(cl_cap_ring(:,3), :);
    cz = (v2(:,1)-v1(:,1)).*(v3(:,2)-v1(:,2)) - (v2(:,2)-v1(:,2)).*(v3(:,1)-v1(:,1));

    bot_cl = cl_cap_ring;
    bot_cl(cz > 0, [2 3]) = bot_cl(cz > 0, [3 2]);
    ring_bot_faces = n_side_ring + bot_cl;

    % Top Cap (+Z)
    ring_top_verts   = [pts_cap_ring, +F/2 * ones(n_cap_pts_ring, 1)];
    ring_top_normals = repmat([0, 0, 1], n_cap_pts_ring, 1);

    top_cl = cl_cap_ring;
    top_cl(cz < 0, [2 3]) = top_cl(cz < 0, [3 2]);
    ring_top_faces = n_side_ring + n_cap_pts_ring + top_cl;

    ring_mesh = struct();
    ring_mesh.vertices = [ring_side_verts; ring_bot_verts; ring_top_verts];
    ring_mesh.normals  = [ring_side_normals; ring_bot_normals; ring_top_normals];
    ring_mesh.faces    = [teeth_faces; rim_faces; ring_bot_faces; ring_top_faces];
    ring_mesh.n_verts  = size(ring_mesh.vertices, 1);
    ring_mesh.n_faces  = size(ring_mesh.faces, 1);
    ring_mesh.r_pitch  = r_pitch;
    ring_mesh.r_rim    = r_rim;
    ring_mesh.F        = F;
end

%% ========================================================================
%  Helper: Build Planet Carrier (Spider Disc + K Carrier Pins) Mesh
%  ========================================================================
function carrier_mesh = build_carrier_mesh(calc)
    F = calc.F;
    C = calc.center_dist;
    K = calc.K;
    r_disc = calc.r_carrier_disc;
    t_disc = calc.carrier_thickness;
    r_pin  = calc.r_pin;

    % Carrier disc sits axially at [-F/2 - t_disc, -F/2]
    z_disc_bot = -F/2 - t_disc;
    z_disc_top = -F/2;

    % Pins extend from z_disc_bot through the disc and into +Z to +F/2 + 2.0 mm
    z_pin_top = F/2 + 2.0;

    % Sub-mesh 1: Circular carrier disc with central hub bore
    r_hub_bore = calc.r_bore_sun * 1.1;
    n_circ = 64;
    th = linspace(0, 2*pi, n_circ + 1); th(end) = [];

    % Build cylinder for the carrier plate
    x_out = r_disc * cos(th);
    y_out = r_disc * sin(th);
    x_in  = r_hub_bore * cos(th);
    y_in  = r_hub_bore * sin(th);

    % Combine carrier disc and K pins into a unified multi-solid mesh structure
    all_verts = [];
    all_normals = [];
    all_faces = [];

    % Disc cylinder
    [disc_v, disc_n, disc_f] = make_annular_cylinder(x_out, y_out, x_in, y_in, z_disc_bot, z_disc_top, r_disc, r_hub_bore);
    all_verts = disc_v;
    all_normals = disc_n;
    all_faces = disc_f;

    % K Carrier Pins (solid cylindrical rods)
    n_pin_circ = 24;
    th_p = linspace(0, 2*pi, n_pin_circ + 1); th_p(end) = [];
    x_p_unit = r_pin * cos(th_p);
    y_p_unit = r_pin * sin(th_p);

    for k = 1:K
        angle_k = (k - 1) * 2 * pi / K;
        cx = C * cos(angle_k);
        cy = C * sin(angle_k);

        px = cx + x_p_unit;
        py = cy + y_p_unit;

        [pin_v, pin_n, pin_f] = make_solid_cylinder(px, py, z_disc_top, z_pin_top, r_pin, cx, cy);
        
        offset = size(all_verts, 1);
        all_verts = [all_verts; pin_v];
        all_normals = [all_normals; pin_n];
        all_faces = [all_faces; pin_f + offset];
    end

    carrier_mesh = struct();
    carrier_mesh.vertices = all_verts;
    carrier_mesh.normals  = all_normals;
    carrier_mesh.faces    = all_faces;
    carrier_mesh.n_verts  = size(all_verts, 1);
    carrier_mesh.n_faces  = size(all_faces, 1);
    carrier_mesh.C        = C;
    carrier_mesh.K        = K;
end

%% Helper: Make Annular Cylinder
function [verts, normals, faces] = make_annular_cylinder(x_out, y_out, x_in, y_in, z_bot, z_top, r_out, r_in)
    N = length(x_out);
    
    % Vertices:
    % 1:N = Outer Bot, (N+1):2N = Outer Top
    % (2N+1):3N = Inner Bot, (3N+1):4N = Inner Top
    side_v = [
        x_out(:), y_out(:), z_bot * ones(N, 1);
        x_out(:), y_out(:), z_top * ones(N, 1);
        x_in(:),  y_in(:),  z_bot * ones(N, 1);
        x_in(:),  y_in(:),  z_top * ones(N, 1)
    ];

    side_n = [
        x_out(:)/r_out, y_out(:)/r_out, zeros(N, 1);
        x_out(:)/r_out, y_out(:)/r_out, zeros(N, 1);
        -x_in(:)/r_in,  -y_in(:)/r_in,  zeros(N, 1);
        -x_in(:)/r_in,  -y_in(:)/r_in,  zeros(N, 1)
    ];

    faces = [];
    % Outer cylindrical surface
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; i, nxt, N + nxt; i, N + nxt, N + i];
    end
    % Inner cylindrical surface
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; 2*N + i, 3*N + nxt, 2*N + nxt; 2*N + i, 3*N + i, 3*N + nxt];
    end

    % Bottom Cap (-Z)
    bot_v = [x_out(:), y_out(:), z_bot * ones(N, 1); x_in(:), y_in(:), z_bot * ones(N, 1)];
    bot_n = repmat([0, 0, -1], 2*N, 1);
    b_off = size(side_v, 1);
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; b_off + i, b_off + N + nxt, b_off + nxt; b_off + i, b_off + N + i, b_off + N + nxt];
    end

    % Top Cap (+Z)
    top_v = [x_out(:), y_out(:), z_top * ones(N, 1); x_in(:), y_in(:), z_top * ones(N, 1)];
    top_n = repmat([0, 0, 1], 2*N, 1);
    t_off = b_off + 2*N;
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; t_off + i, t_off + nxt, t_off + N + nxt; t_off + i, t_off + N + nxt, t_off + N + i];
    end

    verts = [side_v; bot_v; top_v];
    normals = [side_n; bot_n; top_n];
end

%% Helper: Make Solid Cylinder
function [verts, normals, faces] = make_solid_cylinder(x_pts, y_pts, z_bot, z_top, r, cx, cy)
    N = length(x_pts);

    side_v = [x_pts(:), y_pts(:), z_bot * ones(N, 1); x_pts(:), y_pts(:), z_top * ones(N, 1)];
    side_n = [(x_pts(:) - cx)/r, (y_pts(:) - cy)/r, zeros(N, 1); (x_pts(:) - cx)/r, (y_pts(:) - cy)/r, zeros(N, 1)];

    faces = [];
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; i, nxt, N + nxt; i, N + nxt, N + i];
    end

    % Bottom Cap (-Z)
    bot_center = [cx, cy, z_bot];
    bot_v = [bot_center; x_pts(:), y_pts(:), z_bot * ones(N, 1)];
    bot_n = repmat([0, 0, -1], N + 1, 1);
    b_off = size(side_v, 1);
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; b_off + 1, b_off + 1 + nxt, b_off + 1 + i];
    end

    % Top Cap (+Z)
    top_center = [cx, cy, z_top];
    top_v = [top_center; x_pts(:), y_pts(:), z_top * ones(N, 1)];
    top_n = repmat([0, 0, 1], N + 1, 1);
    t_off = b_off + N + 1;
    for i = 1:N
        nxt = mod(i, N) + 1;
        faces = [faces; t_off + 1, t_off + 1 + i, t_off + 1 + nxt];
    end

    verts = [side_v; bot_v; top_v];
    normals = [side_n; bot_n; top_n];
end
