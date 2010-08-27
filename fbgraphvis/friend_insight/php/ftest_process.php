<?php
//
// Application: GraphVis
// File: 'friend_graph_data_fetch.php'
//
// created by Harish Tella
// on July 22, 2009
//
require_once 'fbApi/facebook.php';
require_once 'db/DB.php';
require_once 'constants.php';

$db = new DB();

$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();

$session_key_hash = md5($facebook->api_client->session_key);
session_id($session_key_hash);
session_start();

//the type of data to fetch
$fetch_type = $_GET["type"];
$fetch_id = $_GET["selection_id"];

//fetch UIDS based on fetch type
if ($fetch_type == "all") {
	$friendsUIDS = $facebook->api_client->friends_get();
} else if ($fetch_type == "group") {
	$friendsUIDS = $facebook->api_client->groups_getMembers($fetch_id); 
	$friendsUIDS = $friendsUIDS["members"];
} else if ($fetch_type == "list") {
	$friendsUIDS = $facebook->api_client->friends_get($fetch_id); 
} else {
	//TODO report some error
}

//create array with UID mapped to friend name
$friendNamesResults = $facebook->api_client->users_getInfo($friendsUIDS,"name");
$friendNames = array();
foreach ($friendNamesResults as $friendNamesResult) {
       $friendNames[$friendNamesResult['uid']] =  $friendNamesResult['name'];
}



$ftest_results_merg = array();
$ftest_results = $db->get_all_results($user_id);

foreach ($ftest_results as $ftr){
	$ftest_results_merg = array_merge($ftest_results_merg, unserialize($ftr));
}

//write all the frienship data to a string
$friendshipsFileData = "";
foreach ($ftest_results_merg as $friendshipTestResult) {
	if ( $friendshipTestResult['are_friends'] == 1) {
		$friendshipsFileData .= $friendNames[$friendshipTestResult['uid1']] . "\t" . $friendNames[$friendshipTestResult['uid2']] . "\n";
	}
}


$outputFileName = $user_id . "_" . $fetch_type . "_" . $fetch_id; 

//write the friendship data string to a file
$friendshipsFilePath = $friendshipsDir . $outputFileName . ".txt";
$friendshipsFile = fopen($friendshipsFilePath, 'w'); 
fwrite($friendshipsFile, $friendshipsFileData);
fclose($friendshipsFile);

//convert the plaintext file to json hierarchy
$cmd = $bchierarchyPath;
$args = $friendshipsFilePath . " " . $jsonDir . $outputFileName . ".json";
$result = shell_exec($cmd . " " . $args);


$db->remove_user_ftest_data($user_id);
$db->close();

$_SESSION['filename'] = $outputFileName;
echo "returned foo";

?>
