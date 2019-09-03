########## DFIR PowerShell Profile ##########

$TmpVerbosePreference = $VerbosePreference
#$VerbosePreference = 'Continue'

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

    #PowerShell Remoting Options
    $PSSessionOption.NoMachineProfile = $true
}
#---------End Configuration Section---------#

#Try to get the config file (if used)
try {
    Import-LocalizedData -BindingVariable 'Config' -BaseDirectory $PSScriptRoot -FileName 'Config.psd1' -ErrorAction 'Stop'
    $DefaultConfig.Keys | Where-Object { $Config.Keys -NotContains $PSItem } | Foreach-Object { $Config.$PSItem = $DefaultConfig.$PSItem }
} catch {
    Write-Verbose -Message "Encountered error: $PSItem"
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
        [string]$InputObject,

        [ValidateSet('Unicode','UTF8','ASCII')]
        [String]$Encoding = 'Unicode'
    )

    begin {

        $GetBytes = Invoke-Expression -Command "[System.Text.Encoding]::$Encoding.GetBytes"
    }

    process {

        [System.Convert]::ToBase64String($GetBytes.Invoke("$InputObject"))
    }   
}

#Base64-Decode: Decode base64 encoded strings
function Base64-Decode {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject,

        [ValidateSet('Unicode','UTF8','ASCII')]
        [String]$Encoding = 'Unicode'
    )

    begin {

        $GetString = Invoke-Expression -Command "[System.Text.Encoding]::$Encoding.GetString"
    }

    process {

        #Handle malformed base64 encoded entries (most likely from being truncated by tools)
        if ($InputObject.Length % 4 -eq 1) {
                
                # Base64 string was probably truncated, append an 'A' (0) to the end to avoid a triple '=' padding error
                $InputObject += 'A'
            }

        # Pad strings that are LENGTH % 4 != 0
        $Padding = '=' * ((4 - ($InputObject.Length % 4)) % 4)
        
        $GetString.Invoke([System.Convert]::FromBase64String($InputObject+$Padding))
    } 
}

#URL-Encode: Encode strings into URL encoded strings
function URL-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        [System.Web.HttpUtility]::UrlEncode($InputObject)
    }
}

#URL-Decode: Decode URL encoded strings
function URL-Decode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        [System.Web.HttpUtility]::UrlDecode($InputObject)
    } 
}

#Hex-Encode: Encode strings into hex encoded strings
function Hex-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )
    process {

        $HexOutput = ""
        $InputObject.ToCharArray() | Foreach-Object -process {
            $HexOutput += '{0:X}' -f [int][char]$_
        }
        return $HexOutput
    } 
}

#Hex-Decode: Decodes Hexidecimal encoded strings
function Hex-Decode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )
    process {

        $SplitInput = $InputObject.Replace(" ","")
        ($SplitInput-split"(..)"|Where-Object{$_}|Foreach-Object{[char][convert]::ToInt16($_,16)})-join""
    }  
}

#Convert-ToEpoch: Converts from human readable date and time to Epoch timestamp (All timestamps assume UTC)
function Convert-ToEpoch{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        $FormattedDate = ($InputObject -f "mm/dd/yyyy hh:mm")
        (New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $FormattedDate).TotalSeconds
    }  
}

#Convert-FromEpoch: Converts from Epoch timestamp to human readable timestamp (All timestamps assume UTC)
function Convert-FromEpoch{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        if ($InputObject.Length -gt 10){

            (Get-Date -Date '01/01/1970').AddMilliseconds($InputObject)
        } else {

            (Get-Date -Date '01/01/1970').AddSeconds($InputObject)
        }
    }
}

#Convert-ToMsftFileTime: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)
function Convert-ToMsftFileTime{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )
    process {

        [DateTime]$FormattedDate = ($InputObject -f "mm/dd/yyyy hh:mm")
        $FormattedDate.ToFileTimeUtc()
    }  
}

#Convert-FromMsftFileTime: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)
function Convert-FromMsftFileTime{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        [DateTime]::FromFileTimeUtc($InputObject)
    }  
}

$VerbosePreference = $TmpVerbosePreference

#Clean up created defaultconfig and config variables so they don't appear in session
Remove-Variable -Name 'Alias','DefaultConfig','Config','Module','TmpVerbosePreference' -Force -ErrorAction 'SilentlyContinue'
