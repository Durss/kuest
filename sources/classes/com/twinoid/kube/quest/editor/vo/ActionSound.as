package com.twinoid.kube.quest.editor.vo {
	import com.nurun.core.lang.Disposable;
	
	/**
	 * 
	 * @author Francois
	 * @date 22 mai 2013;
	 */
	public class ActionSound implements Disposable {
		
		private var _url:String;
		private var _loop:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionSound</code>.
		 */
		public function ActionSound() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get url():String { return _url; }

		public function set url(url:String):void { _url = url; }

		public function get loop():Boolean { return _loop; }

		public function set loop(loop:Boolean):void { _loop = loop; }



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
			return "[ActionSound :: loop="+loop+", url=\"" + url + "\"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
	}
}