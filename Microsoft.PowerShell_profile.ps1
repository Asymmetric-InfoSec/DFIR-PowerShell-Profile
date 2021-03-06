########## DFIR PowerShell Profile ##########

$TmpVerbosePreference = $VerbosePreference
$VerbosePreference = 'Continue'

#--------Begin Configuration Section--------#
$DefaultConfig = @{
    #Shell Colors
    AdministratorBackground = 'DarkBlue'
    AdministratorForeground = 'White'
    UserBackground = 'DarkBlue'
    UserForeground = 'White'

    #Working/Startup Directory
    WorkingDirectory = 'C:\'

    #Modules to import for all users
    ImportModules_AllUsers = @(
        # @{Name='ActiveDirectory'; ErrorAction='SilentlyContinue'; ExecuteCommand='$ENV:ADPS_LoadDefaultDrive = 0'}
    )

    #Modules to import specific to admin context
    ImportModules_AdminUsers = @(
        # @{Name='ActiveDirectory'; ErrorAction='SilentlyContinue'; ExecuteCommand='$ENV:ADPS_LoadDefaultDrive = 0'}
    )

    #Modules to import specific to user context
    ImportModules_NonPrivUsers = @(
        # @{Name='ActiveDirectory'; ErrorAction='SilentlyContinue'; ExecuteCommand='$ENV:ADPS_LoadDefaultDrive = 0'}
    )
    #Aliases
    Aliases = @(
        # @{Name = 'claer';Value='clear'}
    )
    
    #Case directory structure
    Case_Dirs = @('Malware','Logs','Notes','PCAPs')

    #PowerShell Remoting Options
    NoMachineProfile = $true
}
#---------End Configuration Section---------#

#Try to get the config file (if used)
try {

    Import-LocalizedData -BindingVariable 'Config' -BaseDirectory $PSScriptRoot -FileName 'Config.psd1' -ErrorAction 'Stop'
    $DefaultConfig.Keys | Where-Object { $Config.Keys -NotContains $PSItem } | Foreach-Object { $Config.$PSItem = $DefaultConfig.$PSItem}

} catch {

    Write-Verbose -Message "Encountered error: $PSItem"
    Write-Verbose -Message "No config file found, using the default config"
    $Config = $DefaultConfig

}

#PowerShell Remoting Options
$PSSessionOption.NoMachineProfile = $Config.NoMachineProfile

#Web request Options - Limited to all versions of TLS 
[System.Net.ServicePointManager]::SecurityProtocol = "Tls12","Tls11","Tls"

#Aliases
foreach ($Alias in $Config.Aliases) {
    
    Write-Verbose -Message "Creating $($Alias.Name) Alias"
    Set-Alias @Alias

}

#Add System.Web type for URL encoding
try {

    Add-Type -AssemblyName System.Web

} catch {

    Write-Warning 'Could not load type System.Web via Add-Type. URL-Encode and URL-Decode will not be available.'
}

#Modules to Import for all users
foreach ($Module in $Config.ImportModules_AllUsers) {
    if ($Module.ExecuteCommand) {
        Write-Verbose -Message "Executing: '$($Module.ExecuteCommand)'"
        Invoke-Expression -Command $Module.ExecuteCommand
        $null = $Module.Remove('ExecuteCommand')
    }
    Write-Verbose -Message "Importing $($Module.Name) Module"
    Import-Module @Module -Force
}

#Context specific actions
if ($Host.UI.RawUI.WindowTitle -match 'Administrator') {

    $Host.UI.RawUI.BackgroundColor = $Config.AdministratorBackground
    $Host.UI.RawUI.ForegroundColor = $Config.AdministratorForeground

    #Modules to Import specific to Admin users
    foreach ($Module in $Config.ImportModules_AdminUsers) {
        if ($Module.ExecuteCommand) {
            Write-Verbose -Message "Executing: '$($Module.ExecuteCommand)'"
            Invoke-Expression -Command $Module.ExecuteCommand
            $null = $Module.Remove('ExecuteCommand')
        }
        Write-Verbose -Message "Importing $($Module.Name) Module"
        Import-Module @Module -Force
    }

} else {

    $Host.UI.RawUI.BackgroundColor = $Config.UserBackground
    $Host.UI.RawUI.ForegroundColor = $Config.UserForeground

    #Modules to Import specific to non-admin users
    foreach ($Module in $Config.ImportModules_NonPrivUsers) {
        if ($Module.ExecuteCommand) {
            Write-Verbose -Message "Executing: '$($Module.ExecuteCommand)'"
            Invoke-Expression -Command $Module.ExecuteCommand
            $null = $Module.Remove('ExecuteCommand')
        }
        Write-Verbose -Message "Importing $($Module.Name) Module"
        Import-Module @Module -Force
    }
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
    [Alias('ConvertTo-Epoch')]
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
    [Alias('ConvertFrom-Epoch')]
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
    [Alias('ConvertTo-MsftFileTime')]
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
    [Alias('ConvertFrom-MsftFileTime')]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        [DateTime]::FromFileTimeUtc($InputObject)
    }  
}

#Defang-URL/Defang-IP/Defang-Domain: Converts URL, IP address, or domain to defanged version
function Defang-URL{
    [CmdletBinding()]
    [Alias('Defang-IP')]
    [Alias('Defang-Domain')]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        $OutputObject = $InputObject -Replace '\.','[.]' -Replace 'http','hxxp'
        return $OutputObject
    }  
}

#Refang-URL/Refang-IP/Refang-Domain: Converts URL, IP address, or domain to fanged version from defanged version
function Refang-URL{
    [CmdletBinding()]
    [Alias('Refang-IP')]
    [Alias('Refang-Domain')]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string] $InputObject
    )

    process {

        $OutputObject = $InputObject -Replace '\[\.\]','.' -Replace 'hxxp','http'
        return $OutputObject
    }  
}

#XML based WhoIs lookups (https://www.whoisxmlapi.com - 500 free queries, plans are really cheap afterwards)
function WhoIs{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][String]$Domain,
        [Parameter(Mandatory=$false,Position=1)][String]$APIKey=$Config.XMLAPIKey
    )

    process {
        
        if (!$APIKey){

            throw "No API key detected. Add API key to config file and try again."
        }

        $APIBase = 'https://www.whoisxmlapi.com/whoisserver/WhoisService'

        $Uri = "{0}?apiKey={1}&domainName={2}" -f $APIBase,$APIKey,$Domain
        Write-Verbose ("Uri: {0}")

        $Response = Invoke-RestMethod -Uri $Uri -Method Get
        if ($Response.ErrorMessage) {
            throw $Response.ErrorMessage.msg
        }

        $Response.WhoisRecord
    }
}

#XML based DNS lookups (https://www.whoisxmlapi.com - 500 free queries monthly, plans are really cheap afterwards)
function DNSLookup{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)][String]$Domain,
        [String]$APIKey=$Config.XMLAPIKey,
        [string]$Type='_all'
    )

    if (!$APIKey){

        throw "No API key detected. Add API key to config file and try again."
    }

    $APIBase = 'https://www.whoisxmlapi.com/whoisserver/DNSService'

    $Uri = "{0}?apiKey={1}&domainName={2}&type={3}" -f $APIBase,$APIKey,$Domain,$Type
    Write-Verbose ("Uri: {0}")

    $Response = Invoke-RestMethod -Uri $Uri -Method Get
        if ($Response.ErrorMessage) {
            throw $Response.ErrorMessage.msg
        }

    $DNSTypeList = @()
    $DNSTypes = $Response.Dnsdata.Dnsrecords
    $DNSTypes | gm | ? {$_.MemberType -eq 'Property'} | Foreach-Object {$DNSTypeList += $_.Name}

    foreach ($DNSType in $DNSTypeList){

        Write-Host ("{0} records for {1}`n`n" -f $DNSType,$Domain)
        $DNSTypes.$DNSType
    }
}

#Malware Analysis Functions (Use at your own risk)
#Deflates/decompresses B64 memory stream to text
function Malware-DeflateB64MemStream2Text {
	
	param(
	   
       [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
	   [String]$InputObject,

       [Parameter(Position=1,Mandatory=$false)]
       [Switch]$OutputToDisk,

       [Parameter(Position=2,Mandatory=$false)]
       [String]$OutputRoot=((Get-Location).Path)
	)

	process {

        #Get Data from B64 String
		$Data = (New-Object IO.StreamReader(New-Object IO.Compression.DeflateStream([IO.MemoryStream][Convert]::FromBase64String($InputObject),[IO.Compression.CompressionMode]::Decompress)),[Text.Encoding]::ASCII).ReadToEnd()

        #Write to Console
        $Banner = @'

##############
Decoded Data:
##############

'@ 
        Write-Host $Banner
        Write-Host $Data

        #Optionally Output to contents to disk 
        if ($OutputToDisk) {

            #Get UID for output of file 
            $UID = (Get-Date -UFormat %s).Split('.')[0]

            #Output decoded contents to file
            $Data | Out-File ('{0}\Decoded_{1}.txt' -f $OutputRoot, $UID) 
        }
	}
}

#Converts byte streams to bin files for analysis (most common with shellcode discovered in PowerShell commands)
function Malware-Bytes2Bin {

    param (

        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [String]$InputObject,

        [Parameter(Position=1,Mandatory=$false)]
        [Int]$XOR,

        [Parameter(Position=2,Mandatory=$false)]
        [String]$OutputRoot=((Get-Location).Path)

    )

    process{

        #Convert base64 into byte stream
        [Byte[]]$Data = [System.Convert]::FromBase64String($InputObject)

        #If data needs to be XOR'd prior to outputting to bin file
        if ($XOR){

            for ($x = 0; $x -lt $Data.Count; $x++) {
                
                $Data[$x] = $Data[$x] -bxor $XOR
            }
        }

        #Write Output to bin file
        $UID = (Get-Date -UFormat %s).Split('.')[0]
        $BinPath = ('{0}\Decoded_{1}.bin' -f $OutputRoot, $UID)
        [IO.File]::WriteAllBytes($BinPath,$Data)
    }
}

#Creates a case structure for organizing investigation samples, notes, etc.
function Create-Case {

    param (

        [Parameter(Position=0,Mandatory=$true)]
        [String]$Name,

        [Parameter(Position=1,Mandatory=$false)]
        [String]$Path=(Get-Location)

    )

    process{
        #Create parent directory
        try{
            $Parent = ('{0}\{1}' -f $Path,$Name)
            $Null = New-Item -Type Directory -Path $Parent -Force -ErrorAction Stop
        
        }catch{

            throw ("Could not create parent directory at {0}\{1}. Quitting." -f $Path,$Name)
        }

        foreach ($Dir in $Config.Case_Dirs){

            try {

                $Null = New-Item -Type Directory -Path ('{0}\{1}' -f $Parent,$Dir) -Force -ErrorAction Stop
            } catch {

                Write-Warning ("Directory could not be created at {0}\{1}. Create manually if desired." -f $Parent,$Dir)
            }
        }
    }
}

$VerbosePreference = $TmpVerbosePreference

#Clean up created defaultconfig and config variables so they don't appear in session
#Remove-Variable -Name 'Alias','DefaultConfig','Config','Module','TmpVerbosePreference' -Force -ErrorAction 'SilentlyContinue'
