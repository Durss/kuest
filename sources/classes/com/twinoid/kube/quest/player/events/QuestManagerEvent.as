package com.twinoid.kube.quest.player.events {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import flash.events.Event;
	
	/**
	 * Event fired by QuestManager
	 * 
	 * @author Francois
	 * @date 15 sept. 2013;
	 */
	public class QuestManagerEvent extends Event {
		
		public static const READY:String = "questManagerReady";
		public static const WRONG_SAVE_FILE_FORMAT:String = "wrongSaveFileFormat";
		public static const NEW_EVENT:String = "questManagerNewEvent";
		public static const INVENTORY_UPDATE:String = "questManagerInventoryUpdate";
		public static const HISTORY_UPDATE:String = "questManagerHistoryUpdate";
		public static const HISTORY_FAVORITES_UPDATE:String = "questManagerHistoryFavoritesUpdate";
		public static const QUEST_COMPLETE:String = "questManagerQuestComplete";
		public static const QUEST_FAILED:String = "questManagerQuestFailed";
		
		private var _kuestEvent:KuestEvent;
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>QuestManager</code>.
		 */
		public function QuestManagerEvent(type:String, kuestEvent:KuestEvent = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_kuestEvent = kuestEvent;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the kuest event related to this event.
		 */
		public function get kuestEvent():KuestEvent { return _kuestEvent; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new QuestManagerEvent(type, kuestEvent, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}