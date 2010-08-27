<?php 
require_once '../fbApi/facebook.php';
require_once '../constants.php';

//fb login
$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();

$fetch = array('userinfo' => array('pattern' =>
'index.php|viewGroups.php|viewLists.php', 'query' => 'SELECT name, sex FROM user WHERE uid="{*user*}"'), 'friendnames' => array('pattern' => 'viewAllFriends.php', 'query' => 'SELECT uid, name FROM user WHERE uid IN(SELECT uid2 FROM friend WHERE uid1 = "{*user*}")')); 

$facebook->api_client->admin_setAppProperties(array('preload_fql' => json_encode($fetch))); 
$res = $facebook->api_client->admin_getAppProperties(array('preload_fql')); 
var_dump($res); 

?>
