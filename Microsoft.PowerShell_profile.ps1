#Console Appearance adjustments - Change colors as desired

$AdministratorBackground = 'DarkBlue'
$AdministratorForeground = 'White'
$UserBackground = 'DarkBlue'
$UserForeground = 'White'

if ($host.UI.RawUI.WindowTitle -match 'Administrator') {

    $host.UI.RawUI.BackgroundColor = $AdministratorBackground
    $Host.UI.RawUI.ForegroundColor = $AdministratorForeground

}else{

    $host.UI.RawUI.BackgroundColor = $UserBackground
    $Host.UI.RawUI.ForegroundColor = $UserForeground

} 

#Modules to Import

Import-Module ActiveDirectory -Force

#Change to Starting working directory
#Update the working directory to the working directory of your choice

$WorkingDirectory = 'C:\'

if (!(Test-Path $WorkingDirectory)){

    New-Item -Type Directory -Path $WorkingDirectory -ForegroundColor
    cd $WorkingDirectory

} else {

    cd $WorkingDirectory
}

#Aliases

Set-Alias -Name claer -Value clear

#Functions
#Base64-Encode: Encode strings into base64 encoded strings

function Base64-Encode {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$InputObject
    )

    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$InputObject"))
    
}

#Base64-Decode: Decode base64 encoded strings

function Base64-Decode {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $InputObject
    )

    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$InputObject"))

}

#URL-Encode: Encode strings into URL encoded strings
function URL-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $InputObject
    )

    [System.Web.HttpUtility]::UrlEncode($InputObject)
}

#URL-Decode: Decode URL encoded strings
function URL-Decode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $InputObject
    )

    [System.Web.HttpUtility]::UrlDecode($InputObject)
    
}

#Hex-Encode: Encode strings into hex encoded strings
function Hex-Encode{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
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
        [Parameter(Position=0,Mandatory=$true)]
        [string] $InputObject
    )

    $SplitInput = $InputObject.Replace(" ","")
    ($SplitInput-split"(..)"|Where-Object{$_}|Foreach-Object{[char][convert]::ToInt16($_,16)})-join""
    
}