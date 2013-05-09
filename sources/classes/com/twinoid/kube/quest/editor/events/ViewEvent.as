package com.twinoid.kube.quest.editor.events {
	import flash.events.Event;
	
	/**
	 * Event fired by ViewLocator
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class ViewEvent extends Event {
		
		public static const LOGING_IN:String = "loggingIn";
		public static const LOGIN_SUCCESS:String = "logginSuccess";
		public static const LOGIN_FAIL:String = "logginFail";
		public static const PROMPT:String = "prompt";
		public static const TUTORIAL:String = "tutorial";
		
		private var _data:*;
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ViewEvent</code>.
		 */

		public function ViewEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_data = data;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data():* {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ViewEvent(type, data, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}