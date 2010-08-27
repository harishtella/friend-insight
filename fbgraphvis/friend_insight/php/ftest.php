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

$stage = $_GET["stage"];

$ftest_uids = $db->get_uids($user_id, $stage);
$l = unserialize($ftest_uids["left_uids"]);
$r = unserialize($ftest_uids["right_uids"]);

$ftest_results = @$facebook->api_client->friends_areFriends($l, $r);

//print_r($ftest_results);
//var_dump($ftest_results);
//echo "<br/><br/>";
//echo sizeof($ftest_results);

// if there was a problem with fb api call we will get empty string
if ($ftest_results === "") {
	$db->close();
	header('HTTP', true, 500);
	die();
}

$db->add_ftest_result($user_id,$stage,serialize($ftest_results));
$db->close();

?>
