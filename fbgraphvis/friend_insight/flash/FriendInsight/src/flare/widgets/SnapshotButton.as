package flare.widgets {
      import com.goodinson.snapshot.*;
      
      import flash.display.Bitmap;
      import flash.display.DisplayObject;
      import flash.display.DisplayObjectContainer;
      import flash.events.Event;
      import flash.events.IOErrorEvent;
      import flash.events.MouseEvent;
      import flash.net.FileReference;
      import flash.utils.ByteArray;
      
      public class SnapshotButton extends ImageButton {
          
          //FileReference Class well will use to save data
          private var fr:FileReference;
 
          public function SnapshotButton(bmp:Bitmap) {
          	  super(bmp);
              addEventListener(MouseEvent.CLICK, savesnapshot);
          }
               
		private function savesnapshot(e:MouseEvent):void
		{
			
			var curObj:DisplayObject = stage.getChildAt(0);
			curObj = (curObj as DisplayObjectContainer).getChildByName("visbox");
			curObj = (curObj as DisplayObjectContainer).getChildByName("visualization");
			curObj = (curObj as DisplayObjectContainer).getChildByName("_layers");
			
			var snapper:Snapshot = new Snapshot();
			snapper.snap("snapshot.jpg", "prompt", curObj);
			var byteArray:ByteArray = snapper.getBytes();
   			  
			//create the FileReference instance
			fr = new FileReference();

			//listen for the file has been saved
			fr.addEventListener(Event.COMPLETE, onFileSave);

			//listen for when then cancel out of the save dialog
			fr.addEventListener(Event.CANCEL,onCancel);

			//listen for any errors that occur while writing the file
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

			//open a native save file dialog, using the default file name
			fr.save(byteArray, "snapshot.jpg");
		}

		/***** File Save Event Handlers ******/

		//called once the file has been saved
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
