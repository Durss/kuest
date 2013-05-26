package com.twinoid.kube.quest.editor.vo {
	import flash.geom.Point;
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
		private var _kubeMode:Boolean;

		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionPlace</code>.
		 */
		public function ActionPlace() {
			_kubeMode = false;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get x():int { return _x; }

		public function set x(value:int):void { _x = value; }

		public function get y():int { return _y; }

		public function set y(value:int):void { _y = value; }

		public function get z():int { return _z; }

		public function set z(value:int):void { _z = value; }

		/**
		 * Gets if the coordinates represent a zone (true) or a kube (false)
		 */
		public function get kubeMode():Boolean { return _kubeMode; }

		/**
		 * Sets if the coordinates represent a zone (true) or a kube (false)
		 */
		public function set kubeMode(value:Boolean):void { _kubeMode = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[ActionPlace :: x="+x+", y="+y+", z="+z+", kubeMode="+kubeMode+"]";
		}
		
		/**
		 * Clones the object
		 */
		public function clone():ActionPlace {
			var a:ActionPlace = new ActionPlace();
			a.x = x;
			a.y = y;
			a.z = z;
			return a;
		}

		/**
		 * Gets the value object as Point or Point3D instance
		 */
		public function getAsPoint():* {
			return !_kubeMode? new Point(x, y) : new Point3D(x, y, z);
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