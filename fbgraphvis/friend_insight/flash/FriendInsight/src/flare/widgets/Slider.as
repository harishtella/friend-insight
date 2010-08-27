package flare.widgets
{
	import flare.display.TextSprite;
	import flare.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	/**
	* Represents the base functionality for Sliders.
	*
	* Broadcasts 1 event:
	* -SliderEvent.CHANGE
	*/
	public class Slider extends Sprite
	{
		// elements
		protected var track:Sprite;
		protected var marker:Sprite;
		protected var _sliderYOffset:int;
		protected var _sliderXOffset:int;
				
		protected var _percent:Number = 0;
		protected var _enabled:Boolean = true;
		/**
		* Get and set the percentage whichi is a value between 0 and 1.
		*/
		public function get percent():Number { return _percent; }
		public function set percent( p:Number ):void
		{
			if (_enabled) {
				_percent = Math.min( 1, Math.max( 0, p ) );
				marker.x = _percent * (track.width - marker.width);			
				dispatchEvent( new SliderEvent( SliderEvent.CHANGE, _percent ) );
			}
		}
		/**
		* Enable and disable this ui.
		*/
		public function get enabled():Boolean {return _enabled; }
		public function set enabled( e:Boolean ):void
		{
			_enabled = e;
			var c:uint = 0xAAAAAA;
			if (_enabled) {
				c = 0x333333;
				marker.addEventListener( MouseEvent.MOUSE_DOWN, markerPress );
				buttonMode = true;
			} else {
				marker.removeEventListener( MouseEvent.MOUSE_DOWN, markerPress );
				buttonMode = false;				
			}
			marker.graphics.beginFill(c, 1);
			marker.graphics.drawRect(_sliderXOffset, _sliderYOffset, 15, 10);
			marker.graphics.endFill();
		}
		
		/**
		* Constructor
		*/
		public function Slider(text:String=null)
		{
			createElements(text);
		}
		
		// ends the sliding session
		protected function stopSliding( e:MouseEvent ):void
		{
			marker.stopDrag();
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, updatePercent );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stopSliding );
			
			dispatchEvent( new SliderEvent( SliderEvent.CHANGE, _percent ) );
		}
		// updates the data to reflect the visuals
		protected function updatePercent( e:MouseEvent ):void
		{
			e.updateAfterEvent();
			_percent = marker.x / (track.width - marker.width);						
		}
		
		// Executed when the marker is pressed by the user.
		protected function markerPress( e:MouseEvent ):void
		{
			marker.startDrag( false, new Rectangle( 0, 0, track.width - marker.width, 0 ) );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, updatePercent );
			stage.addEventListener( MouseEvent.MOUSE_UP, stopSliding );
		} 
		
		/**
		* Creates and initializes the marker/track elements.
		*/
		protected function createElements(text:String):void
		{
			_sliderXOffset = 0;
			_sliderYOffset = 0;
			if(text) {					
				var ts:TextSprite = new TextSprite(text, new TextFormat("Verdana",14), 
				TextSprite.EMBED);						
				addChild(ts);				
				_sliderYOffset = 6;
				_sliderXOffset = ts.width + 2; 
			}

			track = new Sprite();
			marker = new Sprite();
			
			track.graphics.beginFill( 0xCCCCCC, 1 );
			track.graphics.drawRect(_sliderXOffset, _sliderYOffset, 200, 10);
			track.graphics.endFill();
			
			marker.graphics.beginFill( 0x333333, 1 );
			marker.graphics.drawRect(_sliderXOffset, _sliderYOffset, 15, 10);
			marker.graphics.endFill();
			
			marker.addEventListener( MouseEvent.MOUSE_DOWN, markerPress );
			
			addChild( track );
			addChild( marker );
			
			// change the mouse shape	
			buttonMode = true;
		}
	}
}
