function settings = print_settings(material)
%PRINT_SETTINGS Get 3D printing compensation settings for a material
%
%   settings = print_settings('PLA')
%   settings = print_settings('ABS')
%   settings = print_settings('PETG')
%   settings = print_settings('Nylon')
%   settings = print_settings('Resin')
%   settings = print_settings('Steel')   % CNC machined — minimal compensation
%   settings = print_settings('None')    % No compensation (nominal geometry)
%
%   Output struct fields:
%       .material           - Material name
%       .shrinkage_factor   - Scale factor to compensate for shrinkage (> 1.0)
%       .extra_backlash     - Extra backlash per side [mm]
%       .tip_relief         - Tip relief depth [mm]
%       .tip_relief_start   - Relief starts at this fraction of addendum
%       .root_fillet_scale  - Root fillet radius multiplier (1.0 = standard)
%       .lengthwise_crown   - Recommended lengthwise crowning [mm]
%       .profile_crown      - Recommended profile crowning [mm]
%       .min_wall           - Minimum wall thickness [mm]
%       .clearance_add      - Extra clearance to add to bottom clearance [mm]
%       .tolerance          - Typical dimensional tolerance [± mm]
%       .description        - Human-readable description
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-24

    if nargin < 1
        material = 'PLA';
    end

    settings = struct();
    settings.material = upper(material);

    switch upper(material)
        case 'PLA'
            settings.shrinkage_factor   = 1.003;    % 0.3% shrinkage
            settings.extra_backlash     = 0.15;     % mm per side
            settings.tip_relief         = 0.10;     % mm
            settings.tip_relief_start   = 0.85;     % 85% of addendum
            settings.root_fillet_scale  = 1.3;      % 30% larger fillet
            settings.lengthwise_crown   = 0.012;    % mm
            settings.profile_crown      = 0.008;    % mm
            settings.min_wall           = 1.2;      % mm
            settings.clearance_add      = 0.10;     % mm
            settings.tolerance          = 0.15;     % ± mm
            settings.description        = 'PLA (FDM) — Prototype printing, good detail, brittle';

        case 'ABS'
            settings.shrinkage_factor   = 1.006;    % 0.6% shrinkage
            settings.extra_backlash     = 0.20;     % mm per side
            settings.tip_relief         = 0.12;     % mm
            settings.tip_relief_start   = 0.85;
            settings.root_fillet_scale  = 1.3;
            settings.lengthwise_crown   = 0.015;    % mm
            settings.profile_crown      = 0.010;    % mm
            settings.min_wall           = 1.5;      % mm
            settings.clearance_add      = 0.15;     % mm
            settings.tolerance          = 0.20;     % ± mm
            settings.description        = 'ABS (FDM) — Tougher than PLA, more shrinkage';

        case 'PETG'
            settings.shrinkage_factor   = 1.004;    % 0.4% shrinkage
            settings.extra_backlash     = 0.15;
            settings.tip_relief         = 0.10;
            settings.tip_relief_start   = 0.85;
            settings.root_fillet_scale  = 1.2;
            settings.lengthwise_crown   = 0.012;
            settings.profile_crown      = 0.008;
            settings.min_wall           = 1.2;
            settings.clearance_add      = 0.10;
            settings.tolerance          = 0.15;
            settings.description        = 'PETG (FDM) — Good balance of strength and detail';

        case 'NYLON'
            settings.shrinkage_factor   = 1.015;    % 1.5% shrinkage
            settings.extra_backlash     = 0.25;
            settings.tip_relief         = 0.15;
            settings.tip_relief_start   = 0.80;
            settings.root_fillet_scale  = 1.4;
            settings.lengthwise_crown   = 0.020;
            settings.profile_crown      = 0.012;
            settings.min_wall           = 1.5;
            settings.clearance_add      = 0.20;
            settings.tolerance          = 0.25;
            settings.description        = 'Nylon (FDM/SLS) — Tough, flexible, high shrinkage';

        case 'RESIN'
            settings.shrinkage_factor   = 1.002;    % 0.2% shrinkage
            settings.extra_backlash     = 0.08;
            settings.tip_relief         = 0.05;
            settings.tip_relief_start   = 0.90;
            settings.root_fillet_scale  = 1.1;
            settings.lengthwise_crown   = 0.008;
            settings.profile_crown      = 0.005;
            settings.min_wall           = 0.8;
            settings.clearance_add      = 0.05;
            settings.tolerance          = 0.05;
            settings.description        = 'Resin (SLA/DLP) — High precision, brittle';

        case 'STEEL'
            settings.shrinkage_factor   = 1.000;    % CNC — no shrinkage
            settings.extra_backlash     = 0.02;     % Machining tolerance only
            settings.tip_relief         = 0.02;
            settings.tip_relief_start   = 0.92;
            settings.root_fillet_scale  = 1.0;
            settings.lengthwise_crown   = 0.005;
            settings.profile_crown      = 0.003;
            settings.min_wall           = 0;        % No minimum
            settings.clearance_add      = 0.00;
            settings.tolerance          = 0.02;
            settings.description        = 'Steel (CNC) — Production quality, tight tolerances';

        case 'NONE'
            settings.shrinkage_factor   = 1.000;
            settings.extra_backlash     = 0.00;
            settings.tip_relief         = 0.00;
            settings.tip_relief_start   = 1.00;
            settings.root_fillet_scale  = 1.0;
            settings.lengthwise_crown   = 0.000;
            settings.profile_crown      = 0.000;
            settings.min_wall           = 0;
            settings.clearance_add      = 0.00;
            settings.tolerance          = 0.00;
            settings.description        = 'No compensation — nominal theoretical geometry';

        otherwise
            warning('print_settings:unknownMaterial', ...
                'Unknown material "%s". Using PLA defaults.', material);
            settings = print_settings('PLA');
            settings.material = upper(material);
    end
end
