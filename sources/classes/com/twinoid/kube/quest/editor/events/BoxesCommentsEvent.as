package com.twinoid.kube.quest.editor.events {
	import flash.events.Event;
	
	/**
	 * Event fired by BoxesComments view
	 * 
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	public class BoxesCommentsEvent extends Event {
		
		public static const ENTER_EDIT_MODE:String = "ENTER_EDIT_MODE";
		public static const LEAVE_EDIT_MODE:String = "LEAVE_EDIT_MODE";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxesCommentsEvent</code>.
		 */
		public function BoxesCommentsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new BoxesCommentsEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}