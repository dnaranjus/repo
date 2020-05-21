[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$IP,
   [Parameter(Mandatory=$True)]
   [string]$MAXSPEED,

    [switch]$list = $false,
    [switch]$help = $false
	)

	
	
	
Function get_NetworkInterface_ID ($IP)
{
	$ADAPTADOR=Get-WmiObject Win32_NetworkAdapterConfiguration | select Index, IPAddress, Description | Where-Object {$_.IPaddress -eq $ip }
	return $ADAPTADOR
}

if ($help) {
	Write-Host "./prueba -IP <ipaddr> -MAXSPEED <speed> [-list] [-help]"
	Write-Host "	ipaddr:	IP de la tarjeta"
	Write-Host "	speed: 	Velocidad de la tarjeta"
	Write-Host "	list: 	Listado de IPs"
	
}else{
	if ($list) {
		$LISTADOIF=Get-WmiObject Win32_NetworkAdapterConfiguration | select Index, Description, IPAddress | Where-Object {$_.IPaddress -like "*.*.*.*" }
		if ($LISTADOIF){
			if (!$LISTADOIF.LENGTH){
					$index = $LISTADOIF.Index
					$desc= $LISTADOIF.Description
					$ip = $LISTADOIF.IPAddress
				Write-Host "($index;$ip;$desc)"				
			}else{
				for($i=0; $i -lt $LISTADOIF.length; $i++){
					$index = $LISTADOIF[$i].Index
					$desc= $LISTADOIF[$i].Description
					$ip = $LISTADOIF[$i].IPAddress
					Write-Host "($index;$ip;$desc)"				
				}			
			}
		}

	
	 } else {
		Write-Host "$IP -- $MAXSPPED"
		$ADAPTADOR=get_NetworkInterface_ID($ip)

		if ($ADAPTADOR){

			$ADAPTADOR_DESC = $ADAPTADOR.Description
			$PERF_ADAPTOR= Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface -ComputerName localhost | Where {$_.Name -eq "$ADAPTADOR_DESC"}
			$BytesReceived = $PERF_ADAPTOR | % {$_.BytesReceivedPersec}
			$BytesSent = $PERF_ADAPTOR | % {$_.BytesSentPersec}
			Write-Host "OK: Traffic in: ${BytesReceived},00 bit/s (0,00%), traffic out: ${BytesSent},00 bit/s (0,00%) | traffic_in=${BytesReceived}bit/s;0;10000000000 traffic_out=${BytesSent}bit/s;0;10000000000"	
			exit(0)
		}else{
			Write-Host "UNKNOWN - NOT FOUND INTERFACE WITH IP $ip"
			exit(2)
		}

	}
}




