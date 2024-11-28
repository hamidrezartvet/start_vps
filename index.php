<?php
	
	$token = $_GET["token"];
	if($token != 'Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM'){
		exit();
	}

	//here we define system usage report array
	$system_usage = [];
	
	//cpu usage
	$stat1 = file('/proc/stat'); 
	sleep(1); 
	$stat2 = file('/proc/stat'); 
	$info1 = explode(" ", preg_replace("!cpu +!", "", $stat1[0])); 
	$info2 = explode(" ", preg_replace("!cpu +!", "", $stat2[0])); 
	$dif = array(); 
	$dif['user'] = $info2[0] - $info1[0]; 
	$dif['nice'] = $info2[1] - $info1[1]; 
	$dif['sys'] = $info2[2] - $info1[2]; 
	$dif['idle'] = $info2[3] - $info1[3]; 
	$total = array_sum($dif); 
	$cpu = array(); 
	foreach($dif as $x=>$y) $cpu[$x] = round($y / $total * 100, 1);
	$system_usage['CPU'] = $cpu['user'];

	//RAM usage
	$free = shell_exec('free');
	$free = (string)trim($free);
	$free_arr = explode("\n", $free);
	$mem = explode(" ", $free_arr[1]);
	$mem = array_filter($mem);
	$mem = array_merge($mem);
	$memory_usage = $mem[2]/$mem[1]*100;
	$system_usage['RAM'] = $memory_usage;

	//hdd usage
	$mountedDirectory = "/";
	$dts = disk_total_space($mountedDirectory );
	$dfs = disk_free_space($mountedDirectory );
	$usedPercent = round(($dts - $dfs) / $dts * 100)."%";
	$system_usage['HDD'] = $usedPercent;
	
	$str   = @file_get_contents('/proc/uptime');
	$num   = floatval($str);
	$secs  = fmod($num, 60); $num = (int)($num / 60);
	$mins  = $num % 60;      $num = (int)($num / 60);
	$hours = $num % 24;      $num = (int)($num / 24);
	$days  = $num;
	$system_usage['UPTIME'] = 'days:'.$days;


	// Execute the 'who' command to get logged-in users
	$output = [];
	exec("who | grep -i 'pts/' | wc -l", $output, $returnVar);

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
