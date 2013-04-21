package com.twinoid.kube.quest.vo {
	import mx.utils.StringUtil;

	import flash.display.BitmapData;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class CharItemData implements IItemData {
		
		private var _name:String;
		private var _image:BitmapData;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharItemData</code>.
		 */
		public function CharItemData() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get name():String { return _name; }

		public function set name(name:String):void { _name = name; }

		public function get image():BitmapData { return _image; }

		public function set image(image:BitmapData):void { _image = image; }
		
		/**
		 * Gets if the value object is full filled
		 */
		public function get isValid():Boolean { return StringUtil.trim(name).length > 0 && image != null; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}