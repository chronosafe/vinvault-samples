<?php
	$url = 'http://api.vinvault.com/api/decodes.json';
	$data = array('vin' => '1D7RB1CT8AS203937', 'auth_token' => 'RLBVPvj8riQmRuPzcT'); // Replace with your token

	// use key 'http' even if you send the request to https://...
	$options = array(
	    'http' => array(
	        'header'  => "Content-type: application/x-www-form-urlencoded\r\nAccept: application/vnd.vindata.v1\r\n",
	        'method'  => 'POST',
	        'content' => http_build_query($data),
	    ),
	);
	
	$context  = stream_context_create($options);
	$result = file_get_contents($url, false, $context);
	$vehicle = nil;
	
	if ($result) {
		$vehicle = json_decode($result);
		$valid = (json_last_error() === JSON_ERROR_NONE);
		var_dump($vehicle);
	}

?>
