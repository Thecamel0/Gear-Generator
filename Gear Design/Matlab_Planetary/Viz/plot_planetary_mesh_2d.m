function fig2 = plot_planetary_mesh_2d(calc)
%PLOT_PLANETARY_MESH_2D Generates publication-grade 2D contact analysis diagrams
%   for a complete Epicyclic (Planetary) Gear Train.
%
%   - Subplot 1: Full 2D Epicyclic Train Layout (Sun, K Planets, Ring Gear, Orbit Circle)
%   - Subplot 2: High-Magnification Dual-Mesh Contact Zones (Sun-Planet & Planet-Ring Lines of Action)
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-11

    if nargin < 1
        error('plot_planetary_mesh_2d requires calc struct');
    end

    fig2 = figure('Name', 'Planetary Suite — 2D Engagement & Kinematics', ...
        'NumberTitle', 'off', ...
        'Position', [70, 70, 1450, 780], ...
        'Color', [0.07 0.07 0.10]);

    % Kinematics & Radii
    m = calc.m;
    Ns = calc.Ns;
    Np = calc.Np;
    Nr = calc.Nr;
    K = calc.K;
    phi = calc.phi;
    C = calc.center_dist;

    rp_s = calc.rp_s; rb_s = calc.rb_s; ra_s = calc.ra_s; rd_s = calc.rd_s;
    rp_p = calc.rp_p; rb_p = calc.rb_p; ra_p = calc.ra_p; rd_p = calc.rd_p;
    rp_r = calc.rp_r; rb_r = calc.rb_r; ra_r = calc.ra_r_int; rd_r = calc.rd_r_int;
    r_rim = calc.r_rim;

    s_nom = (pi * m) / 2;

    % Generate polygons
    [xc_sun, yc_sun] = generate_spur_profile_2d(Ns, m, phi, m, 1.25*m, s_nom, 80);
    [xc_plan, yc_plan] = generate_spur_profile_2d(Np, m, phi, m, 1.25*m, s_nom, 80);
    [xc_ring, yc_ring, x_rim, y_rim] = generate_internal_spur_profile_2d(calc, 40);

    th_c = linspace(0, 2*pi, 360);

    %% ====================================================================
    %  SUBPLOT 1: Full 2D Engagement Overview
    %  ====================================================================
    ax1 = subplot(1, 2, 1, 'Parent', fig2);
    hold(ax1, 'on');

    % 1. Ring Gear (Bronze Annulus)
    xc_teeth_cw = fliplr(xc_ring);
    yc_teeth_cw = fliplr(yc_ring);
    pgon_ring = polyshape({x_rim, xc_teeth_cw}, {y_rim, yc_teeth_cw}, 'Simplify', false);
    plot(pgon_ring, 'FaceColor', [0.78 0.52 0.28], 'FaceAlpha', 0.60, ...
        'EdgeColor', [0.65 0.40 0.20], 'LineWidth', 1.0, 'Parent', ax1);

    % 2. Central Sun Gear (Polished Silver / Light Blue)
    fill(ax1, xc_sun, yc_sun, [0.80 0.85 0.95], 'FaceAlpha', 0.88, ...
        'EdgeColor', [0.45 0.55 0.75], 'LineWidth', 1.0);

    % 3. K Planet Gears
    planet_colors = [
        0.45 0.58 0.78;
        0.55 0.75 0.55;
        0.72 0.48 0.65;
        0.78 0.68 0.45;
        0.50 0.70 0.75;
        0.70 0.55 0.55
    ];

    for k = 1:K
        th_k = (k - 1) * 2 * pi / K;
        cx = C * cos(th_k);
        cy = C * sin(th_k);

        phi_rot = th_k + th_k * (Ns / Np);
        c_p = cos(phi_rot); s_p = sin(phi_rot);
        px = (xc_plan * c_p - yc_plan * s_p) + cx;
        py = (xc_plan * s_p + yc_plan * c_p) + cy;

        c_idx = mod(k - 1, size(planet_colors, 1)) + 1;
        fill(ax1, px, py, planet_colors(c_idx, :), 'FaceAlpha', 0.85, ...
            'EdgeColor', [0.3 0.3 0.4], 'LineWidth', 1.0);

        % Planet center pin marker & Bore circle
        plot(ax1, cx, cy, 'k+', 'MarkerSize', 8, 'LineWidth', 1.5);
        plot(ax1, cx + calc.r_bore_planet * cos(th_c), cy + calc.r_bore_planet * sin(th_c), ...
            'k-', 'LineWidth', 0.8);
    end

    % 4. Pitch Circles & Carrier Orbit Circle
    plot(ax1, rp_s * cos(th_c), rp_s * sin(th_c), '--', 'Color', [0.6 0.8 1.0], 'LineWidth', 1.2);
    plot(ax1, rp_r * cos(th_c), rp_r * sin(th_c), '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);
    plot(ax1, C * cos(th_c), C * sin(th_c), 'c-.', 'LineWidth', 1.4); % Carrier Orbit Circle

    % 5. Center markers & Centerlines
    plot(ax1, 0, 0, 'w+', 'MarkerSize', 12, 'LineWidth', 1.5);
    plot(ax1, [-r_rim*1.05, r_rim*1.05], [0, 0], ':', 'Color', [0.5 0.5 0.6], 'LineWidth', 0.8);
    plot(ax1, [0, 0], [-r_rim*1.05, r_rim*1.05], ':', 'Color', [0.5 0.5 0.6], 'LineWidth', 0.8);

    % 6. Labels & Annotations
    text(0, -rp_s * 0.5, sprintf('Sun (%dT)\nPD = %.0f mm', Ns, 2*rp_s), ...
        'Color', 'w', 'FontSize', 8, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C, 0, sprintf('Planet 1 (%dT)\nPD = %.0f mm', Np, 2*rp_p), ...
        'Color', 'w', 'FontSize', 8, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(0, rp_r + 6, sprintf('Ring Gear (%dT) - PD = %.0f mm', Nr, 2*rp_r), ...
        'Color', [0.95 0.75 0.35], 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(0, -C - 5, sprintf('Carrier Orbit Radius C = %.1f mm', C), ...
        'Color', 'c', 'FontSize', 8, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    axis(ax1, 'equal'); grid(ax1, 'on');
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]');
    title(ax1, sprintf('2D Epicyclic Layout: Sun + %d Planets + Ring (m = %g mm)', K, m), ...
        'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax1, 'Color', [0.10 0.10 0.14], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);
    xlim(ax1, [-r_rim*1.1, r_rim*1.1]);
    ylim(ax1, [-r_rim*1.1, r_rim*1.1]);

    %% ====================================================================
    %  SUBPLOT 2: High-Magnification Dual-Mesh Contact Mechanics
    %  ====================================================================
    ax2 = subplot(1, 2, 2, 'Parent', fig2);
    hold(ax2, 'on');

    % Magnified view centered on Planet 1 (X = C = 45 mm, Y = 0)
    % Shows Sun-Planet mesh at X = rp_s = 18 mm and Planet-Ring mesh at X = rp_r = 72 mm
    plot(pgon_ring, 'FaceColor', [0.78 0.52 0.28], 'FaceAlpha', 0.50, ...
        'EdgeColor', [0.65 0.40 0.20], 'LineWidth', 1.0, 'Parent', ax2);
    fill(ax2, xc_sun, yc_sun, [0.80 0.85 0.95], 'FaceAlpha', 0.80, ...
        'EdgeColor', [0.45 0.55 0.75], 'LineWidth', 1.0);

    px1 = xc_plan + C;
    py1 = yc_plan;
    fill(ax2, px1, py1, [0.45 0.58 0.78], 'FaceAlpha', 0.85, ...
        'EdgeColor', [0.28 0.36 0.48], 'LineWidth', 1.0);

    % Pitch Points: P1 (Sun-Planet) at (rp_s, 0) and P2 (Planet-Ring) at (rp_r, 0)
    P1 = [rp_s, 0];
    P2 = [rp_r, 0];
    plot(ax2, P1(1), P1(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    plot(ax2, P2(1), P2(2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 7);

    % Lines of Action (LOA)
    loa_len = 20;
    loa_dir = [sin(phi), cos(phi)];
    loa1_a = [P1(1) - loa_len * loa_dir(1), P1(2) - loa_len * loa_dir(2)];
    loa1_b = [P1(1) + loa_len * loa_dir(1), P1(2) + loa_len * loa_dir(2)];
    plot(ax2, [loa1_a(1), loa1_b(1)], [loa1_a(2), loa1_b(2)], 'r-', 'LineWidth', 1.6);

    loa2_a = [P2(1) - loa_len * loa_dir(1), P2(2) - loa_len * loa_dir(2)];
    loa2_b = [P2(1) + loa_len * loa_dir(1), P2(2) + loa_len * loa_dir(2)];
    plot(ax2, [loa2_a(1), loa2_b(1)], [loa2_a(2), loa2_b(2)], 'm-', 'LineWidth', 1.6);

    % Pitch circles in zoom region
    plot(ax2, rp_s * cos(th_c), rp_s * sin(th_c), '--', 'Color', [0.6 0.8 1.0], 'LineWidth', 1.2);
    plot(ax2, C + rp_p * cos(th_c), rp_p * sin(th_c), '--', 'Color', [0.55 0.75 0.95], 'LineWidth', 1.2);
    plot(ax2, rp_r * cos(th_c), rp_r * sin(th_c), '--', 'Color', [0.95 0.75 0.35], 'LineWidth', 1.2);

    % Text Callouts
    text(P1(1) - 2, 8, sprintf('P1: Sun-Planet Mesh\nCR = %.3f', calc.CR_sp), ...
        'Color', [1 0.4 0.4], 'FontSize', 8, 'FontWeight', 'bold');
    text(P2(1) - 8, 8, sprintf('P2: Planet-Ring Mesh\nCR = %.3f', calc.CR_pr), ...
        'Color', [1 0.5 0.9], 'FontSize', 8, 'FontWeight', 'bold');

    % Kinematic Performance Summary Table
    kin_text = {
        sprintf('\\bf Willis Ratio: \\rm i = 1 + Nr/Ns = %.2f:1', calc.i_ratio), ...
        sprintf('\\bf Input Sun Speed: \\rm %.0f RPM  \\rightarrow  \\bf Carrier: \\rm %.1f RPM', calc.n_in_sun, calc.n_carrier_out), ...
        sprintf('\\bf Planet Spin on Pin: \\rm %.1f RPM', calc.n_planet_relative), ...
        sprintf('\\bf Sun Torque: \\rm %.1f N\\cdot m  \\rightarrow  \\bf Carrier: \\rm %.1f N\\cdot m', calc.T_in_sun, calc.T_carrier_out), ...
        sprintf('\\bf Tangential Load / Mesh: \\rm Ft = %.1f N (K_\\gamma = %.2f)', calc.Ft, calc.K_gamma), ...
        sprintf('\\bf Bending Safety SF: \\rm Sun = %.1f, Planet = %.1f, Ring = %.1f', calc.SF_b_s, calc.SF_b_p, calc.SF_b_r), ...
        sprintf('\\bf Contact Stress SF: \\rm Sun-Planet = %.1f, Planet-Ring = %.1f', calc.SF_contact_sp, calc.SF_contact_pr)
    };
    text(ax2, 10, -25, kin_text, 'Color', 'w', 'FontSize', 8.5, ...
        'BackgroundColor', [0.15 0.15 0.20], 'EdgeColor', [0.4 0.4 0.5], 'Margin', 6);

    axis(ax2, 'equal'); grid(ax2, 'on');
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]');
    title(ax2, 'Magnified Dual Contact Mechanics & Kinematic Distribution', ...
        'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    set(ax2, 'Color', [0.10 0.10 0.14], ...
        'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], ...
        'GridColor', [0.25 0.25 0.30], 'GridAlpha', 0.5);
    xlim(ax2, [5, 95]);
    ylim(ax2, [-35, 30]);
end
