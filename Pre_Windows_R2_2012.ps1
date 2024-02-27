#Run this script until get the ' 6. Successfully completed all prerequsites' message

#Set the Prerequisites  which are common in all windows server 
function set_comman_pre
{
	write-host("")
	write-host("")
	write-host("***************** 1. Powershell execution policy is set to RemoteSigned.")
	
	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force 
	$policy_list = Get-ExecutionPolicy -List
	foreach($policy in $policy_list){
		if(($policy.Scope -eq 'LocalMachine') -and ($policy.ExecutionPolicy -eq 'RemoteSigned')){
			write-host("Powershell execution policy set to RemoteSigned successfully !!!")
			$step1='true'
		}
		elseif(($policy.Scope -eq 'LocalMachine') -and ($policy.ExecutionPolicy -eq 'undefined')){
			write-host("Failed to set policy, please try again to set policy")
			return
		}
	} 
	write-host("")
	write-host("")
	write-host("***************** 2. Enable .NET Framework 3.5 using windows features")
	#only for 2008
	Import-Module ServerManager ;Add-WindowsFeature Net-Framework-Core

	#Install-WindowsFeature Net-Framework-Core -source \\network\share\sxs

	$pschild = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse | Get-ItemProperty -name Version,Release -EA 0 | Where { $_.PSChildName -match "^(?!S)\p{L}"} |Select PSChildName, Version | ConvertTo-Json 
	$json_pschild = ConvertFrom-json -InputObject $pschild
	foreach($object in $json_pschild){
	   if ($object.PSChildName -eq 'v3.0'){
		write-host(".NET 3.5 enabled successfully !!!")
		$step2='true'
	 }else{ $step22='false' }
	}
	if($step2 -eq 'fasle'){
		return	
	}
	
	write-host("")
	write-host("")
	write-host("******************* 3. Individual server requirement")
	$windo12 = windows2012
	if($windo12 -eq 'True'){
		write-host("Windows 2012 updated successfully")
		$step3='true'
	} else{ 
		write-host("Failed to update windows 2012")
		return}
		
	write-host("")
	write-host("")
	write-host("***************** 4 .CloudHedge has written a PowerShell script that will ensure all the above prerequisites are met.")
	$result= .\ConfigureRemotingForAnsible.ps1
	$result_expected_script_exec= "Self-signed SSL certificate generated; thumbprint: 986698EE4F9370FE07A62F1D38801625B7E24FAA

	wxf                 : http://schemas.xmlsoap.org/ws/2004/09/transfer
	a                   : http://schemas.xmlsoap.org/ws/2004/08/addressing
	w                   : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
	lang                : en-US
	Address             : http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous
	ReferenceParameters : ReferenceParameters

	Ok.
	"
	$result_after_succ =""
	if(($output -eq $result_expected_script_exec) -or ($result1_after_succ -eq $result)){
		write-host("Script executed successfully !!!")
		$step4='true'
	}
	else{
		write-host("Failed to execute script with following error ",$result)
		write-host("")
		write-host("Script will execute successfully after reboot")
		return
	}
	write-host("")
	write-host("")
	write-host("******************* 5. Run the following command to set the default WinRM configuration values.")
	$result=winrm quickconfig -Force | Out-string
	#$expected_result="WinRM service is already running on this machine.
	#WinRM is already set up for remote management on this computer."
	#write-host($result)
	#If result is equal to expected_result then winrm running else try to run winrm service 

	#(Optional) Run the following command to check whether a listener is running, and verify the default ports.
	$lis_result= winrm e winrm/config/listener | ConvertTo-json

	#The default ports are 5985 for HTTP, and 5986 for HTTPS.
	#Enable basic authentication on the WinRM service.
	#Run the following command to check whether basic authentication is allowed.
	$port_info=winrm get winrm/config/service
	write-host($port_info)
	
	#Run the following command to enable basic authentication.
	winrm set winrm/config/service/auth @{Basic="true"}
	#Run the following command to allow transfer of unencrypted data on the WinRM service.
	winrm set winrm/config/service @{AllowUnencrypted="true"}
	#If the channel binding token hardening level of the WinRM service is set to strict, change its value to relaxed.
	winrm set winrm/config/service/auth @{CbtHardeningLevel="relaxed"}
	#Enable basic authentication on the WinRM client.
	#Run the following command to check whether basic authentication is allowed.
	winrm get winrm/config/client
	#Run the following command to enable basic authentication.
	winrm set winrm/config/client/auth @{Basic="true"}
	#Run the following command to allow transfer of unencrypted data on the WinRM client.
	winrm set winrm/config/client @{AllowUnencrypted="true"}
	#If the WinRM host machine is in an external domain, run the following command to specify the trusted hosts.
	winrm set winrm/config/client @{TrustedHosts="host1, host2, host3"}
	#Run the following command to test the connection to the WinRM service.
	winrm identify -r:http://winrm_server:5986 -auth:basic -u:user_name -p:password -encoding:utf-8
	
	write-host("")
	write-host("")
	if(($step1 -eq'true') -and ($step2 -eq 'true') -and ($step3 -eq 'true') -and ($step4 -eq 'true')){
		write-host("********************************* 6. Successfully completed all prerequsites !!! ******************************")
	}else{
		write-host("Prerequsites not completed")
		write-host("***********************************6. Failed to set prerequisites ***************************************")
		write-host("Reboot system and run script again if this does not work then please check script steps again")
	}

}
function windows2012
{
	write-host("Settings for 2012 started")
	$temp1=""
	$temp2=""
	$x=""
	write-host("   For Windows 2012-R2 install Win8.1AndW2K12R2-KB3191564-x64.msu")#$upd1=wmic qfe | find """KB3191564"""
	$rebootpen = .\Test-RebootRequired.ps1
	#KB3191564 ID found
	if(wmic qfe | find """KB3191564"""){#write-host("")
		write-host("   Updated KB3191564")
		$ps=$PSVersionTable.PSVersion | ConvertTo-json
		$json_com = ConvertFrom-json -InputObject $ps
		if($json_com.Major -eq 5){
			write-host("   Powershell vesion set to 5 ")
			$temp1='true'
		}
		#you have installed update check reboot pending or not
		elseif($rebootpen.RebootIsPending -eq 'True'){
			write-host("   Reboot is pending for windows update please reboot system ,run script onces again after reboot")
			return 
		}	
	}
	#Install updates KB3191564
	else{.\Windows-2012-R2\Win8.1AndW2K12R2-KB3191564-x64.msu /quiet /norestart}
	
	#Install updates KB3154520
	write-host("")
	write-host("   For Windows 2012-R2 install TLS support using this")#$upd2=wmic qfe | find """KB3154520"""
	if(wmic qfe | find """KB3154520"""){
		if($rebootpen.RebootIsPending -eq 'True'){
			write-host("   Reboot is pending for windows update please reboot system ,then try to run script")
			return 
			}
		else{write-host(" Windows 2012-R2 install TLS support updated !!!")
		$temp2='true'}
	}else{
		.\Windows-2012-R2\windows8.1-kb3154520-x64.msu /quiet /norestart
		$rebootpen = .\Test-RebootRequired.ps1
		if($rebootpen.RebootIsPending -eq 'True'){
			write-host("   Reboot is pending for windows update please reboot system ,run script onces again after reboot")
			return 
		}else{ write-host("   Failed to update  windows update")}
	}
	if(($temp1 -eq 'true') -and ($temp2 -eq 'true')){$temp='True'}
	else{$temp='false'}
	return $temp
}