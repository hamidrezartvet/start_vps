<?php
	
	$token = $_GET["token"];
	if($token != 'Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM'){
		exit();
	}

	//here we define system usage report array
	$system_usage = [];

	// Execute the 'who' command to get logged-in users
	$output = [];
	exec("last | grep 'still logged in' | wc -l", $output);
   
	// Check if the command executed successfully
	if ($returnVar !== 0) {
   
	 //here we return error message
	 $system_usage['ONLINE_USERS'] = "Error fetching SSH users.";
	}else{
   
	 //here we return online ssh online users in the system
	 $system_usage['ONLINE_USERS'] = intval($output[0]);
	}

	echo json_encode($system_usage);
?>
