function [ring_mesh, pinion_mesh] = build_internal_spur_mesh_3d(calc, n_sec, n_pts)
%BUILD_INTERNAL_SPUR_MESH_3D Generates watertight 3D solid meshes for an Internal Ring Gear and Pinion
%   Employs dedicated planar cap vertices with strict normals [0 0 1] and [0 0 -1]
%   to guarantee 100% flat, silky-smooth end caps without radial creases.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 2 || isempty(n_sec), n_sec = 4;  end
    if nargin < 3 || isempty(n_pts), n_pts = 40; end

    F = calc.F;
    [xc_ring, yc_ring, x_rim, y_rim, xc_pin, yc_pin] = generate_internal_spur_profile_2d(calc, n_pts);

    %% ====================================================================
    %  1. INTERNAL RING GEAR 3D MESH
    %  ====================================================================
    M_teeth = length(xc_ring);
    M_rim   = length(x_rim);
    z_levels = linspace(-F/2, F/2, n_sec);

    n_slice_ring = M_teeth + M_rim;
    n_side_ring = n_slice_ring * n_sec;

    ring_side_verts   = zeros(n_side_ring, 3);
    ring_side_normals = zeros(n_side_ring, 3);

    % 2D normals for inner teeth (pointing into central tooth space)
    xc_next = [xc_ring(2:end), xc_ring(1)];
    xc_prev = [xc_ring(end), xc_ring(1:end-1)];
    yc_next = [yc_ring(2:end), yc_ring(1)];
    yc_prev = [yc_ring(end), yc_ring(1:end-1)];
    dx = xc_next - xc_prev;
    dy = yc_next - yc_prev;
    mag_d = hypot(dx, dy);
    mag_d(mag_d < eps) = 1;
    nx_teeth = -dy ./ mag_d; % Points inward into space
    ny_teeth = dx ./ mag_d;

    % Outward radial normals for outer rim
    nx_rim = x_rim ./ calc.r_rim;
    ny_rim = y_rim ./ calc.r_rim;

    for s = 1:n_sec
        z_curr = z_levels(s);
        offset = (s - 1) * n_slice_ring;

        % Inner teeth boundary
        ring_side_verts(offset + (1:M_teeth), 1) = xc_ring(:);
        ring_side_verts(offset + (1:M_teeth), 2) = yc_ring(:);
        ring_side_verts(offset + (1:M_teeth), 3) = z_curr;
        ring_side_normals(offset + (1:M_teeth), 1) = nx_teeth(:);
        ring_side_normals(offset + (1:M_teeth), 2) = ny_teeth(:);
        ring_side_normals(offset + (1:M_teeth), 3) = 0;

        % Outer rim boundary
        ring_side_verts(offset + M_teeth + (1:M_rim), 1) = x_rim(:);
        ring_side_verts(offset + M_teeth + (1:M_rim), 2) = y_rim(:);
        ring_side_verts(offset + M_teeth + (1:M_rim), 3) = z_curr;
        ring_side_normals(offset + M_teeth + (1:M_rim), 1) = nx_rim(:);
        ring_side_normals(offset + M_teeth + (1:M_rim), 2) = ny_rim(:);
        ring_side_normals(offset + M_teeth + (1:M_rim), 3) = 0;
    end

    % Lateral faces (Inner teeth quads)
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

    % Lateral faces (Outer rim quads)
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

    % Combine Ring Gear Mesh
    ring_mesh = struct();
    ring_mesh.vertices = [ring_side_verts; ring_bot_verts; ring_top_verts];
    ring_mesh.normals  = [ring_side_normals; ring_bot_normals; ring_top_normals];
    ring_mesh.faces    = [teeth_faces; rim_faces; ring_bot_faces; ring_top_faces];
    ring_mesh.n_verts  = size(ring_mesh.vertices, 1);
    ring_mesh.n_faces  = size(ring_mesh.faces, 1);
    ring_mesh.r_pitch  = calc.rp_g;
    ring_mesh.r_rim    = calc.r_rim;
    ring_mesh.F        = F;

    %% ====================================================================
    %  2. EXTERNAL MATING PINION 3D MESH
    %  ====================================================================
    M_pin = length(xc_pin);
    r_bore_pin = 0; % Solid pinion body (no bore hole)
    has_bore = false;
    if has_bore
        n_bore = max(32, round(calc.Np * 3));
        th_b = linspace(0, 2*pi, n_bore + 1);
        th_b(end) = [];
        xb_pin = r_bore_pin * cos(th_b);
        yb_pin = r_bore_pin * sin(th_b);
        M_bore_pin = n_bore;
    else
        xb_pin = []; yb_pin = []; M_bore_pin = 0;
    end

    n_slice_pin = M_pin + M_bore_pin;
    n_side_pin = n_slice_pin * n_sec;

    pin_side_verts   = zeros(n_side_pin, 3);
    pin_side_normals = zeros(n_side_pin, 3);

    % Outward 2D normals for pinion
    dx_p = [xc_pin(2:end), xc_pin(1)] - [xc_pin(end), xc_pin(1:end-1)];
    dy_p = [yc_pin(2:end), yc_pin(1)] - [yc_pin(end), yc_pin(1:end-1)];
    mag_p = hypot(dx_p, dy_p); mag_p(mag_p < eps) = 1;
    nx_pout = dy_p ./ mag_p;
    ny_pout = -dx_p ./ mag_p;

    for s = 1:n_sec
        z_curr = z_levels(s);
        offset = (s - 1) * n_slice_pin;

        pin_side_verts(offset + (1:M_pin), 1) = xc_pin(:);
        pin_side_verts(offset + (1:M_pin), 2) = yc_pin(:);
        pin_side_verts(offset + (1:M_pin), 3) = z_curr;
        pin_side_normals(offset + (1:M_pin), 1) = nx_pout(:);
        pin_side_normals(offset + (1:M_pin), 2) = ny_pout(:);
        pin_side_normals(offset + (1:M_pin), 3) = 0;

        if has_bore
            pin_side_verts(offset + M_pin + (1:M_bore_pin), 1) = xb_pin(:);
            pin_side_verts(offset + M_pin + (1:M_bore_pin), 2) = yb_pin(:);
            pin_side_verts(offset + M_pin + (1:M_bore_pin), 3) = z_curr;
            pin_side_normals(offset + M_pin + (1:M_bore_pin), 1) = -cos(th_b(:));
            pin_side_normals(offset + M_pin + (1:M_bore_pin), 2) = -sin(th_b(:));
            pin_side_normals(offset + M_pin + (1:M_bore_pin), 3) = 0;
        end
    end

    % Pinion lateral faces
    n_p_quads = (n_sec - 1) * M_pin;
    p_teeth_faces = zeros(n_p_quads * 2, 3);
    qp_idx = 1;
    for s = 1:(n_sec - 1)
        b1 = (s - 1) * n_slice_pin;
        b2 = s * n_slice_pin;
        for k = 1:M_pin
            kn = mod(k, M_pin) + 1;
            p_teeth_faces(qp_idx,   :) = [b1 + k, b1 + kn, b2 + kn];
            p_teeth_faces(qp_idx+1, :) = [b1 + k, b2 + kn, b2 + k];
            qp_idx = qp_idx + 2;
        end
    end

    p_bore_faces = [];
    if has_bore
        n_pb_quads = (n_sec - 1) * M_bore_pin;
        p_bore_faces = zeros(n_pb_quads * 2, 3);
        qpb_idx = 1;
        for s = 1:(n_sec - 1)
            b1 = (s - 1) * n_slice_pin + M_pin;
            b2 = s * n_slice_pin + M_pin;
            for k = 1:M_bore_pin
                kn = mod(k, M_bore_pin) + 1;
                p_bore_faces(qpb_idx,   :) = [b1 + k, b2 + kn, b1 + kn];
                p_bore_faces(qpb_idx+1, :) = [b1 + k, b2 + k,  b2 + kn];
                qpb_idx = qpb_idx + 2;
            end
        end
    end

    % Pinion Planar End Caps
    if has_bore
        th_hole_cw = fliplr(th_b);
        xb_cw = r_bore_pin * cos(th_hole_cw);
        yb_cw = r_bore_pin * sin(th_hole_cw);
        pgon_pin = polyshape({xc_pin, xb_cw}, {yc_pin, yb_cw}, 'Simplify', false);
    else
        pgon_pin = polyshape(xc_pin, yc_pin, 'Simplify', false);
    end

    tr_pin = triangulation(pgon_pin);
    pts_cap_pin = tr_pin.Points;
    cl_cap_pin  = tr_pin.ConnectivityList;
    n_cap_pts_pin = size(pts_cap_pin, 1);

    pin_bot_verts   = [pts_cap_pin, -F/2 * ones(n_cap_pts_pin, 1)];
    pin_bot_normals = repmat([0, 0, -1], n_cap_pts_pin, 1);

    v1p = pts_cap_pin(cl_cap_pin(:,1), :);
    v2p = pts_cap_pin(cl_cap_pin(:,2), :);
    v3p = pts_cap_pin(cl_cap_pin(:,3), :);
    czp = (v2p(:,1)-v1p(:,1)).*(v3p(:,2)-v1p(:,2)) - (v2p(:,2)-v1p(:,2)).*(v3p(:,1)-v1p(:,1));

    bot_cl_p = cl_cap_pin;
    bot_cl_p(czp > 0, [2 3]) = bot_cl_p(czp > 0, [3 2]);
    pin_bot_faces = n_side_pin + bot_cl_p;

    pin_top_verts   = [pts_cap_pin, +F/2 * ones(n_cap_pts_pin, 1)];
    pin_top_normals = repmat([0, 0, 1], n_cap_pts_pin, 1);

    top_cl_p = cl_cap_pin;
    top_cl_p(czp < 0, [2 3]) = top_cl_p(czp < 0, [3 2]);
    pin_top_faces = n_side_pin + n_cap_pts_pin + top_cl_p;

    pinion_mesh = struct();
    pinion_mesh.vertices = [pin_side_verts; pin_bot_verts; pin_top_verts];
    pinion_mesh.normals  = [pin_side_normals; pin_bot_normals; pin_top_normals];
    pinion_mesh.faces    = [p_teeth_faces; p_bore_faces; pin_bot_faces; pin_top_faces];
    pinion_mesh.n_verts  = size(pinion_mesh.vertices, 1);
    pinion_mesh.n_faces  = size(pinion_mesh.faces, 1);
    pinion_mesh.r_pitch  = calc.rp_p;
    pinion_mesh.r_root   = calc.rd_p;
    pinion_mesh.r_bore   = r_bore_pin;
    pinion_mesh.F        = F;
end
