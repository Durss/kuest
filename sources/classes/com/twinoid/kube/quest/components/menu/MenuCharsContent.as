package com.twinoid.kube.quest.components.menu {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
	
	/**
	 * Displays the characters creator.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuCharsContent extends Sprite {
		
		private var _width:int;
		private var _label:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuCharsContent</code>.
		 */
		public function MenuCharsContent(width:int) {
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
			_label = addChild(new CssTextField("menu-label")) as CssTextField;
			
			_label.text = Label.getLabel("menu-chars");
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}