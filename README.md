## DFIR-PowerShell-Profile

This PowerShell profile was created to assist with common DFIR related tasks in Windows PowerShell. The intent was to give more of a Bash feel for what can be done at the commandline without having to move to a Linux machine. This is also a good profile to implement into a Windows analysis machine for common analysis commandline tools.

### Configuration Section ###

#### Shell Colors ####
Allows you to specifiy the shell colors associated with administrator and user shells

#### Working/Startup Directory ####
Allows you to specify the directory that PowerShell will move to after loading the profile

#### Modules to Import ####
Allows you to specify what modules are loaded by PowerShell. Each module should be added to the array as a hashtable with key value pairs representing parameters and the deisred parameter values. 

Example: Adding `@{Name=ActiveDirectory;ErrorAction=SilentlyContinue}` to the `$ImportModules` array would result in the following PowerShell command being executed by the profile import: `Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue -Force`

#### Aliases ####
Allows you to create aliases to use during your PowerShell session. Each alias should be added to the array as a hashtable with key values pairs representing the `Name` and `Value` for the alias.

Example: Adding `@{Name = 'claer';Value='clear'}` to the `$Aliases` array would result in the following PowerShell command being executed via the profile import: `Set-Alias -Name 'claer' -Value 'clear'`

### Functions ###

#### Encoding and Decoding Functions ####

`Base64-Encode`: Encode strings into base64 encoded strings

`Base64-Decode`: Decode base64 encoded strings

`URL-Encode`: Encode strings into URL encoded strings

`URL-Decode`: Decode URL encoded strings

`Hex-Encode`: Encode strings into hex encoded strings

`Hex-Decode`: Decodes Hexidecimal encoded strings

#### Timestamp Conversions ####

`Convert-ToEpoch`: Convert human readable date and time to Epoch timestamp (All timestamps assume UTC)

`Convert-FromEpoch`: Converts from Epoch timestamp to human readable timestamp (All timestamps assume UTC)

`Convert-ToMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

`Convert-FromMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

### Alaises ###

`Claer`: Alias for `Clear`
