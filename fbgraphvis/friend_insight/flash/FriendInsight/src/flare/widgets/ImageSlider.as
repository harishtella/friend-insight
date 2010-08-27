package flare.widgets
{
	import flare.events.SliderEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.filters.DropShadowFilter;

	public class ImageSlider extends Sprite
	{
		protected var track:Sprite;
		protected var marker:Sprite;
        protected var _bmpLeft:Bitmap;
        protected var _bmpRight:Bitmap;		

		protected var _enabled:Boolean = true;
		protected var _percent:Number = 0;

		public function ImageSlider(bmpLeft:Bitmap, bmpRight:Bitmap)
		{
			_bmpLeft = bmpLeft;
			_bmpRight = bmpRight;
			createElements();
		}
		/** Creates and initializes the marker/track elements. */
		protected function createElements():void
		{
			track = new Sprite();
			marker = new Sprite();
			
			var yoffset:Number = (_bmpLeft.height-10)/2;
			track.graphics.beginFill( 0xCCCCCC, 1 );
			track.graphics.drawRoundRect(_bmpLeft.width+5, yoffset, 200, 10, 10, 10);
			track.graphics.endFill();
			
			marker.graphics.beginFill( 0x333333, 1 );
			marker.graphics.drawCircle(_bmpLeft.width+5, yoffset+5, 5);
			marker.graphics.endFill();
			
			marker.addEventListener( MouseEvent.MOUSE_DOWN, markerPress );
			
			_bmpRight.x = _bmpLeft.width + track.width + 10; 
			
			addChild( track );
			addChild( marker );
			addChild(_bmpLeft);
			addChild(_bmpRight);
			
			marker.filters = [new DropShadowFilter(1.5)];
			
			// change the mouse shape	
			buttonMode = true;
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
			_percent = (marker.x - marker.width/2) / (track.width - marker.width);						
		}
		
		// Executed when the marker is pressed by the user.
		protected function markerPress( e:MouseEvent ):void
		{
			marker.startDrag( false, new Rectangle( marker.width/2, 0, track.width - marker.width, 0 ) );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, updatePercent );
			stage.addEventListener( MouseEvent.MOUSE_UP, stopSliding );
		} 
		
		/** Get and set the percentage whichi is a value between 0 and 1. */
		public function get percent():Number { return _percent; }
		public function set percent( p:Number ):void
		{
			if (_enabled) {
				_percent = Math.min( 1, Math.max( 0, p ) );
				marker.x = _percent * (track.width - marker.width) + marker.width/2;			
				dispatchEvent( new SliderEvent( SliderEvent.CHANGE, _percent ) );
			}
		}
		/** Enable and disable this ui. */
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
			var yoffset:Number = (_bmpLeft.height-10)/2;
			marker.graphics.beginFill(c, 1);
			marker.graphics.drawCircle(_bmpLeft.width+5, yoffset+5, 5);
			marker.graphics.endFill();
		}			
	}
}