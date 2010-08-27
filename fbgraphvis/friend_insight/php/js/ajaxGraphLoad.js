$(document).ready(function(){
	var loader_file = siteDomain + "/php/friend_graph_data_fetch.php"; 
	var graph_url =  siteDomain + "/flash/graph.php?sk=" + sk;
	var debug_win = null;
	$.get(loader_file, fb_sig_params , onSuccessful , "text" );
	function onSuccessful(data) {
		debug_win = window.open('','DebugWindow', 'width=600,height=600');
		debug_win.document.open();
		debug_win.document.write(data);
		debug_win.document.close();

		window.location.replace(graph_url);
	};

	//XXX add on failure mode that returns an error page
}); 
