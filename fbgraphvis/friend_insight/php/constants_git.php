<?php

//this files is a copy of 'constants.php' with sensitive information removed
// constants.php is imported in the rest of the php files used in the project. 


//turn error reporting on all our files for now
error_reporting(E_ALL); 
ini_set("display_errors", 1);
ini_set("session.save_path", dirname(__FILE__)."/sessions");

$siteDomain = 'http://friendinsight.web.cs.illinois.edu/friend_insight';
$fbDomain = 'http://apps.facebook.com/friendinsight';
$appName = 'Friend Insight';

//given by facebook
$appapikey = '84b11f18cffaa6c5ce867b414a77d95f';
$appsecret = 'removed for security';
$appid = '104328553894';

//app folder structure 
$friendshipsDir = "../output_friendships/";
$jsonDir = "../output_json/";
$bchierarchyPath = "../bchierarchy/main";

//url structure
$graph_loader_url = $siteDomain . "/php/friend_graph_loader.php";
$css_url = $siteDomain . "/php/stylesheets/indexStyle.css?v=5.5";
$pic_url = $siteDomain . "/php/images/";
$invite_url = "invite.php";

//constants for friend_graph_data_fetch.php
// and viewFriendsAll.php
$dataFetch_friendsNum = 200;
$dataFetch_comparisonsPerCall = 3000;
?>
