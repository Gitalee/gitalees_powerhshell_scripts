function set_comman_pre
{
}
function 2008
{
}
function 2012
{
}
function 2016
{
}
# 1. Powershell execution policy is set to RemoteSigned.

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force


$policy_list="
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine    RemoteSigned


" 
$policy = Get-ExecutionPolicy -List
 


$p =Out-String -InputObject $policy
#write-host($policy_list.GetType())

write-host($p)
if ($p -eq $policy_list){

   write-host("policy set")
}

else {
 write-host("1. step policy not set !!!")
}

#2. Enable .NET Framework 3.5 using windows features
Install-WindowsFeature Net-Framework-Core -source \\network\share\sxs

$net = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -recurse | Get-ItemProperty -name Version,Release -EA 0 | Where { $_.PSChildName -match "^(?!S)\p{L}"} |Select PSChildName, Version | ConvertTo-Json 
write-host($net.GetType())
#$array = $net.ToCharArray()
#write-host($array[1])
$json_net = ConvertFrom-json -InputObject $net
#write-host($json_net.PSChildName)
foreach($x in $json_net){
   #write-host($x)
   if ($x.PSChildName -eq 'v3.0'){
	write-host("2. step enable")
 }
}
#***********************************Windows 2008-R2 SP1
#For Windows 2008-R2 SP1 download and install Win7AndW2K8R2-xxxxxxx-x64.zip using
.\Windows-2008-R2-SP1\Install-WMF5.1.ps1
$PSVersionTable.PSVersion
$com=$PSVersionTable.PSVersion | ConvertTo-json

$json_com = ConvertFrom-json -InputObject $com
if($json_com.Major -eq 5){
	write-host("set ps 5")
}

.\windows6.1-kb3154518-x64.msu
#***********************************Windows 2012 R2
#For Windows 2012-R2 download and install Win8.1AndW2K12R2-xxxxxx-x64.msu using this link.
.\Windows-2012-R2\Win8.1AndW2K12R2-KB3191564-x64.msu /quiet
$com=$PSVersionTable.PSVersion | ConvertTo-json

$json_com = ConvertFrom-json -InputObject $com
if($json_com.Major -eq 5){
	write-host("set ps 5")
}

#For Windows 2012-R2 install TLS support using this 
.\Windows-2012-R2\windows8.1-kb3154520-x64.msu 

#******************************Windows 2016
#3. For Windows 2016 download and install windows updates using this link, follow instructions given in install this update section. - Restart after the above updates.
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot


#Install-Module -Name PSWindowsUpdate -Force
#Get-WindowsUpdate –Install -Force

#4. Upon download, remove the ".txt" extension, and save file as "ConfigureRemotingForAnsible.ps1" and execute the script. This script will perform following operations:
$res= .\ConfigureRemotingForAnsible.ps1
$result= "Self-signed SSL certificate generated; thumbprint: 986698EE4F9370FE07A62F1D38801625B7E24FAA

wxf                 : http://schemas.xmlsoap.org/ws/2004/09/transfer
a                   : http://schemas.xmlsoap.org/ws/2004/08/addressing
w                   : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
lang                : en-US
Address             : http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous
ReferenceParameters : ReferenceParameters

Ok.
"
$result_after_succ =""
if(($res -eq $result) -or ($result1_after_succ -eq $res)){
	write-host("4. step success")
}
 
#5. Run the following command to set the default WinRM configuration values.
$a=winrm quickconfig -Force | Out-String
$b="WinRM service is already running on this machine.
WinRM is already set up for remote management on this computer."
write-host($a)
if($a -eq $b){
	write-host("qinrm running")
}
#(Optional) Run the following command to check whether a listener is running, and verify the default ports.
#$x= winrm e winrm/config/listener | Out-String
$y="Listener
    Address = *
    Transport = HTTP
    Port = 5985
    Hostname
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint
    ListeningOn = 127.0.0.1, 169.254.27.225, 169.254.40.246, 169.254.223.25, 169.254.224.186, 169.254.250.90, 192.168.43.54, 192.168.56.1, 192.168.99.1, ::1, 2409:4042:2408:798:bc25:bbb8:c5af:ff6d, 2409:4042:2408:798:edd8:a6b7:804:ed9a, fe80::2859:a3ca:606a:df19%6, fe80::31b2:3ca0:9404:510e%5, fe80::45be:c90b:ad7f:1be1%8, fe80::4d20:e787:78ba:fa5a%19, fe80::b5fa:700:dcc5:e0ba%18, fe80::bc25:bbb8:c5af:ff6d%11, fe80::c520:2188:2c33:28f6%10, fe80::ec6f:fbb2:624c:3e9f%14"
if($x -eq $y){
	write-host("listener running")
}
#The default ports are 5985 for HTTP, and 5986 for HTTPS.
#Enable basic authentication on the WinRM service.
#Run the following command to check whether basic authentication is allowed.
$c=winrm get winrm/config/service
$d="
Service
    RootSDDL = O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
    MaxConcurrentOperations = 4294967295
    MaxConcurrentOperationsPerUser = 1500
    EnumerationTimeoutms = 240000
    MaxConnections = 300
    MaxPacketRetrievalTimeSeconds = 120
    AllowUnencrypted = false
    Auth
        Basic = false
        Kerberos = true
        Negotiate = true
        Certificate = false
        CredSSP = false
        CbtHardeningLevel = Relaxed
    DefaultPorts
        HTTP = 5985
        HTTPS = 5986
    IPv4Filter = *
    IPv6Filter = *
    EnableCompatibilityHttpListener = false
    EnableCompatibilityHttpsListener = false
    CertificateThumbprint
    AllowRemoteAccess = true
"
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

shutdown –r
