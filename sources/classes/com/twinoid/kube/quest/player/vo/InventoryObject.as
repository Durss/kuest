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
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>InventoryObject</code>.
		 */
		public function InventoryObject(vo:ObjectItemData, total:int) {
			_total = total;
			_vo = vo;
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[InventoryObject :: total="+total+", vo="+vo+"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}