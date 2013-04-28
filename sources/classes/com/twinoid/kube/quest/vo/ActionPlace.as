package com.twinoid.kube.quest.vo {
	import com.nurun.core.lang.Disposable;
	import com.nurun.core.lang.io.Serializable;
	
	/**
	 * Stores an action's place coordinates.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class ActionPlace implements Serializable, Disposable {
		
		private var _x:int;
		private var _y:int;
		private var _z:int;
		private var _zoneMode:Boolean;

		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionPlace</code>.
		 */
		public function ActionPlace(x:int, y:int, z:int = -1) {
			_z = z;
			_y = y;
			_x = x;
			_zoneMode = z == -1;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get x():int { return _x; }

		public function get y():int { return _y; }

		public function get z():int { return _z; }
		
		/**
		 * Gets if the coordinates represent a zone (true) or a kube (false)
		 */
		public function get zoneMode():Boolean {
			return _zoneMode;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function clone():ActionPlace {
			return new ActionPlace(x, y, z);
		}

		public function deserialize(input:String):void {
		}

		public function serialize():String {
			return "";
		}

		public function dispose():void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}