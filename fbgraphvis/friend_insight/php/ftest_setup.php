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

//friends chosen by user in viewAllFriends.php
$f_chosen = (isset($_GET["ids"]) ? 
	unserialize(base64_decode($_GET["ids"])) : 
	Array());
//friends of the friends chosen 
$f_of_f_chosen = Array();

//fetch all UIDS based on fetch type
if ($fetch_type == "all") {
	$friendsUIDS = $facebook->api_client->friends_get();
} else if ($fetch_type == "group") {
	$friendsUIDS = $facebook->api_client->groups_getMembers($fetch_id); 
	$friendsUIDS = $friendsUIDS["members"];
} else if ($fetch_type == "list") {
	$friendsUIDS = $facebook->api_client->friends_get($fetch_id); 
} 

// friends left to pick from 
$friends_left = array_diff($friendsUIDS, $f_chosen);

// if user has chosen some friends 
// get the uids of friends of the friends chosen 
// to get a nicer graph
if (count($f_chosen)) {

	$test_set_1 = Array();
	$test_set_2 = Array();
	foreach ($f_chosen as $f){
		foreach ($friends_left as $lf){
			$test_set_1[] = $f; 
			$test_set_2[] = $lf;
		}
	}

	$test_r = @$facebook->api_client->friends_areFriends($test_set_1,$test_set_2);

	// if our fb api call failed just return error code 500 
	if ($test_r === "") {
		$db->close();
		header('HTTP', true, 500);
		die();
	}

	foreach($test_r as $t){
		if ($t['are_friends'] == 1) {
			if ($k = array_search($t['uid2'], $friends_left)){
				unset($friends_left[$k]);	
				$f_of_f_chosen[] = $t['uid2'];	
			}
		}
	}

	//clean up indicies after any removals above
	$friends_left = array_values($friends_left);
}


//random selection of friends

$f_chosen_c = count($f_chosen);
$f_of_f_chosen_c = count($f_of_f_chosen);
$spaces_left = $dataFetch_friendsNum - $f_chosen_c - $f_of_f_chosen_c;

//for randomly picked friends if we need them
$friends_rand = Array();

if($spaces_left < 0){
	//cut some friends out so were under the limit
	$f_of_f_chosen = array_slice($f_of_f_chosen, 0, $spaces_left); 
} else if ($spaces_left > 0) {
	// we have enough friends left over to pick randomly from 
	if (count($friends_left) > $spaces_left) {
		$rk = array_rand($friends_left, $spaces_left);
		foreach ($rk as $key) {
			$friends_rand[] = $friends_left[$key];
		}
	// not enough left over friends, so we add them all
	} else { 
		$friends_rand = $friends_left; 
	}
}

$friendsUIDS = array_merge($f_of_f_chosen, $f_chosen);
$friendsUIDS = array_merge($friendsUIDS, $friends_rand);

$friendsUIDS1 = $friendsUIDS;
$friendsUIDS2 = $friendsUIDS;
$uidsList1 = array();
$uidsList2 = array();

//prepare lists of UIDS to pass to facebook 
//to check for friendship
array_splice($friendsUIDS1,-1);
foreach ($friendsUIDS1 as $friendsUID1) {
	$friendsUIDS2 = array_splice($friendsUIDS2,1);
	foreach ($friendsUIDS2 as $friendsUID2) {
		$uidsList1[] = $friendsUID1;
		$uidsList2[] = $friendsUID2;
	}
}

//check for friendships amongst friends

$stage = 0 ;
$requestChuckSize = $dataFetch_comparisonsPerCall;
if ((count($uidsList1) < $requestChuckSize) && (count($uidsList2) < $requestChuckSize)) {
	$db->new_ftest_row($user_id,$stage,serialize($uidsList1), serialize($uidsList2));	
	$stage++;
} else {
	$uidsList1chopped = array_chunk($uidsList1, $requestChuckSize);
	$uidsList2chopped = array_chunk($uidsList2, $requestChuckSize);

	while ((count($uidsList1chopped) > 0) && (count($uidsList2chopped) > 0)){
		$testset1 = array_shift($uidsList1chopped);
		$testset2 = array_shift($uidsList2chopped);

		$db->new_ftest_row($user_id,$stage,serialize($testset1), serialize($testset2));	
		$stage++;
	}
}

$db->close();
echo $stage; 

?>
