$VAR = Get-WmiObject Win32_NetworkAdapterConfiguration | Select IPAddress | Where-Object {$_.IPaddress -like "*.*"}

 for ($i=0; $i -lt $VAR.length; $i++){
	write-host $VAR[$i].Ipaddress[0]":";

 }
exit 0
