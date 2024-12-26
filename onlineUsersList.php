<?php
	
	$token = $_GET["token"];
	if($token != 'Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM'){
		exit();
	}

	// Initialize the result array
	$system_usage = [];
	
	// Execute the 'last' command to fetch the names of logged-in users
	$userOutput = [];
	exec("last | grep 'still logged in' | awk '{print $1}' | sort | uniq", $userOutput, $returnVar);
	
	// Return the list of online SSH user names
	$system_usage['ONLINE_USERS_LIST'] = $userOutput;

	// Output the result as JSON
	echo json_encode($system_usage);	
	
?>
