package flare.widgets
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ImageButton extends Sprite
	{
        protected var _rect:Sprite;
        protected var _bmp :Bitmap;
		public var selColor:uint     = 0xff0000;
		public var hoverColor:uint   = 0xff7777;

		public function ImageButton(bmp:Bitmap)
		{
			_bmp = bmp;
			createElements();			
			buttonMode = true;
          	addEventListener(MouseEvent.MOUSE_DOWN, shadebutton);
          	addEventListener(MouseEvent.CLICK, unshadebutton);
          	addEventListener(MouseEvent.MOUSE_OUT, unshadebutton);
          	addEventListener(MouseEvent.MOUSE_OVER, shadebutton);
		}
		/** * Creates and initializes the box elements. */
		protected function createElements():void
		{
			addChild(_bmp);
			addChild(_rect = new Sprite());			
		}
		
		private function shadebutton(e:MouseEvent):void{
			var c:uint = e.buttonDown ? selColor : hoverColor;
          	_rect.graphics.clear()
          	_rect.graphics.lineStyle(2, c);	          	
            _rect.graphics.drawRoundRect(0, 0, _bmp.width, _bmp.height, 5, 5);
            _rect.graphics.endFill();
        }
          
        private function unshadebutton(e:MouseEvent):void{
          	_rect.graphics.clear()
        }
	}
}