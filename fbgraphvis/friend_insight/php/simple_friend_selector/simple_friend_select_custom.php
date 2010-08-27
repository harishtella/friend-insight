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
if (array_key_exists("friendnames", $pfql)){ 
	$friendnames_fql = json_decode($pfql["friendnames"]); 
} 

//process friendnames from preloaded data
$friendnames_by_id = array(); 
foreach ($friendnames_fql as $friendname) {
	$friendnames_by_id[$friendname[0]] = $friendname[1];
}
asort($friendnames_by_id);



//process user name from preloaded data
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

	<p style='margin-top: 0pt; padding-top: 0pt;'>Friend Insight creates a visualization of your social network.</p>

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

		//code for friend selector
		var friends_names = <?php echo json_encode($friendnames_by_id); ?>;
		var friends_num_max = <?php echo $dataFetch_friendsNum; ?>;

		// populates 'friends_names' into select box and alphabetizes 
		function setup_names_options(id){
			for (var uid in friends_names) {
				add_option_bot(id, uid, friends_names[uid]); 
			}
			sort_options_alpha(id);
		}

		// clears left and right select box and calls 'setup_names_options'
		function reset_names_options(id_left, id_right){
			var options_left = 
			document.getElementById(id_left).getElementsByTagName('option');
			var options_right = 
			document.getElementById(id_right).getElementsByTagName('option');
			
			for(var i=0; i < options_left.length; i++) {
				options_left[i].getParentNode().removeChild(options_left[i]);
			}
			for(var i=0; i < options_right.length; i++) {
				options_right[i].getParentNode().removeChild(options_right[i]);
			}
			setup_names_options(id_left);
		}

		// add option to bottom of select box
		function add_option_bot(id, value, text, selected) {
			if (typeof selected == "undefined") {
				selected = false;
			}

			var select = document.getElementById(id);
			var option = document.createElement('option');
			option.setValue(value).setTextValue(text);
			option.setSelected(selected);
			select.appendChild(option);
		}


		// add option to top of select box
		function add_option_top(id, value, text, selected) {
			if (typeof selected == "undefined") {
				selected = false;
			}
			
			var select = document.getElementById(id);
			var first_option = select.getElementsByTagName('option')[0];
			var new_option = document.createElement('option');
			new_option.setValue(value).setTextValue(text);
			new_option.setSelected(selected);
			select.insertBefore(new_option, first_option);
		}

		// sort options alphabetically
		function sort_options_alpha(id) {
			var select = document.getElementById(id);
			var select_options = select.getElementsByTagName('option');
			var opts = [];

			for(var i = 0; i < select_options.length; i++) {
				var cur_id = select_options[i].getValue();  
				var cur_name = friends_names[cur_id];
				var	cur_selected = select_options[i].getSelected();  

				opts.push({id: cur_id, name: cur_name, selected: cur_selected}); 
				select_options[i].getParentNode().removeChild(select_options[i]);
			}

			opts.sort(function (x,y) {return x.name > y.name;});

			for(var i = 0; i < opts.length; i++) {
				add_option_bot(id, opts[i].id,
				opts[i].name, opts[i].selected);
			}
		}

		// unselect everything 
		function unselect_all(id) {
			var select = document.getElementById(id);
			var select_options = select.getElementsByTagName('option');
			for(var i = 0; i < select_options.length; i++) {
				select_options[i].setSelected(false); 
			}
		}

		// remove a single option
		function remove_option(id, value) {
			var options = document.getElementById(id).getElementsByTagName('option');
			for(var i = 0; i < options.length; i++) {
				if(options[i].getValue() == value) {
					options[i].getParentNode().removeChild(options[i]);
					break;
				}
			}
		}

		// move a random selection of options 
		// num_options: to be move to select_to_id
		// doesn't check wether that many will get moved
		function move_random(select_from_id, select_to_id, num_options)
		{
			select_from = document.getElementById(select_from_id);
			select_to = document.getElementById(select_to_id);
			
			for(var i = 0; i < num_options; i++) {
				var avail_opt = select_from.getElementsByTagName('option');

				var rand_opt_index = Math.floor(Math.random()*avail_opt.length);	
				var opt_uid = avail_opt[rand_opt_index].getValue();

				remove_option(select_from_id, opt_uid);
				add_option_bot(select_to_id, opt_uid, friends_names[opt_uid]);
			}
			sort_options_alpha(select_to_id);
		}

		// move selected options 
		function move_selected(select_from_id, select_to_id)
		{
			select_from = document.getElementById(select_from_id);
			select_to = document.getElementById(select_to_id);
			unselect_all(select_to_id);	

			var select_from_opts = select_from.getElementsByTagName('option');
			var opts_selected_ids = [];
			var opts_count = 0;

			// Find the selected Options in reverse order
			// and delete them from the 'from' Select.
			for(var i=select_from_opts.length-1; i>=0; i--)
			{
				if(select_from_opts[i].getSelected())
				{
					opts_selected_ids[opts_count] =
						select_from_opts[i].getValue();
					remove_option(select_from_id, opts_selected_ids[opts_count]);
					opts_count++;
				}
			}

			// Add the selected text/values in reverse order.
			// This will add the Options to the 'to' Select
			// in the same order as they were in the 'from' Select.
			for(i=opts_count-1; i>=0; i--)
			{
				add_option_bot(select_to_id, opts_selected_ids[i],
				friends_names[opts_selected_ids[i]], true);
			}


			// setup everything up 
			sort_options_alpha(select_to_id);
		}

		function getMethods(obj) {
		  var result = [];
		  for (var id in obj) {
			try {
			  if (typeof(obj[id]) == "function") {
				result.push(id + ": " + obj[id].toString());
			  }
			} catch (err) {
			  result.push(id + ": inaccessible");
			}
		  }
		  return result;
		}

		setup_names_options("left_sel");
	</script>

	<a href="#" onclick="move_random('left_sel', 'right_sel', 10); return false;"
	>complete random</a>
	<a href="#" onclick="reset_names_options('left_sel', 'right_sel'); return false;"
	>reset</a>

	<form name="friend_form" id="friend_form" method="POST"
	action="http://graphics.cs.uiuc.edu/friendvis/alpha/php/bg_test_load.php">
		<table border="0">
			<tr>
				<td>
					<select name="left_sel" id="left_sel" size="40" multiple="multiple">
					</select>
				</td>
				<td align="center" valign="middle">
					<input type="button" value="--&gt;"
					 onclick="move_selected('left_sel', 'right_sel');" /><br />
					<input type="button" value="&lt;--"
					 onclick="move_selected('right_sel', 'left_sel');" />
				</td>
				<td>
					<select name="right_sel" id="right_sel" size="40" multiple="multiple">
					</select>
				</td>
			</tr>
		</table>
	</form>

</div>

</fb:fbml> 


