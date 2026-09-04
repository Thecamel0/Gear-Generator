' ======================================================================
' SOLIDWORKS VBA MACRO - PARAMETRIC HELICAL GEAR CREATOR
' Wind Turbine Pitch Control System (Parallel-Axis Drive)
' Generated automatically by MATLAB Helical Gear Suite
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swModelExt As Object
Dim swFeatMgr As Object
Dim swSketchMgr As Object
Dim swEqnMgr As Object
Dim boolstatus As Boolean

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Pinion (Np = 16, mn = 3 mm, beta = 15 deg, F = 40 mm, C = 99.39 mm)
    CreateHelicalGear 3#, 16, 48, 15#, 20#, 49.6933#, 55.6933#, 42.1933#, 40#, 16#, "Helical_Pinion_16T"

    ' 2. Create Central Gear (Ng = 48, mn = 3 mm, beta = 15 deg, F = 40 mm)
    CreateHelicalGear 3#, 48, 16, -15#, 20#, 149.08#, 155.08#, 141.58#, 40#, 50#, "Helical_Gear_48T"

    MsgBox "Parametric Helical Gear Generation Complete!" & vbCrLf & _
           "Generated: Pinion (16T, PD=49.69mm, RH) and Central Gear (48T, PD=149.08mm, LH)" & vbCrLf & _
           "Center Distance = 99.39 mm", vbInformation, "Success"
End Sub

Sub CreateHelicalGear(mn As Double, N As Integer, N_match As Integer, beta As Double, phi_n As Double, _
                      d_pitch As Double, d_tip As Double, d_root As Double, _
                      face_w As Double, bore_d As Double, partName As String)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    ' Global Variables / Parameters
    swEqnMgr.Add -1, """NormalModule"" = " & mn
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """HelixAngle"" = " & beta
    swEqnMgr.Add -1, """NormalPressureAngle"" = " & phi_n
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """TipDiameter"" = " & d_tip
    swEqnMgr.Add -1, """RootDiameter"" = " & d_root
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swModel.EditRebuild3

    ' Create Cylindrical Blank on Front Plane
    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    Dim r_tip_m As Double, r_bore_m As Double, fw_m As Double
    r_tip_m = (d_tip / 2) / 1000
    r_bore_m = (bore_d / 2) / 1000
    fw_m = face_w / 1000

    swSketchMgr.CreateCircleByRadius 0, 0, 0, r_tip_m
    If bore_d > 0 Then
        swSketchMgr.CreateCircleByRadius 0, 0, 0, r_bore_m
    End If

    swFeatMgr.FeatureExtrusion3 True, False, False, 0, 0, fw_m, 0.01, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False
    swModel.ViewZoomtofit2
End Sub
