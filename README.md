## DFIR-PowerShell-Profile

This PowerShell profile was created to assist with common DFIR related tasks in Windows PowerShell. The intent was to give more of a Bash feel for what can be done at the commandline without having to move to a Linux machine. This is also a good profile to implement into a Windows analysis machine for common analysis commandline tools.

### Installation

There are a couple of methods that you can use to install the DFIR PowerShell Profile

#### Method 1: Use the Setup Script (Preferred)

Run Setup.ps1 from the install directory and the setup will occur automatically.

#### Method 2: Dot Source the repo from your chosen installation location

Clone (or download) this repo to a location of your choosing.

Open or create the file `Microsoft.PowerShell_profile.ps1` located in `C:\Windows\System32\WindowsPowerShell\v1.0\`

Add the following line: `. C:\Path\to\repo\install\directory\Microsoft.PowerShell_profile.ps1`

The next time you load a PowerShell session, the DFIR PowerShell Profile will be dot sourced by the main profile and all will be loaded accordingly. Additionally, you can seamlessly update and modify the profile and config file without needing admin privileges.

#### Method 3: Place the DFIR PowerShell Profile into `C:\Windows\System32\WindowsPowerShell\v1.0`

Clone (or download) this repo to a location of your choosing.

Copy the `Microsoft.PowerShell_profile.ps1` and corresponding config file to `C:\Windows\System32\WindowsPowerShell\v1.0\`

The next time you load a PowerShell session, the DFIR PowerShell profile will be loaded. Keep in mind that each time you need to edit or update the profile, you will need to replace it (which usually requires admin privileges)

## DFIR PowerShell Profile Details

### Configuration Section

#### Shell Colors
Allows you to specifiy the shell colors associated with administrator and user shells

#### Working/Startup Directory
Allows you to specify the directory that PowerShell will move to after loading the profile

#### Modules to Import
Allows you to specify what modules are loaded by PowerShell. Each module should be added to the array as a hashtable with key value pairs representing parameters and the deisred parameter values. 

Example: Adding `@{Name=ActiveDirectory;ErrorAction=SilentlyContinue}` to the `$ImportModules` array would result in the following PowerShell command being executed by the profile import: `Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue -Force`

#### Aliases
Allows you to create aliases to use during your PowerShell session. Each alias should be added to the array as a hashtable with key values pairs representing the `Name` and `Value` for the alias.

Example: Adding `@{Name = 'claer';Value='clear'}` to the `$Aliases` array would result in the following PowerShell command being executed via the profile import: `Set-Alias -Name 'claer' -Value 'clear'`

### Functions

#### Encoding and Decoding Functions

##### `Base64-Encode`: Encode strings into base64 encoded strings

Example: `Base64-Encode 'Asymmetric Info Sec Rocks - Checkout Power-Response!'` 

Result: `QQBzAHkAbQBtAGUAdAByAGkAYwAgAEkAbgBmAG8AIABTAGUAYwAgAFIAbwBjAGsAcwAgAC0AIABDAGgAZQBjAGsAbwB1AHQAIABQAG8AdwBlAHIALQBSAGUAcwBwAG8AbgBzAGUAIQA=`

##### `Base64-Decode`: Decode base64 encoded strings

Example: `Base64-Decode QQBzAHkAbQBtAGUAdAByAGkAYwAgAEkAbgBmAG8AIABTAGUAYwAgAFIAbwBjAGsAcwAgAC0AIABDAGgAZQBjAGsAbwB1AHQAIABQAG8AdwBlAHIALQBSAGUAc
wBwAG8AbgBzAGUAIQA=`

Result: `'Asymmetric Info Sec Rocks - Checkout Power-Response!'`

##### `URL-Encode`: Encode strings into URL encoded strings

Example: `URL-Encode 'Asymmetric Infosec Rocks!'`

Result: `Asymmetric+Infosec+Rocks!`

##### `URL-Decode`: Decode URL encoded strings

Example: `URL-Decode 'Asymmetric+Infosec+Rocks!'`

Result: `Asymmetric Infosec Rocks!`

##### `Hex-Encode`: Encode strings into hex encoded strings

Example: `Hex-Encode 'Hack all the things'`

Result: `4861636B20616C6C20746865207468696E6773`

##### `Hex-Decode`: Decodes Hexidecimal encoded strings

Example: `Hex-Decode 4861636B20616C6C20746865207468696E6773`

Result: `Hack all the things`

#### Timestamp Conversions

##### `Convert-ToEpoch`: Convert human readable date and time to Epoch timestamp (All timestamps assume UTC)

Example: `Convert-ToEpoch $(Get-Date)`

Result: `1567592252`

##### `Convert-FromEpoch`: Converts from Epoch timestamp to human readable timestamp (All timestamps assume UTC)

Example: `Convert-FromEpoch 1567592252`

Result: `Wednesday, September 4, 2019 10:17:32`

##### `Convert-ToMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

Example: `Convert-ToMsftFileTime $(Get-Date)`

Result: `132120659970000000`

##### `Convert-FromMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

Example: `Convert-FromMsftFileTime 132120659970000000`

Result: `Wednesday, September 4, 2019 10:19:57`

##### `Defang-URL`/`Defang-IP`/`Defang-Domain`: Converts URL, IP address, or domain to defanged version

Example: `Defang-URL http://malicious.domain.com`

Result: `hxxp://malicious[.]domain[.]com`

Example: `Defang-IP 10.100.200.237`

Result: `10[.]100[.]200[.]237`

Example: `Defang-Domain malicious.domain`

Result: `malicious[.]domain`

##### `Refang-URL`/`Refang-IP`/`Refang-Domain`: Converts URL, IP address, or domain to fanged version from defanged version

Example: `Refang-URL hxxp://malicious[.]domain[.]com`

Result: `http://malicious.domain.com`

Example: `Refang-IP 10[.]100[.]200[.]237`

Result: `10.100.200.237`

Example: `Refang-Domain malicious[.]domain`

Result: `malicious.domain`

#### API Based Functions 

##### `Whois`: Performs a whois lookup using an XML WhoIs API (https://www.whoisxmlapi.com) (500 queries free, but plans are really cheap afterwards)

Example: `WhoIs -Domain example.com`

##### `DNSLookup`: Performs a DNS lookup for a domain without the query originating from your domain/location (gets all DNS records available) using an XML DNS API (https://www.whoisxmlapi.com) (500 queries monthly are free, but plans are really cheap as well) NOTE: Consider your level of OPSEC before using this function!

Example: `DNSLookup -Domain example.com`

### Alaises ###

##### `Claer`: Alias for `Clear` #####
