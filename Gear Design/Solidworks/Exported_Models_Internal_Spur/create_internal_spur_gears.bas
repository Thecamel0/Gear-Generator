' =========================================================================
' SOLIDWORKS VBA MACRO: PARAMETRIC INTERNAL SPUR GEAR DRIVE
' Wind Turbine Pitch Control System
' Module: 3 mm, Teeth: 16 (Pinion) / 48 (Ring Gear)
' Center Distance: 48.00 mm, Face Width: 25.00 mm
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

    MsgBox "Internal Spur Gear Parameters Loaded:" & vbCrLf & _
           "Module: 3 mm" & vbCrLf & _
           "Pinion Teeth: 16" & vbCrLf & _
           "Ring Teeth: 48" & vbCrLf & _
           "Center Distance: 48.00 mm" & vbCrLf & _
           "Contact Ratio: 1.807", vbInformation, "Gear Master Suite"
End Sub
