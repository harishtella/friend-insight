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

//create the publication fields to be used in post_to_stream (javascript)
$pubGen = new PublicationGen($gender);

//FQL query that gets all data needed for page
$fqlQuery = 'SELECT gid, name, description FROM group WHERE gid in (SELECT gid FROM group_member WHERE uid=' . $user_id .') AND privacy!="secret"';
$fqlResponse = $facebook->api_client->fql_query($fqlQuery);

//process the fqlresult into structure easy for printing
$glist = null;
if($fqlResponse != null) {
	$glist = Array(); 
	foreach ($fqlResponse as $groupinfo) {
		$glist[$groupinfo["name"]] = Array("gid" => $groupinfo["gid"],
			"description" => $groupinfo["description"]);
	}
}
?>

<fb:fbml>
<link rel="stylesheet" type="text/css" media="screen" href="<?php echo $css_url; ?>"/>
<?php include 'dashboard.php' ?>
<div style='margin: 0.1em 1em 1em;'>

	<script>
	<!--
		function post_to_stream(){
			var message = "<?php echo $pubGen->message; ?>"; 
			var attachment = <?php echo $pubGen->attachment; ?>;
			var promptMsg =  "<?php echo $pubGen->promptMsg; ?>";
			var actionLinks = <?php echo $pubGen->actionLinks; ?>;
			Facebook.streamPublish(message, attachment, actionLinks, null, promptMsg);
		}

		function load_graph(selection_id){
				document.getElementById("selection_id").setValue(selection_id);	
				document.getElementById("graph_loader_form").submit();
		}
	//-->
	</script>

	<form name="graph_loader_form" id="graph_loader_form" method="POST" action="<?php echo $graph_loader_url ?>">
		<input type=hidden name=type value=group> 
		<input type=hidden id=selection_id name=selection_id value=-1> 
	</form>

	<div id="group_choices">
		<p/>
			<?php 
			if(is_array($glist)){
				echo "<div align=center>which group do you want to visualize?</div><p/>";
				foreach ($glist as $gname => $ginfo) {
					$gid = $ginfo["gid"]; 
					echo "<div id=\"group_listing\">";
					echo "<div id=\"group_name\">";
					echo "<a href=\"#\" onClick=\"load_graph($gid); return false;\">";
					echo "» " . $gname . "<br/>";
					echo "</a>";
					echo "</div>";
					echo "<div id=\"group_description\">";
					echo $ginfo["description"] . "<br/><br/>";
					echo "</div>";
					echo "</div>";
				} 
			} else {
				echo "<div align=center>you dont belong to any groups</div>";
			}
			?>
	</div>

</div>
</fb:fbml> 


