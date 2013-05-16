package com.twinoid.kube.quest.editor.vo {
	import mx.utils.StringUtil;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	[Event(name="clear", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Contains the data about a character (image/name/guid)
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class CharItemData extends EventDispatcher implements IItemData {
		
		internal static var _GUID:int;
		
		private var _name:String;
		private var _image:SerializableBitmapData;
		private var _guid:int;
		private var _isKilled:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharItemData</code>.
		 */
		public function CharItemData() {
			_guid = ++_GUID;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get name():String { return _name; }

		public function set name(value:String):void { _name = value; }

		public function get image():SerializableBitmapData { return _image; }

		public function set image(value:SerializableBitmapData):void {
			if(_image != null) {
				_image.removeEventListener(Event.CHANGE, dispatchEvent);
			}
			value.addEventListener(Event.CHANGE, dispatchEvent);
			_image = value;
			dispatchEvent(new Event(Event.CHANGE));
		}

		public function get guid():int { return _guid; }

		public function set guid(value:int):void {
			_guid = value;
			if(value > _GUID) _GUID = value + 1;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[CharItemData :: guid='"+guid+"', name=\""+name+"\", image="+_image+"]";
		}
		
		/**
		 * Gets if the value object is full filled
		 */
		public function isValid():Boolean { return StringUtil.trim(name).length > 0 && image != null; }
		
		/**
		 * @inheritDoc
		 */
		public function isKilled():Boolean { return _isKilled; }
		
		/**
		 * @inheritDoc
		 */
		public function kill():void {
			if(_image != null) _image.dispose();
			_image = null;
			_isKilled = true;
			dispatchEvent(new Event(Event.CLEAR));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}