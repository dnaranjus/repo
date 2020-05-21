[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$IP,
   [Parameter(Mandatory=$False)]
   [string]$WARN,
   [Parameter(Mandatory=$False)]
   [string]$CRIT,
   [Parameter(Mandatory=$true)]
   [string]$MAXSPEED,
    [switch]$list = $false,
    [switch]$help = $false
	)

	
	
	
Function get_NetworkInterface_ID ($IP)
{
	$ADAPTADOR=Get-WmiObject Win32_NetworkAdapterConfiguration | select Index, IPAddress, Description | Where-Object {$_.IPaddress -like "*$ip*" }
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
		$ADAPTADOR=get_NetworkInterface_ID($ip)
		if ($ADAPTADOR){

			$ADAPTADOR_DESC = $ADAPTADOR.Description
			$ADAPTADOR_DESC= $ADAPTADOR_DESC -replace "\(", "["
			$ADAPTADOR_DESC= $ADAPTADOR_DESC -replace "\)", "]"
			$ADAPTADOR_DESC= $ADAPTADOR_DESC -replace "\#", "_"	
			$ADAPTADOR_DESC= $ADAPTADOR_DESC -replace "\/", "_"						
			$PERF_ADAPTOR= Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface -ComputerName localhost | Where {$_.Name -eq "$ADAPTADOR_DESC"}
			$BytesReceived = $PERF_ADAPTOR.BytesReceivedPersec *8
			$BytesSent = $PERF_ADAPTOR.BytesSentPersec *8
			
			$WARN_LIMIT = ($MAXSPEED / 100) * $WARN;
			$CRIT_LIMIT = ($MAXSPEED  / 100) * $CRIT;	
			
			$per_use_send = $BytesSent / $MAXSPEED;
			$per_use_received = $BytesReceived / $MAXSPEED;
			if ($BytesSent -gt $CRIT_LIMIT -or $bytesReceived -gt $CRIT_LIMIT){
				Write-Host "CRITICAL: Traffic in: ${BytesReceived},00 bit/s ($per_use_received%), traffic out: ${BytesSent},00 bit/s ($per_use_send%) | traffic_in=${BytesReceived}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED traffic_out=${BytesSent}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED"	
				$salida=2
			}else{
				if ($BytesSent -gt $WARN_LIMIT -or $bytesReceived -gt $WARN_LIMIT){
					Write-Host "WARNING: Traffic in: ${BytesReceived},00 bit/s ($per_use_received%), traffic out: ${BytesSent},00 bit/s ($per_use_send%) | traffic_in=${BytesReceived}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED traffic_out=${BytesSent}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED"	
					$salida=1					
				}else{
					Write-Host "OK: Traffic in: ${BytesReceived},00 bit/s ($per_use_received%), traffic out: ${BytesSent},00 bit/s ($per_use_send%) | traffic_in=${BytesReceived}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED traffic_out=${BytesSent}bit/s;$WARN_LIMIT;$CRIT_LIMIT;0;$MAXSPEED"	
					$salida=0
				}
			}
			exit($salida)
			
		}else{
			Write-Host "UNKNOWN - NOT FOUND INTERFACE WITH IP $ip"
			exit(3)
		}

	}
}
exit(0)
