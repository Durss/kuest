package com.twinoid.kube.quest.editor.vo {
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
			//Provides a way to get a selectable empty item.
			//The first item of the ItemSelectorView is done like that
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

		public function get guid():int { return 0; }

		public function set guid(value:int):void { }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function kill():void { }
		
		/**
		 * @inheritDoc
		 */
		public function isKilled():Boolean { return false; }


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}