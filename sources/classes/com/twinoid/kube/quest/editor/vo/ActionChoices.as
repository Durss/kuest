package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class ActionChoices {
		
		public static const MODE_CHOICE:String = "choice";
		public static const MODE_INPUT_STRICT:String = "strict";
		public static const MODE_INPUT_TOLERANT:String = "tolerant";
		
		private var _choices:Vector.<String>;
		private var _choicesCosts:Vector.<int>;
		private var _choicesModes:Vector.<String>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionChoice</code>.
		 */
		public function ActionChoices() {
			_choices = new Vector.<String>();
			_choicesModes = new Vector.<String>();
			_choicesCosts = new Vector.<int>();
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
		public function get choicesCost():Vector.<int> { return _choicesCosts; }

		/**
		 * @private
		 * Here just for serialisation
		 */
		public function set choicesCost(choices:Vector.<int>):void { _choicesCosts = choices; }
		
		/**
		 * Gets the choices modes.
		 */
		public function get choicesModes():Vector.<String> {
			return _choicesModes;
		}
		
		/**
		 * @private
		 * Here just for serialisation
		 */
		public function set choicesModes(choicesModes:Vector.<String>):void {
			_choicesModes = choicesModes;
		}



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
		public function addChoice(label:String, choiceCost:int, choiceMode:String = MODE_CHOICE):void {
			_choices.push(label);
			_choicesCosts.push(choiceCost);
			_choicesModes.push(choiceMode);
		}
		
		/**
		 * Clones the object
		 */
		public function clone():ActionChoices {
			var a:ActionChoices	= new ActionChoices();
			a.choices			= choices.concat();
			a.choicesCost		= choicesCost.concat();
			a.choicesModes		= choicesModes.concat();
			return a;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}