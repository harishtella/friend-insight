<?php
// 
// Application: GraphVis
// File: 'viewGroups.php' 
//
// created by Harish Tella 
// on August 3, 2009
// 
require_once 'fbApi/facebook.php';
require_once 'constants.php';
require_once 'publicationGen.php';

//fb login
$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();
//handle session work
$session_key_hash = md5($facebook->api_client->session_key);
session_id($session_key_hash);
session_start();
session_unset(); 

//initialize basic user info using preloaded FQL
$pfql = $facebook->get_valid_fb_params($_POST, null, 'fb_sig');
$userinfo = null;
if (array_key_exists("userinfo", $pfql)){ $userinfo = json_decode($pfql["userinfo"]); } 
if ($userinfo != null){
	$user_name = $userinfo[0][0];
	$gender = $userinfo[0][1];
} else {
	$user_name = "Somebody"; 
	$gender = "he/she";
}

//FQL query that gets all data needed for page
$fqlQuery = '
{"flists": "SELECT flid, name FROM friendlist WHERE owner=' . $user_id . '", 
"fluids" : "SELECT flid,uid FROM friendlist_member WHERE flid IN (SELECT flid FROM #flists)",
"flnames": "SELECT name, uid FROM user WHERE uid IN (SELECT uid FROM #fluids)"}';
$fqlResponse = $facebook->api_client->fql_multiquery($fqlQuery);
foreach ($fqlResponse as $fqlR){
	$respName = $fqlR["name"];
	if ($respName == "flists") { $flists = $fqlR["fql_result_set"]; } else
	if ($respName == "fluids") { $fluids = $fqlR["fql_result_set"]; } else
	if ($respName == "flnames") { $flnames = $fqlR["fql_result_set"]; } 
}

//process the fqlresult into structure easy for printing
//assoc array indexed with flist name 
//[friendlistname]->flid
//[friendlistname]->Array( of names of friends in list)
$friendListsFinal = null;
if($flists != null) {
	$flistsPost = Array();
	foreach ($flists as $flist){
		$flistsPost[$flist["name"]] = $flist["flid"];
	}
	$fluidsPost = Array();
	foreach ($fluids as $fluid){
		if(array_key_exists($fluid["flid"], $fluidsPost) == false){
			$fluidsPost[$fluid["flid"]] = Array();
		}
		$fluidsPost[$fluid["flid"]][] = $fluid["uid"];	
	}
	$flnamesPost = Array();
	foreach ($flnames as $flname){
		$flnamesPost[$flname["uid"]] = $flname["name"];
	}
	$friendListsFinal = Array();
	foreach($flistsPost as $flname => $flid){
		$friendListsFinal[$flname] = Array();
		$friendListsFinal[$flname]["friends"] = Array();
		$friendListsFinal[$flname]["flid"]= $flid; 
		$curfluids = $fluidsPost[$flid]; 
		foreach ($curfluids as $curfluid){
			$friendListsFinal[$flname]["friends"][] = $flnamesPost[$curfluid];
		}
	}
}

//create the publication fields to be used in post_to_stream (javascript)
$pubGen = new PublicationGen($gender);
?>

<fb:fbml>
<link rel="stylesheet" type="text/css" media="screen" href="<?php echo $css_url; ?>"/>
<?php include 'dashboard.php' ?>
<div style='margin: 0.1em 1em 1em;'>

	<script>
		function post_to_stream(){
			var message = "<?php echo $pubGen->message; ?>"; 
			var attachment = <?php echo $pubGen->attachment; ?>;
			var promptMsg =  "<?php echo $pubGen->promptMsg; ?>";
			var actionLinks = <?php echo $pubGen->actionLinks; ?>;
			Facebook.streamPublish(message, attachment, actionLinks, null, promptMsg );
		}

		function load_graph(selection_id){
				document.getElementById("selection_id").setValue(selection_id);	
				document.getElementById("graph_loader_form").submit();
		}
	</script>

	<form name="graph_loader_form" id="graph_loader_form" method="POST" action="<?php echo $graph_loader_url ?>">
		<input type=hidden name=type value=list> 
		<input type=hidden id=selection_id name=selection_id value=-1> 
	</form>

	<div id="group_choices">
			<?php 
			if (is_array($friendListsFinal)){
				echo "<div align=center>which friend list do you want to visualize?</div><p/>";
				foreach ($friendListsFinal as $flistname => $flistinfo) {
					$flid = $flistinfo["flid"];
					echo "<div id=\"flist_listing\">";

					echo "<div id=\"flist_name\">";
					echo "<a href=\"#\" onClick=\"load_graph($flid); return false;\">";
					echo "» " . $flistname . "<br/>";
					echo "</a>";
					echo "</div>";

					echo "<div id=\"flist_names\">";
					$namesString = "";
					foreach ($flistinfo["friends"] as $name){
						$namesString .= $name . ", ";
					}
					$namesString = substr($namesString, 0, -2);
					echo $namesString . "<br/><br/>";	
					echo "</div>";
					
					echo "</div>";
				} 
			} else {
				echo "<div align=center>you haven't created any friend lists</div><p/>";
			}
			?>
	</div>

</div>
</fb:fbml> 


