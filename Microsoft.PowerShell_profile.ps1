#Change background if in Admin Session

if ($host.UI.RawUI.WindowTitle -match "Administrator") {

    $host.UI.RawUI.BackgroundColor = "DarkRed"
    $Host.UI.RawUI.ForegroundColor = "White"

}else{

    $host.UI.RawUI.BackgroundColor = "DarkBlue"
    $Host.UI.RawUI.ForegroundColor = "White"

} 

#Import CSIRT workflow modules

Import-Module "C:\Program Files\WindowsPowerShell\Modules\Credential" -force
Import-Module "C:\Program Files\WindowsPowerShell\Modules\ServiceNow" -force
Import-Module "C:\Program Files\WindowsPowerShell\Modules\PhishMe" -force
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Case" -force

#Change to tools directory
cd C:\Tools\

#base64 functions

function base64-encode {
    [CmdletBinding()]
    Param(
    [Parameter(Position=0)]
    [string]$inputobject
    )

    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$inputobject"))
    
}

function base64-decode {
    [CmdletBinding()]
    Param(
    [CmdletBinding()]
    [Parameter(Position=0)]
    [string] $inputobject
    )

    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$inputobject"))

}

#Set alias for clear because I cant type 

Set-Alias -Name claer -Value clear

#Greeting of the day
Write-Host "Ready to do thy bidding, my master"