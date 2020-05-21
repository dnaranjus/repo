$NET_ADAPTER = Get-WmiObject Win32_NetworkAdapterConfiguration | Select IPAddress,macaddress,Description | Where-Object {$_.macaddress -like "*:*"}
$WIN = Get-WmiObject win32_networkadapter | Where-Object {$_.macaddress -like "*:*"}
$NET_PERFORMANCE = Get-WmiObject Win32_PerfFormattedData_Tcpip_NetworkInterface | Select BytesSentPersec, Name,CurrentBandwidth 
Get-WmiObject Win32_PerfRawData_Tcpip_NetworkInterface
 for ($i=0; $i -lt $NET_ADAPTER.length; $i++){
 	write-host $i;
	write-host $NET_ADAPTER[$i].Description;
	write-host $WIN[$i].Name;
	write-host $NET_PERFORMANCE[$i].Name;

 }
$NET_ADAPTER.length
$WIN.length
$NET_PERFORMANCE.length

