package com.twinoid.kube.quest.editor.vo {
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	[Event(name="change", type="flash.events.Event")]
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
		private var _takeMode:Boolean;
		
		
		
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
		/**
		 * Globaly unique identifier used to restore the dependencies on deserialization
		 */
		public function get itemGUID():int { return _itemGuid; }

		/**
		 * Globaly unique identifier used to restore the dependencies on deserialization
		 */
		public function set itemGUID(value:int):void { _itemGuid = value; }
		
		/**
		 * Sets the action's message.
		 */
		public function get text():String { return _text; }

		/**
		 * Gets the action's message.
		 */
		public function set text(text:String):void { _text = text; }

		/**
		 * Gets the action's type (dialogue or object).
		 */
		public function get type():String { return _type; }

		/**
		 * Gets the action's type (dialogue or object).
		 */
		public function set type(type:String):void { _type = type; }
		
		/**
		 * Gets if the user receives an object (true) or uses an object (false)
		 * when he arrives at the specified coordinates
		 */
		public function get takeMode():Boolean { return _takeMode; }
		
		/**
		 * Defines if an object is taken or put in case of object type.
		 * If true, when the user arrives at the specified coordinates, he will
		 * receive the object.
		 * If false, he will use the object.
		 */
		public function set takeMode(value:Boolean):void { _takeMode = value; }



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
			if(_item != null) {
				_item.removeEventListener(Event.CLEAR, itemClearedHandler);
				_item.removeEventListener(Event.CHANGE, dispatchEvent);
			}
			_item = item;
			if(_item != null) {
				_item.addEventListener(Event.CLEAR, itemClearedHandler);
				_item.addEventListener(Event.CHANGE, dispatchEvent);
			}
			_itemGuid = item == null? -1 : item.guid;
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