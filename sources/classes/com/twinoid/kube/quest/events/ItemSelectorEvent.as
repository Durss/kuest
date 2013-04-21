package com.twinoid.kube.quest.events {
	import flash.events.Event;
	
	/**
	 * Event fired by views to other views through the ViewLocator.
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class ItemSelectorEvent extends Event {
		
		public static const SELECT_ITEM:String = "selectItem";
		
		public static const ITEM_TYPE_CHAR:String = "char";
		public static const ITEM_TYPE_OBJECT:String = "object";
		
		private var _itemType:String;
		private var _callback:Function;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ViewsEvent</code>.
		 */

		public function ItemSelectorEvent(type:String, itemType:String, callback:Function, bubbles:Boolean = false, cancelable:Boolean = false) {
			_callback = callback;
			_itemType = itemType;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the event's data.
		 */
		public function get itemType():String { return _itemType; }
		
		/**
		 * Callback method to give it the selected item.
		 */
		public function get callback():Function { return _callback; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ItemSelectorEvent(itemType, itemType, callback, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}