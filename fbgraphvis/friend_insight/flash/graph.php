<?php 
require_once '../php/constants.php';

$session_key_hash = $_GET['sk'];
session_id($session_key_hash);
session_start();

if(isset($_SESSION["filename"])){
	$filename = $_SESSION["filename"]; 
} else {
	$filename = null ;
	//TODO add error handling
}
?>

<html>
	<head>
		<meta http-equiv="PRAGMA" content="NO-CACHE">
		<title>Friend Insight</title>
		
		<script type="text/javascript" 
			src="<?php echo $siteDomain ?>/php/js/swfobject.js">
		</script>
		<script type="text/javascript" 
			src="<?php echo $siteDomain ?>/php/js/swfmacmousewheel2.js">
		</script>
		<script type="text/javascript">
			var filename = "<?php echo $filename; ?>";
			var flashvars = {};
			var params = {};
			var attributes = {id:'friendinsight', name:'friendinsight'};
			flashvars.filename = filename;
			swfobject.embedSWF("FriendInsight.swf", "flashcontent", "99%", "99%", "10", "expressInstall.swf", flashvars, params, attributes);
			swfmacmousewheel.registerObject(attributes.id);
		</script>
	</head>

	<body>
		<div id="flashcontent">
			Friend Insight graph
		</div>
	</body>
</html>
