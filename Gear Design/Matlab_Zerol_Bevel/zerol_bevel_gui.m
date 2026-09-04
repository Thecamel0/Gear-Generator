function zerol_bevel_gui()
%% ========================================================================
%  ZEROL BEVEL GEAR DESIGN STUDIO — NATIVE MATLAB GUI
%  Wind Turbine Pitch Control System
%  ========================================================================
%  A standalone graphical user interface allowing users to adjust gear
%  parameters, calculate kinematics and bending stresses, view 3D assembly
%  and 2D meshing diagrams interactively, and export STEP (.stp), IGES (.igs),
%  STL (.stl), and SolidWorks VBA macros directly without modifying code.
%
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-01
% =========================================================================

    % Ensure required folders are on MATLAB path
    script_folder = fileparts(mfilename('fullpath'));
    if ~isempty(script_folder)
        addpath(fullfile(script_folder, 'Core'));
        addpath(fullfile(script_folder, 'PrintComp'));
        addpath(fullfile(script_folder, 'Export'));
        addpath(fullfile(script_folder, 'Viz'));
    end

    % Main Figure Window
    fig = uifigure('Name', 'Zerol Bevel Gear Studio — Wind Turbine Pitch Control', ...
        'Position', [80, 60, 1400, 840], ...
        'Color', [0.08, 0.10, 0.15]);

    % Main Grid Layout (Left: Parameter Sidebar, Right: Visualizations & Exports)
    mainGrid = uigridlayout(fig, [1, 2]);
    mainGrid.ColumnWidth = {420, '1x'};
    mainGrid.Padding = [12, 12, 12, 12];
    mainGrid.ColumnSpacing = 12;

    % =====================================================================
    % LEFT PANEL: PARAMETERS & INPUTS
    % =====================================================================
    leftPanel = uipanel(mainGrid, 'Title', '⚙️ Design Parameters', ...
        'FontWeight', 'bold', 'FontSize', 14, ...
        'ForegroundColor', [0.9, 0.95, 1.0], ...
        'BackgroundColor', [0.11, 0.14, 0.20]);
    
    leftGrid = uigridlayout(leftPanel, [18, 2]);
    leftGrid.ColumnWidth = {'1x', '1x'};
    leftGrid.RowHeight = repmat({28}, 1, 18);
    leftGrid.Padding = [8, 8, 8, 8];
    leftGrid.RowSpacing = 6;

    row = 1;

    % 1. Module
    uilabel(leftGrid, 'Text', 'Module m [mm]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_m = uieditfield(leftGrid, 'numeric', 'Value', 3.0, 'Limits', [0.5, 30], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 2. Teeth Pinion & Gear
    uilabel(leftGrid, 'Text', 'Pinion Teeth (Np):', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_Np = uieditfield(leftGrid, 'numeric', 'Value', 16, 'Limits', [6, 120], 'RoundFractionalValues', 'on', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    uilabel(leftGrid, 'Text', 'Ring Gear Teeth (Ng):', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_Ng = uieditfield(leftGrid, 'numeric', 'Value', 48, 'Limits', [10, 300], 'RoundFractionalValues', 'on', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 3. Pressure Angle & Shaft Angle
    uilabel(leftGrid, 'Text', 'Pressure Angle ϕ [deg]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_phi = uieditfield(leftGrid, 'numeric', 'Value', 20.0, 'Limits', [14.5, 30], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    uilabel(leftGrid, 'Text', 'Shaft Angle Σ [deg]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_Sigma = uieditfield(leftGrid, 'numeric', 'Value', 90.0, 'Limits', [10, 170], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 4. Pinions count & Face width factor
    uilabel(leftGrid, 'Text', 'Number of Pinions:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_pinions = uieditfield(leftGrid, 'numeric', 'Value', 3, 'Limits', [1, 8], 'RoundFractionalValues', 'on', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    uilabel(leftGrid, 'Text', 'Face Width / Ao Ratio:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_f_factor = uieditfield(leftGrid, 'numeric', 'Value', 0.28, 'Limits', [0.15, 0.35], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 5. Cutter Radius
    uilabel(leftGrid, 'Text', 'Cutter Radius rc [mm]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_rc = uieditfield(leftGrid, 'numeric', 'Value', 0, 'Limits', [0, 500], 'Tooltip', 'Set to 0 for Auto (Mean cone distance)', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 6. Operating Conditions
    uilabel(leftGrid, 'Text', 'Input Torque [N·m]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_torque = uieditfield(leftGrid, 'numeric', 'Value', 20.0, 'Limits', [1, 10000], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    uilabel(leftGrid, 'Text', 'Ring Speed [RPM]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_rpm = uieditfield(leftGrid, 'numeric', 'Value', 100.0, 'Limits', [1, 5000], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    uilabel(leftGrid, 'Text', 'Allowable Stress [MPa]:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_sigma_allow = uieditfield(leftGrid, 'numeric', 'Value', 250.0, 'Limits', [20, 2000], 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 7. 3D Print Material
    uilabel(leftGrid, 'Text', '3D Print Material:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    dd_material = uidropdown(leftGrid, 'Items', {'PLA', 'ABS', 'PETG', 'Nylon', 'Resin', 'Steel', 'None'}, ...
        'Value', 'PLA', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % 8. Mesh Detail
    uilabel(leftGrid, 'Text', 'Mesh Resolution (inv/sec):', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    ef_n_inv = uieditfield(leftGrid, 'numeric', 'Value', 18, 'Limits', [8, 40], 'RoundFractionalValues', 'on', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % Compute & Action Buttons
    btn_compute = uibutton(leftGrid, 'push', 'Text', '🚀 Compute & Visualize', ...
        'FontWeight', 'bold', 'FontSize', 13, ...
        'BackgroundColor', [0.15, 0.45, 0.85], 'FontColor', 'w', ...
        'Layout', struct('Row', [row, row+1], 'Column', [1, 2]));
    row = row + 2;

    % Quick Preset Dropdown
    uilabel(leftGrid, 'Text', 'Load Preset:', 'FontColor', [0.75, 0.85, 0.95], 'Layout', struct('Row', row, 'Column', 1));
    dd_preset = uidropdown(leftGrid, 'Items', {'Standard (16T/48T)', 'Compact (18T/36T)', 'High Ratio (12T/60T)', 'Heavy Duty (20T/60T)'}, ...
        'Value', 'Standard (16T/48T)', 'Layout', struct('Row', row, 'Column', 2));
    row = row + 1;

    % Status Message Label
    lbl_status = uilabel(leftGrid, 'Text', 'Ready. Adjust parameters and click Compute.', ...
        'FontColor', [0.4, 0.8, 0.5], 'FontSize', 11, 'FontAngle', 'italic', ...
        'Layout', struct('Row', row, 'Column', [1, 2]));

    % =====================================================================
    % RIGHT PANEL: TABS & EXPORTS
    % =====================================================================
    rightPanel = uipanel(mainGrid, 'BorderType', 'none', 'BackgroundColor', [0.08, 0.10, 0.15]);
    rightGrid = uigridlayout(rightPanel, [2, 1]);
    rightGrid.RowHeight = {'1x', 52};
    rightGrid.Padding = [0, 0, 0, 0];
    rightGrid.RowSpacing = 8;

    % Tab Group for Visualizations
    tabGroup = uitabgroup(rightGrid);
    tabGroup.Layout.Row = 1;

    tab3D = uitab(tabGroup, 'Title', '🌟 3D Multi-Pinion Assembly', 'BackgroundColor', [0.08, 0.08, 0.11]);
    tab2D = uitab(tabGroup, 'Title', '📐 2D Tooth Mesh & Contact Zone', 'BackgroundColor', [0.07, 0.07, 0.10]);
    tabReport = uitab(tabGroup, 'Title', '📊 Engineering Summary Table', 'BackgroundColor', [0.10, 0.12, 0.18]);

    % 3D Axes
    ax3D = uiaxes(tab3D, 'Position', [10, 10, 880, 640]);
    ax3D.Color = [0.10, 0.10, 0.14];
    ax3D.XColor = [0.7, 0.7, 0.7]; ax3D.YColor = [0.7, 0.7, 0.7]; ax3D.ZColor = [0.7, 0.7, 0.7];
    grid(ax3D, 'on');

    % 2D Grid inside Tab2D (Left: Overview, Right: Zoom)
    grid2D = uigridlayout(tab2D, [1, 2]);
    grid2D.Padding = [6, 6, 6, 6];
    ax2D_overview = uiaxes(grid2D);
    ax2D_overview.Color = [0.11, 0.11, 0.15];
    ax2D_zoom = uiaxes(grid2D);
    ax2D_zoom.Color = [0.11, 0.11, 0.15];

    % Report Table inside TabReport
    uitbl_report = uitable(tabReport, 'Position', [20, 20, 880, 630], ...
        'ColumnName', {'Parameter', 'Value', 'Unit', 'Assessment / Notes'}, ...
        'ColumnWidth', {220, 150, 100, 380}, ...
        'FontSize', 12);

    % Export Action Bar (Bottom of Right Panel)
    exportBar = uipanel(rightGrid, 'BackgroundColor', [0.12, 0.16, 0.24], 'BorderType', 'line');
    exportBar.Layout.Row = 2;
    exportGrid = uigridlayout(exportBar, [1, 6]);
    exportGrid.Padding = [6, 6, 6, 6];
    exportGrid.ColumnSpacing = 8;

    btn_exp_stp = uibutton(exportGrid, 'push', 'Text', '📁 Export STEP (.stp)', 'FontWeight', 'bold', 'BackgroundColor', [0.18, 0.26, 0.38], 'FontColor', 'w');
    btn_exp_igs = uibutton(exportGrid, 'push', 'Text', '📁 Export IGES (.igs)', 'FontWeight', 'bold', 'BackgroundColor', [0.18, 0.26, 0.38], 'FontColor', 'w');
    btn_exp_stl = uibutton(exportGrid, 'push', 'Text', '📁 Export STL (.stl)', 'FontWeight', 'bold', 'BackgroundColor', [0.18, 0.26, 0.38], 'FontColor', 'w');
    btn_exp_macro = uibutton(exportGrid, 'push', 'Text', '📝 SolidWorks Macro', 'FontWeight', 'bold', 'BackgroundColor', [0.18, 0.26, 0.38], 'FontColor', 'w');
    btn_exp_all = uibutton(exportGrid, 'push', 'Text', '⚡ Export ALL Files', 'FontWeight', 'bold', 'BackgroundColor', [0.10, 0.55, 0.35], 'FontColor', 'w');
    btn_open_folder = uibutton(exportGrid, 'push', 'Text', '📂 Open Folder', 'FontWeight', 'bold', 'BackgroundColor', [0.25, 0.32, 0.45], 'FontColor', 'w');

    % State storage
    appData = struct();

    % =====================================================================
    % CALLBACK FUNCTIONS
    % =====================================================================

    % Presets Callback
    dd_preset.ValueChangedFcn = @(src, event) applyPresetDropdown(src.Value);

    function applyPresetDropdown(presetName)
        switch presetName
            case 'Standard (16T/48T)'
                ef_m.Value = 3.0; ef_Np.Value = 16; ef_Ng.Value = 48; ef_phi.Value = 20; ef_torque.Value = 20; ef_rpm.Value = 100;
            case 'Compact (18T/36T)'
                ef_m.Value = 2.5; ef_Np.Value = 18; ef_Ng.Value = 36; ef_phi.Value = 20; ef_torque.Value = 15; ef_rpm.Value = 150;
            case 'High Ratio (12T/60T)'
                ef_m.Value = 3.5; ef_Np.Value = 12; ef_Ng.Value = 60; ef_phi.Value = 22.5; ef_torque.Value = 30; ef_rpm.Value = 80;
            case 'Heavy Duty (20T/60T)'
                ef_m.Value = 4.0; ef_Np.Value = 20; ef_Ng.Value = 60; ef_phi.Value = 20; ef_torque.Value = 50; ef_rpm.Value = 60;
        end
        ef_rc.Value = 0; % Auto
        runCompute();
    end

    % Main Compute Callback
    btn_compute.ButtonPushedFcn = @(src, event) runCompute();

    function runCompute()
        lbl_status.Text = 'Computing geometry & building 3D meshes...';
        lbl_status.FontColor = [0.9, 0.8, 0.3];
        drawnow;

        try
            % 1. Read Inputs
            m = ef_m.Value;
            Np = round(ef_Np.Value);
            Ng = round(ef_Ng.Value);
            phi_deg = ef_phi.Value;
            Sigma = ef_Sigma.Value;
            n_pinions = round(ef_pinions.Value);
            f_factor = ef_f_factor.Value;
            r_cutter_in = ef_rc.Value;
            khw_factor = 2.00;
            c_factor = 0.188;
            T_in_ring = ef_torque.Value;
            n_in_ring = ef_rpm.Value;
            eta = 0.97;
            sigma_allow_bend = ef_sigma_allow.Value;
            print_material = dd_material.Value;
            n_inv = round(ef_n_inv.Value);
            n_sec = 14;

            phi = deg2rad(phi_deg);
            Sigma_r = deg2rad(Sigma);
            i_ratio = Ng / Np;

            % Pitch diameters & cone angles
            dp = m * Np;
            dg = m * Ng;
            gamma_p = atan2(sin(Sigma_r), (Ng/Np + cos(Sigma_r)));
            gamma_g = Sigma_r - gamma_p;

            Ao = dp / (2 * sin(gamma_p));
            F = f_factor * Ao;
            Am = Ao - F/2;

            if r_cutter_in <= 0
                r_cutter = Am;
            else
                r_cutter = r_cutter_in;
            end

            hw = khw_factor * m;
            c_std = c_factor * m;
            ht = hw + c_std;

            a_p = 0.600 * hw; a_g = 0.400 * hw;
            b_p = ht - a_p;   b_g = ht - a_g;

            s_nom = pi * m / 2;
            s_shift = 0.180 * m;
            s_p = s_nom + s_shift;
            s_g = s_nom - s_shift;

            Do_p = dp + 2 * a_p * cos(gamma_p);
            Do_g = dg + 2 * a_g * cos(gamma_g);

            rb_p = dp / (2 * cos(gamma_p));
            rb_g = dg / (2 * cos(gamma_g));
            Nv_p = Np / cos(gamma_p);
            Nv_g = Ng / cos(gamma_g);

            rv_p  = m * Nv_p / 2;
            rv_g  = m * Nv_g / 2;
            rav_p = rv_p + a_p;
            rav_g = rv_g + a_g;
            rbv_p = rv_p * cos(phi);
            rbv_g = rv_g * cos(phi);
            pb    = pi * m * cos(phi);
            CR = (sqrt(rav_p^2 - rbv_p^2) + sqrt(rav_g^2 - rbv_g^2) - (rv_p + rv_g) * sin(phi)) / pb;

            MD_p = Ao * cos(gamma_p) - a_p * sin(gamma_p);
            MD_g = Ao * cos(gamma_g) - a_g * sin(gamma_g);

            % Kinematics & Forces
            n_pinion_out = n_in_ring * i_ratio;
            T_ring_per_mesh = T_in_ring / n_pinions;
            T_pinion_each = (T_ring_per_mesh / i_ratio) * eta;
            dg_mean = dg * Am / Ao;
            Ft = 2 * T_ring_per_mesh * 1000 / dg_mean;
            Fr_p = Ft * tan(phi) * cos(gamma_p);
            Fa_p = Ft * tan(phi) * sin(gamma_p);
            F_resultant = sqrt(Ft^2 + Fr_p^2 + Fa_p^2);

            m_mean = m * Am / Ao;
            Y_p = (0.484 - 2.87 / Nv_p) * (s_p / s_nom)^2;
            Y_g = (0.484 - 2.87 / Nv_g) * (s_g / s_nom)^2;
            sigma_b_p = Ft / (F * m_mean * Y_p);
            sigma_b_g = Ft / (F * m_mean * Y_g);
            SF_p = sigma_allow_bend / sigma_b_p;
            SF_g = sigma_allow_bend / sigma_b_g;

            % 3D Print Settings
            ps = print_settings(print_material);
            crowning_p = struct('lengthwise', ps.lengthwise_crown, 'profile', ps.profile_crown, ...
                'tip_relief', ps.tip_relief, 'tip_relief_start', ps.tip_relief_start);
            crowning_g = crowning_p;
            s_p_print = s_p - ps.extra_backlash;
            s_g_print = s_g - ps.extra_backlash;
            c_print = c_std + ps.clearance_add;
            ht_print = hw + c_print;
            b_p_print = ht_print - a_p;
            b_g_print = ht_print - a_g;

            % Generate 3D Meshes
            pinion_mesh = build_bevel_mesh_v2(Np, m, phi, a_p, b_p_print, gamma_p, ...
                Ao, F, r_cutter, n_inv, n_sec, 3, 3, s_p_print, crowning_p);
            gear_mesh = build_bevel_mesh_v2(Ng, m, phi, a_g, b_g_print, gamma_g, ...
                Ao, F, r_cutter, n_inv, n_sec, 3, 3, s_g_print, crowning_g);

            if ps.shrinkage_factor ~= 1.0
                pinion_mesh = print_compensation(pinion_mesh, ps.shrinkage_factor);
                gear_mesh = print_compensation(gear_mesh, ps.shrinkage_factor);
            end

            % Store in appData
            appData.m = m; appData.Np = Np; appData.Ng = Ng; appData.phi = phi; appData.phi_deg = phi_deg;
            appData.gamma_p = gamma_p; appData.gamma_g = gamma_g; appData.Ao = Ao; appData.Am = Am; appData.F = F;
            appData.r_cutter = r_cutter; appData.CR = CR; appData.dp = dp; appData.dg = dg;
            appData.Do_p = Do_p; appData.Do_g = Do_g; appData.MD_p = MD_p; appData.MD_g = MD_g;
            appData.a_p = a_p; appData.a_g = a_g; appData.b_p = b_p; appData.b_g = b_g;
            appData.hw = hw; appData.ht = ht; appData.c_std = c_std; appData.s_p = s_p; appData.s_g = s_g;
            appData.n_pinions = n_pinions; appData.pinion_mesh = pinion_mesh; appData.gear_mesh = gear_mesh;
            appData.T_in_ring = T_in_ring; appData.n_in_ring = n_in_ring; appData.T_pinion_each = T_pinion_each;
            appData.n_pinion_out = n_pinion_out; appData.Ft = Ft; appData.SF_p = SF_p; appData.SF_g = SF_g;
            appData.print_material = print_material;

            % 2. Render 3D Multi-Pinion Assembly
            cla(ax3D);
            hold(ax3D, 'on');

            % Central Ring Gear (Bronze)
            patch(ax3D, 'Vertices', gear_mesh.vertices, 'Faces', gear_mesh.faces, ...
                'FaceColor', [0.78 0.52 0.28], 'EdgeColor', 'none', 'FaceAlpha', 0.92, ...
                'FaceLighting', 'gouraud', 'AmbientStrength', 0.35);

            % Multi-Pinions
            pinion_colors = [0.45 0.58 0.78; 0.55 0.75 0.55; 0.72 0.48 0.65; 0.78 0.68 0.45];
            Ry90 = [0 0 1; 0 1 0; -1 0 0];
            phi_clock = pi / Np;
            R_clock = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];

            for p = 1:n_pinions
                angle_offset = (p - 1) * 2 * pi / n_pinions;
                c_a = cos(angle_offset); s_a = sin(angle_offset);
                Rz = [c_a -s_a 0; s_a c_a 0; 0 0 1];

                phase_angle = angle_offset * (Ng / Np);
                R_phase = [cos(phase_angle) -sin(phase_angle) 0; sin(phase_angle) cos(phase_angle) 0; 0 0 1];
                R_pinion = Rz * Ry90 * R_clock * R_phase;

                pin_verts = (R_pinion * pinion_mesh.vertices')';
                col = pinion_colors(mod(p-1, size(pinion_colors,1))+1, :);

                patch(ax3D, 'Vertices', pin_verts, 'Faces', pinion_mesh.faces, ...
                    'FaceColor', col, 'EdgeColor', 'none', 'FaceAlpha', 0.92, ...
                    'FaceLighting', 'gouraud', 'AmbientStrength', 0.35);
            end

            light(ax3D, 'Position', [1 1 1], 'Style', 'infinite');
            light(ax3D, 'Position', [-1 -1 0.5], 'Style', 'infinite');
            axis(ax3D, 'equal');
            xlabel(ax3D, 'X [mm]'); ylabel(ax3D, 'Y [mm]'); zlabel(ax3D, 'Z [mm]');
            title(ax3D, sprintf('3D Assembly: %d Pinions + Ring Gear (m=%g, rc=%.1f mm)', n_pinions, m, r_cutter), ...
                'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
            view(ax3D, [-40, 25]);

            % 3. Render 2D Plots
            render2DPlots(ax2D_overview, ax2D_zoom, appData);

            % 4. Populate Results Table
            tblData = {
                'Module (m)', sprintf('%.2f', m), 'mm', 'Metric standard module';
                'Teeth (Np / Ng)', sprintf('%d / %d', Np, Ng), '-', sprintf('Ratio 1:%.2f', i_ratio);
                'Pitch Diameters', sprintf('%.2f / %.2f', dp, dg), 'mm', 'dp = m*Np, dg = m*Ng';
                'Cone Angles (γp / γg)', sprintf('%.2f° / %.2f°', rad2deg(gamma_p), rad2deg(gamma_g)), 'deg', 'Pitch cone angles';
                'Cone Distance (Ao)', sprintf('%.2f', Ao), 'mm', 'Outer cone apex distance';
                'Face Width (F)', sprintf('%.2f', F), 'mm', sprintf('%.1f%% of Ao', f_factor*100);
                'Cutter Radius (rc)', sprintf('%.2f', r_cutter), 'mm', 'Gleason Zerol circular curvature';
                'Contact Ratio (CR)', sprintf('%.3f', CR), '-', evalCR(CR);
                'Pinion Speed / Torque', sprintf('%.0f RPM / %.2f N·m', n_pinion_out, T_pinion_each), '-', 'Output per blade shaft';
                'Mesh Forces (Ft / Fres)', sprintf('%.1f / %.1f', Ft, F_resultant), 'N', 'Tangential & resultant force';
                'Safety Factors (SF_p / SF_g)', sprintf('%.2f / %.2f', SF_p, SF_g), '-', evalSF(SF_p, SF_g);
                '3D Print Material', print_material, '-', ps.description
            };
            uitbl_report.Data = tblData;

            lbl_status.Text = sprintf('Design ready! CR = %.3f | SF = %.2f/%.2f', CR, SF_p, SF_g);
            lbl_status.FontColor = [0.3, 0.9, 0.4];

        catch ME
            lbl_status.Text = ['Error: ' ME.message];
            lbl_status.FontColor = [1.0, 0.3, 0.3];
        end
    end

    function str = evalCR(cr)
        if cr >= 1.5, str = 'GOOD (≥ 1.5)';
        elseif cr >= 1.2, str = 'ACCEPTABLE (≥ 1.2)';
        else, str = 'WARNING — Low contact ratio';
        end
    end

    function str = evalSF(sfp, sfg)
        if sfp >= 1.5 && sfg >= 1.5, str = 'SAFE (SF ≥ 1.5)';
        elseif sfp >= 1.0 && sfg >= 1.0, str = 'ACCEPTABLE (SF ≥ 1.0)';
        else, str = 'WARNING — High Bending Stress';
        end
    end

    function render2DPlots(ax1, ax2, data)
        cla(ax1); hold(ax1, 'on');
        cla(ax2); hold(ax2, 'on');

        rp_p = data.m * data.Np / 2;
        rp_g = data.m * data.Ng / 2;
        center_dist = rp_p + rp_g;

        % Subplot 1: Overview
        theta_c = linspace(0, 2*pi, 200);
        plot(ax1, rp_p*cos(theta_c), rp_p*sin(theta_c), '--', 'Color', [0.4 0.7 1.0], 'LineWidth', 1.2);
        plot(ax1, center_dist + rp_g*cos(theta_c), rp_g*sin(theta_c), '--', 'Color', [1.0 0.7 0.3], 'LineWidth', 1.2);
        plot(ax1, [0, center_dist], [0, 0], '-.', 'Color', [0.6 0.6 0.6]);
        plot(ax1, rp_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

        title(ax1, sprintf('2D Overview: %dT / %dT (C = %.1f mm)', data.Np, data.Ng, center_dist), 'Color', 'w', 'FontSize', 11);
        axis(ax1, 'equal'); grid(ax1, 'on');

        % Subplot 2: Zoom on Pitch Point
        loa_len = 15;
        loa_dir = [sin(data.phi), cos(data.phi)];
        plot(ax2, [rp_p - loa_len*loa_dir(1), rp_p + loa_len*loa_dir(1)], ...
                  [-loa_len*loa_dir(2), loa_len*loa_dir(2)], 'r-', 'LineWidth', 2);
        plot(ax2, rp_p, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

        title(ax2, sprintf('Active Meshing Zone (ϕ = %.1f°)', data.phi_deg), 'Color', 'w', 'FontSize', 11);
        axis(ax2, 'equal'); grid(ax2, 'on');
        xlim(ax2, [rp_p - 10, rp_p + 10]);
        ylim(ax2, [-10, 10]);
    end

    % =====================================================================
    % EXPORT HANDLERS
    % =====================================================================
    gear_design_dir = fileparts(script_folder);
    export_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Zerol_Bevel');

    btn_exp_stp.ButtonPushedFcn = @(s, e) exportSTEPFiles();
    btn_exp_igs.ButtonPushedFcn = @(s, e) exportIGESFiles();
    btn_exp_stl.ButtonPushedFcn = @(s, e) exportSTLFiles();
    btn_exp_macro.ButtonPushedFcn = @(s, e) exportMacroFiles();
    btn_exp_all.ButtonPushedFcn = @(s, e) exportAll();
    btn_open_folder.ButtonPushedFcn = @(s, e) winopen(export_dir);

    function exportSTEPFiles()
        if ~isfield(appData, 'pinion_mesh'), runCompute(); end
        if ~exist(export_dir, 'dir'), mkdir(export_dir); end
        export_step_v2(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.stp'));
        export_step_v2(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.stp'));
        uialert(fig, ['STEP AP214 Solid files saved to: ' export_dir], 'Export Complete', 'Icon', 'success');
    end

    function exportIGESFiles()
        if ~isfield(appData, 'pinion_mesh'), runCompute(); end
        if ~exist(export_dir, 'dir'), mkdir(export_dir); end
        export_gear_igs(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.igs'));
        export_gear_igs(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.igs'));
        uialert(fig, ['IGES 5.3 Surface/Solid files saved to: ' export_dir], 'Export Complete', 'Icon', 'success');
    end

    function exportSTLFiles()
        if ~isfield(appData, 'pinion_mesh'), runCompute(); end
        if ~exist(export_dir, 'dir'), mkdir(export_dir); end
        export_stl_v2(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.stl'));
        export_stl_v2(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.stl'));
        uialert(fig, ['3D Printable STL files saved to: ' export_dir], 'Export Complete', 'Icon', 'success');
    end

    function exportMacroFiles()
        if ~isfield(appData, 'pinion_mesh'), runCompute(); end
        export_solidworks_macro(appData, fullfile(gear_design_dir, 'Solidworks'));
        uialert(fig, 'SolidWorks VBA Macro & Equations saved to Solidworks folder!', 'Export Complete', 'Icon', 'success');
    end

    function exportAll()
        if ~isfield(appData, 'pinion_mesh'), runCompute(); end
        if ~exist(export_dir, 'dir'), mkdir(export_dir); end
        export_step_v2(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.stp'));
        export_step_v2(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.stp'));
        export_gear_igs(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.igs'));
        export_gear_igs(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.igs'));
        export_stl_v2(appData.pinion_mesh, fullfile(export_dir, 'zerol_pinion_v2.stl'));
        export_stl_v2(appData.gear_mesh, fullfile(export_dir, 'zerol_gear_v2.stl'));
        export_solidworks_macro(appData, fullfile(gear_design_dir, 'Solidworks'));
        uialert(fig, ['All CAD files (STP, IGS, STL, SolidWorks Macros) successfully exported to: ' export_dir], 'Export All Complete', 'Icon', 'success');
    end

    % Initial calculation on launch
    runCompute();
end
