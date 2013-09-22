package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 11 mai 2013;
	 */
	public class Point3D {
		
		private var _x:int;
		private var _y:int;
		private var _z:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Point3D</code>.
		 */
		public function Point3D(x:int=0, y:int=0, z:int=0) {
			_z = z;
			_y = y;
			_x = x;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get x():int {
			return _x;
		}

		public function set x(x:int):void {
			_x = x;
		}

		public function get y():int {
			return _y;
		}

		public function set y(y:int):void {
			_y = y;
		}

		public function get z():int {
			return _z;
		}

		public function set z(z:int):void {
			_z = z;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Test if a point equals this instance.
		 */
		public function equals(p:Point3D):Boolean {
			return p.x == x && p.y == y && p.z == z;
		}
		
		/**
		 * Gets a clone of the object
		 */
		public function clone():Point3D {
			return new Point3D(x,y,z);
		}
		
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return '(x='+x+', y='+y+', z='+z+')';
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}