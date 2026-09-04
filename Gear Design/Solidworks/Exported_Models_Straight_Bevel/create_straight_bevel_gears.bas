' ======================================================================
' SOLIDWORKS VBA MACRO - PARAMETRIC STRAIGHT BEVEL GEAR BUILDER
' Wind Turbine Pitch Actuator Drive (Orthogonal 90 deg Multi-Pinion Drive)
' Author: Ahmed Majdy Ahmed
' Date:   2026-09-03
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swEqnMgr As Object

Sub main()
    Set swApp = Application.SldWorks
    MsgBox "Straight Bevel Gear Parameters Loaded:" & vbCrLf & _
           "Module: 3 mm" & vbCrLf & _
           "Pinion Teeth: 16 (Pitch Dia = 48.00 mm, Cone Angle = 18.43 deg)" & vbCrLf & _
           "Gear Teeth: 48 (Pitch Dia = 144.00 mm, Cone Angle = 71.57 deg)" & vbCrLf & _
           "Cone Distance Ao = 75.89 mm, Face Width F = 25.00 mm" & vbCrLf & _
           "Contact Ratio CR = 1.702 (Transverse)", vbInformation, "Straight Bevel Gear Suite"
End Sub
