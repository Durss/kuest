package com.twinoid.kube.quest.components.char {
	import com.twinoid.kube.quest.graphics.FaceGraphic;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class CharFace extends Sprite {
		private var _face:FaceGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharFace</code>.
		 */
		public function CharFace() {
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
			graphics.lineStyle(0, 0x2D89B0, 1);
			graphics.beginFill(0x7EC3DF, 1);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
			
			_face = addChild(new FaceGraphic()) as FaceGraphic;
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}