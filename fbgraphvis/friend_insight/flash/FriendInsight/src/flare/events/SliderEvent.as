package flare.events
{
	import flash.events.Event;

	public class SliderEvent extends Event
	{
		// events
		public static const CHANGE:String = "change";

		protected var _percent:Number;
		/**
		* Read-Only
		*/
		public function get percent():Number
		{
			return _percent;
		}

		/**
		* Constructor
		*/
		public function SliderEvent(type:String, percent:Number)
		{
			super(type);
			_percent = percent;
		}				
	}


}