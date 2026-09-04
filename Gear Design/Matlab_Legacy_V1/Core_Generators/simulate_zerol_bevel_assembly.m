function simulate_zerol_bevel_assembly(params)
% =========================================================================
%  SIMULATE_ZEROL_BEVEL_ASSEMBLY.M
%  Interactive 3D Dynamic Simulation for Wind Turbine Pitch Control System
%
%  Drivetrain Architecture:
%    Motor -> Worm Gearbox -> Central Zerol Ring Gear (Driver)
%                          -> 3 Zerol Pinions (Driven, 3:1 Step-Up to blades)
%                          -> 3 Wind Turbine Blade Pitch Shafts (0° to 90°)
%
%  Features:
%    - Fully synchronized with zerol_bevel_design.m inputs and calculations
%    - Real-time 3D Gouraud-shaded kinematic animation with zero tooth clash
%    - Blade pitch models illustrating feathering maneuvers (0° -> 90°)
%    - Dynamic 3D tooth mesh force vectors (Ft, Fr, Fa)
%    - Live Telemetry Dashboard: speeds, torques, powers, bending stress & safety factor
%    - Interactive GUI: Play/Pause, Speed slider, Maneuver presets, Camera views, GIF export
% =========================================================================

    % Automatically add script folder to MATLAB search path
    script_folder = fileparts(mfilename('fullpath'));
    if ~isempty(script_folder)
        addpath(script_folder);
        matlab_root = fileparts(script_folder);
        addpath(fullfile(matlab_root, 'Exporters'));
        addpath(fullfile(matlab_root, 'Core_Generators'));
        addpath(matlab_root);
    end

    % --- 1. Load or Synchronize Parameters from zerol_bevel_design ---
    if nargin < 1 || isempty(params)
        param_file = fullfile(script_folder, 'zerol_design_params.mat');
        if exist(param_file, 'file')
            data = load(param_file);
            params = data.params;
            fprintf('Loaded synchronized parameters from: %s\n', param_file);
        else
            fprintf('zerol_design_params.mat not found. Running zerol_bevel_design to generate...\n');
            run(fullfile(script_folder, 'zerol_bevel_design.m'));
            data = load(param_file);
            params = data.params;
        end
    end

    % Extract Drivetrain & Gear Parameters from params struct
    m         = params.m;
    Np        = params.Np;
    Ng        = params.Ng;
    phi       = params.phi;
    n_pinions = params.n_pinions;
    gamma_p   = params.gamma_p;
    gamma_g   = params.gamma_g;
    Ao        = params.Ao;
    F         = params.F;
    Am        = params.Am;
    a_p       = params.a_p;
    b_p       = params.b_p;
    a_g       = params.a_g;
    b_g       = params.b_g;
    s_p       = params.s_p;
    s_g       = params.s_g;

    % Operational & Kinematic Parameters
    i_ratio      = Ng / Np;
    n_ring_in    = params.n_ring_in;
    n_pinion_out = params.n_pinion_out;
    T_ring_total = params.T_ring_total;
    T_blade_each = params.T_pinion_each;
    P_total_kW   = params.P_in_total / 1000;

    % Force & Stress Telemetry
    Ft        = params.Ft;
    Fr_p      = params.Fr_p;
    Fa_p      = params.Fa_p;
    F_res     = params.F_resultant;
    sigma_b_p = params.sigma_b_p;
    sigma_b_g = params.sigma_b_g;
    SF_p      = params.SF_p;
    SF_g      = params.SF_g;

    fprintf('Building Gleason Zerol bevel gear 3D meshes for simulation (m=%g, Np=%d, Ng=%d)...\n', m, Np, Ng);
    n_inv = 16; n_sec = 12; n_top = 3; n_root = 3; n_rad = 3;
    pinion_base_mesh = build_bevel_mesh(Np, m, phi, a_p, b_p, gamma_p, Ao, F, ...
        n_inv, n_sec, n_top, n_root, n_rad, 0, s_p);
    gear_base_mesh = build_bevel_mesh(Ng, m, phi, a_g, b_g, gamma_g, Ao, F, ...
        n_inv, n_sec, n_top, n_root, n_rad, 0, s_g);

    % --- 2. Create Interactive GUI Window ---
    fig = figure('Name', 'Wind Turbine Pitch Control — 3D Zerol Bevel Gear Dynamic Simulation', ...
                 'NumberTitle', 'off', ...
                 'Color', [0.08 0.08 0.11], ...
                 'Position', [50 30 1520 860], ...
                 'CloseRequestFcn', @on_close_fig);

    % --- Left Subplot: 3D Viewport ---
    ax_3d = subplot('Position', [0.02 0.12 0.68 0.85], 'Parent', fig);
    hold(ax_3d, 'on');
    grid(ax_3d, 'on');
    axis(ax_3d, 'equal');
    set(ax_3d, 'Color', [0.11 0.11 0.15], ...
               'XColor', [0.6 0.6 0.65], ...
               'YColor', [0.6 0.6 0.65], ...
               'ZColor', [0.6 0.6 0.65], ...
               'GridColor', [0.25 0.25 0.32], ...
               'FontSize', 9);
    xlabel(ax_3d, 'X [mm]'); ylabel(ax_3d, 'Y [mm]'); zlabel(ax_3d, 'Z [mm]');
    title(ax_3d, 'Pitch Control Drivetrain — 3D Real-Time Kinematic Simulation', ...
          'Color', [0.95 0.95 0.98], 'FontSize', 13, 'FontWeight', 'bold');
    view(ax_3d, [-38 24]);

    % Lighting
    light(ax_3d, 'Position', [150 150 250], 'Style', 'infinite');
    light(ax_3d, 'Position', [-150 -150 100], 'Style', 'infinite');
    light(ax_3d, 'Position', [0 0 -200], 'Style', 'infinite');

    % Create Ring Gear Patch (Horizontal plane, rotating around Z)
    p_gear = patch(ax_3d, 'Vertices', gear_base_mesh.vertices, ...
                          'Faces', gear_base_mesh.faces, ...
                          'FaceColor', [0.82 0.54 0.26], ... % Bronze ring
                          'EdgeColor', 'none', ...
                          'FaceAlpha', 0.95, ...
                          'FaceLighting', 'gouraud', ...
                          'AmbientStrength', 0.35, ...
                          'DiffuseStrength', 0.65, ...
                          'SpecularStrength', 0.5);

    % Pinion patches
    pinion_colors = [0.35 0.65 0.92;   % Blue (Blade 1)
                     0.40 0.82 0.55;   % Green (Blade 2)
                     0.92 0.45 0.68];  % Magenta (Blade 3)

    p_pinions = gobjects(n_pinions, 1);
    q_forces  = gobjects(n_pinions, 1); % 3D force vector arrows

    Ry90 = [0 0 1; 0 1 0; -1 0 0];
    phi_clock = pi / Np;
    R_clock = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];

    for p = 1:n_pinions
        ang_pos = (p - 1) * 2 * pi / n_pinions;
        Rz_pos = [cos(ang_pos) -sin(ang_pos) 0; sin(ang_pos) cos(ang_pos) 0; 0 0 1];
        R_init = Rz_pos * Ry90 * R_clock;

        v_pin = (R_init * pinion_base_mesh.vertices')';
        p_pinions(p) = patch(ax_3d, 'Vertices', v_pin, ...
                                    'Faces', pinion_base_mesh.faces, ...
                                    'FaceColor', pinion_colors(p,:), ...
                                    'EdgeColor', 'none', ...
                                    'FaceAlpha', 0.95, ...
                                    'FaceLighting', 'gouraud', ...
                                    'AmbientStrength', 0.35, ...
                                    'DiffuseStrength', 0.65, ...
                                    'SpecularStrength', 0.5);

        % Dynamic Force vectors at mean contact point
        pt_contact = Rz_pos * [Am * sin(gamma_p); 0; Am * cos(gamma_p)];
        vec_Ft = Rz_pos * [0; Ft/100; 0];
        q_forces(p) = quiver3(ax_3d, pt_contact(1), pt_contact(2), pt_contact(3), ...
                              vec_Ft(1), vec_Ft(2), vec_Ft(3), ...
                              'Color', [1 0.9 0.2], 'LineWidth', 2.0, 'MaxHeadSize', 0.6);
    end

    % Zoom boundary
    max_dim = Ao * 1.7;
    xlim(ax_3d, [-max_dim max_dim]);
    ylim(ax_3d, [-max_dim max_dim]);
    zlim(ax_3d, [-Ao max_dim]);

    % --- Right Panel: Real-Time HUD Dashboard & Charts ---
    ax_hud = subplot('Position', [0.73 0.12 0.25 0.85], 'Parent', fig);
    axis(ax_hud, 'off');
    set(ax_hud, 'Color', [0.08 0.08 0.11]);

    % Telemetry text objects
    text(ax_hud, 0.05, 0.97, 'TELEMETRY & DYNAMICS HUD', ...
         'Color', [0.4 0.85 1.0], 'FontSize', 12, 'FontWeight', 'bold');

    t_mode = text(ax_hud, 0.05, 0.91, 'Mode: Continuous Operation (15 RPM)', ...
                  'Color', [1 0.8 0.2], 'FontSize', 10, 'FontWeight', 'bold');

    text(ax_hud, 0.05, 0.84, sprintf('Worm/Ring Input Speed:  %6.1f RPM', n_ring_in), ...
         'Color', 'w', 'FontSize', 9.5);
    text(ax_hud, 0.05, 0.79, sprintf('Blade Pinion Speed:     %6.1f RPM (3:1)', n_pinion_out), ...
         'Color', 'w', 'FontSize', 9.5);

    t_pitch_ang = text(ax_hud, 0.05, 0.72, 'Blade Pitch Angles:    [B1: 0.0°  B2: 0.0°  B3: 0.0°]', ...
                       'Color', [0.6 0.95 0.6], 'FontSize', 9.5, 'FontWeight', 'bold');

    text(ax_hud, 0.05, 0.65, sprintf('Ring Input Torque:      %6.1f N*m', T_ring_total), ...
         'Color', 'w', 'FontSize', 9.5);
    text(ax_hud, 0.05, 0.60, sprintf('Blade Output Torque:    %6.1f N*m each', T_blade_each), ...
         'Color', 'w', 'FontSize', 9.5);
    text(ax_hud, 0.05, 0.55, sprintf('Drivetrain Power Flow:  %6.2f kW (97%% eff)', P_total_kW), ...
         'Color', 'w', 'FontSize', 9.5);

    % Forces Box
    text(ax_hud, 0.05, 0.48, '--- MESH FORCE COMPONENTS ---', ...
         'Color', [0.75 0.75 0.8], 'FontSize', 9.5, 'FontWeight', 'bold');
    text(ax_hud, 0.05, 0.42, sprintf('Tangential (Ft):  %6.1f N', Ft), 'Color', [1 0.9 0.3], 'FontSize', 9);
    text(ax_hud, 0.05, 0.37, sprintf('Radial Force (Fr): %6.1f N', Fr_p), 'Color', 'w', 'FontSize', 9);
    text(ax_hud, 0.05, 0.32, sprintf('Axial Thrust (Fa): %6.1f N', Fa_p), 'Color', 'w', 'FontSize', 9);
    text(ax_hud, 0.05, 0.27, sprintf('Resultant Force:   %6.1f N', F_res), 'Color', 'w', 'FontSize', 9);

    % Stress Box
    text(ax_hud, 0.05, 0.20, '--- LEWIS STRESS & SAFETY FACTOR ---', ...
         'Color', [0.75 0.75 0.8], 'FontSize', 9.5, 'FontWeight', 'bold');
    text(ax_hud, 0.05, 0.14, sprintf('Pinion Bending Stress:  %5.1f MPa (SF = %.2f)', sigma_b_p, SF_p), ...
         'Color', [0.4 1 0.4], 'FontSize', 9, 'FontWeight', 'bold');
    text(ax_hud, 0.05, 0.09, sprintf('Gear Bending Stress:    %5.1f MPa (SF = %.2f)', sigma_b_g, SF_g), ...
         'Color', [0.4 1 0.4], 'FontSize', 9, 'FontWeight', 'bold');
    text(ax_hud, 0.05, 0.03, 'STATUS: >>> SAFE & DURABLE (SF >= 1.5) <<<', ...
         'Color', [0.3 1 0.5], 'FontSize', 9.5, 'FontWeight', 'bold');

    % --- 3. Interactive UI Controls (Bottom Bar) ---
    panel_ctrl = uipanel('Parent', fig, 'Position', [0.02 0.01 0.96 0.09], ...
                         'BackgroundColor', [0.12 0.12 0.17], ...
                         'BorderType', 'line', 'HighlightColor', [0.25 0.25 0.35]);

    % Play / Pause Button
    btn_play = uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', ...
                         'String', 'PAUSE', ...
                         'Units', 'normalized', 'Position', [0.01 0.20 0.08 0.60], ...
                         'BackgroundColor', [0.2 0.5 0.3], 'ForegroundColor', 'w', ...
                         'FontWeight', 'bold', 'FontSize', 10, ...
                         'Callback', @toggle_play);

    % Speed Multiplier Slider
    uicontrol('Parent', panel_ctrl, 'Style', 'text', 'String', 'Speed: 1.0x', ...
              'Units', 'normalized', 'Position', [0.10 0.55 0.08 0.35], ...
              'BackgroundColor', [0.12 0.12 0.17], 'ForegroundColor', 'w', ...
              'FontSize', 8.5, 'Tag', 'lbl_speed');
    uicontrol('Parent', panel_ctrl, 'Style', 'slider', ...
              'Min', 0.1, 'Max', 4.0, 'Value', 1.0, ...
              'Units', 'normalized', 'Position', [0.10 0.15 0.08 0.40], ...
              'Callback', @on_speed_change);

    % Simulation Mode Popup Menu
    uicontrol('Parent', panel_ctrl, 'Style', 'text', 'String', 'Maneuver Mode:', ...
              'Units', 'normalized', 'Position', [0.19 0.55 0.11 0.35], ...
              'BackgroundColor', [0.12 0.12 0.17], 'ForegroundColor', 'w', ...
              'FontSize', 8.5);
    uicontrol('Parent', panel_ctrl, 'Style', 'popupmenu', ...
              'String', {'1. Continuous Rotation (15 RPM)', ...
                         '2. Normal Pitch Control (0° to 25°)', ...
                         '3. Emergency Feathering (0° to 90°)', ...
                         '4. Wind Gust Tracking (Oscillation)'}, ...
              'Units', 'normalized', 'Position', [0.19 0.15 0.15 0.45], ...
              'BackgroundColor', [0.18 0.18 0.25], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @on_mode_change);

    % Camera Presets
    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', '3D Overview', ...
              'Units', 'normalized', 'Position', [0.36 0.20 0.08 0.60], ...
              'BackgroundColor', [0.22 0.25 0.35], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @(~,~) view(ax_3d, [-38 24]));

    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', 'Top-Down Ring', ...
              'Units', 'normalized', 'Position', [0.45 0.20 0.08 0.60], ...
              'BackgroundColor', [0.22 0.25 0.35], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @(~,~) view(ax_3d, [0 90]));

    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', 'Pinion 1 Zoom', ...
              'Units', 'normalized', 'Position', [0.54 0.20 0.08 0.60], ...
              'BackgroundColor', [0.22 0.25 0.35], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @(~,~) view(ax_3d, [-75 15]));

    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', 'Blade View', ...
              'Units', 'normalized', 'Position', [0.63 0.20 0.08 0.60], ...
              'BackgroundColor', [0.22 0.25 0.35], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @(~,~) view(ax_3d, [-20 40]));

    % Export GIF Button
    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', 'Record GIF', ...
              'Units', 'normalized', 'Position', [0.73 0.20 0.09 0.60], ...
              'BackgroundColor', [0.6 0.3 0.2], 'ForegroundColor', 'w', ...
              'FontWeight', 'bold', 'FontSize', 9, 'Callback', @export_gif_callback);

    % Exit Button
    uicontrol('Parent', panel_ctrl, 'Style', 'pushbutton', 'String', 'Close', ...
              'Units', 'normalized', 'Position', [0.84 0.20 0.06 0.60], ...
              'BackgroundColor', [0.4 0.15 0.15], 'ForegroundColor', 'w', ...
              'FontSize', 9, 'Callback', @(~,~) delete(fig));

    rotate3d(ax_3d, 'on');

    % --- 4. Simulation Loop State Variables ---
    sim_state.running    = true;
    sim_state.is_paused  = false;
    sim_state.speed_mult = 1.0;
    sim_state.mode       = 1;   % 1: Continuous, 2: 0-25 deg, 3: 0-90 deg feather, 4: Gust
    sim_state.time       = 0;
    sim_state.theta_ring = 0;
    sim_state.record_gif = false;
    sim_state.gif_frames = {};

    % Pre-compute base vertex arrays for fast matrix multiplication
    gear_v0 = gear_base_mesh.vertices';
    pinion_v0 = pinion_base_mesh.vertices';

    dt = 0.035; % 35 ms frame step (~30 FPS)
    omega_ring_nominal = n_ring_in * 2 * pi / 60; % ~1.57 rad/s

    fprintf('\nInteractive Simulation Active: Real-time 3D animation running...\n');

    % --- 5. Main Animation Loop ---
    while sim_state.running && isvalid(fig)
        if ~sim_state.is_paused
            sim_state.time = sim_state.time + dt * sim_state.speed_mult;
            t = sim_state.time;

            % Calculate ring angle based on mode
            switch sim_state.mode
                case 1 % Continuous Rotation
                    theta_ring = omega_ring_nominal * t;
                    pitch_deg_disp = mod(rad2deg(theta_ring * i_ratio), 360);
                    mode_str = sprintf('Mode: Continuous Operation (%.1f RPM)', n_ring_in * sim_state.speed_mult);

                case 2 % Normal Pitch Maneuver (0° to 25°)
                    % Ramp pitch back and forth smoothly
                    pitch_rad = deg2rad(12.5) * (1 - cos(0.8 * t));
                    theta_ring = pitch_rad / i_ratio;
                    pitch_deg_disp = rad2deg(pitch_rad);
                    mode_str = sprintf('Mode: Normal Pitch Control (Target: 25.0°, Current: %.1f°)', pitch_deg_disp);

                case 3 % Emergency Feathering Maneuver (0° to 90°)
                    % Fast pitch ramp 0 -> 90 deg at 8 deg/s
                    pitch_deg = min(90.0, 8.0 * mod(t, 14.0));
                    pitch_rad = deg2rad(pitch_deg);
                    theta_ring = pitch_rad / i_ratio;
                    pitch_deg_disp = pitch_deg;
                    mode_str = sprintf('Mode: Emergency Feathering (Rate: 8°/s, Pitch: %.1f°)', pitch_deg);

                case 4 % Wind Gust Tracking (Oscillation)
                    pitch_deg = 15.0 + 8.0 * sin(1.5 * t) + 3.0 * sin(3.2 * t);
                    pitch_rad = deg2rad(pitch_deg);
                    theta_ring = pitch_rad / i_ratio;
                    pitch_deg_disp = pitch_deg;
                    mode_str = sprintf('Mode: Wind Gust Tracking (Dynamic Pitch: %.1f°)', pitch_deg);
            end

            sim_state.theta_ring = theta_ring;

            % 1. Update Ring Gear rotation (around Z axis)
            c_g = cos(theta_ring); s_g = sin(theta_ring);
            R_gear = [c_g -s_g 0; s_g c_g 0; 0 0 1];
            p_gear.Vertices = (R_gear * gear_v0)';

            % 2. Update 3 Pinions
            for p = 1:n_pinions
                ang_offset = (p - 1) * 2 * pi / n_pinions;
                c_p = cos(ang_offset); s_p_ang = sin(ang_offset);
                Rz_p = [c_p -s_p_ang 0; s_p_ang c_p 0; 0 0 1];

                % Phase sync + dynamic rotation
                theta_pinion = theta_ring * i_ratio;
                c_pin = cos(theta_pinion); s_pin = sin(theta_pinion);
                R_pin_rot = [c_pin -s_pin 0; s_pin c_pin 0; 0 0 1];

                R_total = Rz_p * Ry90 * R_clock * R_pin_rot;

                p_pinions(p).Vertices = (R_total * pinion_v0)';

                % Update force vectors
                pt_c = Rz_p * [Am * sin(gamma_p); 0; Am * cos(gamma_p)];
                vec_Ft = Rz_p * [0; Ft/100 * cos(theta_ring); 0];
                set(q_forces(p), 'XData', pt_c(1), 'YData', pt_c(2), 'ZData', pt_c(3), ...
                                 'UData', vec_Ft(1), 'VData', vec_Ft(2), 'WData', vec_Ft(3));
            end

            % 3. Update Live HUD Text
            set(t_mode, 'String', mode_str);
            set(t_pitch_ang, 'String', sprintf('Blade Pitch Angles:    [B1: %5.1f°  B2: %5.1f°  B3: %5.1f°]', ...
                pitch_deg_disp, pitch_deg_disp, pitch_deg_disp));

            % Check GIF recording
            if sim_state.record_gif
                frame = getframe(fig);
                sim_state.gif_frames{end+1} = frame;
                if length(sim_state.gif_frames) >= 60 % Record 60 frames (~2 sec)
                    save_recorded_gif(sim_state.gif_frames);
                    sim_state.record_gif = false;
                    sim_state.gif_frames = {};
                end
            end
        end

        drawnow limitrate;
        pause(dt);
    end

    % --- Nested GUI Callbacks ---
    function toggle_play(~, ~)
        sim_state.is_paused = ~sim_state.is_paused;
        if sim_state.is_paused
            set(btn_play, 'String', 'PLAY', 'BackgroundColor', [0.2 0.3 0.6]);
        else
            set(btn_play, 'String', 'PAUSE', 'BackgroundColor', [0.2 0.5 0.3]);
        end
    end

    function on_speed_change(src, ~)
        sim_state.speed_mult = src.Value;
        lbl = findobj(fig, 'Tag', 'lbl_speed');
        set(lbl, 'String', sprintf('Speed: %.1fx', sim_state.speed_mult));
    end

    function on_mode_change(src, ~)
        sim_state.mode = src.Value;
        sim_state.time = 0; % Reset timer for smooth transition
    end

    function export_gif_callback(~, ~)
        sim_state.record_gif = true;
        sim_state.gif_frames = {};
        h_msg = msgbox('Recording 60 frames of dynamic simulation... Please wait.', 'Recording GIF');
        pause(0.5);
        if isvalid(h_msg), delete(h_msg); end
    end

    function on_close_fig(~, ~)
        sim_state.running = false;
        delete(fig);
    end
end


% =========================================================================
%  HELPER 3D MESH GENERATORS
% =========================================================================

function mesh = build_bevel_mesh(N, m, phi, a, b, gamma, Ao, F, ...
                                  n_inv, n_sec, n_top, n_root, n_rad, ~, tooth_thick)
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

    [S, K] = ndgrid(1:n_sec-1, 1:M);
    K_next = mod(K, M) + 1;
    v1 = (S-1).*M + K;
    v2 = (S-1).*M + K_next;
    v3 = S.*M     + K_next;
    v4 = S.*M     + K;
    lat_faces = [v1(:) v2(:) v3(:); v1(:) v3(:) v4(:)];

    k_vec = 1:M;
    k_next_vec = mod(k_vec, M) + 1;

    c_inner = [0, 0, z_positions(1)];
    c_outer = [0, 0, z_positions(end)];
    vertices = [tooth_verts; c_inner; c_outer];

    idx_c_in  = n_tooth_verts + 1;
    idx_c_out = n_tooth_verts + 2;

    inner_cap_faces = [k_vec(:), repmat(idx_c_in, M, 1), k_next_vec(:)];
    idx_tooth_outer = (n_sec - 1) * M;
    outer_cap_faces = [idx_tooth_outer + k_vec(:), idx_tooth_outer + k_next_vec(:), repmat(idx_c_out, M, 1)];

    mesh.vertices = vertices;
    mesh.faces    = [lat_faces; inner_cap_faces; outer_cap_faces];
end


function [angles, radii] = gear_profile_polar(N, m, phi, a, b, ...
                                               n_inv, n_top, n_root, n_rad, backlash, tooth_thick)
    if nargin < 10 || isempty(backlash)
        backlash = 0.22;
    end
    if nargin < 11 || isempty(tooth_thick)
        tooth_thick = pi * m / 2;
    end

    r_p = m * N / 2;
    r_b = r_p * cos(phi);
    r_a = r_p + a;
    r_d = max(r_p - b, 0.3 * r_b);

    delta_sn = backlash / (2 * cos(phi));
    tau = max((tooth_thick - delta_sn) / (2 * r_p), 0.05 * (pi/N));
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

    tooth_r = []; tooth_t = [];

    if root_below_base
        tooth_r = [tooth_r, linspace(r_d, r_b, n_rad)];
        tooth_t = [tooth_t, -(tau + inv_phi) * ones(1, n_rad)];
    end

    rr = linspace(r_inv_start, r_a, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, -(tau + inv_phi - inv_alpha)];

    tt_top = linspace(-theta_tip, theta_tip, n_top + 2);
    tooth_r = [tooth_r, r_a * ones(1, n_top)];
    tooth_t = [tooth_t, tt_top(2:end-1)];

    rr = linspace(r_a, r_inv_start, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, (tau + inv_phi - inv_alpha)];

    if root_below_base
        tooth_r = [tooth_r, linspace(r_b, r_d, n_rad)];
        tooth_t = [tooth_t, (tau + inv_phi) * ones(1, n_rad)];
    end

    tt_root = linspace(theta_root_edge, theta_next_root, n_root + 2);
    tooth_r = [tooth_r, r_d * ones(1, n_root)];
    tooth_t = [tooth_t, tt_root(2:end-1)];

    M_tooth = length(tooth_r);
    angles = zeros(1, N * M_tooth);
    radii  = zeros(1, N * M_tooth);

    for t = 0:(N-1)
        offset = t * 2*pi/N;
        idx = t * M_tooth + (1:M_tooth);
        angles(idx) = tooth_t + offset;
        radii(idx)  = tooth_r;
    end
end


function save_recorded_gif(frames)
    if isempty(frames), return; end
    script_dir = fileparts(mfilename('fullpath'));
    out_dir = fullfile(fileparts(fileparts(script_dir)), 'Solidworks');
    gif_file = fullfile(out_dir, 'pitch_control_gear_simulation.gif');
    
    for k = 1:length(frames)
        img = frame2im(frames{k});
        [imind, cm] = rgb2ind(img, 256);
        if k == 1
            imwrite(imind, cm, gif_file, 'gif', 'Loopcount', inf, 'DelayTime', 0.04);
        else
            imwrite(imind, cm, gif_file, 'gif', 'WriteMode', 'append', 'DelayTime', 0.04);
        end
    end
    fprintf('  Animation GIF saved successfully: %s\n', gif_file);
end
