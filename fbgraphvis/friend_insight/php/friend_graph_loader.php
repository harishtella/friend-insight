<?php 
require_once 'fbApi/facebook.php';
require_once 'constants.php'; 

$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();

$session_key_hash = md5($facebook->api_client->session_key);
session_id($session_key_hash);
session_start();

//cant send this unserialized to data_fetch_page
if (isset($_POST['ids'])) { 
	$temp_ar = $_POST['ids'];
	$_POST['ids'] = base64_encode(serialize($temp_ar));
}
//for sending to data_fetch_page
$fb_sig_params_json = json_encode($_POST);
?>

<html>
	<head> 
		<meta http-equiv="PRAGMA" content="NO-CACHE">
		<title>loading....</title> 

		<link rel="stylesheet" type="text/css"
		href="stylesheets/loading_bar.css?v=1.7"/>
		<script type="text/javascript" src="js/jquery-1.3.2.min.js"></script> 
		<script type="text/javascript" src="js/loading_bar.js"></script> 
		<script type="text/javascript">
			
			var sk = "<?php echo $session_key_hash; ?>"; 
			var fb_sig_params = <?php echo $fb_sig_params_json; ?>;
			var siteDomain = "<?php echo $siteDomain; ?>";

			var setup_file = siteDomain + "/php/ftest_setup.php"; 
			var ftest_file = siteDomain + "/php/ftest.php"; 
			var process_file = siteDomain + "/php/ftest_process.php"; 

			var graph_url =  siteDomain + "/flash/graph.php?sk=" + sk;

			var loading_bar = new LoadBar();  

			//center loading bar whenever window is resized
			window.onresize = function(){  
				loading_bar.locate();  
			};  

			// this gets run on page load
			$(document).ready(function(){
				//center the loading bar
				loading_bar.locate();  

				// call ftest_setup.php
				$.ajax({async: false, url: setup_file, data: fb_sig_params, 
				success: start_ftests, error: display_error,
				dataType: "text" });
			});

			function start_ftests(data) {
				var stages = parseInt(data);	
				run_ftests(0, stages, null); 
			};

			// call ftest.php recursively then when done
			// call ftest_process.php
			function run_ftests(cur_stage, last_stage, data){
				loading_bar.setValue(((cur_stage)/last_stage)*100);

				if (cur_stage < last_stage){
					//make a deep copy of fb_sig_params
					var ftest_params = jQuery.extend(true, {}, fb_sig_params);
					//set stage in the paramter set sent to ftest.php
					ftest_params["stage"] = cur_stage;	

					$.ajax({async: false, url: ftest_file, data:
					ftest_params, success: function(data){ run_ftests(
					cur_stage + 1, last_stage, data) }, 
					error: display_error, dataType: "text" });
				} else {
					$.ajax({async: false, url: process_file, data: fb_sig_params ,
					success: goto_graph , error: display_error, dataType: "text"});
				}
			}

			function goto_graph(data){
				window.location.replace(graph_url);
			};

			function display_error(){
				$('#infoLoading').html("<span class='error_small'> oops, something went "
				+ "wrong, please try again</span>");
				$('#infoProgress').html("<span class='error'>XX%</span>");
				$('#loadingSms').html("<span class='error'>ERROR</span>");
				$('#progressBar').css({background:"#FA6C6C"});
			};
		</script>
	</head>
	
	<body> 
		<div id="loadingZone">  
			<div id="loadingSms">
				LOADING  
				<img id="loading" src="images/loading_small.gif" /> 
			</div>
			<div id="infoProgress">0%</div>  
			<br class="clear" />  
			<div id="loadingBar">  
				<div id="progressBar"></div>  
			</div>  
			<div id="infoLoading">
				testing friendships, this could take a couple of minutes
			</div>  
			<br/>
	    </div>  

	</body>
</html> 
