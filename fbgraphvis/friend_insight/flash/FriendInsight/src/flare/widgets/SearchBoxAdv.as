package flare.widgets
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class SearchBoxAdv extends Sprite
	{
		public static const SEARCH:String = "search";
		
		private var _input:TextField;
		private var _enter:EnterButton;
		private var _hit:Sprite;
		
		private var _fmt:TextFormat;
		private var _border:Boolean = true;
		private var _editable:Boolean = true;
		private var _borderColor:uint = 0xff0000;
		private var _boxWidth:Number = 200;		
		
		public function get input():TextField { return _input; }
		
		public function get text():String { return _input.text; }
		public function set text(q:String):void { 
			_input.text=q;
		}
		
		public function get editable():Boolean { return _editable; }
		public function set editable(b:Boolean):void {
			_editable = b;
			if (_editable) {	
				_input.text = "Type to search";
				_input.width = _boxWidth;
				_input.autoSize = TextFieldAutoSize.NONE;
				_enter.visible = true;
				border = true;	
			} else {
				border = false; 
				_enter.visible = false; 			
				_input.autoSize = TextFieldAutoSize.LEFT;				
			}
		}
		
		public function get border():Boolean { return _border; }
		public function set border(b:Boolean):void {
			if (b != _border) { _border = b; resize(); }
		}
		
		public function get borderColor():uint { return _borderColor; }
		public function set borderColor(c:uint):void {
			if (c != _borderColor) { _borderColor = c; resize(); }
		}
				
		// --------------------------------------------------------------------
		
		public function SearchBoxAdv(fmt:TextFormat=null, 
			searchBoxWidth:Number=250, searchBoxHeight:Number=20)
		{
			_fmt = fmt ? fmt : new TextFormat();
			init(searchBoxWidth, searchBoxHeight);
		}
		
		protected function init(boxWidth:Number, boxHeight:Number):void
		{		
			// create search box
			_input = new TextField();
			_input.type = TextFieldType.INPUT;
			_input.defaultTextFormat = _fmt;
			_input.selectable = true;
			_boxWidth = boxWidth;
			_input.width = boxWidth;
			_input.height = boxHeight;
			_input.autoSize = TextFieldAutoSize.NONE;
			_input.text = "Type to search";
			_input.wordWrap = false;			
			_input.addEventListener(KeyboardEvent.KEY_DOWN, function (evt:KeyboardEvent):void {
				if(evt.charCode == 13) {
					_enter.selected = true;
					dispatchEvent(new Event(SEARCH));
				}
			});
			_input.addEventListener(KeyboardEvent.KEY_UP, function (evt:KeyboardEvent):void {
				if(evt.charCode == 13) {
					_enter.selected = false;
					_input.setSelection(0, _input.text.length);
				}
			});
			_input.addEventListener(MouseEvent.CLICK, function (evt:MouseEvent):void {
				_input.setSelection(0, _input.text.length);
			});
			addChild(_input);			
			
			// create clear button
			_enter = new EnterButton();
			_enter.visible = true;	
			_enter.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				_input.setSelection(0, _input.text.length);
				dispatchEvent(new Event(SEARCH));
			});
			addChild(_enter);
			
			addChild(_hit = new Sprite());
			_hit.visible = false;
			
			resize();
		}
		
		public function resize():void {
			_input.x = (_border ? 3 : 1);
			_enter.x = _input.x + _input.width + 2;
			_enter.size = _input.height / 2;
			_enter.y = _input.height / 4;
			
			graphics.clear();
			if (_border) drawBorder();
			
			_hit.graphics.clear();
			_hit.graphics.beginFill(0);
			_hit.graphics.drawRect(0, 0, width, height);
			hitArea = _hit;
		}
		
		private function drawBorder():void {
			graphics.lineStyle(2, _borderColor);
			graphics.drawRect(_input.x-3, 0,
				_input.width + 2 +_enter.width + 6,
				_input.height);
		}
			
		private function onSearch(evt:KeyboardEvent):void
		{
			if(evt.charCode == 13) {				
				dispatchEvent(new Event(SEARCH));				
			}
		}	
	} // end of class SearchBoxAdv
}

import flash.display.CapsStyle;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
	
class EnterButton extends Sprite
{
	private var _size:Number = 20;
	private var _defColor:uint = 0x333333;
	private var _selColor:uint = 0xAAAAAA;
	private var _selected:Boolean = false;
	
	public function get size():Number { return _size; }
	public function set size(s:Number):void { _size = s; render(); }
	
	public function get selected():Boolean { return _selected; }
	public function set selected(s:Boolean):void { _selected = s; render(); }
	
	public function get defaultColor():uint { return _defColor; }
	public function set defaultColor(c:uint):void { _defColor = c; render(); }
	
	public function get selectedColor():uint { return _selColor; }
	public function set selectedColor(c:uint):void { _selColor = c; render(); }
	
	public function EnterButton(size:Number=20,
		defaultColor:uint=0x333333, selectedColor:uint=0xAAAAAA)
	{
		_size = size;
		_defColor = defaultColor;
		_selColor = selectedColor;
		buttonMode = true;
		render();
		
		var sel:Function = function(e:Event):void { selected = true; };
		var des:Function = function(e:Event):void { selected = false; };
		addEventListener(MouseEvent.MOUSE_DOWN, sel);
		addEventListener(MouseEvent.MOUSE_UP, des);
	}
	
	private function render():void
	{
		var c:uint = _selected ? _selColor : _defColor;
		graphics.clear();
		graphics.lineStyle(int(_size/5)+1, c, 1, false, "normal", CapsStyle.ROUND);
		graphics.moveTo(_size, 0);
		graphics.lineTo(_size, _size*3/4);		
		graphics.lineTo(0, _size*3/4);
		graphics.lineTo(_size/4, _size/2);
		graphics.moveTo(0, _size*3/4);
		graphics.lineTo(_size/4, _size);
	}
	
} // end of class EnterButton