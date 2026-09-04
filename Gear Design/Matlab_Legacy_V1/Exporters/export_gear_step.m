function export_gear_step(mesh, filename, header_text)
%EXPORT_GEAR_STEP Export 3D gear mesh as ISO 10303-21 STEP AP214 (.stp) file
%
%   Uses MANIFOLD_SOLID_BREP with ADVANCED_FACE + EDGE_LOOP + PLANE topology.
%   This is the standard B-Rep format that SolidWorks, CATIA, Creo all support.
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-06

if nargin < 3 || isempty(header_text)
    header_text = 'Zerol Bevel Gear 3D Solid Model';
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

% Ensure unit outward normals directly from mesh face winding
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
    error('export_gear_step:fileOpen', 'Cannot open file: %s', filename);
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
    fprintf(fid, 'FILE_NAME(''%s.stp'',''%s'',(''Ahmed Majdy Ahmed''),(''Wind Turbine Pitch Control''),''MATLAB STEP Exporter'',''MATLAB R2024b'','''');\n', name_only, date_str);
    fprintf(fid, 'FILE_SCHEMA((''AUTOMOTIVE_DESIGN''));\n');
    fprintf(fid, 'ENDSEC;\n');
    fprintf(fid, 'DATA;\n');

    % =================================================================
    % CONTEXT & UNITS  (#1 .. #16)
    % =================================================================
    eid = 1;

    e_app = eid;
    fprintf(fid, '#%d=APPLICATION_CONTEXT(''core data for automotive mechanical design processes'');\n', eid); eid=eid+1;

    e_apd = eid;
    fprintf(fid, '#%d=APPLICATION_PROTOCOL_DEFINITION(''international standard'',''automotive_design'',2000,#%d);\n', eid, e_app); eid=eid+1;

    e_prc = eid;
    fprintf(fid, '#%d=PRODUCT_RELATED_PRODUCT_CATEGORY(''part'',(#%d));\n', eid, eid+1); eid=eid+1;

    e_prod = eid;
    fprintf(fid, '#%d=PRODUCT(''%s'',''%s'','''',(#%d));\n', eid, name_only, header_text, eid+1); eid=eid+1;

    e_pctx = eid;
    fprintf(fid, '#%d=PRODUCT_CONTEXT('''',#%d,''mechanical'');\n', eid, e_app); eid=eid+1;

    e_pdf = eid;
    fprintf(fid, '#%d=PRODUCT_DEFINITION_FORMATION('''','''',#%d);\n', eid, e_prod); eid=eid+1;

    e_pdc = eid;
    fprintf(fid, '#%d=PRODUCT_DEFINITION_CONTEXT(''detailed design'',#%d,''design'');\n', eid, e_app); eid=eid+1;

    e_pd = eid;
    fprintf(fid, '#%d=PRODUCT_DEFINITION(''design'','''',#%d,#%d);\n', eid, e_pdf, e_pdc); eid=eid+1;

    e_pds = eid;
    fprintf(fid, '#%d=PRODUCT_DEFINITION_SHAPE('''','''',#%d);\n', eid, e_pd); eid=eid+1;

    % Units
    e_lu = eid;
    fprintf(fid, '#%d=(LENGTH_UNIT()NAMED_UNIT(*)SI_UNIT(.MILLI.,.METRE.));\n', eid); eid=eid+1;

    e_au = eid;
    fprintf(fid, '#%d=(NAMED_UNIT(*)PLANE_ANGLE_UNIT()SI_UNIT($,.RADIAN.));\n', eid); eid=eid+1;

    e_su = eid;
    fprintf(fid, '#%d=(NAMED_UNIT(*)SI_UNIT($,.STERADIAN.)SOLID_ANGLE_UNIT());\n', eid); eid=eid+1;

    e_unc = eid;
    fprintf(fid, '#%d=UNCERTAINTY_MEASURE_WITH_UNIT(LENGTH_MEASURE(1.E-06),#%d,''distance_accuracy_value'',''maximum tolerance'');\n', eid, e_lu); eid=eid+1;

    e_ctx = eid;
    fprintf(fid, '#%d=(GEOMETRIC_REPRESENTATION_CONTEXT(3)GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT((#%d))GLOBAL_UNIT_ASSIGNED_CONTEXT((#%d,#%d,#%d))REPRESENTATION_CONTEXT(''Context3D'',''3D Context''));\n', ...
        eid, e_unc, e_lu, e_au, e_su); eid=eid+1;

    % Origin axis
    e_org = eid;
    fprintf(fid, '#%d=CARTESIAN_POINT(''Origin'',(0.,0.,0.));\n', eid); eid=eid+1;
    e_dz = eid;
    fprintf(fid, '#%d=DIRECTION(''axis'',(0.,0.,1.));\n', eid); eid=eid+1;
    e_dx = eid;
    fprintf(fid, '#%d=DIRECTION(''refdir'',(1.,0.,0.));\n', eid); eid=eid+1;
    e_ax = eid;
    fprintf(fid, '#%d=AXIS2_PLACEMENT_3D(''placement'',#%d,#%d,#%d);\n', eid, e_org, e_dz, e_dx); eid=eid+1;

    % =================================================================
    % CARTESIAN_POINT for each unique vertex
    % =================================================================
    pt_base = eid;
    for i = 1:n_verts
        fprintf(fid, '#%d=CARTESIAN_POINT('''',(%.6f,%.6f,%.6f));\n', ...
            eid, vertices(i,1), vertices(i,2), vertices(i,3));
        eid = eid + 1;
    end

    % VERTEX_POINT for each unique vertex
    vp_base = eid;
    for i = 1:n_verts
        fprintf(fid, '#%d=VERTEX_POINT('''',#%d);\n', eid, pt_base + i - 1);
        eid = eid + 1;
    end

    % =================================================================
    % Build ADVANCED_FACEs with EDGE_LOOP topology
    % =================================================================
    % For each triangular face we create:
    %   3 x LINE (edge geometry)
    %   3 x EDGE_CURVE
    %   3 x ORIENTED_EDGE
    %   1 x EDGE_LOOP
    %   1 x FACE_OUTER_BOUND
    %   1 x PLANE (surface geometry)
    %   1 x ADVANCED_FACE
    % = 12 entities per face

    face_eids = zeros(n_faces, 1);

    for f = 1:n_faces
        vi = faces(f, :); % 3 vertex indices
        vp = [vp_base+vi(1)-1, vp_base+vi(2)-1, vp_base+vi(3)-1];
        pp = [pt_base+vi(1)-1, pt_base+vi(2)-1, pt_base+vi(3)-1];

        p1 = vertices(vi(1), :);
        p2 = vertices(vi(2), :);
        p3 = vertices(vi(3), :);

        % Edge directions (normalized)
        edges = [p2-p1; p3-p2; p1-p3];
        edge_lens = sqrt(sum(edges.^2, 2));
        edge_lens(edge_lens < eps) = 1;
        edge_dirs = edges ./ edge_lens;

        % 3 DIRECTIONs for edge vectors
        ed = zeros(3,1);
        for e = 1:3
            ed(e) = eid;
            fprintf(fid, '#%d=DIRECTION('''',(%.9f,%.9f,%.9f));\n', eid, edge_dirs(e,1), edge_dirs(e,2), edge_dirs(e,3));
            eid = eid + 1;
        end

        % 3 VECTORs
        ev = zeros(3,1);
        for e = 1:3
            ev(e) = eid;
            fprintf(fid, '#%d=VECTOR('''',#%d,%.6f);\n', eid, ed(e), edge_lens(e));
            eid = eid + 1;
        end

        % 3 LINEs (edge1: p1->p2, edge2: p2->p3, edge3: p3->p1)
        el = zeros(3,1);
        start_pts = [pp(1), pp(2), pp(3)];
        for e = 1:3
            el(e) = eid;
            fprintf(fid, '#%d=LINE('''',#%d,#%d);\n', eid, start_pts(e), ev(e));
            eid = eid + 1;
        end

        % 3 EDGE_CURVEs
        ec = zeros(3,1);
        vp_start = [vp(1), vp(2), vp(3)];
        vp_end   = [vp(2), vp(3), vp(1)];
        for e = 1:3
            ec(e) = eid;
            fprintf(fid, '#%d=EDGE_CURVE('''',#%d,#%d,#%d,.T.);\n', eid, vp_start(e), vp_end(e), el(e));
            eid = eid + 1;
        end

        % 3 ORIENTED_EDGEs (all forward = .T.)
        oe = zeros(3,1);
        for e = 1:3
            oe(e) = eid;
            fprintf(fid, '#%d=ORIENTED_EDGE('''',*,*,#%d,.T.);\n', eid, ec(e));
            eid = eid + 1;
        end

        % EDGE_LOOP
        e_el = eid;
        fprintf(fid, '#%d=EDGE_LOOP('''',(#%d,#%d,#%d));\n', eid, oe(1), oe(2), oe(3));
        eid = eid + 1;

        % FACE_OUTER_BOUND
        e_fob = eid;
        fprintf(fid, '#%d=FACE_OUTER_BOUND('''',#%d,.T.);\n', eid, e_el);
        eid = eid + 1;

        % PLANE (surface geometry for this face)
        n = normals(f, :);

        % Compute a ref_direction perpendicular to normal
        if abs(n(3)) < 0.9
            ref = cross(n, [0 0 1]);
        else
            ref = cross(n, [1 0 0]);
        end
        ref = ref / norm(ref);

        e_fp = eid;
        fprintf(fid, '#%d=CARTESIAN_POINT('''',(%.6f,%.6f,%.6f));\n', eid, p1(1), p1(2), p1(3));
        eid = eid + 1;

        e_fn = eid;
        fprintf(fid, '#%d=DIRECTION('''',(%.9f,%.9f,%.9f));\n', eid, n(1), n(2), n(3));
        eid = eid + 1;

        e_fr = eid;
        fprintf(fid, '#%d=DIRECTION('''',(%.9f,%.9f,%.9f));\n', eid, ref(1), ref(2), ref(3));
        eid = eid + 1;

        e_fax = eid;
        fprintf(fid, '#%d=AXIS2_PLACEMENT_3D('''',#%d,#%d,#%d);\n', eid, e_fp, e_fn, e_fr);
        eid = eid + 1;

        e_plane = eid;
        fprintf(fid, '#%d=PLANE('''',#%d);\n', eid, e_fax);
        eid = eid + 1;

        % ADVANCED_FACE
        face_eids(f) = eid;
        fprintf(fid, '#%d=ADVANCED_FACE('''',(#%d),#%d,.T.);\n', eid, e_fob, e_plane);
        eid = eid + 1;
    end

    % =================================================================
    % CLOSED_SHELL -> MANIFOLD_SOLID_BREP -> SHAPE_REP
    % =================================================================
    e_shell = eid;
    fprintf(fid, '#%d=CLOSED_SHELL(''shell'',(', eid);
    for f = 1:n_faces
        if f > 1, fprintf(fid, ','); end
        if mod(f, 20) == 0, fprintf(fid, '\n'); end
        fprintf(fid, '#%d', face_eids(f));
    end
    fprintf(fid, '));\n');
    eid = eid + 1;

    e_brep = eid;
    fprintf(fid, '#%d=MANIFOLD_SOLID_BREP(''%s'',#%d);\n', eid, name_only, e_shell);
    eid = eid + 1;

    e_sr = eid;
    fprintf(fid, '#%d=ADVANCED_BREP_SHAPE_REPRESENTATION(''%s'',(#%d,#%d),#%d);\n', ...
        eid, name_only, e_brep, e_ax, e_ctx);
    eid = eid + 1;

    fprintf(fid, '#%d=SHAPE_DEFINITION_REPRESENTATION(#%d,#%d);\n', eid, e_pds, e_sr);

    % =================================================================
    % FOOTER
    % =================================================================
    fprintf(fid, 'ENDSEC;\n');
    fprintf(fid, 'END-ISO-10303-21;\n');

catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

info = dir(filename);
fprintf('  STEP saved: %s  (%d faces, %.1f KB)\n', ...
    filename, n_faces, info.bytes/1024);
end
