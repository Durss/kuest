package com.twinoid.kube.quest.vo {
	import mx.utils.StringUtil;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class CharItemData extends EventDispatcher implements IItemData {
		
		private var _name:String;
		private var _image:SerializableBitmapData;
		
		
		
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

		public function get image():SerializableBitmapData { return _image; }

		public function set image(image:SerializableBitmapData):void { _image = image; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[CharItemData :: name=\""+name+"\", image="+_image+"]";
		}
		
		/**
		 * Gets if the value object is full filled
		 */
		public function isValid():Boolean { return StringUtil.trim(name).length > 0 && image != null; }
		
		/**
		 * @inheritDoc
		 */
		public function kill():void {
			if(_image != null) _image.dispose();
			_image = null;
			dispatchEvent(new Event(Event.CLEAR));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}