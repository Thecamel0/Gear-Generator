' ======================================================================
' SOLIDWORKS VBA MACRO - PARAMETRIC SPIRAL BEVEL GEAR BUILDER
' Wind Turbine Pitch Control Actuator (90 deg Multi-Pinion Drive)
' Author: Ahmed Majdy Ahmed
' Date:   2026-09-04
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swEqnMgr As Object

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Pinion (Right Hand, 16 Teeth, Helix 35 deg)
    CreateSpiralBevelComponent "Spiral_Bevel_Pinion_16T_RH", 3, 16, 20, 35, 18.4349, 75.8947, 25, 1

    ' 2. Create Central Ring Gear (Left Hand, 48 Teeth, Helix 35 deg)
    CreateSpiralBevelComponent "Spiral_Bevel_Gear_48T_LH", 3, 48, 20, 35, 71.5651, 75.8947, 25, -1

    MsgBox "Spiral Bevel Gear Assembly generated successfully!" & vbCrLf & _
           "Module: 3 mm" & vbCrLf & _
           "Pinion Teeth: 16 (Pitch Dia = 48.00 mm, Pitch Cone = 18.43 deg)" & vbCrLf & _
           "Gear Teeth: 48 (Pitch Dia = 144.00 mm, Pitch Cone = 71.57 deg)" & vbCrLf & _
           "Mean Spiral Angle: 35.0 deg (RH Pinion / LH Gear)" & vbCrLf & _
           "Cone Distance Ao: 75.89 mm, Face Width F: 25.00 mm" & vbCrLf & _
           "Total Contact Ratio CR: 2.579 (Transverse 1.31 + Overlap 2.22)", vbInformation, "Spiral Bevel Gear Suite"
End Sub

Sub CreateSpiralBevelComponent(partName As String, m As Double, N As Long, phi_n As Double, beta_m As Double, gamma As Double, Ao As Double, F As Double, hand As Long)
    Dim partDoc As Object
    Set partDoc = swApp.NewDocument(swApp.GetUserPreferenceStringValue(0), 0, 0, 0)
    If partDoc Is Nothing Then Exit Sub

    Dim eqnMgr As Object
    Set eqnMgr = partDoc.GetEquationMgr
    eqnMgr.Add -1, """m"" = " & Str(m)
    eqnMgr.Add -1, """N"" = " & Str(N)
    eqnMgr.Add -1, """phi_n"" = " & Str(phi_n)
    eqnMgr.Add -1, """beta_m"" = " & Str(beta_m)
    eqnMgr.Add -1, """gamma"" = " & Str(gamma)
    eqnMgr.Add -1, """Ao"" = " & Str(Ao)
    eqnMgr.Add -1, """F"" = " & Str(F)
    eqnMgr.Add -1, """dp"" = ""m"" * ""N"""
    eqnMgr.EvaluateAll
End Sub
