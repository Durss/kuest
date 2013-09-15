package com.twinoid.kube.quest.player.events {
	import flash.events.Event;
	
	/**
	 * Event fired by QuestManager
	 * 
	 * @author Francois
	 * @date 15 sept. 2013;
	 */
	public class QuestManagerEvent extends Event {
		
		public static const READY:String = "questManagerReady";
		public static const NEW_EVENT:String = "questManagerNewEvent";
		public static const INVENTORY_UPDATE:String = "questManagerInventoryUpdate";
		public static const HISTORY_UPDATE:String = "questManagerHistoryUpdate";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>QuestManager</code>.
		 */
		public function QuestManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new QuestManagerEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}