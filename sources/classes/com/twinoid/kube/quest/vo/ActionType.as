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
		private var _itemGuid:int;
		
		
		
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

		public function set text(text:String):void { _text = text; }

		public function get type():String { return _type; }

		public function set type(type:String):void { _type = type; }

		public function get itemGUID():int { return _itemGuid; }

		public function set itemGUID(value:int):void { _itemGuid = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[ActionType :: type="+type+", item="+_item+", text=\""+text+"\"]";
		}
		
		public function dispose():void {
			_item = null;
		}
		
		/**
		 * Gets the item's reference related to this value object.
		 * Not written as a getter/setter to prevent this value object from
		 * being serialized.
		 */
		public function getItem():IItemData { return _item; }

		/**
		 * Sets the item's reference related to this value object.
		 * Not written as a getter/setter to prevent this value object from
		 * being serialized.
		 */
		public function setItem(item:IItemData):void {
			if(_item != null) _item.removeEventListener(Event.CLEAR, itemClearedHandler);
			_item = item;
			if(_item != null) _item.addEventListener(Event.CLEAR, itemClearedHandler);
			_itemGuid = item.guid;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when the item source is delete.
		 */
		private function itemClearedHandler(event:Event):void {
			_item = null;
			_itemGuid = -1;
			dispatchEvent(event);
		}
		
	}
}