package com.twinoid.kube.quest.components.menu {
	import com.nurun.structure.environnement.label.Label;

	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuFileContent extends AbstractMenuContent {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuFileContent</code>.
		 */

		public function MenuFileContent(width:int) {
			super(width);
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
		override protected function initialize(event:Event):void {
			super.initialize(event);
			
			_label.text = Label.getLabel("menu-file");
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			super.computePositions(event);
			
		}
		
	}
}