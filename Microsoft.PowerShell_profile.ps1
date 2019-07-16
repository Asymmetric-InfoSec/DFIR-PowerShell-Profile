########## DFIR PowerShell Profile ##########

$TmpVerbosePreference = $VerbosePreference
# $VerbosePreference = 'Continue'

#--------Begin Configuration Section--------#
$DefaultConfig = @{
    #Shell Colors
    AdministratorBackground = 'DarkBlue'
    AdministratorForeground = 'White'
    UserBackground = 'DarkBlue'
    UserForeground = 'White'

    #Working/Startup Directory
    WorkingDirectory = 'C:\'

    #Modules to import
    ImportModules = @(
        @{Name='ActiveDirectory'; ErrorAction='SilentlyContinue'}
    )

    #Aliases
    Aliases = @(
        @{Name = 'claer';Value='clear'}
    )
}
#---------End Configuration Section---------#

#Try to get the config file
try {
    Import-LocalizedData -BindingVariable 'Config' -BaseDirectory $PSScriptRoot -FileName 'Config.psd1' -ErrorAction 'Stop'
    $DefaultConfig.Keys | Where-Object { $Config.Keys -NotContains $PSItem } | Foreach-Object { $Config.$PSItem = $DefaultConfig.$PSItem }
} catch {
    Write-Verbose -Message "No config file found, using the default config"
    $Config = $DefaultConfig
}

#Aliases
foreach ($Alias in $Config.Aliases) {
    Write-Verbose -Message "Creating $($Alias.Name) Alias"
    Set-Alias @Alias
}

#Modules to Import
foreach ($Module in $Config.ImportModules) {
    Write-Verbose -Message "Importing $($Module.Name) Module"
    Import-Module @Module -Force
}

#Console Appearance adjustments - Change colors as desired in the configuration section
if ($Host.UI.RawUI.WindowTitle -match 'Administrator') {

    $Host.UI.RawUI.BackgroundColor = $Config.AdministratorBackground
    $Host.UI.RawUI.ForegroundColor = $Config.AdministratorForeground

} else {

    $Host.UI.RawUI.BackgroundColor = $Config.UserBackground
    $Host.UI.RawUI.ForegroundColor = $Config.UserForeground

}

#Change to Starting working directory
#Update the working directory to the working directory of your choice
if (!(Test-Path $Config.WorkingDirectory)){

    New-Item -Type Directory -Path $Config.WorkingDirectory -Force
    Set-Location -Path $Config.WorkingDirectory

} else {

    Set-Location -Path $Config.WorkingDirectory
}

#Functions
#Base64-Encode: Encode strings into base64 encoded strings
function Base64-Encode {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string]$InputObject
    )

    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$InputObject"))
}

#Base64-Decode: Decode base64 encoded strings
function Base64-Decode {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$InputObject"))
}

#URL-Encode: Encode strings into URL encoded strings
function URL-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    [System.Web.HttpUtility]::UrlEncode($InputObject)
}

#URL-Decode: Decode URL encoded strings
function URL-Decode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    [System.Web.HttpUtility]::UrlDecode($InputObject)
}

#Hex-Encode: Encode strings into hex encoded strings
function Hex-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    $HexOutput = ""
    $InputObject.ToCharArray() | Foreach-Object -process {
        $HexOutput += '{0:X}' -f [int][char]$_
    }
    return $HexOutput
}

#Hex-Decode: Decodes Hexidecimal encoded strings
function Hex-Decode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    $SplitInput = $InputObject.Replace(" ","")
    ($SplitInput-split"(..)"|Where-Object{$_}|Foreach-Object{[char][convert]::ToInt16($_,16)})-join""
}

#Convert-ToEpoch: Converts from human readable date and time to Epoch timestamp (All timestamps assume UTC)
function Convert-ToEpoch{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    $FormattedDate = ($InputObject -f "mm/dd/yyyy hh:mm")
    (New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $FormattedDate).TotalSeconds
}

#Convert-FromEpoch: Converts from Epoch timestamp to human readable timestamp (All timestamps assume UTC)
function Convert-FromEpoch{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    if ($InputObject.Length -gt 10){

        (Get-Date -Date '01/01/1970').AddMilliseconds($InputObject)
    } else {

        (Get-Date -Date '01/01/1970').AddSeconds($InputObject)
    }
}

#Convert-ToMsftFileTime: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)
function Convert-ToMsftFileTime{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    [DateTime]$FormattedDate = ($InputObject -f "mm/dd/yyyy hh:mm")
    $FormattedDate.ToFileTimeUtc()
}

#Convert-FromMsftFileTime: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)
function Convert-FromMsftFileTime{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    [DateTime]::FromFileTimeUtc($InputObject)
}

$VerbosePreference = $TmpVerbosePreference

#Clean up created defaultconfig and config variables so they don't appear in session
Remove-Variable -Name 'Alias','DefaultConfig','Config','Module','TmpVerbosePreference' -Force -ErrorAction 'SilentlyContinue'
