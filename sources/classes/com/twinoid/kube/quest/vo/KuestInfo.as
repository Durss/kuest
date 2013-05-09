package com.twinoid.kube.quest.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 8 mai 2013;
	 */
	public class KuestInfo {
		
		private var _id:String;
		private var _title:String;
		private var _description:String;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestInfo</code>.
		 */
		public function KuestInfo(title:String, description:String, id:String) {
			_id = id;
			_title = title;
			_description = description;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get id():String { return _id; }

		public function get title():String { return _title; }

		public function get description():String { return _description; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}