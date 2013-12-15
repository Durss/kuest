package com.twinoid.kube.quest.editor.events {
	import flash.events.Event;
	
	/**
	 * Event fired by a Box item
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class BoxEvent extends Event {
		
		public static const DELETE:String = "delete";
		public static const CREATE_LINK:String = "createLink";
		public static const ACTIVATE_DEBUG:String = "activateDebug";
		
		private var _choiceIndex:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxEvent</code>.
		 */

		public function BoxEvent(type:String, choiceIndex:int = 0, bubbles:Boolean = false, cancelable:Boolean = false) {
			_choiceIndex = choiceIndex;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets from which choice's index the link as been created.
		 */
		public function get choiceIndex():int { return _choiceIndex; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new BoxEvent(type, choiceIndex, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}