package com.goodinson.snapshot
{
	import com.adobe.images.*;
	import com.dynamicflash.util.Base64;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;

	public class Snapshot
	{
		// supported image file types
		public static const JPG:String = "jpg";
		public static const PNG:String = "png";
		
		// supported server-side actions
		public static const DISPLAY:String = "display";
		public static const PROMPT:String = "prompt";
		public static const LOAD:String = "load";
		public static const SAVE:String = "save";
		
		// default parameters
		private static const JPG_QUALITY_DEFAULT:uint = 70;
		private static const PIXEL_BUFFER:uint = 1;
		private static const DEFAULT_FILE_NAME:String = 'FriendInsight.jpg';
		
		// the request containing picture to be sent to server
		private var request:URLRequest;
		private var options:Array;
		private var byteArray:ByteArray;
		private var fr:FileReference;
				
		public function Snapshot()
		{
		}
	
		public function snap(curObj:DisplayObject, action:String, 
							 filename:String = "FriendInsight", format:String = "jpg"):void		
		{	
			this.options = new Array();
			options["filename"] = filename; 
			options["format"] = format; 
			options["action"] = action;	
			this.capture(curObj);
		}
		
		public function getBytes():ByteArray
		{
			return byteArray;
		}
				
		private function capture(target:DisplayObject):void
		{
			var relative:DisplayObject = target.parent;
			
			// get target bounding rectangle
			var rect:Rectangle = target.getBounds(relative);						
			
			// capture within bounding rectangle; add a 1-pixel buffer around the perimeter to ensure that all anti-aliasing is included
			if(rect.width>2000 || rect.height>2000) {
				if (rect.left<0) { rect.width += rect.left; rect.left = 0; }
				if (rect.top<0) { rect.height += rect.top; rect.top = 0; }			
				if (rect.right>2000) { rect.width -= rect.right-2000; rect.right=2000; }
				if (rect.bottom>2000) { rect.height -= rect.bottom-2000; rect.bottom=2000; }			
			}
			
			var target_trans:Matrix = new Matrix(1,0,0,1,-rect.left, -rect.top);
			var bitmapData:BitmapData = new BitmapData(rect.width + PIXEL_BUFFER * 2, rect.height + PIXEL_BUFFER * 2);
						
			// capture the target into bitmapData			
			bitmapData.draw(relative, target_trans);
						
			// encode image to ByteArray
			switch (options["format"])
			{
				case JPG:
				// encode as JPG
				var jpgEncoder:JPGEncoder = new JPGEncoder(JPG_QUALITY_DEFAULT);
				byteArray = jpgEncoder.encode(bitmapData);
				break;
				
				case PNG:
				default:
				// encode as PNG
				byteArray = PNGEncoder.encode(bitmapData);
				break;
			}	
		}
		
		// send image to a server side script
		public function send(serverScriptUrl:String):void
		{
			// convert binary ByteArray to plain-text, for transmission in POST data
			var byteArrayAsString:String = Base64.encodeByteArray(byteArray);

			// constuct server-side URL to which to send image data
			var url:String = serverScriptUrl + '?' + Math.random();
			
			// create URL request
			request = new URLRequest(url);
			
			// send data via POST method
			request.method = URLRequestMethod.POST;
			
			// set data to send
			var variables:URLVariables = new URLVariables();
			variables.filename = options.filename + '.' + options.format;
			variables.format = options.format;			
			variables.action = options.action;
			variables.image = byteArrayAsString;
			request.data = variables;

			// send the post request	
			if (options["action"] == SAVE) {
				//correct way does it in the background
				/*var loader:URLLoader = new URLLoader();
				try {
	    			loader.load(request);
	    		} catch (error:ArgumentError) {
				    trace("An ArgumentError has occurred.");
				} catch (error:SecurityError) {
			    	trace("A SecurityError has occurred.");
				}*/
				//this is wasy is easier for debugging
				//it send post request in a new browser tab
				navigateToURL(request, "_blank");
			}
		}
		
		public function saveToLocal():void
		{
			//create the FileReference instance
			fr = new FileReference();

			//listen for the file has been saved
			fr.addEventListener(Event.COMPLETE, onFileSave);

			//listen for when then cancel out of the save dialog
			fr.addEventListener(Event.CANCEL,onCancel);

			//listen for any errors that occur while writing the file
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

			//open a native save file dialog, using the default file name
			fr.save(byteArray, options.filename + '.' + options.format);
		}
		
		private function onFileSave(e:Event):void
		{
			trace("File Saved");
			fr = null;
		}

		//called if the user cancels out of the file save dialog
		private function onCancel(e:Event):void
		{
			trace("File save select canceled.");
			fr = null;
		}

		//called if an error occurs while saving the file
		private function onSaveError(e:IOErrorEvent):void
		{
			trace("Error Saving File : " + e.text);
			fr = null;
		}
	}
}