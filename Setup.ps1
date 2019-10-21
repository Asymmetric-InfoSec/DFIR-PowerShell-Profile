[cmdletbinding()]

param(

    [Parameter(ParameterSetName = "CurrentUser", Position = 0, Mandatory = $false)]
    [Switch]$CurrentUser
  
)

# Location of the DFIR-PowerShell-Profile
$ProfileLocation = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
# Dot source to place in actual PowerShell profiles (so you do not have to edit the PowerShell to update)
$ScriptText = @'

# DFIR-PowerShell-Profile
# Added by the DFIR-PowerShell-Profile Setup script on {0:u}
. {1}
'@ -f (Get-Date).ToUniversalTime(),$ProfileLocation

# If the file C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1 exists
if (!$CurrentUser) {

    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $Identity
    $Admin = $Principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )

    if (!$Admin){

        Throw 'Administrator privileges not detected for AllUsers profile dot sourcing. Run as Administrator and try again.'
        Exit
    }
    
    # Determine if the DFIR-PowerShell-Profile has already been dot sourced 
    try {

        $Sourced = Select-String -Pattern '# DFIR-PowerShell-Profile' -Path $Profile.AllUsersCurrentHost -ErrorAction Stop

    } catch {

        Write-Warning $PSItem

    }

    #Only dot source for profiles that have not already been dot sourced
    if(!$Sourced){

        try {

            # Append the text to C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1
            Add-Content -Path $Profile.AllUsersCurrentHost -Value $ScriptText -ErrorAction Stop
            Write-Host ('Dot source added to {0}' -f ($Profile.AllUsersCurrentHost)) 

        } catch {

            Write-Warning ('Dot source could not be added to {0}. Add manually if desired.' -f ($Profile.AllUsersCurrentHost))
        } 
    }
}

if ($CurrentUser) {

    # Determine if the DFIR-PowerShell-Profile has already been dot sourced 
    try {

        $Sourced = Select-String -Pattern '# DFIR-PowerShell-Profile' -Path $Profile -ErrorAction Stop

    } catch {

        Write-Warning $PSItem

    }
    
    #Only dot source for profiles that have not already been dot sourced
    if(!$Sourced){

        try{
            # Append the text to C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
            Add-Content -Path $Profile -Value $ScriptText -ErrorAction Stop
            Write-Host ('Dot source added to {0}' -f $Profile)
        
        } catch {

            Write-Warning ('Dot source could not be added to {0}. Add manually if desired.' -f $Profile)
        }
    }
}

if (!(Test-Path "$PSScriptRoot\config.psd1")){

    Write-Host 'Config not deteted. Creating DFIR-PowerShell-Profile config file.'
    Copy-Item -Path "$PSScriptRoot\config.example.psd1" -Destination "$PSScriptRoot\config.psd1" -Force
}


Write-Host 'DFIR-PowerShell-Profile setup completed' -ForegroundColor 'Cyan' -BackgroundColor 'Black'
