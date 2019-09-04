#Requires -RunAsAdministrator

$ProfileLocation = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
$ScriptText = @'

# Added by the DFIR-PowerShell-Profile Setup script on {0:u}
. {1}
'@ -f (Get-Date).ToUniversalTime(), $ProfileLocation

# If the file C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1 exists
if (Test-Path -Path $Profile.AllUsersAllHosts -PathType 'Leaf') {
    # Append the text to C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1
    Add-Content -Path $Profile.AllUsersAllHosts -Value $ScriptText
} else {
    # Append the text to C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
    Add-Content -Path $Profile.AllUsersCurrentHost -Value $ScriptText
}
