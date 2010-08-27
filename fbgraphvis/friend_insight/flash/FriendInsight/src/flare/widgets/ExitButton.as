package flare.widgets
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.BitmapAsset;
	
	public class ExitButton extends ImageButton
	{
		private var _url:String;
		//"http://apps.facebook.com/friendinsight/"

		public function ExitButton(bmp:Bitmap, url:String)
		{
			super(bmp);
			_url = url;
			addEventListener(MouseEvent.CLICK, ShowWindow);	                
		}
		
		private function ShowWindow(e:MouseEvent):void
		{
			navigateToURL(new URLRequest(_url), "_self");	   
		}
	}
}