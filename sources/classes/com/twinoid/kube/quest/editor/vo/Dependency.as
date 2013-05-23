package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * Contains a dependency's data.
	 * Defines the KuestEvent it relates to and which choice index of the event
	 * unlocks the current event.
	 * 
	 * @author Francois
	 * @date 4 mai 2013;
	 */
	public class Dependency  {
		
		private var _event:KuestEvent;
		private var _choiceIndex:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Dependency</code>.
		 */
		public function Dependency(event:KuestEvent = null, choiceIndex:int = 0) {
			_event = event;
			_choiceIndex = choiceIndex;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get event():KuestEvent { return _event; }

		public function set event(value:KuestEvent):void { _event = value; }

		public function get choiceIndex():int { return _choiceIndex; }

		public function set choiceIndex(value:int):void { _choiceIndex = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[Dependency :: eventGUID="+event.guid+", choiceIndex="+choiceIndex+"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}