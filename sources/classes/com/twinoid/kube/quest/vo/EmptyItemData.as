package com.twinoid.kube.quest.vo {
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

		public function get name():String { return ""; }

		public function set name(value:String):void { }

		public function get image():SerializableBitmapData { return null; }

		public function set image(value:SerializableBitmapData):void { }

		public function get isDefined():Boolean { return _isDefined; }



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