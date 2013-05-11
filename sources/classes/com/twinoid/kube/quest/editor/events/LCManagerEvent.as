package com.twinoid.kube.quest.editor.events {
	import flash.events.Event;
	
	/**
	 * Event fired by LCManager
	 * 
	 * @author Francois
	 * @date 11 mai 2013;
	 */
	public class LCManagerEvent extends Event {
		
		public static const GAME_CONNECTION_STATE_CHANGE:String = "connectionGameStateChange";
		public static const PLAYER_CONNECTION_STATE_CHANGE:String = "connectionPlayerStateChange";
		public static const FORUM_TOUCHED:String = "forumTOuched";
		public static const ZONE_CHANGE:String = "zoneChange";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LCManagerEvent</code>.
		 */
		public function LCManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new LCManagerEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}