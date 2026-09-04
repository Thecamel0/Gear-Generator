function [xc, yc, r_p, r_b, r_a, r_d] = generate_spur_profile_2d(N, m, phi, a, b, tooth_thick, n_pts)
%GENERATE_SPUR_PROFILE_2D Generates a closed, high-precision 2D polygon of all N teeth
%   Guarantees zero duplicate consecutive points at curve transitions.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 7 || isempty(n_pts)
        n_pts = 300;
    end

    r_p = m * N / 2;
    r_b = r_p * cos(phi);
    r_a = r_p + a;
    r_d = max(r_p - b, 0.25 * r_b);

    tau = tooth_thick / (2 * r_p);
    inv_phi = tan(phi) - phi;

    root_below_base = (r_d < r_b);
    r_inv_start = max(r_b, r_d);

    alpha_tip = acos(min(r_b / r_a, 1.0));
    theta_tip = tau + inv_phi - (tan(alpha_tip) - alpha_tip);

    if root_below_base
        theta_root = tau + inv_phi;
    else
        alpha_root = acos(min(r_b / r_d, 1.0));
        theta_root = tau + inv_phi - (tan(alpha_root) - alpha_root);
    end
    theta_next_root = 2 * pi / N - theta_root;

    % Build single tooth profile (counter-clockwise)
    % Exclude endpoint of each segment to prevent duplicate coincident vertices
    xc_tooth = [];
    yc_tooth = [];

    % 1. Left flank root transition (below base circle if applicable)
    if root_below_base
        nr = max(6, round(n_pts * 0.12));
        rr = linspace(r_d, r_b, nr);
        rr(end) = []; % drop r_b (start of involute)
        tt = -(tau + inv_phi) * ones(size(rr));
        xc_tooth = [xc_tooth, rr .* cos(tt)];
        yc_tooth = [yc_tooth, rr .* sin(tt)];
    end

    % 2. Left involute active flank (r_inv_start -> r_a)
    rr = linspace(r_inv_start, r_a, n_pts);
    rr(end) = []; % drop r_a (start of tip land)
    alpha = acos(min(r_b ./ rr, 1.0));
    inv_alpha = tan(alpha) - alpha;
    tt = -(tau + inv_phi - inv_alpha);
    xc_tooth = [xc_tooth, rr .* cos(tt)];
    yc_tooth = [yc_tooth, rr .* sin(tt)];

    % 3. Tip land arc at r_a (-theta_tip -> +theta_tip)
    n_tip = max(10, round(n_pts * 0.1));
    tt_top = linspace(-theta_tip, theta_tip, n_tip);
    tt_top(end) = []; % drop +theta_tip (start of right involute)
    xc_tooth = [xc_tooth, r_a * cos(tt_top)];
    yc_tooth = [yc_tooth, r_a * sin(tt_top)];

    % 4. Right involute active flank (r_a -> r_inv_start)
    rr = linspace(r_a, r_inv_start, n_pts);
    rr(end) = []; % drop r_inv_start (start of root fillet)
    alpha = acos(min(r_b ./ rr, 1.0));
    inv_alpha = tan(alpha) - alpha;
    tt = (tau + inv_phi - inv_alpha);
    xc_tooth = [xc_tooth, rr .* cos(tt)];
    yc_tooth = [yc_tooth, rr .* sin(tt)];

    % 5. Right flank root transition (r_b -> r_d)
    if root_below_base
        nr = max(6, round(n_pts * 0.12));
        rr = linspace(r_b, r_d, nr);
        rr(end) = []; % drop r_d (start of root land)
        tt = (tau + inv_phi) * ones(size(rr));
        xc_tooth = [xc_tooth, rr .* cos(tt)];
        yc_tooth = [yc_tooth, rr .* sin(tt)];
    end

    % 6. Root land arc at r_d (theta_root -> theta_next_root)
    n_root_pts = max(10, round(n_pts * 0.1));
    tt_root = linspace(theta_root, theta_next_root, n_root_pts);
    tt_root(end) = []; % drop theta_next_root (start of next tooth)
    xc_tooth = [xc_tooth, r_d * cos(tt_root)];
    yc_tooth = [yc_tooth, r_d * sin(tt_root)];

    % 7. Replicate single tooth across all N teeth around 360 degrees
    M = length(xc_tooth);
    xc = zeros(1, N * M);
    yc = zeros(1, N * M);

    for t = 0:(N-1)
        angle = t * 2 * pi / N;
        c = cos(angle);
        s = sin(angle);
        idx = t * M + (1:M);
        xc(idx) = xc_tooth * c - yc_tooth * s;
        yc(idx) = xc_tooth * s + yc_tooth * c;
    end
end
