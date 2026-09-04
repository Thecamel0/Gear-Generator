function export_gear_stl(mesh, filename, header_text)
%EXPORT_GEAR_STL  Export gear mesh as binary STL using stlwrite toolbox
%
%   export_gear_stl(mesh, filename, header_text)
%
%   Inputs:
%       mesh        - struct with .vertices (Vx3 double, mm) and .faces (Fx3 int)
%       filename    - full path for the output .stl file
%       header_text - unused (kept for API compatibility)
%
%   Requires: stlwrite toolbox (MATLAB File Exchange, by Sven)
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-13

if nargin < 3
    header_text = ''; %#ok<NASGU>
end

% --- Ensure output directory exists ---
out_dir = fileparts(filename);
if ~isempty(out_dir) && ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

% --- Write binary STL via stlwrite ---
tri = triangulation(mesh.faces, mesh.vertices);
stlwrite(tri, filename);

info = dir(filename);
fprintf('  STL saved: %s  (%d triangles, %.1f KB)\n', ...
    filename, size(mesh.faces, 1), info.bytes / 1024);

end
