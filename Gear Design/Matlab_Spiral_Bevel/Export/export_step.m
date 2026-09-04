function export_step(mesh, filename, header_text)
%EXPORT_STEP Export 3D gear mesh as ISO 10303-21 STEP AP214 (.stp) solid body
%
%   Uses MANIFOLD_SOLID_BREP with ADVANCED_FACE + EDGE_LOOP + PLANE topology.
%   Opens directly as a solid body in SolidWorks, CATIA, Inventor, Fusion 360, etc.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 3 || isempty(header_text)
        header_text = 'Spiral Bevel Gear Solid Model';
    end

    vertices = mesh.vertices;
    faces    = mesh.faces;
    n_verts  = size(vertices, 1);
    n_faces  = size(faces, 1);

    % Ensure output directory exists
    out_dir = fileparts(filename);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % Ensure unit outward normals
    v1 = vertices(faces(:,1), :);
    v2 = vertices(faces(:,2), :);
    v3 = vertices(faces(:,3), :);
    edge1 = v2 - v1;
    edge2 = v3 - v1;
    normals = cross(edge1, edge2, 2);
    mag = sqrt(sum(normals.^2, 2));
    mag(mag < eps) = 1;
    normals = normals ./ mag;

    fid = fopen(filename, 'w');
    if fid == -1
        error('export_step:fileOpen', 'Cannot open file: %s', filename);
    end

    try
        [~, name_only, ~] = fileparts(filename);
        date_str = datestr(now, 'yyyy-mm-ddTHH:MM:SS');

        % =================================================================
        % HEADER
        % =================================================================
        fprintf(fid, 'ISO-10303-21;\n');
        fprintf(fid, 'HEADER;\n');
        fprintf(fid, 'FILE_DESCRIPTION((''%s''),''2;1'');\n', header_text);
        fprintf(fid, 'FILE_NAME(''%s.stp'',''%s'',(''Ahmed Majdy Ahmed''),(''Wind Turbine Pitch Control''),''MATLAB STEP Exporter'',''MATLAB R2026a'','''');\n', name_only, date_str);
        fprintf(fid, 'FILE_SCHEMA((''AUTOMOTIVE_DESIGN''));\n');
        fprintf(fid, 'ENDSEC;\n');
        fprintf(fid, 'DATA;\n');

        % =================================================================
        % CONTEXT & UNITS
        % =================================================================
        eid = 1;

        id_app_ctx = eid; eid = eid + 1;
        fprintf(fid, '#%d=APPLICATION_CONTEXT(''core data for automotive mechanical design processes'');\n', id_app_ctx);
        id_app_proto = eid; eid = eid + 1;
        fprintf(fid, '#%d=APPLICATION_PROTOCOL_DEFINITION(''international standard'',''automotive_design'',2000,#%d);\n', id_app_proto, id_app_ctx);
        id_prod_ctx = eid; eid = eid + 1;
        fprintf(fid, '#%d=PRODUCT_CONTEXT('''',#%d,''mechanical'');\n', id_prod_ctx, id_app_ctx);

        id_prod = eid; eid = eid + 1;
        fprintf(fid, '#%d=PRODUCT(''%s'',''%s'','''',(#%d));\n', id_prod, name_only, name_only, id_prod_ctx);
        id_prod_def_form = eid; eid = eid + 1;
        fprintf(fid, '#%d=PRODUCT_DEFINITION_FORMATION('''','''',#%d);\n', id_prod_def_form, id_prod);
        id_prod_def = eid; eid = eid + 1;
        fprintf(fid, '#%d=PRODUCT_DEFINITION(''design'','''',#%d,#%d);\n', id_prod_def, id_prod_def_form, id_prod_ctx);

        % Units (SI mm, rad, steradian)
        id_len_unit = eid; eid = eid + 1;
        fprintf(fid, '#%d=(LENGTH_UNIT()NAMED_UNIT(*)SI_UNIT(.MILLI.,.METRE.));\n', id_len_unit);
        id_ang_unit = eid; eid = eid + 1;
        fprintf(fid, '#%d=(NAMED_UNIT(*)PLANE_ANGLE_UNIT()SI_UNIT($,.RADIAN.));\n', id_ang_unit);
        id_sol_unit = eid; eid = eid + 1;
        fprintf(fid, '#%d=(NAMED_UNIT(*)SI_UNIT($,.STERADIAN.)SOLID_ANGLE_UNIT());\n', id_sol_unit);
        id_dim_ctx = eid; eid = eid + 1;
        fprintf(fid, '#%d=DIMENSIONAL_EXPOSITIONS_REPRESENTATION_CONTEXT(3);\n', id_dim_ctx);
        id_geom_ctx = eid; eid = eid + 1;
        fprintf(fid, '#%d=(GEOMETRIC_REPRESENTATION_CONTEXT(3)GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT((#%d))GLOBAL_UNIT_ASSIGNED_CONTEXT((#%d,#%d,#%d))REPRESENTATION_CONTEXT(''%s'',''TOP_LEVEL_ASSEMBLY_PART''));\n', ...
            id_geom_ctx, id_geom_ctx+1, id_len_unit, id_ang_unit, id_sol_unit, name_only);
        eid = eid + 1;
        fprintf(fid, '#%d=UNCERTAINTY_MEASURE_WITH_UNIT(LENGTH_MEASURE(1.E-05),#%d,''distance_accuracy_value'',''confusion accuracy'');\n', ...
            eid-1, id_len_unit);

        % =================================================================
        % CARTESIAN POINTS (Vertices)
        % =================================================================
        vertex_eids = zeros(n_verts, 1);
        for i = 1:n_verts
            vertex_eids(i) = eid;
            fprintf(fid, '#%d=CARTESIAN_POINT('''',(%g,%g,%g));\n', ...
                eid, vertices(i,1), vertices(i,2), vertices(i,3));
            eid = eid + 1;
        end

        % VERTEX POINTS
        vpoint_eids = zeros(n_verts, 1);
        for i = 1:n_verts
            vpoint_eids(i) = eid;
            fprintf(fid, '#%d=VERTEX_POINT('''',#%d);\n', eid, vertex_eids(i));
            eid = eid + 1;
        end

        % =================================================================
        % UNIQUE EDGES & ORIENTED EDGES
        % =================================================================
        raw_edges = [faces(:,[1 2]); faces(:,[2 3]); faces(:,[3 1])];
        sorted_edges = sort(raw_edges, 2);
        [unique_edges, ~, edge_map] = unique(sorted_edges, 'rows');
        n_unique_edges = size(unique_edges, 1);

        edge_curve_eids = zeros(n_unique_edges, 1);
        for e = 1:n_unique_edges
            id_dir = eid; eid = eid + 1;
            va = unique_edges(e, 1);
            vb = unique_edges(e, 2);
            dx = vertices(vb,1) - vertices(va,1);
            dy = vertices(vb,2) - vertices(va,2);
            dz = vertices(vb,3) - vertices(va,3);
            L = sqrt(dx^2 + dy^2 + dz^2);
            if L < eps, dx = 1; L = 1; end
            fprintf(fid, '#%d=DIRECTION('''',(%g,%g,%g));\n', id_dir, dx/L, dy/L, dz/L);

            id_vector = eid; eid = eid + 1;
            fprintf(fid, '#%d=VECTOR('''',#%d,%g);\n', id_vector, id_dir, L);

            id_line = eid; eid = eid + 1;
            fprintf(fid, '#%d=LINE('''',#%d,#%d);\n', id_line, vertex_eids(va), id_vector);

            edge_curve_eids(e) = eid;
            fprintf(fid, '#%d=EDGE_CURVE('''',#%d,#%d,#%d,.T.);\n', ...
                eid, vpoint_eids(va), vpoint_eids(vb), id_line);
            eid = eid + 1;
        end

        % =================================================================
        % FACES (ADVANCED_FACE)
        % =================================================================
        face_eids = zeros(n_faces, 1);
        for f = 1:n_faces
            e_idx = [edge_map(f), edge_map(f + n_faces), edge_map(f + 2*n_faces)];

            oe_eids = zeros(3, 1);
            for k = 1:3
                f_v1 = faces(f, k);
                f_v2 = faces(f, mod(k,3)+1);
                ue = unique_edges(e_idx(k), :);
                is_forward = (f_v1 == ue(1) && f_v2 == ue(2));

                oe_eids(k) = eid;
                bool_str = '.T.';
                if ~is_forward, bool_str = '.F.'; end
                fprintf(fid, '#%d=ORIENTED_EDGE('''',*,*,#%d,%s);\n', ...
                    eid, edge_curve_eids(e_idx(k)), bool_str);
                eid = eid + 1;
            end

            id_loop = eid; eid = eid + 1;
            fprintf(fid, '#%d=EDGE_LOOP('''',(#%d,#%d,#%d));\n', ...
                id_loop, oe_eids(1), oe_eids(2), oe_eids(3));

            id_bound = eid; eid = eid + 1;
            fprintf(fid, '#%d=FACE_OUTER_BOUND('''',#%d,.T.);\n', id_bound, id_loop);

            % Plane for face
            id_norm_dir = eid; eid = eid + 1;
            fprintf(fid, '#%d=DIRECTION('''',(%g,%g,%g));\n', ...
                id_norm_dir, normals(f,1), normals(f,2), normals(f,3));

            id_ref_dir = eid; eid = eid + 1;
            ref_x = 1; ref_y = 0; ref_z = 0;
            if abs(normals(f,1)) > 0.9, ref_x = 0; ref_y = 1; end
            fprintf(fid, '#%d=DIRECTION('''',(%g,%g,%g));\n', id_ref_dir, ref_x, ref_y, ref_z);

            id_axis = eid; eid = eid + 1;
            fprintf(fid, '#%d=AXIS2_PLACEMENT_3D('''',#%d,#%d,#%d);\n', ...
                id_axis, vertex_eids(faces(f,1)), id_norm_dir, id_ref_dir);

            id_plane = eid; eid = eid + 1;
            fprintf(fid, '#%d=PLANE('''',#%d);\n', id_plane, id_axis);

            face_eids(f) = eid;
            fprintf(fid, '#%d=ADVANCED_FACE('''',(#%d),#%d,.T.);\n', ...
                eid, id_bound, id_plane);
            eid = eid + 1;
        end

        % =================================================================
        % CLOSED SHELL & MANIFOLD SOLID BREP
        % =================================================================
        id_shell = eid; eid = eid + 1;
        fprintf(fid, '#%d=CLOSED_SHELL('''',(', id_shell);
        for f = 1:n_faces
            if f > 1, fprintf(fid, ','); end
            fprintf(fid, '#%d', face_eids(f));
        end
        fprintf(fid, '));\n');

        id_brep = eid; eid = eid + 1;
        fprintf(fid, '#%d=MANIFOLD_SOLID_BREP(''%s'',#%d);\n', id_brep, name_only, id_shell);

        id_shape_rep = eid; eid = eid + 1;
        fprintf(fid, '#%d=ADVANCED_BREP_SHAPE_REPRESENTATION(''%s'',(#%d),#%d);\n', ...
            id_shape_rep, name_only, id_brep, id_geom_ctx);

        id_shape_def = eid; eid = eid + 1;
        fprintf(fid, '#%d=PRODUCT_DEFINITION_SHAPE('''','''',#%d);\n', id_shape_def, id_prod_def);

        id_shape_assign = eid; eid = eid + 1;
        fprintf(fid, '#%d=SHAPE_DEFINITION_REPRESENTATION(#%d,#%d);\n', ...
            id_shape_assign, id_shape_def, id_shape_rep);

        fprintf(fid, 'ENDSEC;\n');
        fprintf(fid, 'END-ISO-10303-21;\n');
        fclose(fid);

        f_info = dir(filename);
        fprintf('    [STEP] Successfully wrote %s (%.2f MB, %d faces)\n', ...
            filename, f_info.bytes / 1e6, n_faces);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end
