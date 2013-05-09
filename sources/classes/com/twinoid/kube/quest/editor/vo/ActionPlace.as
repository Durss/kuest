package com.twinoid.kube.quest.editor.vo {
	import com.nurun.core.lang.Disposable;
	
	/**
	 * Stores an action's place coordinates.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class ActionPlace implements Disposable {
		
		private var _x:int;
		private var _y:int;
		private var _z:int;

		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionPlace</code>.
		 */
		public function ActionPlace() {
			_z = int.MIN_VALUE;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get x():int { return _x; }

		public function set x(value:int):void { _x = value; }

		public function get y():int { return _y; }

		public function set y(value:int):void { _y = value; }

		public function get z():int { return _z == int.MIN_VALUE? 0 : _z; }

		public function set z(value:int):void { _z = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[ActionPlace :: x="+x+", y="+y+", z="+z+", zoneMode="+zoneMode()+"]";
		}
		
		/**
		 * Gets if the coordinates represent a zone (true) or a kube (false)
		 */
		public function zoneMode():Boolean { return _z == int.MIN_VALUE; }
		
		public function clone():ActionPlace {
			var a:ActionPlace = new ActionPlace();
			a.x = x;
			a.y = y;
			a.z = z;
			return a;
		}

		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}