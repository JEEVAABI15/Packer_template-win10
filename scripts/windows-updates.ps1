# Sample script to update Windows
Install-Module PSWindowsUpdate -Force -Scope CurrentUser
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
