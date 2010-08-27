<?php
// 
// Application: GraphVis
// File: 'index.php' 
//
// created by Harish Tella 
// on August 3, 2009
// 
require_once 'fbApi/facebook.php';
require_once 'constants.php';

$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();
?>

<fb:fbml>

<link rel="stylesheet" type="text/css" media="screen" href="<?php echo $css_url; ?>"/>
<?php include 'dashboard.php' ?>
<div style='margin: 0.1em 1em 1em;'>

<?php 
	if(isset($_POST["ids"])) { 
		echo "<center>Thank you for inviting ".
			sizeof($_POST["ids"]). " of your friends on <b><a href=\"".
			$fbDomain."/\">".$appName."</a></b>.<br><br>\n"; 
		echo "<h2><a href=\"".$fbDomain."/\">Click here to return to ".
			$appName."</a>.</h2></center>"; 
	} else { 
		// Retrieve array of friends who've already authorized the app. 
		$fql = 'SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1='.
			$user_id.') AND is_app_user = 1'; 
		$_friends = $facebook->api_client->fql_query($fql); 

		// Extract the user ID's returned in the FQL request into a new array. 
		$friendsExclude = array(); 
		if (is_array($_friends) && count($_friends)) { 
			foreach ($_friends as $friend) { 
				$friendsExclude[] = $friend['uid']; 
			} 
		} 

		// Convert the array of friends into a comma-delimeted string. 
		$friendsExclude = implode(',', $friendsExclude); 
		
		// Prepare the invitation text that all invited users will receive. 
		$content = 
			"<fb:name uid=\"".$user_id.
			"\" firstnameonly=\"true\" shownetwork=\"false\"/> has started using <a href=\"".
			$fbDomain."/\">".$appName.
			"</a>, a revolutionary new way to see how your friends know each other. Try it now. Its really easy.\n". 
			"<fb:req-choice url=\"". $facebook->get_add_url()."\" label=\"Check out ".
			$appName."\"/>"; 
?> 

<fb:request-form 
	action="<?php echo $invite_url; ?>" 
	method="post" type="<?php echo $appName; ?>" 
	content="<?php echo htmlentities($content,ENT_COMPAT,'UTF-8'); ?>"> 

	<fb:multi-friend-selector 
		actiontext="Here are your friends who don't have <?php echo $appName; ?> yet. Invite whoever you want." 
		exclude_ids="<?php echo $friendsExclude; ?>" /> 
</fb:request-form> 
<?php } ?> 

</div>
</fb:fbml> 


