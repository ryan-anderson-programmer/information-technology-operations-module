@ECHO OFF
SET current_directory=%~dp0
PowerShell.exe -Command "Import-Module %current_directory%informationtechnologyoperationsmodule/InformationTechnologyOperationsModule.psm1; Get-Help Start-InformationTechnologyOperationVirtualMachine -Full; Start-InformationTechnologyOperationVirtualMachine -Name 'Windows*', 'Ubuntu*', 'OS-EN-US-User' -Threshold 0.55 -Force"
PAUSE