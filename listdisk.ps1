$VAR=Get-WMIObject -Class Win32_logicaldisk 

#if ($VAR.lenght == "")
   #
if (!$VAR.LENGTH){
	write-host $VAR.Deviceid
}else{
	for ($i=0; $i -lt $VAR.length; $i++){
		write-host $VAR[$i].Deviceid

	 }
}
WRITE-HOST ""
exit 0