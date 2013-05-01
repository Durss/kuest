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
		
		public static const TYPE_CHARACTER:String = "character";
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

		public function ActionType() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get text():String { return _text; }

		public function get item():IItemData { return _item; }

		public function get type():String { return _type; }

		public function set type(type:String):void { _type = type; }

		public function set item(item:IItemData):void {
			if(_item != null) _item.removeEventListener(Event.CLEAR, itemClearedHandler);
			_item = item;
			if(_item != null) _item.addEventListener(Event.CLEAR, itemClearedHandler);
		}

		public function set text(text:String):void { _text = text; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[ActionType :: type="+type+", item="+item+", text=\""+text+"\"]";
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