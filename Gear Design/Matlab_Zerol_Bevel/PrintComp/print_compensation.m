function mesh_out = print_compensation(mesh_in, shrinkage_factor)
%PRINT_COMPENSATION Apply global shrinkage compensation to a gear mesh
%
%   mesh_out = print_compensation(mesh_in, shrinkage_factor)
%
%   Scales all vertices by the shrinkage_factor to compensate for material
%   shrinkage during 3D printing. The scaling is uniform in all directions
%   from the centroid of the mesh.
%
%   Inputs:
%       mesh_in          - struct with .vertices and .faces
%       shrinkage_factor - scale factor (e.g., 1.003 for 0.3% PLA shrinkage)
%
%   Output:
%       mesh_out - compensated mesh
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-24

    mesh_out = mesh_in;

    if abs(shrinkage_factor - 1.0) < 1e-8
        return;  % No compensation needed
    end

    % Scale from centroid (preserves centering)
    centroid = mean(mesh_in.vertices, 1);
    mesh_out.vertices = (mesh_in.vertices - centroid) * shrinkage_factor + centroid;
end
