Write-Host "Hello, World!"
function set_pre{
	write-host("IN FUNCTION")
	$var="gi"
	write-host($var)
	if($var -eq 456789){
	return $var}
	else{
	$policy_list = Get-ExecutionPolicy -List
	write-host($policy)
	foreach($policy in $policy_list){
		write-host($policy.Scope,$policy.ExecutionPolicy)
	}
}
}

$fun_rt=set_pre
write-host($fun_rt)
