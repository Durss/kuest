package com.twinoid.kube.quest.player.views {
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 mai 2013;
	 */
	public class PlayerInventoryView extends Sprite {
		
		private var _width:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerInventoryView</code>.
		 */

		public function PlayerInventoryView(width:int) {
			_width = width;
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
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}