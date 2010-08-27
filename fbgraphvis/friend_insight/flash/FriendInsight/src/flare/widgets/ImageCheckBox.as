package flare.widgets
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flare.events.CheckBoxEvent;

	public class ImageCheckBox extends Sprite
	{
        protected var _rect:Sprite;
        protected var _bmp :Bitmap;
		protected var _checked:Boolean = false;
		protected var _enabled:Boolean = true;
		public var selColor:uint     = 0xff0000;
		public var hoverColor:uint   = 0xff7777;
		public var disableColor:uint = 0xcccccc;
		
		public function ImageCheckBox(bmp:Bitmap)
		{
			_bmp = bmp;
			createElements();
			buttonMode = true;
          	addEventListener(MouseEvent.MOUSE_DOWN, mousedown);          	
          	addEventListener(MouseEvent.MOUSE_OUT, mouseout);
          	addEventListener(MouseEvent.MOUSE_OVER, mouseover);
		}
		/** Creates and initializes the box elements. */
		protected function createElements():void
		{
			addChild(_bmp);
			addChild(_rect = new Sprite());			
		}

		/** Whether the box is checked */
		public function get checked():Boolean { return _checked; }
		public function set checked( c:Boolean ):void 
		{ 
			if (_enabled && c!=_checked) {				
				if (c) {
					shadebutton(selColor);				
				}
				else {
					_rect.graphics.clear()					
				}
				_checked = c;
				// event
				dispatchEvent( new CheckBoxEvent( CheckBoxEvent.CHANGE, _checked) );
			}
		}
		
		/** Enable and disable the check box */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled( e:Boolean ):void
		{
			if (e != _enabled) {
				if (e) {				
					_rect.graphics.clear()					
		          	addEventListener(MouseEvent.MOUSE_DOWN, mousedown);          	
	          		addEventListener(MouseEvent.MOUSE_OUT, mouseout);
	          		addEventListener(MouseEvent.MOUSE_OVER, mouseover);
					buttonMode = true;
				} else {
					//disable clears the state as well
					checked = false;
					shadebutton(disableColor);
		          	removeEventListener(MouseEvent.MOUSE_DOWN, mousedown);          	
		          	removeEventListener(MouseEvent.MOUSE_OUT, mouseout);
	    	      	removeEventListener(MouseEvent.MOUSE_OVER, mouseover);
					buttonMode = false;	
				}
				_enabled = e;		
			}	
		} 
		private function shadebutton(color:uint):void{
          	_rect.graphics.clear()
          	_rect.graphics.lineStyle(2, color);	          	
            _rect.graphics.drawRoundRect(0, 0, _bmp.width, _bmp.height, 5, 5);
            _rect.graphics.endFill();
        }        
        private function mousedown(event:MouseEvent):void{
        	checked = !_checked;
        }
        private function mouseover(event:MouseEvent):void{
        	if(_enabled && !_checked) {
        		shadebutton(hoverColor);
        	}
        }
        private function mouseout(event:MouseEvent):void {
        	if(_enabled && !_checked) {
        		_rect.graphics.clear();
        	}
        }
	}
}