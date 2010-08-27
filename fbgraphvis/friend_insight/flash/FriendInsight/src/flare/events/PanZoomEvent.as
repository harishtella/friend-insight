package flare.events
{
	import flash.events.Event;

	public class PanZoomEvent extends Event
	{
		public static const PZACTIVE:String = "pzactive";
		public static const PZOFF:String = "pzoff";
		
		public function PanZoomEvent(type:String)
		{
			super(type);
		}
		
	}
}