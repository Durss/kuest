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
		private var _sfxr:String;
		
		
		
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

		public function get sfxr():String { return _sfxr; }

		public function set sfxr(sfxr:String):void { _sfxr = sfxr; }



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
			return "[ActionSound :: loop=" + loop + ", url=\"" + url + "\", sfxr=\"" + sfxr + "\"]";
		}
		
		/**
		 * Clones the object
		 */
		public function clone():ActionSound {
			var a:ActionSound = new ActionSound();
			a.url = url;
			a.loop = loop;
			a.sfxr = sfxr;
			return a;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
	}
}