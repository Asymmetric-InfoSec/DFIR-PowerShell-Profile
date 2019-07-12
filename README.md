## DFIR-PowerShell-Profile

This PowerShell profile was created to assist with common DFIR related tasks in Windows PowerShell. The intent was to give more of a Bash feel for what can be done at the commandline without having to move to a Linux machine. This is also a good profile to implement into a Windows analysis machine for common analysis commandline tools.

###Functions###

####Encoding and Decoding Functions####

`Base64-Encode`: Encode strings into base64 encoded strings

`Base64-Decode`: Decode base64 encoded strings

`URL-Encode`: Encode strings into URL encoded strings

`URL-Decode`: Decode URL encoded strings

`Hex-Encode`: Encode strings into hex encoded strings

`Hex-Decode`: Decodes Hexidecimal encoded strings

####Timestamp Conversions####

`Convert-ToEpoch`: Convert human readable date and time to Epoch timestamp (All timestamps assume UTC)

`Convert-FromEpoch`: Converts from Epoch timestamp to human readable timestamp (All timestamps assume UTC)

`Convert-ToMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

`Convert-FromMsftFileTime`: Converts from a human readable data and time to Microsoft FileTime timestamp (All timestamps assume UTC)

###Alaises###

`Claer`: Alias for `Clear`
