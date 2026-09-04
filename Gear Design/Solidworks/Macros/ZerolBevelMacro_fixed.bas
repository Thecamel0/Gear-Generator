' ======================================================================
' ZEROL BEVEL GEAR CREATOR — v6 (geometry fix: no apex-on-axis)
' ======================================================================
' FIX: SolidWorks FeatureRevolve2 fails when a single profile vertex
'      sits exactly on the revolve axis. Replaced triangular apex with
'      a small quadrilateral segment on the axis (2mm blunt tip).
'      The bore cut removes this center material anyway.
' ======================================================================

Option Explicit

Dim swApp       As Object
Dim swModel     As Object
Dim swFeat      As Object
Dim swFeatMgr   As Object
Dim swModelExt  As Object
Dim swSketchMgr As Object
Dim bRet        As Boolean

Sub main()
    Set swApp = Application.SldWorks
    If swApp Is Nothing Then
        MsgBox "Cannot connect to SolidWorks.", vbCritical
        Exit Sub
    End If

    CreateBevelGear 5, 20, 60, 20, 100, 109.49, 18.43, 47.43, 148.42, 25, "Zerol_Pinion"
    CreateBevelGear 5, 60, 20, 20, 300, 303.16, 71.57, 47.43, 45.26, 45, "Zerol_Gear"

    MsgBox "Done! Both Pinion (20T) and Gear (60T) solid bodies created.", _
           vbInformation, "Zerol Bevel Gears"
End Sub


Sub CreateBevelGear(m As Double, N As Integer, N_match As Integer, phi As Double, _
                    d_pitch As Double, d_outer As Double, gamma_deg As Double, _
                    face_w As Double, MD As Double, bore_d As Double, _
                    partName As String)

    ' ---- Create new part ----
    Set swModel = swApp.NewPart()
    If swModel Is Nothing Then
        MsgBox "Failed to create part for " & partName, vbCritical
        Exit Sub
    End If

    Set swModelExt  = swModel.Extension
    Set swFeatMgr   = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager

    ' ---- Equations ----
    Dim swEqnMgr As Object
    Set swEqnMgr = swModel.GetEquationMgr
    swEqnMgr.Add -1, """Module"" = " & m
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """PressureAngle"" = " & phi
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """OutsideDiameter"" = " & d_outer
    swEqnMgr.Add -1, """PitchConeAngle"" = " & gamma_deg
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """MountingDistance"" = " & MD
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swModel.EditRebuild3

    ' ---- Geometry (mm -> metres) ----
    Dim r_out     As Double: r_out     = (d_outer / 2#) / 1000#
    Dim MD_m      As Double: MD_m      = MD / 1000#
    Dim fw_m      As Double: fw_m      = face_w / 1000#
    Dim g_rad     As Double: g_rad     = gamma_deg * 3.14159265358979 / 180#
    Dim z_top     As Double: z_top     = MD_m - (r_out / Tan(g_rad))

    ' Blunt apex: replace the sharp cone tip at (0,0) with a small
    ' segment on the axis. 1mm above and below origin = 2mm blunt tip.
    ' The bore cut removes this center anyway.
    Dim apex_half As Double: apex_half = 0.001   ' 1mm

    ' ================================================================
    ' REVOLVE: Cone profile on Front Plane
    ' ================================================================
    bRet = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    ' Centerline along Y-axis (extends well beyond profile)
    swSketchMgr.CreateCenterLine 0, z_top - fw_m - 0.02, 0, 0, MD_m + 0.02, 0

    ' Quadrilateral profile (blunt cone cross-section)
    '
    '   P1 (0, +apex_half)   ---- P2 (r_out, z_top)
    '   |                              |
    '   |  (on axis)                   |  (outer wall)
    '   |                              |
    '   P4 (0, -apex_half)   ---- P3 (r_out, z_top - fw_m)
    '
    swSketchMgr.CreateLine 0, apex_half, 0, r_out, z_top, 0              ' P1 -> P2
    swSketchMgr.CreateLine r_out, z_top, 0, r_out, z_top - fw_m, 0      ' P2 -> P3
    swSketchMgr.CreateLine r_out, z_top - fw_m, 0, 0, -apex_half, 0     ' P3 -> P4
    swSketchMgr.CreateLine 0, -apex_half, 0, 0, apex_half, 0            ' P4 -> P1 (on axis)

    ' Exit sketch
    swSketchMgr.InsertSketch True

    ' Select sketch (auto-detect centerline as axis)
    swModel.ClearSelection2 True
    bRet = swModelExt.SelectByID2("Sketch1", "SKETCH", 0, 0, 0, False, 0, Nothing, 0)

    ' Revolve 360 degrees
    Set swFeat = swFeatMgr.FeatureRevolve2( _
        True, True, False, False, False, False, _
        0, 0, 6.28318530717958, 0, _
        False, False, 0.01, 0.01, _
        0, 0, 0, True, True, True)

    If swFeat Is Nothing Then
        MsgBox "REVOLVE FAILED for " & partName & "." & vbCrLf & _
               "r_out=" & r_out & " z_top=" & z_top & " fw=" & fw_m, vbCritical
        Exit Sub
    End If

    swModel.ViewZoomtofit2

    ' ================================================================
    ' BORE CUT (Through All on Top Plane)
    ' ================================================================
    bRet = swModelExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCircle 0, 0, 0, (bore_d / 2#) / 1000#, 0, 0
    swSketchMgr.InsertSketch True

    swModel.ClearSelection2 True
    bRet = swModelExt.SelectByID2("Sketch2", "SKETCH", 0, 0, 0, False, 0, Nothing, 0)

    Set swFeat = swFeatMgr.FeatureCut3( _
        True, False, False, 4, 0, 0.1, 0.1, _
        False, False, False, False, 0, 0, _
        False, False, False, False, False, _
        True, True, True, True, False, 0, 0, False)

    If swFeat Is Nothing Then
        MsgBox "Bore cut failed for " & partName & " (non-critical)", vbExclamation
    End If

    swModel.ViewZoomtofit2

End Sub
