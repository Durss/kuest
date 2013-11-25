package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	
	/**
	 * 
	 * @author Francois
	 * @date 25 mai 2013;
	 */
	public class InventoryObject {
		
		private var _vo:ObjectItemData;
		private var _total:int;
		private var _unlocked:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>InventoryObject</code>.
		 */
		public function InventoryObject(vo:ObjectItemData, total:int, unlocked:Boolean = false) {
			_total = total;
			_vo = vo;
			_unlocked = unlocked;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get vo():ObjectItemData {
			return _vo;
		}

		public function get total():int {
			return _total;
		}

		public function set total(value:int):void {
			_total = value;
		}

		public function get unlocked():Boolean {
			return _unlocked;
		}

		public function set unlocked(unlocked:Boolean):void {
			_unlocked = unlocked;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[InventoryObject :: total=" + total + ", vo=" + vo + ", unlocked=" + unlocked + "]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}