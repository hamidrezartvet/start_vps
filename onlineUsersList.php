<?php
	
	$token = $_GET["token"];
	if($token != 'Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM'){
		exit();
	}

	// Initialize the result array
	$system_usage = [];
	
	// Check if the command to get the count executed successfully
	if ($returnVar !== 0) {
		// Return error message if the command fails
		$system_usage['ONLINE_USERS'] = "Error fetching SSH users.";
	} else {
		// Get the total count of online users
		$system_usage['ONLINE_USERS_COUNT'] = intval($totalOutput[0]);
	
		// Execute the 'last' command to fetch the names of logged-in users
		$userOutput = [];
		exec("last | grep 'still logged in' | awk '{print $1}' | sort | uniq", $userOutput, $returnVar);
	
		if ($returnVar !== 0) {
			// Return error message if the command fails
			$system_usage['online_users_list'] = "Error fetching SSH user names.";
		} else {
			// Get the list of online SSH user names
			$system_usage['online_users_list'] = $userOutput;
		}
	}
	
	// Output the result as JSON
	echo json_encode($system_usage);
	
?>
