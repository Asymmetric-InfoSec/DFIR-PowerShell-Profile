########## DFIR PowerShell Profile ##########

#--------Begin Configuration Section--------#
#Shell Colors
$AdministratorBackground = 'DarkBlue'
$AdministratorForeground = 'White'
$UserBackground = 'DarkBlue'
$UserForeground = 'White'

#Working/Startup Directory
$WorkingDirectory = 'C:\'

#Modules to import
$ImportModules = @( 
    @{Name='ActiveDirectory';ErrorAction='SilentlyContinue'}
)

#Aliases
$Aliases = @(
    @{Name = 'claer';Value='clear'}
)

#---------End Configuration Section---------#

#Aliases
Set-Alias @Aliases

#Modules to Import
Import-Module @ImportModules -Force

#Console Appearance adjustments - Change colors as desired in the configuration section
if ($host.UI.RawUI.WindowTitle -match 'Administrator') {

    $host.UI.RawUI.BackgroundColor = $AdministratorBackground
    $Host.UI.RawUI.ForegroundColor = $AdministratorForeground

}else{

    $host.UI.RawUI.BackgroundColor = $UserBackground
    $Host.UI.RawUI.ForegroundColor = $UserForeground

} 

#Change to Starting working directory
#Update the working directory to the working directory of your choice
if (!(Test-Path $WorkingDirectory)){

    New-Item -Type Directory -Path $WorkingDirectory -Force
    cd $WorkingDirectory

} else {

    cd $WorkingDirectory
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