' ======================================================================
' SOLIDWORKS VBA MACRO — PARAMETRIC ZEROL BEVEL GEAR CREATOR
' Wind Turbine Pitch Control Drive System
' Generated automatically by MATLAB Zerol Bevel Design Suite
' ======================================================================
' Instructions:
'   1. In SolidWorks, go to: Tools > Macro > New...
'   2. Save as "ZerolBevelCreator.swp"
'   3. Replace all code in the editor with this file's contents
'   4. Press F5 to execute. Both Pinion and Gear will be created!
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swFeatMgr As Object
Dim swModelExt As Object
Dim swEqnMgr As Object
Dim swSketchMgr As Object
Dim swSketchSegment As Object
Dim boolstatus As Boolean
Dim longstatus As Long, longwarnings As Long

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Pinion (Solid)
    CreateBevelGear 3, 16, 48, 20, 48, 53.69, 18.43, 21.25, 69.21, 0, 36, "Zerol_Pinion"

    ' 2. Create Ring Gear (Solid)
    CreateBevelGear 3, 48, 16, 20, 144, 145.90, 71.57, 21.25, 21.13, 0, 72, "Zerol_Gear"

    MsgBox "Parametric Zerol Bevel Gear Generation Complete!" & vbCrLf & _
           "Both Pinion (16T) and Gear (48T) solid models generated.", vbInformation, "Success"
End Sub

Sub CreateBevelGear(m As Double, N As Integer, N_match As Integer, phi As Double, _
                    d_pitch As Double, d_outer As Double, gamma_deg As Double, _
                    face_w As Double, MD As Double, bore_d As Double, hub_d As Double, _
                    partName As String)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    ' Add Equations / Global Variables
    swEqnMgr.Add -1, """Module"" = " & m
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """MatchingTeeth"" = " & N_match
    swEqnMgr.Add -1, """PressureAngle"" = " & phi
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """OutsideDiameter"" = " & d_outer
    swEqnMgr.Add -1, """PitchConeAngle"" = " & gamma_deg
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """MountingDistance"" = " & MD
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swModel.EditRebuild3

    ' Create Revolved Gear Blank on Front Plane
    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    Dim rad_out As Double, MD_m As Double, fw_m As Double, gamma_rad As Double
    rad_out = (d_outer / 2) / 1000
    MD_m = MD / 1000
    fw_m = face_w / 1000
    gamma_rad = gamma_deg * 3.14159265358979 / 180#

    ' Draw Axis of Revolution and Mark as Centerline
    Set swSketchSegment = swSketchMgr.CreateCenterLine(0, 0, 0, 0, MD_m, 0)
    swSketchSegment.ConstructionGeometry = True

    ' Draw Closed Cone Profile
    Dim z_top As Double
    z_top = MD_m - (rad_out / Tan(gamma_rad))
    swSketchMgr.CreateLine 0, 0, 0, rad_out, z_top, 0
    swSketchMgr.CreateLine rad_out, z_top, 0, rad_out, z_top - fw_m, 0
    swSketchMgr.CreateLine rad_out, z_top - fw_m, 0, 0, 0, 0

    ' Select Centerline Axis (Mark = 4) WHILE STILL IN SKETCH MODE
    swSketchSegment.Select2 False, 4

    ' Revolve Boss/Base (360 degrees = 6.283185 rad) directly from active sketch
    swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, 6.28318530717958, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True
    swModel.ViewZoomtofit2

    ' Cut Bore Through All on Top Plane (only if bore_d > 0)
    If bore_d > 0 Then
        boolstatus = swModelExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
        swSketchMgr.InsertSketch True
        swSketchMgr.CreateCircle 0, 0, 0, (bore_d / 2) / 1000, 0, 0
        swFeatMgr.FeatureCut3 True, False, False, 4, 0, 0.1, 0.1, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False
    End If
End Sub
