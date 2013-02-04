package com.twinoid.kube.quest.components.box {
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxLink extends Sprite {

		private var _startEntry:Box;
		private var _endEntry:Box;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxLink</code>.
		 */
		public function BoxLink(startEntry:Box, endEntry:Box) {
			_endEntry = endEntry;
			_startEntry = startEntry;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			
		}
		
	}
}