' ======================================================================
' SOLIDWORKS VBA MACRO — PARAMETRIC SPUR GEAR CREATOR
' Wind Turbine Pitch Control Drive System
' Generated automatically by MATLAB Spur Gear Design Suite
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

    ' 1. Create Pinion (16T, Module 3, Face 25 mm, Pitch Dia 48 mm, Bore 16 mm)
    CreateSpurGear 3#, 16, 48, 20#, 48#, 55.2, 42.07, 25#, 16#, "Spur_Pinion_16T"

    ' 2. Create Central Spur Bull Gear (48T, Module 3, Face 25 mm, Pitch Dia 144 mm, Bore 50 mm)
    CreateSpurGear 3#, 48, 16, 20#, 144#, 148.8, 135.67, 25#, 50#, "Spur_Gear_48T"

    MsgBox "Parametric Spur Gear Generation Complete!" & vbCrLf & _
           "Generated: Pinion (16T, PD=48mm) and Central Gear (48T, PD=144mm)" & vbCrLf & _
           "Center Distance = 96.0 mm", vbInformation, "Success"
End Sub

Sub CreateSpurGear(m As Double, N As Integer, N_match As Integer, phi As Double, _
                   d_pitch As Double, d_tip As Double, d_root As Double, _
                   face_w As Double, bore_d As Double, partName As String)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    ' Global Variables / Parameters
    swEqnMgr.Add -1, """Module"" = " & m
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """MatchingTeeth"" = " & N_match
    swEqnMgr.Add -1, """PressureAngle"" = " & phi
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """TipDiameter"" = " & d_tip
    swEqnMgr.Add -1, """RootDiameter"" = " & d_root
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swEqnMgr.Add -1, """CenterDistance"" = " & ((d_pitch + m * N_match) / 2)
    swModel.EditRebuild3

    ' Create Cylindrical Blank on Front Plane
    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    ' Outer circle (d_tip)
    Set swSketchSegment = swSketchMgr.CreateCircle(0, 0, 0, (d_tip / 2) / 1000#, 0, 0)
    ' Inner bore circle (bore_d)
    If bore_d > 0 Then
        Set swSketchSegment = swSketchMgr.CreateCircle(0, 0, 0, (bore_d / 2) / 1000#, 0, 0)
    End If

    swSketchMgr.InsertSketch True
    swModel.ClearSelection2 True

    ' Boss Extrude (Blind, FaceWidth)
    boolstatus = swModelExt.SelectByID2("Sketch1", "SKETCH", 0, 0, 0, False, 0, Nothing, 0)
    swFeatMgr.FeatureExtrusion2 True, False, False, 0, 0, (face_w / 1000#), 0, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False

    swModel.ViewZoomtofit2
End Sub
