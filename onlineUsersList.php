<?php
	
	$token = $_GET["token"];
	if($token != 'Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM'){
		exit();
	}

	$interactiveOutput = [];
	exec("who | awk '{print $1}'", $interactiveOutput);
	
	// Use 'ss' to fetch established SSH connections and extract usernames
	$vpnOutput = [];
	exec("ss -tnep | grep ':666 ' | grep ESTAB | awk '{print $6}' | cut -d'=' -f2", $vpnOutput);
	
	// Combine both outputs and deduplicate usernames
	$allUsers = array_merge($interactiveOutput, $vpnOutput);
	$uniqueUsers = array_unique($allUsers);
	
	// Count the unique active SSH users
	$system_usage['ONLINE_USERS_LIST'] = count($uniqueUsers);
	
	// Output the result as JSON
	echo json_encode($system_usage);	
	
?>
