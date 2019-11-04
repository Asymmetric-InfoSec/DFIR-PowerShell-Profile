[cmdletbinding(DefaultParameterSetName = "Default")]

param(

    [Parameter(ParameterSetName = "AllUsersCurrentHost", Position = 0, Mandatory = $false)]
    [Switch]$AllUsersCurrentHost,
    [Parameter(ParameterSetName = "AllUsersAllHosts", Position = 0, Mandatory = $false)]
    [Switch]$AllUsersAllHosts,
    [Parameter(ParameterSetName = "CurrentUserCurrentHost", Position = 0, Mandatory = $false)]
    [Switch]$CurrentUserCurrentHost,
    [Parameter(ParameterSetName = "CurrentUserAllHosts", Position = 0, Mandatory = $false)]
    [Switch]$CurrentUserAllHosts,

    [ValidateScript({
        if (@($Profile.AllUsersAllHosts, $Profile.AllUsersCurrentHost, $Profile.CurrentUserAllHosts, $Profile.CurrentUserCurrentHost) -NotContains $PSItem) {
            throw 'Path is not a valid PowerShell profile location. Run ''$Profile | Select-Object -Property *'' to view all profile options.'
        }
        return $true
    })]
    [String]$Path
 
)

# Location of the DFIR-PowerShell-Profile
$ProfileLocation = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"

# Location of the DFIR-PowerShell-Profile configuration file
$ConfigLocation = "$PSScriptRoot\Config.psd1"

# Location of the example DFIR-PowerShell-Profile configuration file
$ExampleConfigLocation = "$PSScriptRoot\Config.example.psd1"

# Dot source to place in actual PowerShell profiles (so you do not have to edit the PowerShell to update)
$ScriptText = @'

# DFIR-PowerShell-Profile
# Added by the DFIR-PowerShell-Profile Setup script on {0:u}
. {1}
'@ -f (Get-Date).ToUniversalTime(),$ProfileLocation

# Make sure the DFIR-PowerShell-Profile and either of the configuration files are present
if (!(Test-Path -Path $ProfileLocation -PathType 'Leaf') -or !(Test-Path -Path $ConfigLocation -PathType 'Leaf' -or Test-Path -Path $ExampleConfigLocation -PathType 'Leaf')) {

    throw 'DFIR Profile or Configuration not detected, re-download this project and try again.'

}

# Check administrator status
$Principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
$Admin = $Principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )

# Collect the profile options
if ($Admin) {

    # All profile locations are available as an admin
    $ProfileOptions = @($Profile.AllUsersCurrentHost, $Profile.AllUsersAllHosts, $Profile.CurrentUserCurrentHost, $Profile.CurrentUserAllHosts)

} else {

    # Remove AllUsers* options without admin privileges
    $ProfileOptions = @($Profile.CurrentUserCurrentHost, $Profile.CurrentUserAllHosts)

}

# Infer path based on the first existing option
$Path = $ProfileOptions | Where-Object { Test-Path -Path $PSItem -PathType 'Leaf' } | Select-Object -First 1

# Make sure we have a path to move forward with
if ($PSCmdlet.ParameterSetName -ne 'Default') {

    # Set path to specified switch value
    $Path = $Profile.($PSCmdlet.ParameterSetName)

} elseif (!$Path) {

    # No profiles exist yet, create the first one in the list
    $Path = $ProfileOptions[0]

}

# Error if attempting to edit a AllUsers* profile without admin privileges
if (!$Admin -and @($Profile.AllUsersCurrentHost, $Profile.AllUsersAllHosts) -Contains $Path) {

    throw 'Administrator privileges not detected for AllUsers profile dot sourcing. Run as Administrator and try again.'

}

# Determine if the DFIR-PowerShell-Profile has already been dot sourced
try {

    $Sourced = Select-String -Pattern '# DFIR-PowerShell-Profile' -Path $Path -ErrorAction 'Stop'

} catch {

    Write-Warning -Message $PSItem

}

# Only dot source for profiles that have not already been dot sourced
if(!$Sourced){

    try {

        # Append the text to C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1
        Add-Content -Path $Path -Value $ScriptText -ErrorAction 'Stop'
        Write-Host -Object ('Dot source added to {0}' -f $Path)

    } catch {

        Write-Warning -Message ('Dot source could not be added to {0}. Add manually if desired.' -f $Path)
    }
} else {

    Write-Host -Object ('Dot source already exists in {0}' -f $Path)

}

# Create the configuration file from the example
if (!(Test-Path -Path $ConfigLocation -PathType 'Leaf')){

    Write-Host -Object 'Config not deteted. Creating DFIR-PowerShell-Profile config file.'
    Copy-Item -Path $ExampleConfigLocation -Destination $ConfigLocation -Force

}


Write-Host -Object 'DFIR-PowerShell-Profile setup completed' -ForegroundColor 'Cyan' -BackgroundColor 'Black'
