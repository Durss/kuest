package com.twinoid.kube.quest.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class ActionChoices {
		
		private var _choices:Vector.<String>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionChoice</code>.
		 */
		public function ActionChoices() {
			_choices = new Vector.<String>();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the choices labels.
		 */
		public function get choices():Vector.<String> { return _choices; }

		/**
		 * @private
		 * Here just for serialisation
		 */
		public function set choices(choices:Vector.<String>):void { _choices = choices; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
		}
		
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[ActionChoices :: ]";
		}
		
		/**
		 * Adds a choice to the list
		 */
		public function addChoice(label:String):void {
			_choices.push(label);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}