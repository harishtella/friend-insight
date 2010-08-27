<?php 
require_once 'fbApi/facebook.php';
require_once 'constants.php';

class PublicationGen
{
	public $message;
	public $attachment;
	public $promptMsg;
	public $actionLinks;
	public $uuid;
	
	public function __construct($gender)
	{
		global $fbDomain;
		global $siteDomain;
		global $an;

		if ($gender == "male") {
			$gender_pronoun = "his";
		} elseif ($gender == "female") {
			$gender_pronoun = "her";
		} else {
			$gender_pronoun = "their";
		}


		$this->message = 'just used Friend Insight.'; 
		$this->attachment = array(
			'name' => 'Friend Insight', 
			'href' => $fbDomain, 
			'caption' => '{*actor*} just used a revolutionary new way to see how ' . $gender_pronoun . ' friends know each other.',
			'description' => 'You can also use Friend Insight right now, its really easy.',
			'media' => array(array('type' => 'image',
					 'src' => $siteDomain . '/php/images/page_image.png',
					 'href' => $fbDomain)));
		$this->attachment = json_encode($this->attachment);

		$this->promptMsg = "Share your thoughts on Friend Insight"; 
		$this->actionLinks = array(array('text' => 'Friend Insight', 'href' => $fbDomain)); 
		$this->actionLinks = json_encode($this->actionLinks);

	}
}



