package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class ActionChoices {
		
		private var _choices:Vector.<String>;
		private var _choicesCosts:Vector.<uint>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionChoice</code>.
		 */
		public function ActionChoices() {
			_choices = new Vector.<String>();
			_choicesCosts = new Vector.<uint>();
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
		
		/**
		 * Gets the choices costs.
		 */
		public function get choicesCost():Vector.<uint> { return _choicesCosts; }

		/**
		 * @private
		 * Here just for serialisation
		 */
		public function set choicesCost(choices:Vector.<uint>):void { _choicesCosts = choices; }



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
			return "[ActionChoices :: length="+_choices.length+" ]";
		}
		
		/**
		 * Adds a choice to the list
		 */
		public function addChoice(label:String, choiceCost:uint):void {
			_choices.push(label);
			_choicesCosts.push(choiceCost);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}