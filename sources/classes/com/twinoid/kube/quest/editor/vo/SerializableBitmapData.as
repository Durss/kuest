package com.twinoid.kube.quest.editor.vo {
	import flash.events.IOErrorEvent;
	import by.blooddy.crypto.image.JPEGEncoder;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	[Event(name="change", type="flash.events.Event")]
	
	
	/**
	 * Contains the data about bitmapData and allows it to be serialized and deserialized.
	 * 
	 * @author Francois
	 * @date 1 mai 2013;
	 */
	public class SerializableBitmapData extends EventDispatcher {
		
		private var _width:int;
		private var _height:int;
		private var _bmd:BitmapData;
		private var _bytes:ByteArray;
		private var _lastBytes:ByteArray;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SerializableBitmapData</code>.
		 */
		public function SerializableBitmapData() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get width():int { return _width; }

		public function set width(width:int):void {
			_width = width;
			initBmd();
		}

		public function get height():int { return _height; }

		public function set height(height:int):void {
			_height = height;
			initBmd();
		}
		
		public function get bytes():ByteArray {
			return JPEGEncoder.encode( _bmd, 80 );
		}
		
		public function set bytes(value:ByteArray):void {
			value.position = 0;
			_lastBytes = value;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.loadBytes(value);
			initBmd();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[SerializableBitmapData :: width="+width+", height="+height+", bytesLength="+(_bmd == null? 0 : bytes.length)+"]";
		}
		
		/**
		 * Draws a target onto the bitmapData
		 */
		public function draw(target:IBitmapDrawable):void {
			_bmd.draw(target);
		}
		
		/**
		 * Draws a bitmapData into this bitmapData
		 */
		public function fromBitmapData(bmd:BitmapData):void {
			_bmd = bmd.clone();
			_width = bmd.width;
			_height = bmd.height;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			_bmd.dispose();
		}
		
		/**
		 * Gets the concrete bitmapdata's instance.
		 */
		public function getConcreteBitmapData():BitmapData {
			return _bmd;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		private function initBmd():void {
			if(width > 0 && height > 0) {
				_bmd = new BitmapData(width, height);
			}
			if(_bmd != null && _bytes != null) {
				_bmd.setPixels(_bmd.rect, _bytes);
			}
		}
		
		/**
		 * Called when JPEG data are decompressed.
		 */
		private function loadCompleteHandler(event:Event):void {
			var bmp:Bitmap = LoaderInfo(event.currentTarget).loader.content as Bitmap;
			_bmd = bmp.bitmapData;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Retro compatibility.
		 * If loading failed, that's because the image's data weren't optimized
		 * as JPEG.
		 */
		private function loadErrorHandler(event:IOErrorEvent):void {
			_bytes = _lastBytes;
			initBmd();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}