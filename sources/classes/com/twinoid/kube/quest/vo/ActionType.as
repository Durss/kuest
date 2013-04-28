package com.twinoid.kube.quest.vo {
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 22 avr. 2013;
	 */
	public class ActionType extends EventDispatcher {
		
		public static const TYPE_DIALOGUE:String = "dialogue";
		public static const TYPE_OBJECT:String = "object";
		
		private var _type:String;
		private var _item:IItemData;
		private var _text:String;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionType</code>.
		 */

		public function ActionType(type:String, item:IItemData, text:String) {
			_text = text;
			_item = item;
			_type = type;
			if(_item != null){
				_item.addEventListener(Event.CLEAR, itemClearedHandler);
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get text():String { return _text; }

		public function get item():IItemData { return _item; }

		public function get type():String { return _type; }



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function deserialize(input:String):void {
		}

		public function serialize():String {
			return "";
		}

		public function dispose():void {
			_item = null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when the item source is delete.
		 */
		private function itemClearedHandler(event:Event):void {
			_item = null;
			dispatchEvent(event);
		}
		
	}
}