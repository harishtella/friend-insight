package flare.events
{
	import flash.events.Event;

	public class CheckBoxEvent extends Event
	{
		// events
		public static const CHANGE:String = "change";

		// checked
		protected var _checked:Boolean = false;
	    /**
		* Read-Only
		*/
		public function get checked():Boolean {	return _checked; }

		/**
		* Constructor
		*/
		public function CheckBoxEvent(type:String, c:Boolean)
		{
			super(type);
			_checked = c;
		}		
	}
}