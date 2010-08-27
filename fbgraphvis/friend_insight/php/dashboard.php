<?php require_once 'constants.php'; ?> 

<fb:dashboard>
	<h2>
	<fb:action href='index.php'>Friend Insight</fb:action> 
	<fb:action href='invite.php'>Invite Friends</fb:action> 
	<fb:action href='index.php' onclick='post_to_stream(); return false;' >Share Feedstory</fb:action> 
	<fb:action href='http://www.facebook.com/apps/application.php?id=<?php echo $appid; ?>'>Our Page</fb:action> 
	</h2>
</fb:dashboard> 


