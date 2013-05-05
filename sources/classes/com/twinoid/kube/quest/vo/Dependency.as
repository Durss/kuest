package com.twinoid.kube.quest.vo {
	
	/**
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

		public function set event(event:KuestEvent):void { _event = event; }

		public function get choiceIndex():int { return _choiceIndex; }

		public function set choiceIndex(choiceIndex:int):void { _choiceIndex = choiceIndex; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}