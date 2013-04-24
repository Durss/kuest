package com.twinoid.kube.quest.vo {
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class EmptyItemData extends EventDispatcher implements IItemData {
		
		private var _isDefined:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EmptyItemData</code>.
		 */

		public function EmptyItemData(isDefined:Boolean = false) {
			_isDefined = isDefined;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get name():String {
			return "";
		}

		public function get image():BitmapData {
			return null;
		}

		public function get isDefined():Boolean {
			return _isDefined;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function kill():void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}