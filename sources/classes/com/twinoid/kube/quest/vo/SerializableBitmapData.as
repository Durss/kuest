package com.twinoid.kube.quest.vo {
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 mai 2013;
	 */
	public class SerializableBitmapData {
		
		private var _width:int;
		private var _height:int;
		private var _bmd:BitmapData;
		private var _bytes:ByteArray;
		
		
		
		
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
		
		public function get bytes():ByteArray { return _bmd.getPixels(_bmd.rect); }
		
		public function set bytes(value:ByteArray):void {
			_bytes = value;
			initBmd();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
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
		
	}
}