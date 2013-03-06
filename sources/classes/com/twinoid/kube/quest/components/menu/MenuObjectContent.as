package com.twinoid.kube.quest.components.menu {
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuObjectContent extends Sprite {
		
		private var _width:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuObjectContent</code>.
		 */
		public function MenuObjectContent(width:int) {
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