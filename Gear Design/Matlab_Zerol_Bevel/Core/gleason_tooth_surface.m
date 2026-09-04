function [verts_3d, n_pts_per_sec, n_sections] = gleason_tooth_surface(N, m, phi, a, b, ...
        gamma, Ao, F, r_cutter, n_inv, n_sec, n_top, n_root, tooth_thick)
%GLEASON_TOOTH_SURFACE Generate a Zerol bevel gear tooth surface (TRUE CONE)
%
%   Produces TRUE bevel gear geometry where:
%     - The tooth profile is defined in the back-cone (Tregold) plane
%     - Addendum/dedendum project NORMAL to the pitch cone surface
%     - Each cross-section sits ON the pitch cone, not on flat Z planes
%     - Teeth taper correctly from heel (outer) to toe (inner)
%
%   This matches real Gleason face-milled bevel gears where the tooth
%   depth is measured perpendicular to the cone surface.
%
%   Inputs:
%       N           - Number of teeth
%       m           - Module [mm]
%       phi         - Pressure angle [rad]
%       a           - Addendum [mm] (measured normal to cone)
%       b           - Dedendum [mm] (measured normal to cone)
%       gamma       - Pitch cone angle [rad]
%       Ao          - Outer cone distance [mm]
%       F           - Face width [mm]
%       r_cutter    - Cutter radius [mm] (controls tooth curvature)
%       n_inv       - Points per involute curve
%       n_sec       - Cross-sections along face width
%       n_top       - Points on tip arc
%       n_root      - Points on root arc
%       tooth_thick - Circular tooth thickness at pitch circle [mm]
%
%   Outputs:
%       verts_3d       - [n_sec*M x 3] 3D vertex coordinates (X, Y, Z)
%       n_pts_per_sec  - number of points per cross-section (M)
%       n_sections     - number of cross-sections (n_sec)
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-26

    % Derived cone distances
    Ai = Ao - F;                    % Inner cone distance
    Am = Ao - F/2;                  % Mean cone distance

    % Positions along face width (inner to outer)
    cone_dists = linspace(Ai, Ao, n_sec);

    % Generate the reference 2D involute profile at the OUTER cone distance
    % This profile is in the Tregold back-cone plane
    [ref_angles, ref_radii] = involute_profile(N, m, phi, a, b, ...
                                                n_inv, n_top, n_root, tooth_thick);
    M = length(ref_angles);     % Points per profile

    % Pre-allocate 3D output
    verts_3d = zeros(n_sec * M, 3);

    % Pitch radius at outer cone
    r_pitch_outer = m * N / 2;

    for s = 1:n_sec
        A = cone_dists(s);

        % --- Scale factor (teeth shrink toward cone apex) ---
        sf = A / Ao;

        % --- Zerol tooth trace: circular arc offset ---
        if isempty(r_cutter) || isinf(r_cutter) || r_cutter <= 0
            delta_theta = 0;
        else
            delta = A - Am;
            arg = r_cutter^2 - delta^2;
            if arg > 0
                delta_theta = -(r_cutter - sqrt(arg)) / (A * sin(gamma));
            else
                delta_theta = 0;
            end
        end

        % --- Scale the 2D profile for this cone distance ---
        scaled_radii = ref_radii * sf;
        scaled_angles = ref_angles + delta_theta;

        % --- Place the profile ON the pitch cone ---
        % For each point, compute its deviation from the pitch circle
        % and project that deviation NORMAL to the cone surface.
        %
        % In the 2D profile:
        %   r_pitch_local = r_pitch_outer * sf
        %   delta_r = scaled_radii - r_pitch_local  (positive = outward/tip, negative = root)
        %
        % On the cone surface:
        %   - The pitch point is at (r_pitch_local, 0, z_pitch) where
        %     r_pitch_local = A * sin(gamma), z_pitch = A * cos(gamma)
        %   - The cone OUTWARD normal is [sin(gamma), 0, cos(gamma)]
        %     in the (radial, tangential, axial) frame
        %   - Addendum goes OUTWARD along the normal (tip sticks up)
        %   - Dedendum goes INWARD along the normal (root goes into the cone)
        %
        % So a point at profile radius r has:
        %   delta_r_2d = r - r_pitch_local  (from the 2D involute)
        %   actual_3d_radial = r_pitch_cone + delta_r_2d * cos(gamma)
        %   actual_3d_axial  = z_pitch_cone - delta_r_2d * sin(gamma)
        %
        % This correctly projects the tooth height normal to the cone.

        r_pitch_local = r_pitch_outer * sf;  % 2D pitch radius at this section
        r_cone = A * sin(gamma);             % 3D radial position of pitch on cone
        z_cone = A * cos(gamma);             % 3D axial position of pitch on cone

        % Deviation from pitch circle in the 2D profile
        delta_r = scaled_radii - r_pitch_local;

        % Project onto cone: normal to cone surface points
        % outward at angle gamma from the axial direction
        r_3d = r_cone + delta_r * cos(gamma);  % radial component
        z_3d = z_cone - delta_r * sin(gamma);  % axial component (tips go up, roots go down)

        % Convert (r, theta, z) cylindrical to Cartesian
        idx = (s-1)*M + (1:M);
        verts_3d(idx, 1) = r_3d .* cos(scaled_angles);
        verts_3d(idx, 2) = r_3d .* sin(scaled_angles);
        verts_3d(idx, 3) = z_3d;
    end

    n_pts_per_sec = M;
    n_sections = n_sec;
end


function [angles, radii] = involute_profile(N, m, phi, a, b, ...
                                             n_inv, n_top, n_root, tooth_thick)
%INVOLUTE_PROFILE Generate complete 2D gear profile (all N teeth)
%   with proper involute flanks, tip land, root land, and root fillet.
%
%   This is a cleaned-up version that avoids degenerate (zero-area)
%   triangles at tooth boundaries by careful point placement.

    r_p = m * N / 2;                % Pitch radius
    r_b = r_p * cos(phi);           % Base circle radius
    r_a = r_p + a;                  % Addendum (tip) radius
    r_d = max(r_p - b, 0.3 * r_b); % Dedendum (root) radius, with floor

    % Root fillet radius (smooth transition, not sharp corner)
    r_fillet = 0.30 * m;            % ~30% of module

    % Half-tooth angle (angular extent of one tooth flank at pitch circle)
    % Uses actual tooth thickness (may differ for pinion vs gear)
    tau = tooth_thick / (2 * r_p);

    % Involute function at pressure angle
    inv_phi = tan(phi) - phi;

    % Check if root is below base circle
    root_below_base = (r_d < r_b);
    r_inv_start = max(r_b, r_d);

    % Tip involute angle
    alpha_tip = acos(min(r_b / r_a, 1));
    theta_tip = tau + inv_phi - (tan(alpha_tip) - alpha_tip);

    % Root involute angle
    if root_below_base
        theta_root = tau + inv_phi;
    else
        alpha_root = acos(min(r_b / r_d, 1));
        theta_root = tau + inv_phi - (tan(alpha_root) - alpha_root);
    end

    % Next tooth's root angle
    theta_next_root = 2*pi/N - theta_root;

    % === Build one tooth profile (left flank -> tip -> right flank -> root) ===
    tooth_r = [];
    tooth_t = [];

    % --- Left flank: root to tip ---
    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_d, r_b, nr);
        tt = -(tau + inv_phi) * ones(1, nr);
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    % Involute curve from base/root to tip
    rr = linspace(r_inv_start, r_a, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = -(tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    % --- Tip land arc ---
    if n_top > 0
        tt_top = linspace(-theta_tip, theta_tip, n_top + 2);
        tt_top = tt_top(2:end-1);
        rr_top = r_a * ones(1, n_top);
        tooth_r = [tooth_r, rr_top];
        tooth_t = [tooth_t, tt_top];
    end

    % --- Right flank: tip to root ---
    rr = linspace(r_a, r_inv_start, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = (tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    if root_below_base
        nr = max(3, round(n_inv * 0.2));
        rr = linspace(r_b, r_d, nr);
        tt = (tau + inv_phi) * ones(1, nr);
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    % --- Root land arc ---
    n_root_pts = max(n_root, 2);
    tt_root = linspace(theta_root, theta_next_root, n_root_pts + 2);
    tt_root = tt_root(2:end-1);
    rr_root = r_d * ones(1, n_root_pts);
    tooth_r = [tooth_r, rr_root];
    tooth_t = [tooth_t, tt_root];

    % === Replicate for all N teeth ===
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
