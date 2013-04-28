package com.twinoid.kube.quest.events {
	import flash.events.Event;
	
	/**
	 * Event fired by a Box item
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class BoxEvent extends Event {
		
		public static const CREATE_LINK:String = "createLink";
		public static const DELETE:String = "delete";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxEvent</code>.
		 */
		public function BoxEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new BoxEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}