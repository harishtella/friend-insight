<?php
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
if (array_key_exists("userinfo", $pfql)){ 
	$userinfo = json_decode($pfql["userinfo"]); 
} 
if ($userinfo != null){
	$user_name = $userinfo[0][0];
	$gender = $userinfo[0][1];
} else {
	$user_name = "Somebody"; 
	$gender = "he/she";
}

// create the publication fields to be used in post_to_stream call (fbjs) 
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
	
	<p>
		Type in a few friends' names you want to see in your graph
		<br/>
		or just click "Insight!" and we'll choose friends for you.
	</p>

	<form name="graph_loader_form" id="graph_loader_form" method="POST"
	action="<?php echo $graph_loader_url?>">
		<input type=hidden name=type value=all> 
		<input type=hidden id=selection_id name=selection_id value=-1> 
		<fb:multi-friend-input width="500px" max="100" />
	</form>

	<br/>
	<br/>
	<a class="fb_button" href="#" onClick="load_graph(-1); return false;">Insight!</a>

</fb:fbml>
