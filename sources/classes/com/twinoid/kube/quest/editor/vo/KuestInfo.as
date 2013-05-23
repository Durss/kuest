package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 8 mai 2013;
	 */
	public class KuestInfo {
		
		private var _guid:String;
		private var _title:String;
		private var _description:String;
		private var _users:Array;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestInfo</code>.
		 */
		public function KuestInfo(title:String, description:String, guid:String, users:Array) {
			_users = users;
			_guid = guid;
			_title = title;
			_description = description;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get guid():String { return _guid; }

		public function get users():Array { return _users; }

		public function get title():String { return _title; }

		public function get description():String { return _description; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[KuestInfo :: guid="+guid+", title=\""+title+"\"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}