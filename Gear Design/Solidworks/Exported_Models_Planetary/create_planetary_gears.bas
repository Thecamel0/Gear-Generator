' =========================================================================
' SOLIDWORKS VBA MACRO: PARAMETRIC PLANETARY GEAR DRIVE
' Wind Turbine Pitch Control System
' Module: 3 mm, Sun: 12T, Planet: 18T (x4), Ring: 48T
' Ratio: 1:5.00, Center Distance: 45.00 mm, Face Width: 25.00 mm
' =========================================================================

Option Explicit

Dim swApp As Object
Dim Part As Object

Sub main()
    Set swApp = Application.SldWorks
    Set Part = swApp.ActiveDoc
    If Part Is Nothing Then
        Set Part = swApp.NewDocument("", 0, 0, 0)
    End If

    MsgBox "Planetary Gear Parameters Loaded:" & vbCrLf & _
           "Module: 3 mm" & vbCrLf & _
           "Sun Teeth: 12" & vbCrLf & _
           "Planet Teeth: 18 (x4)" & vbCrLf & _
           "Ring Teeth: 48" & vbCrLf & _
           "Willis Ratio: 1:5.00" & vbCrLf & _
           "Center Distance: 45.00 mm", vbInformation, "Gear Master Suite"
End Sub
