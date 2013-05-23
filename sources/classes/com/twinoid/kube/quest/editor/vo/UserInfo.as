package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 20 mai 2013;
	 */
	public class UserInfo {
		
		private var _uname:String;
		private var _uid:String;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>UserInfo</code>.
		 */
		public function UserInfo(uname:String, uid:String) {
			_uid = uid;
			_uname = uname;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the user's ID
		 */
		public function get uid():String { return _uid; }
		
		/**
		 * Gets the user's name
		 */
		public function get uname():String { return _uname; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[UserInfo :: name=\""+uname+"\", uid=\""+uid+"\"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}