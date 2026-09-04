function results = zerol_bevel_pitch_control()
%==========================================================================
% ZEROl BEVEL GEAR PAIR
% WIND TURBINE PITCH CONTROL SYSTEM
%
% File:
%   zerol_bevel_pitch_control.m
%
% Purpose:
%   Parametric generation and visualization of a Zerol bevel gear pair
%   intended for a wind-turbine blade pitch-control drivetrain.
%
% IMPORTANT:
%
%   A true Zerol bevel gear has:
%
%       Spiral angle = 0 degrees
%
%   Therefore, unlike a spiral bevel gear, the tooth does NOT progressively
%   rotate around the gear face.
%
%   This program creates a parametric engineering visualization model.
%   It is NOT a production Gleason/Klingelnberg manufacturing generator.
%
% OUTPUT FILES:
%
%   ZEROL_PINION.stl
%   ZEROL_GEAR.stl
%   ZEROL_BEVEL_PITCH_CONTROL.mat
%   ZEROL_BEVEL_DESIGN_REPORT.csv
%
% VISUAL OUTPUT:
%
%   Figure 1 - Zerol Pinion
%   Figure 2 - Zerol Gear
%   Figure 3 - 3D Gear Assembly
%   Figure 4 - 2D Meshing Diagram
%
%==========================================================================

clc;
close all;

fprintf('\n');
fprintf('==============================================================\n');
fprintf('       ZEROl BEVEL GEAR - WIND TURBINE PITCH CONTROL\n');
fprintf('==============================================================\n\n');

%% ========================================================================
% 1. USER DESIGN INPUTS
% ==========================================================================

P = struct();

%==========================================================================
% GEAR RATIO
%==========================================================================

P.ratio = 4.0;

%==========================================================================
% NUMBER OF TEETH
%==========================================================================

P.z1 = 20;                     % Pinion
P.z2 = round(P.z1 * P.ratio);  % Gear

%==========================================================================
% MODULE / PITCH DIAMETER
%==========================================================================

P.pitchDiameter1 = 80;         % Pinion pitch diameter [mm]

P.module = P.pitchDiameter1 / P.z1;

P.pitchDiameter2 = ...
    P.module * P.z2;

%==========================================================================
% PRESSURE ANGLE
%==========================================================================

P.pressureAngleDeg = 20;

%==========================================================================
% ZEROl SPIRAL ANGLE
%
% THIS MUST BE ZERO FOR A ZEROl BEVEL GEAR
%==========================================================================

P.spiralAngleDeg = 0;

%==========================================================================
% FACE WIDTH
%==========================================================================

P.faceWidth = 30;              % mm

%==========================================================================
% CONTACT RATIO TARGET
%==========================================================================

P.targetContactRatio = 1.40;

%==========================================================================
% TOOTH DIMENSIONS
%==========================================================================

P.addendum = P.module;

P.dedendum = 1.25 * P.module;

P.clearance = ...
    P.dedendum - P.addendum;

P.backlash = 0.05;             % mm

%==========================================================================
% SHAFT BORES
%==========================================================================

P.boreDiameter1 = 20;          % Pinion bore [mm]
P.boreDiameter2 = 40;          % Gear bore [mm]

%==========================================================================
% WIND TURBINE PITCH DRIVE INPUT
%
% Replace these with your actual actuator/motor values.
%==========================================================================

P.inputSpeedRPM = 12;

P.inputTorqueNm = 1000;

P.efficiency = 0.94;

%==========================================================================
% MESH / GEOMETRY RESOLUTION
%==========================================================================

P.nFace = 20;

P.nAngularPerTooth = 24;

%==========================================================================
% VISUALIZATION
%==========================================================================

P.showToothEdges = true;

%% ========================================================================
% 2. DERIVED GEAR PARAMETERS
% ==========================================================================

P.pitchRadius1 = ...
    P.pitchDiameter1 / 2;

P.pitchRadius2 = ...
    P.pitchDiameter2 / 2;

%==========================================================================
% OUTER DIAMETERS
%==========================================================================

P.outerDiameter1 = ...
    P.pitchDiameter1 + 2 * P.addendum;

P.outerDiameter2 = ...
    P.pitchDiameter2 + 2 * P.addendum;

%==========================================================================
% ROOT DIAMETERS
%==========================================================================

P.rootDiameter1 = ...
    P.pitchDiameter1 - 2 * P.dedendum;

P.rootDiameter2 = ...
    P.pitchDiameter2 - 2 * P.dedendum;

%==========================================================================
% BEVEL PITCH CONE ANGLES
%
% For a 90-degree shaft arrangement:
%
%       tan(delta1) = z1/z2
%       delta2 = 90 - delta1
%
%==========================================================================

P.pitchConeAngle1Deg = ...
    atand(P.z1 / P.z2);

P.pitchConeAngle2Deg = ...
    90 - P.pitchConeAngle1Deg;

%==========================================================================
% CONE DISTANCE
%==========================================================================

P.coneDistance = ...
    P.pitchRadius1 / ...
    sind(P.pitchConeAngle1Deg);

%==========================================================================
% INPUT / OUTPUT SPEED
%==========================================================================

P.outputSpeedRPM = ...
    P.inputSpeedRPM / P.ratio;

%==========================================================================
% INPUT / OUTPUT TORQUE
%==========================================================================

P.outputTorqueNm = ...
    P.inputTorqueNm * ...
    P.ratio * ...
    P.efficiency;

%==========================================================================
% POWER
%==========================================================================

P.inputPowerW = ...
    2*pi*P.inputSpeedRPM/60 * ...
    P.inputTorqueNm;

P.outputPowerW = ...
    2*pi*P.outputSpeedRPM/60 * ...
    P.outputTorqueNm;

%==========================================================================
% PITCH LINE VELOCITY
%==========================================================================

P.pitchVelocityMS = ...
    pi*(P.pitchDiameter1/1000) * ...
    P.inputSpeedRPM/60;

%==========================================================================
% TANGENTIAL FORCE
%==========================================================================

P.pitchRadius1M = ...
    P.pitchRadius1 / 1000;

P.tangentialForceN = ...
    P.inputTorqueNm / P.pitchRadius1M;

%==========================================================================
% APPROXIMATE RADIAL / AXIAL FORCE
%==========================================================================

alpha = deg2rad(P.pressureAngleDeg);

P.approxRadialForceN = ...
    P.tangentialForceN * tan(alpha);

P.approxAxialForceN = ...
    P.tangentialForceN * ...
    tan(deg2rad(P.pitchConeAngle1Deg));

%% ========================================================================
% 3. CONTACT RATIO
% ==========================================================================

P.contactRatioApprox = ...
    approximate_contact_ratio(P);

%% ========================================================================
% 4. DISPLAY DESIGN PARAMETERS
% ==========================================================================

fprintf('DESIGN PARAMETERS\n');
fprintf('--------------------------------------------------------------\n');

fprintf('Gear ratio                    : %.3f : 1\n', ...
    P.ratio);

fprintf('Pinion teeth                  : %d\n', ...
    P.z1);

fprintf('Gear teeth                    : %d\n', ...
    P.z2);

fprintf('Module                        : %.3f mm\n', ...
    P.module);

fprintf('\n');

fprintf('Pinion pitch diameter         : %.3f mm\n', ...
    P.pitchDiameter1);

fprintf('Gear pitch diameter           : %.3f mm\n', ...
    P.pitchDiameter2);

fprintf('Pinion outer diameter         : %.3f mm\n', ...
    P.outerDiameter1);

fprintf('Gear outer diameter           : %.3f mm\n', ...
    P.outerDiameter2);

fprintf('Pinion root diameter          : %.3f mm\n', ...
    P.rootDiameter1);

fprintf('Gear root diameter            : %.3f mm\n', ...
    P.rootDiameter2);

fprintf('\n');

fprintf('Pressure angle                : %.3f deg\n', ...
    P.pressureAngleDeg);

fprintf('Spiral angle                  : %.3f deg\n', ...
    P.spiralAngleDeg);

fprintf('Pinion pitch cone angle       : %.3f deg\n', ...
    P.pitchConeAngle1Deg);

fprintf('Gear pitch cone angle         : %.3f deg\n', ...
    P.pitchConeAngle2Deg);

fprintf('Cone distance                 : %.3f mm\n', ...
    P.coneDistance);

fprintf('Face width                    : %.3f mm\n', ...
    P.faceWidth);

fprintf('\n');

fprintf('Target contact ratio          : %.3f\n', ...
    P.targetContactRatio);

fprintf('Approx. contact ratio         : %.3f\n', ...
    P.contactRatioApprox);

fprintf('\n');

%% ========================================================================
% 5. WIND TURBINE DRIVE PARAMETERS
% ==========================================================================

fprintf('WIND TURBINE PITCH DRIVE\n');
fprintf('--------------------------------------------------------------\n');

fprintf('Input speed                   : %.3f RPM\n', ...
    P.inputSpeedRPM);

fprintf('Output speed                  : %.3f RPM\n', ...
    P.outputSpeedRPM);

fprintf('Input torque                  : %.3f Nm\n', ...
    P.inputTorqueNm);

fprintf('Output torque                 : %.3f Nm\n', ...
    P.outputTorqueNm);

fprintf('Efficiency                    : %.2f %%\n', ...
    P.efficiency*100);

fprintf('Input power                   : %.3f kW\n', ...
    P.inputPowerW/1000);

fprintf('Output power                  : %.3f kW\n', ...
    P.outputPowerW/1000);

fprintf('Pitch-line velocity            : %.3f m/s\n', ...
    P.pitchVelocityMS);

fprintf('Tangential tooth force        : %.3f N\n', ...
    P.tangentialForceN);

fprintf('Approx. radial force          : %.3f N\n', ...
    P.approxRadialForceN);

fprintf('Approx. axial force           : %.3f N\n', ...
    P.approxAxialForceN);

fprintf('\n');

%% ========================================================================
% 6. DESIGN VALIDATION
% ==========================================================================

fprintf('DESIGN VALIDATION\n');
fprintf('--------------------------------------------------------------\n');

%==========================================================================
% RATIO
%==========================================================================

actualRatio = P.z2 / P.z1;

if abs(actualRatio - P.ratio) < 1e-9

    fprintf('[PASS] Gear ratio = %.3f : 1\n', ...
        actualRatio);

else

    fprintf('[FAIL] Gear ratio\n');

end

%==========================================================================
% CONE ANGLES
%==========================================================================

coneAngleError = ...
    abs(P.pitchConeAngle1Deg + ...
        P.pitchConeAngle2Deg - 90);

if coneAngleError < 1e-9

    fprintf('[PASS] Pitch cone angles sum to 90 degrees\n');

else

    fprintf('[FAIL] Pitch cone angles\n');

end

%==========================================================================
% ZEROl CONDITION
%==========================================================================

if abs(P.spiralAngleDeg) < 1e-9

    fprintf('[PASS] Spiral angle = 0 degrees -> ZEROl\n');

else

    fprintf('[FAIL] Spiral angle is not zero\n');

end

%==========================================================================
% PINION TOOTH COUNT
%==========================================================================

if P.z1 >= 18

    fprintf('[PASS] Pinion tooth count = %d\n',P.z1);

else

    fprintf('[WARNING] Pinion tooth count is low\n');

end

%==========================================================================
% FACE WIDTH
%==========================================================================

if P.faceWidth <= P.coneDistance/3

    fprintf('[PASS] Face width / cone distance\n');

else

    fprintf('[WARNING] Face width is relatively large\n');

end

%==========================================================================
% CONTACT RATIO
%==========================================================================

if P.contactRatioApprox >= 1

    fprintf('[PASS] Approximate contact ratio > 1\n');

else

    fprintf('[WARNING] Approximate contact ratio < 1\n');

end

fprintf('\n');

%% ========================================================================
% 7. GENERATE ZEROl PINION
% ==========================================================================

fprintf('Generating Zerol pinion...\n');

pinion = generate_zerol_bevel_gear( ...
    P.z1, ...
    P.pitchDiameter1, ...
    P.pitchConeAngle1Deg, ...
    P.module, ...
    P.pressureAngleDeg, ...
    P.faceWidth, ...
    P.dedendum, ...
    P.addendum, ...
    P.boreDiameter1, ...
    P.nFace, ...
    P.nAngularPerTooth);

fprintf('Pinion generated successfully.\n');

%% ========================================================================
% 8. GENERATE ZEROl GEAR
% ==========================================================================

fprintf('Generating Zerol gear...\n');

gear = generate_zerol_bevel_gear( ...
    P.z2, ...
    P.pitchDiameter2, ...
    P.pitchConeAngle2Deg, ...
    P.module, ...
    P.pressureAngleDeg, ...
    P.faceWidth, ...
    P.dedendum, ...
    P.addendum, ...
    P.boreDiameter2, ...
    P.nFace, ...
    P.nAngularPerTooth);

fprintf('Gear generated successfully.\n');

%% ========================================================================
% 9. STORE RESULTS
% ==========================================================================

results.parameters = P;

results.pinion = pinion;

results.gear = gear;

%% ========================================================================
% 10. EXPORT STL
% ==========================================================================

fprintf('\nExporting STL files...\n');

write_binary_stl( ...
    pinion.vertices, ...
    pinion.faces, ...
    'ZEROL_PINION.stl', ...
    'ZEROL PINION');

write_binary_stl( ...
    gear.vertices, ...
    gear.faces, ...
    'ZEROL_GEAR.stl', ...
    'ZEROL GEAR');

fprintf('Created: ZEROL_PINION.stl\n');
fprintf('Created: ZEROL_GEAR.stl\n');

%% ========================================================================
% 11. SAVE MATLAB RESULTS
% ==========================================================================

save( ...
    'ZEROL_BEVEL_PITCH_CONTROL.mat', ...
    'results');

fprintf('Created: ZEROL_BEVEL_PITCH_CONTROL.mat\n');

%% ========================================================================
% 12. EXPORT CSV DESIGN REPORT
% ==========================================================================

write_design_report(P);

fprintf('Created: ZEROL_BEVEL_DESIGN_REPORT.csv\n');

%% ========================================================================
% 13. PLOT PINION
% ==========================================================================

figure( ...
    'Name','ZEROL Pinion', ...
    'Color','w');

patch( ...
    'Vertices',pinion.vertices, ...
    'Faces',pinion.faces, ...
    'FaceColor',[0.65 0.70 0.76], ...
    'EdgeColor','none');

axis equal;

grid on;

xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');

title( ...
    sprintf('TRUE ZEROl BEVEL PINION - %d TEETH',P.z1));

view(35,25);

camlight headlight;
lighting gouraud;

%% ========================================================================
% 14. PLOT GEAR
% ==========================================================================

figure( ...
    'Name','ZEROL Gear', ...
    'Color','w');

patch( ...
    'Vertices',gear.vertices, ...
    'Faces',gear.faces, ...
    'FaceColor',[0.72 0.76 0.82], ...
    'EdgeColor','none');

axis equal;

grid on;

xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');

title( ...
    sprintf('TRUE ZEROl BEVEL GEAR - %d TEETH',P.z2));

view(35,25);

camlight headlight;
lighting gouraud;

%% ========================================================================
% 15. 3D GEAR ASSEMBLY
% ==========================================================================

figure( ...
    'Name','ZEROL Gear Assembly', ...
    'Color','w');

%----------------------------------------------------------------------
% PINION
%----------------------------------------------------------------------

vp = pinion.vertices;

fp = pinion.faces;

patch( ...
    'Vertices',vp, ...
    'Faces',fp, ...
    'FaceColor',[0.55 0.63 0.72], ...
    'EdgeColor','none');

hold on;

%----------------------------------------------------------------------
% GEAR
%
% The gear shaft is perpendicular to the pinion shaft.
%----------------------------------------------------------------------

vg = gear.vertices;

% Rotation matrix
%
% Original gear axis = Z
% New gear axis      = X

R = [ ...
     0  0  1;
     0  1  0;
    -1  0  0];

vg = (R * vg')';

% Move gear approximately to the cone-distance location
vg(:,1) = vg(:,1) + P.coneDistance;

patch( ...
    'Vertices',vg, ...
    'Faces',gear.faces, ...
    'FaceColor',[0.80 0.68 0.48], ...
    'EdgeColor','none');

%----------------------------------------------------------------------
% SHAFT AXES
%----------------------------------------------------------------------

shaftLength = ...
    P.coneDistance + ...
    max(P.outerDiameter2,P.outerDiameter1);

plot3( ...
    [-shaftLength shaftLength], ...
    [0 0], ...
    [0 0], ...
    'k--', ...
    'LineWidth',1);

plot3( ...
    [P.coneDistance P.coneDistance], ...
    [0 0], ...
    [-shaftLength shaftLength], ...
    'k--', ...
    'LineWidth',1);

%----------------------------------------------------------------------
% CONTACT MARKER
%----------------------------------------------------------------------

contactPoint = ...
    [P.coneDistance/2 0 0];

plot3( ...
    contactPoint(1), ...
    contactPoint(2), ...
    contactPoint(3), ...
    'ko', ...
    'MarkerFaceColor','r', ...
    'MarkerSize',8);

text( ...
    contactPoint(1), ...
    contactPoint(2), ...
    contactPoint(3)+10, ...
    'Approx. mesh/contact region', ...
    'FontWeight','bold');

%----------------------------------------------------------------------
% PLOT SETTINGS
%----------------------------------------------------------------------

axis equal;

grid on;

xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');

title({ ...
    'ZEROL BEVEL GEAR PAIR', ...
    sprintf('Wind Turbine Pitch Control - Ratio %.1f:1',P.ratio), ...
    'Pinion and gear shafts at 90°'});

view(35,25);

camlight headlight;
lighting gouraud;

hold off;

%% ========================================================================
% 16. 2D MESHING DIAGRAM
% ==========================================================================

plot_zerol_meshing_diagram(P);

%% ========================================================================
% 17. FINAL MESSAGE
% ==========================================================================

fprintf('\n');
fprintf('==============================================================\n');
fprintf('                 GENERATION COMPLETE\n');
fprintf('==============================================================\n');

fprintf('\n');

fprintf('Generated files:\n');

fprintf('  ZEROL_PINION.stl\n');
fprintf('  ZEROL_GEAR.stl\n');
fprintf('  ZEROL_BEVEL_PITCH_CONTROL.mat\n');
fprintf('  ZEROL_BEVEL_DESIGN_REPORT.csv\n');

fprintf('\n');

fprintf('Generated figures:\n');

fprintf('  1. Zerol pinion\n');
fprintf('  2. Zerol gear\n');
fprintf('  3. 3D gear assembly\n');
fprintf('  4. 2D gear meshing diagram\n');

fprintf('\n');

fprintf('ZEROl condition:\n');

fprintf('  Spiral angle = %.3f degrees\n', ...
    P.spiralAngleDeg);

fprintf('\n');

fprintf(['NOTE: The generated geometry is an engineering-level\n' ...
         'parametric approximation. For manufacturing, the tooth\n' ...
         'flanks should be replaced with validated Gleason or\n' ...
         'Klingelnberg Zerol tooth-surface equations.\n']);

fprintf('\n');

end


%==========================================================================
% ZEROl BEVEL GEAR GENERATOR
%==========================================================================

function gear = generate_zerol_bevel_gear( ...
    z, ...
    pitchDiameter, ...
    coneAngleDeg, ...
    module, ...
    pressureAngleDeg, ...
    faceWidth, ...
    dedendum, ...
    addendum, ...
    boreDiameter, ...
    nFace, ...
    nAngularPerTooth)

%==========================================================================
% BASIC VALUES
%==========================================================================

rp = pitchDiameter / 2;

rootRadiusPitch = ...
    rp - dedendum;

tipRadiusPitch = ...
    rp + addendum;

%==========================================================================
% CONE GEOMETRY
%==========================================================================

coneDistance = ...
    rp / sind(coneAngleDeg);

% Large end and small end radial scaling
%
% The bevel gear is represented along a conical surface.
%==========================================================================

largeConeDistance = coneDistance;

smallConeDistance = ...
    largeConeDistance - faceWidth;

if smallConeDistance <= 0

    error([ ...
        'Face width is too large for the selected cone geometry. ' ...
        'Reduce P.faceWidth.']);

end

%==========================================================================
% ANGULAR RESOLUTION
%==========================================================================

nTheta = ...
    z * nAngularPerTooth;

theta = ...
    linspace(0,2*pi,nTheta+1);

theta(end) = [];

%==========================================================================
% VERTEX STORAGE
%==========================================================================

vertices = [];

%==========================================================================
% GENERATE CONICAL TOOTH SURFACE
%==========================================================================

for j = 1:(nFace+1)

    % Face position
    f = ...
        (j-1)/nFace;

    % Distance from virtual apex
    conePos = ...
        largeConeDistance - f*faceWidth;

    % Local pitch radius
    rpLocal = ...
        conePos * sind(coneAngleDeg);

    % Scaling
    scale = ...
        rpLocal / rp;

    % Local root and tip radii
    rr = ...
        rootRadiusPitch * scale;

    rt = ...
        tipRadiusPitch * scale;

    %----------------------------------------------------------------------
    % TOOTH ANGULAR PROFILE
    %----------------------------------------------------------------------

    toothPitch = ...
        2*pi/z;

    localPhase = ...
        mod(theta + toothPitch/2, ...
            toothPitch) - ...
        toothPitch/2;

    normalized = ...
        abs(localPhase) / ...
        (toothPitch/2);

    %----------------------------------------------------------------------
    % ROOT / TIP TOOTH PROFILE
    %----------------------------------------------------------------------

    radius = ...
        rr * ones(size(theta));

    % Tip region
    tipLimit = 0.38;

    % Root region
    rootLimit = 0.92;

    isTip = ...
        normalized <= tipLimit;

    radius(isTip) = rt;

    % Flank
    isFlank = ...
        normalized > tipLimit & ...
        normalized < rootLimit;

    u = ...
        (normalized(isFlank)-tipLimit) ./ ...
        (rootLimit-tipLimit);

    % Smooth involute-like approximation
    profile = ...
        0.5*(1+cos(pi*u));

    radius(isFlank) = ...
        rr + ...
        (rt-rr).*profile;

    %----------------------------------------------------------------------
    % ZEROl CONDITION
    %
    % There is deliberately NO twist angle here.
    %
    % For spiral bevel:
    %
    %     theta_modified = theta + twist(z)
    %
    % For Zerol:
    %
    %     theta_modified = theta
    %
    %----------------------------------------------------------------------

    thetaLocal = theta;

    %----------------------------------------------------------------------
    % CARTESIAN COORDINATES
    %----------------------------------------------------------------------

    x = ...
        radius .* cos(thetaLocal);

    y = ...
        radius .* sin(thetaLocal);

    zcoord = ...
        conePos * cosd(coneAngleDeg);

    zvec = ...
        zcoord * ones(size(x));

    vertices = ...
        [vertices;
         x(:), ...
         y(:), ...
         zvec(:)];

end

%==========================================================================
% CONNECT FACE RINGS
%==========================================================================

faces = [];

for j = 1:nFace

    row1 = ...
        (j-1)*nTheta + ...
        (1:nTheta);

    row2 = ...
        j*nTheta + ...
        (1:nTheta);

    row1next = ...
        [row1(2:end),row1(1)];

    row2next = ...
        [row2(2:end),row2(1)];

    f1 = ...
        [row1(:), ...
         row2(:), ...
         row2next(:)];

    f2 = ...
        [row1(:), ...
         row2next(:), ...
         row1next(:)];

    faces = ...
        [faces;
         f1;
         f2];

end

%==========================================================================
% FRONT / BACK BORE
%==========================================================================

boreRadius = ...
    boreDiameter/2;

%==========================================================================
% LARGE-END BORE RING
%==========================================================================

largeRow = ...
    (nFace)*nTheta + ...
    (1:nTheta);

boreStart = ...
    size(vertices,1) + 1;

largeZ = ...
    largeConeDistance*cosd(coneAngleDeg);

for k = 1:nTheta

    ang = theta(k);

    vertices = ...
        [vertices;
         boreRadius*cos(ang), ...
         boreRadius*sin(ang), ...
         largeZ];

end

boreLargeRow = ...
    boreStart:(boreStart+nTheta-1);

%==========================================================================
% BACK ANNULAR FACE
%==========================================================================

for k = 1:nTheta

    k2 = ...
        mod(k,nTheta)+1;

    faces = ...
        [faces;
         largeRow(k), ...
         boreLargeRow(k), ...
         boreLargeRow(k2)];

    faces = ...
        [faces;
         largeRow(k), ...
         boreLargeRow(k2), ...
         largeRow(k2)];

end

%==========================================================================
% BORE INNER SURFACE
%==========================================================================

boreDepth = ...
    min(faceWidth,0.8*largeConeDistance);

boreEndZ = ...
    largeZ - boreDepth;

boreEndStart = ...
    size(vertices,1)+1;

for k = 1:nTheta

    ang = theta(k);

    vertices = ...
        [vertices;
         boreRadius*cos(ang), ...
         boreRadius*sin(ang), ...
         boreEndZ];

end

boreEndRow = ...
    boreEndStart:(boreEndStart+nTheta-1);

for k = 1:nTheta

    k2 = ...
        mod(k,nTheta)+1;

    faces = ...
        [faces;
         boreLargeRow(k), ...
         boreEndRow(k), ...
         boreEndRow(k2)];

    faces = ...
        [faces;
         boreLargeRow(k), ...
         boreEndRow(k2), ...
         boreLargeRow(k)];

end

%==========================================================================
% BORE END CAP
%==========================================================================

centerIndex = ...
    size(vertices,1)+1;

vertices = ...
    [vertices;
     0 0 boreEndZ];

for k = 1:nTheta

    k2 = ...
        mod(k,nTheta)+1;

    faces = ...
        [faces;
         centerIndex, ...
         boreEndRow(k2), ...
         boreEndRow(k)];

end

%==========================================================================
% REMOVE DUPLICATE / INVALID FACES
%==========================================================================

valid = ...
    all(faces > 0,2);

faces = ...
    faces(valid,:);

%==========================================================================
% OUTPUT
%==========================================================================

gear.vertices = vertices;

gear.faces = faces;

gear.teeth = z;

gear.pitchDiameter = ...
    pitchDiameter;

gear.module = ...
    module;

gear.pressureAngle = ...
    pressureAngleDeg;

gear.coneAngle = ...
    coneAngleDeg;

gear.faceWidth = ...
    faceWidth;

gear.boreDiameter = ...
    boreDiameter;

gear.spiralAngle = 0;

end


%==========================================================================
% APPROXIMATE CONTACT RATIO
%==========================================================================

function epsilon = approximate_contact_ratio(P)

%==========================================================================
% This is an engineering screening approximation.
%
% A complete bevel-gear contact-ratio calculation requires the actual
% generated tooth surfaces and transverse/face contact geometry.
%==========================================================================

alpha = ...
    deg2rad(P.pressureAngleDeg);

% Virtual tooth numbers
z1v = ...
    P.z1 / cosd(P.pitchConeAngle1Deg);

z2v = ...
    P.z2 / cosd(P.pitchConeAngle2Deg);

% Virtual pitch diameters
d1v = ...
    P.module * z1v;

d2v = ...
    P.module * z2v;

% Base radii
rb1 = ...
    d1v*cos(alpha)/2;

rb2 = ...
    d2v*cos(alpha)/2;

% Addendum radii
ra1 = ...
    d1v/2 + P.module;

ra2 = ...
    d2v/2 + P.module;

% Virtual center distance
centerDistance = ...
    (d1v+d2v)/2;

% Approximate path of contact
term1 = ...
    sqrt(max(ra1^2-rb1^2,0));

term2 = ...
    sqrt(max(ra2^2-rb2^2,0));

pathContact = ...
    term1 + ...
    term2 - ...
    centerDistance*sin(alpha);

% Base pitch
basePitch = ...
    pi*P.module*cos(alpha);

epsilon = ...
    pathContact/basePitch;

% Prevent nonsensical negative values
epsilon = ...
    max(epsilon,0);

end


%==========================================================================
% 2D ZEROl MESHING DIAGRAM
%==========================================================================

function plot_zerol_meshing_diagram(P)

%==========================================================================
% FIGURE
%==========================================================================

figure( ...
    'Name','ZEROL Bevel Gear Meshing Diagram', ...
    'Color','w', ...
    'Position',[80 80 1350 800]);

hold on;

axis equal;

grid on;

%==========================================================================
% BASIC DIMENSIONS
%==========================================================================

r1 = ...
    P.pitchDiameter1/2;

r2 = ...
    P.pitchDiameter2/2;

%==========================================================================
% CENTERS
%
% The 2D diagram is a conceptual projection.
% The actual 3D shafts are perpendicular.
%==========================================================================

C1 = [0 0];

C2 = [P.coneDistance 0];

%==========================================================================
% PITCH CIRCLES
%==========================================================================

theta = ...
    linspace(0,2*pi,600);

% Pinion pitch circle
plot( ...
    C1(1)+r1*cos(theta), ...
    C1(2)+r1*sin(theta), ...
    'k--', ...
    'LineWidth',1.5);

% Gear pitch circle
plot( ...
    C2(1)+r2*cos(theta), ...
    C2(2)+r2*sin(theta), ...
    'k--', ...
    'LineWidth',1.5);

%==========================================================================
% ROOT CIRCLES
%==========================================================================

rr1 = ...
    r1 - P.dedendum;

rr2 = ...
    r2 - P.dedendum;

plot( ...
    C1(1)+rr1*cos(theta), ...
    C1(2)+rr1*sin(theta), ...
    'LineWidth',0.7);

plot( ...
    C2(1)+rr2*cos(theta), ...
    C2(2)+rr2*sin(theta), ...
    'LineWidth',0.7);

%==========================================================================
% DRAW PINION TEETH
%==========================================================================

for k = 1:P.z1

    a = ...
        2*pi*(k-1)/P.z1;

    pitch = ...
        2*pi/P.z1;

    halfRoot = ...
        pitch*0.44;

    halfTip = ...
        pitch*0.20;

    aRoot1 = a-halfRoot;

    aRoot2 = a+halfRoot;

    aTip1 = a-halfTip;

    aTip2 = a+halfTip;

    Rroot = ...
        rr1;

    Rtip = ...
        r1 + P.addendum;

    % Four corners
    p1 = ...
        C1 + ...
        Rroot*[cos(aRoot1) sin(aRoot1)];

    p2 = ...
        C1 + ...
        Rtip*[cos(aTip1) sin(aTip1)];

    p3 = ...
        C1 + ...
        Rtip*[cos(aTip2) sin(aTip2)];

    p4 = ...
        C1 + ...
        Rroot*[cos(aRoot2) sin(aRoot2)];

    plot( ...
        [p1(1) p2(1) p3(1) p4(1) p1(1)], ...
        [p1(2) p2(2) p3(2) p4(2) p1(2)], ...
        'LineWidth',1);

end

%==========================================================================
% DRAW GEAR TEETH
%==========================================================================

for k = 1:P.z2

    a = ...
        2*pi*(k-1)/P.z2;

    pitch = ...
        2*pi/P.z2;

    halfRoot = ...
        pitch*0.44;

    halfTip = ...
        pitch*0.20;

    aRoot1 = a-halfRoot;

    aRoot2 = a+halfRoot;

    aTip1 = a-halfTip;

    aTip2 = a+halfTip;

    Rroot = ...
        rr2;

    Rtip = ...
        r2 + P.addendum;

    p1 = ...
        C2 + ...
        Rroot*[cos(aRoot1) sin(aRoot1)];

    p2 = ...
        C2 + ...
        Rtip*[cos(aTip1) sin(aTip1)];

    p3 = ...
        C2 + ...
        Rtip*[cos(aTip2) sin(aTip2)];

    p4 = ...
        C2 + ...
        Rroot*[cos(aRoot2) sin(aRoot2)];

    plot( ...
        [p1(1) p2(1) p3(1) p4(1) p1(1)], ...
        [p1(2) p2(2) p3(2) p4(2) p1(2)], ...
        'LineWidth',1);

end

%==========================================================================
% SHAFT CENTER MARKERS
%==========================================================================

plot( ...
    C1(1),C1(2), ...
    'ko', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',8);

plot( ...
    C2(1),C2(2), ...
    'ko', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',8);

%==========================================================================
% SHAFT AXES
%==========================================================================

shaftLength = ...
    0.65*max(P.outerDiameter2, ...
             P.coneDistance);

plot( ...
    [C1(1)-shaftLength C1(1)+shaftLength], ...
    [C1(2) C1(2)], ...
    'k:', ...
    'LineWidth',1.3);

plot( ...
    [C2(1) C2(1)], ...
    [C2(2)-shaftLength C2(2)+shaftLength], ...
    'k:', ...
    'LineWidth',1.3);

%==========================================================================
% CENTER DISTANCE
%==========================================================================

plot( ...
    [C1(1) C2(1)], ...
    [C1(2) C2(2)], ...
    'k-', ...
    'LineWidth',1.4);

text( ...
    P.coneDistance/2, ...
    8, ...
    sprintf('Cone distance = %.2f mm', ...
    P.coneDistance), ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');

%==========================================================================
% CONTACT POINT
%
% For this conceptual diagram the contact is represented at the
% intersection of the pitch geometry.
%==========================================================================

contactX = ...
    C1(1) + ...
    P.pitchRadius1;

contactY = ...
    0;

plot( ...
    contactX, ...
    contactY, ...
    'ko', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',11);

% Contact zone line
contactZone = 12;

plot( ...
    [contactX-contactZone contactX+contactZone], ...
    [contactY contactY], ...
    'LineWidth',5);

text( ...
    contactX+15, ...
    contactY+15, ...
    'CONTACT ZONE', ...
    'FontWeight','bold', ...
    'FontSize',11);

%==========================================================================
% LINE OF ACTION
%==========================================================================

alpha = ...
    deg2rad(P.pressureAngleDeg);

loaLength = ...
    100;

loaX = ...
    contactX + ...
    [-loaLength*cos(alpha), ...
      loaLength*cos(alpha)];

loaY = ...
    contactY + ...
    [-loaLength*sin(alpha), ...
      loaLength*sin(alpha)];

plot( ...
    loaX, ...
    loaY, ...
    'k-.', ...
    'LineWidth',1.5);

text( ...
    loaX(2)+5, ...
    loaY(2), ...
    'Line of action', ...
    'FontWeight','bold');

%==========================================================================
% PINION ROTATION ARROW
%==========================================================================

arrowR1 = ...
    r1*0.70;

arrowAngles1 = ...
    linspace(-0.8*pi,0.15*pi,60);

plot( ...
    C1(1)+arrowR1*cos(arrowAngles1), ...
    C1(2)+arrowR1*sin(arrowAngles1), ...
    'LineWidth',2);

% Arrow head
idx = ...
    length(arrowAngles1)-2;

quiver( ...
    C1(1)+arrowR1*cos(arrowAngles1(idx)), ...
    C1(2)+arrowR1*sin(arrowAngles1(idx)), ...
    10, ...
    5, ...
    0, ...
    'LineWidth',2, ...
    'MaxHeadSize',2);

text( ...
    C1(1)-r1*0.30, ...
    C1(2)+r1*0.90, ...
    'PINION', ...
    'FontWeight','bold', ...
    'FontSize',12);

%==========================================================================
% GEAR ROTATION ARROW
%==========================================================================

arrowR2 = ...
    r2*0.55;

arrowAngles2 = ...
    linspace(0.2*pi,1.15*pi,60);

plot( ...
    C2(1)+arrowR2*cos(arrowAngles2), ...
    C2(2)+arrowR2*sin(arrowAngles2), ...
    'LineWidth',2);

idx2 = ...
    length(arrowAngles2)-2;

quiver( ...
    C2(1)+arrowR2*cos(arrowAngles2(idx2)), ...
    C2(2)+arrowR2*sin(arrowAngles2(idx2)), ...
    -10, ...
    5, ...
    0, ...
    'LineWidth',2, ...
    'MaxHeadSize',2);

text( ...
    C2(1)-r2*0.25, ...
    C2(2)-r2*0.85, ...
    'GEAR', ...
    'FontWeight','bold', ...
    'FontSize',12);

%==========================================================================
% 4:1 RATIO LABEL
%==========================================================================

ratioText = sprintf( ...
    'SPEED RATIO = %.2f : 1', ...
    P.ratio);

text( ...
    mean([C1(1) C2(1)]), ...
    -0.22*r2, ...
    ratioText, ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',12);

%==========================================================================
% INPUT / OUTPUT LABELS
%==========================================================================

text( ...
    C1(1)-shaftLength*0.9, ...
    C1(2)-25, ...
    sprintf('INPUT\\n%.2f RPM\\n%.2f Nm', ...
    P.inputSpeedRPM, ...
    P.inputTorqueNm), ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');

text( ...
    C2(1), ...
    C2(2)+shaftLength*0.75, ...
    sprintf('OUTPUT\\n%.2f RPM\\n%.2f Nm', ...
    P.outputSpeedRPM, ...
    P.outputTorqueNm), ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');

%==========================================================================
% SHAFT ANGLE
%==========================================================================

text( ...
    C1(1)+30, ...
    C1(2)+shaftLength*0.50, ...
    '90° SHAFT ANGLE', ...
    'FontWeight','bold');

%==========================================================================
% DESIGN INFORMATION BOX
%==========================================================================

infoText = sprintf([ ...
    'ZEROl BEVEL GEAR MESH\n\n' ...
    'Pinion teeth       : %d\n' ...
    'Gear teeth         : %d\n' ...
    'Ratio              : %.2f : 1\n' ...
    'Module             : %.2f mm\n' ...
    'Pressure angle     : %.1f°\n' ...
    'Spiral angle       : %.1f°\n' ...
    'Pinion cone angle  : %.2f°\n' ...
    'Gear cone angle    : %.2f°\n' ...
    'Face width         : %.1f mm\n' ...
    'Contact ratio      : %.3f'], ...
    P.z1, ...
    P.z2, ...
    P.ratio, ...
    P.module, ...
    P.pressureAngleDeg, ...
    P.spiralAngleDeg, ...
    P.pitchConeAngle1Deg, ...
    P.pitchConeAngle2Deg, ...
    P.faceWidth, ...
    P.contactRatioApprox);

annotation( ...
    'textbox', ...
    [0.72 0.55 0.25 0.35], ...
    'String',infoText, ...
    'FitBoxToText','on', ...
    'BackgroundColor','w', ...
    'EdgeColor','k', ...
    'FontSize',10);

%==========================================================================
% ZEROl IDENTIFICATION
%==========================================================================

text( ...
    C1(1)-r1*1.15, ...
    C1(2)+r1*1.15, ...
    'TRUE ZEROl: SPIRAL ANGLE = 0°', ...
    'FontWeight','bold', ...
    'FontSize',12);

%==========================================================================
% TITLE
%==========================================================================

title({ ...
    'ZEROl BEVEL GEAR MESHING DIAGRAM', ...
    'Wind Turbine Pitch Control Gear System'}, ...
    'FontSize',15, ...
    'FontWeight','bold');

xlabel('Position X [mm]');
ylabel('Position Y [mm]');

%==========================================================================
% LIMITS
%==========================================================================

xlim([ ...
    -1.5*r1, ...
    C2(1)+1.2*r2]);

ylim([ ...
    -1.15*r2, ...
    1.15*r2]);

hold off;

end


%==========================================================================
% BINARY STL WRITER
%==========================================================================

function write_binary_stl( ...
    vertices, ...
    faces, ...
    filename, ...
    solidName)

fid = ...
    fopen(filename,'w','ieee-le');

if fid == -1

    error( ...
        'Could not create STL file: %s', ...
        filename);

end

%==========================================================================
% STL HEADER
%==========================================================================

header = ...
    zeros(1,80,'uint8');

nameBytes = ...
    uint8(solidName);

nCopy = ...
    min(length(nameBytes),80);

header(1:nCopy) = ...
    nameBytes(1:nCopy);

fwrite( ...
    fid, ...
    header, ...
    'uint8');

%==========================================================================
% NUMBER OF TRIANGLES
%==========================================================================

nFaces = ...
    size(faces,1);

fwrite( ...
    fid, ...
    uint32(nFaces), ...
    'uint32');

%==========================================================================
% TRIANGLES
%==========================================================================

for i = 1:nFaces

    p1 = ...
        vertices(faces(i,1),:);

    p2 = ...
        vertices(faces(i,2),:);

    p3 = ...
        vertices(faces(i,3),:);

    % Triangle vectors
    v1 = ...
        p2-p1;

    v2 = ...
        p3-p1;

    % Normal
    n = ...
        cross(v1,v2);

    L = ...
        norm(n);

    if L > 0

        n = n/L;

    else

        n = [0 0 0];

    end

    fwrite( ...
        fid, ...
        single(n), ...
        'float32');

    fwrite( ...
        fid, ...
        single(p1), ...
        'float32');

    fwrite( ...
        fid, ...
        single(p2), ...
        'float32');

    fwrite( ...
        fid, ...
        single(p3), ...
        'float32');

    % Attribute byte count
    fwrite( ...
        fid, ...
        uint16(0), ...
        'uint16');

end

fclose(fid);

end


%==========================================================================
% CSV DESIGN REPORT
%==========================================================================

function write_design_report(P)

fid = ...
    fopen( ...
    'ZEROL_BEVEL_DESIGN_REPORT.csv', ...
    'w');

if fid == -1

    error( ...
        'Could not create CSV design report.');

end

fprintf( ...
    fid, ...
    'Parameter,Value,Unit\n');

fprintf( ...
    fid, ...
    'Gear Ratio,%.6f,:1\n', ...
    P.ratio);

fprintf( ...
    fid, ...
    'Pinion Teeth,%d,count\n', ...
    P.z1);

fprintf( ...
    fid, ...
    'Gear Teeth,%d,count\n', ...
    P.z2);

fprintf( ...
    fid, ...
    'Module,%.6f,mm\n', ...
    P.module);

fprintf( ...
    fid, ...
    'Pinion Pitch Diameter,%.6f,mm\n', ...
    P.pitchDiameter1);

fprintf( ...
    fid, ...
    'Gear Pitch Diameter,%.6f,mm\n', ...
    P.pitchDiameter2);

fprintf( ...
    fid, ...
    'Pinion Outer Diameter,%.6f,mm\n', ...
    P.outerDiameter1);

fprintf( ...
    fid, ...
    'Gear Outer Diameter,%.6f,mm\n', ...
    P.outerDiameter2);

fprintf( ...
    fid, ...
    'Pinion Root Diameter,%.6f,mm\n', ...
    P.rootDiameter1);

fprintf( ...
    fid, ...
    'Gear Root Diameter,%.6f,mm\n', ...
    P.rootDiameter2);

fprintf( ...
    fid, ...
    'Pressure Angle,%.6f,deg\n', ...
    P.pressureAngleDeg);

fprintf( ...
    fid, ...
    'Spiral Angle,%.6f,deg\n', ...
    P.spiralAngleDeg);

fprintf( ...
    fid, ...
    'Pinion Pitch Cone Angle,%.6f,deg\n', ...
    P.pitchConeAngle1Deg);

fprintf( ...
    fid, ...
    'Gear Pitch Cone Angle,%.6f,deg\n', ...
    P.pitchConeAngle2Deg);

fprintf( ...
    fid, ...
    'Cone Distance,%.6f,mm\n', ...
    P.coneDistance);

fprintf( ...
    fid, ...
    'Face Width,%.6f,mm\n', ...
    P.faceWidth);

fprintf( ...
    fid, ...
    'Target Contact Ratio,%.6f,-\n', ...
    P.targetContactRatio);

fprintf( ...
    fid, ...
    'Approximate Contact Ratio,%.6f,-\n', ...
    P.contactRatioApprox);

fprintf( ...
    fid, ...
    'Input Speed,%.6f,RPM\n', ...
    P.inputSpeedRPM);

fprintf( ...
    fid, ...
    'Output Speed,%.6f,RPM\n', ...
    P.outputSpeedRPM);

fprintf( ...
    fid, ...
    'Input Torque,%.6f,Nm\n', ...
    P.inputTorqueNm);

fprintf( ...
    fid, ...
    'Output Torque,%.6f,Nm\n', ...
    P.outputTorqueNm);

fprintf( ...
    fid, ...
    'Efficiency,%.6f,decimal\n', ...
    P.efficiency);

fprintf( ...
    fid, ...
    'Input Power,%.6f,kW\n', ...
    P.inputPowerW/1000);

fprintf( ...
    fid, ...
    'Output Power,%.6f,kW\n', ...
    P.outputPowerW/1000);

fprintf( ...
    fid, ...
    'Pitch Line Velocity,%.6f,m/s\n', ...
    P.pitchVelocityMS);

fprintf( ...
    fid, ...
    'Tangential Force,%.6f,N\n', ...
    P.tangentialForceN);

fprintf( ...
    fid, ...
    'Approximate Radial Force,%.6f,N\n', ...
    P.approxRadialForceN);

fprintf( ...
    fid, ...
    'Approximate Axial Force,%.6f,N\n', ...
    P.approxAxialForceN);

fclose(fid);

end