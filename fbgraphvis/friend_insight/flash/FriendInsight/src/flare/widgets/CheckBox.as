package flare.widgets
{
	import flare.display.TextSprite;
	import flare.events.CheckBoxEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class CheckBox extends Sprite
	{
		// elements
		protected var _box:Sprite;
		protected var _txt:TextSprite = null;
		protected var _boxYOffset:int;
		protected var _boxXOffset:int;
		protected var _color:uint = 0xCCCCCC;
		// checked
		protected var _checked:Boolean = false;
		protected var _enabled:Boolean = true;

		/**
		* Whether the box is checked
		*/
		public function get checked():Boolean { return _checked; }
		public function set checked( c:Boolean ):void 
		{ 
			if (_enabled) {
				_checked = c;
				if (_checked) {
					_color = 0x333333;				
				}
				else {
					_color = 0xCCCCCC;					
				}
				_box.graphics.beginFill(_color, 1)
				_box.graphics.drawRect(_boxXOffset, _boxYOffset, 10, 10);
				_box.graphics.endFill();
				// event
				dispatchEvent( new CheckBoxEvent( CheckBoxEvent.CHANGE, _checked) );
			}
		}
		
		/**
		* Enable and disable the check box
		*/
		public function get enabled():Boolean { return _enabled; }
		public function set enabled( e:Boolean ):void
		{
			_enabled = e;
			var c:uint = 0xAAAAAA;
			if (_enabled) {
				c = _color;
				_box.addEventListener( MouseEvent.MOUSE_DOWN, boxPress );
				_txt.addEventListener( MouseEvent.MOUSE_DOWN, boxPress );
				_txt.mouseChildren = false;				
				buttonMode = true;
			} else {
				_box.removeEventListener( MouseEvent.MOUSE_DOWN, boxPress );
				_txt.removeEventListener( MouseEvent.MOUSE_DOWN, boxPress );
				_txt.mouseChildren = true;				
				buttonMode = false;	
			}
			_box.graphics.beginFill(c, 1)
			_box.graphics.drawRect(_boxXOffset, _boxYOffset, 10, 10);
			_box.graphics.endFill();
		} 

		public function CheckBox(text:String=null)
		{
			createElements(text);	
		}
		
		/**
		* Creates and initializes the box elements.
		*/
		protected function createElements(text:String):void
		{
			// box X,Y offset because of font size
			_boxXOffset = 0
			_boxYOffset = 0;			
			if (text) {					
				addChild(_txt= new TextSprite(text, new TextFormat("Verdana",14), 
				TextSprite.EMBED));
				_boxYOffset = 6;
				_boxXOffset = _txt.width + 3;
				_txt.addEventListener( MouseEvent.MOUSE_DOWN, boxPress );
				_txt.mouseChildren = false;				
			}
			
			_box = new Sprite();			
			_box.graphics.beginFill(_color, 1);
			_box.graphics.drawRect(_boxXOffset, _boxYOffset, 10, 10);
			_box.graphics.endFill();
			
			_box.addEventListener( MouseEvent.MOUSE_DOWN, boxPress );			
			addChild( _box );
			
			// change the mouse shape	
			buttonMode = true;
		}
		
		// Executed when the box is pressed by the user.
		protected function boxPress( e:MouseEvent ):void
		{			
			checked = !_checked;			
		} 
	}
}