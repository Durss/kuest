package com.twinoid.kube.quest.editor.vo {
	import com.nurun.core.lang.Disposable;
	
	/**
	 * 
	 * @author Francois
	 * @date 16 déc. 2013;
	 */
	public class ActionMoney implements Disposable {
		
		public static const GREATER:int = 0;
		public static const LOWER:int = 1;
		public static const EQUALS:int = 2;
		public static const GREATER_EQUALS:int = 3;
		public static const LOWER_EQUALS:int = 4;
		
		private var _kuborsEarned:uint;
		private var _unlockConditionEnabled:Boolean;
		private var _unlockCondition:uint;
		private var _unlockValue:uint;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionMoney</code>.
		 */
		public function ActionMoney() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get kuborsEarned():uint {
			return _kuborsEarned;
		}

		public function set kuborsEarned(value:uint):void {
			_kuborsEarned = value;
		}

		public function get unlockConditionEnabled():Boolean {
			return _unlockConditionEnabled;
		}

		public function set unlockConditionEnabled(value:Boolean):void {
			_unlockConditionEnabled = value;
		}

		public function get unlockCondition():uint {
			return _unlockCondition;
		}

		public function set unlockCondition(value:uint):void {
			_unlockCondition = value;
		}

		public function get unlockValue():uint {
			return _unlockValue;
		}

		public function set unlockValue(value:uint):void {
			_unlockValue = value;
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
			return "[ActionMoney :: kuborsEarned="+kuborsEarned+"]";
		}
		
		/**
		 * Clones the object
		 */
		public function clone():ActionMoney {
			var a:ActionMoney = new ActionMoney();
			a.kuborsEarned = kuborsEarned;
			return a;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}