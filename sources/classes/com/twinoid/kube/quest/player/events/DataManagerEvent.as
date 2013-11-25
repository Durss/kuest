package com.twinoid.kube.quest.player.events {
	import flash.events.Event;
	
	/**
	 * Event fired by DataManager
	 * 
	 * @author Francois
	 * @date 12 mai 2013;
	 */
	public class DataManagerEvent extends Event {
		
		public static const LOAD_COMPLETE:String				= "loadComplete";
		public static const LOAD_ERROR:String					= "loadError";
		public static const ON_LOGIN_STATE:String				= "longinState";
		public static const NO_KUEST_SELECTED:String			= "noKuest";
		public static const NEW_EVENT:String					= "newEvent";
		public static const WRONG_OBJECT:String					= "wrongObject";
		public static const NO_NEED_FOR_OBJECT:String			= "noNeedForObject";
		public static const CLEAR_PROGRESSION_COMPLETE:String	= "clearProgressComplete";
		public static const QUEST_COMPLETE:String				= "questComplete";
		public static const QUEST_FAILED:String					= "questFailed";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DataManagerEvent</code>.
		 */
		public function DataManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new DataManagerEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}