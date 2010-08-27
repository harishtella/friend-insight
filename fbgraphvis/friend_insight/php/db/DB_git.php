<?php  

// this file is a copy of DB.php with sensitive information removed

class DB {
	
	public function __construct() {

		$db = 'removed for security';
		$dbLoc = 'removed for security';
		$dbUser = "removed for security";
		$dbPw = 'removed for security';

		$this->dbcnx = mysql_connect($dbLoc, $dbUser, $dbPw);
		if (!$this->dbcnx) {
		  echo( "<P>Unable to connect to the " .
				"database server at this time.</P>" );
		  echo("<P>" . mysql_error() . "</P>");
		  exit();
		}
		mysql_select_db("friendin_db");
     }

	function close() {
		mysql_close($this->dbcnx);
	}
                
	function get_all_results($uid){
		$query = "SELECT result FROM ftest_uids WHERE uid='$uid'";
		if ($result = mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

		$results_array = array(); 	
		while ($row = mysql_fetch_assoc($result)){
		 $results_array[] = $row["result"];
		}

		mysql_free_result($result);

		return $results_array;
	}



	function get_result($uid, $stage){
		$query = "SELECT result FROM ftest_uids WHERE uid='$uid'
		AND stage='$stage'";
		if ($result = mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

		return mysql_fetch_assoc($result);

		mysql_free_result($result);
	}


	function get_uids($uid, $stage){
		$query = "SELECT left_uids,right_uids FROM ftest_uids WHERE uid='$uid'
		AND stage='$stage'";
		if ($result = mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

		return mysql_fetch_assoc($result);

		mysql_free_result($result);

	}



	function remove_user_ftest_data($uid){
		$query = "DELETE FROM ftest_uids WHERE uid='$uid'";
		if (mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

	}

	function add_ftest_result($uid,$stage,$result){
		$query = "UPDATE ftest_uids SET result='$result' WHERE uid='$uid'
		AND stage='$stage'";

		if (mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

	}


	function new_ftest_row($uid,$stage,$left_uids,$right_uids){

		$query = "INSERT INTO ftest_uids (uid,stage,left_uids,right_uids) VALUES
		('$uid','$stage','$left_uids','$right_uids')";

		if (mysql_query($query, $this->dbcnx))
		{
			//echo("<P>db ok</P>");
		} else {
			//echo("<P>Error with db" . mysql_error() . "</P>");
		}

	}
}

?>
