package com.twinoid.kube.quest.editor.vo {
	
	/**
	 * Contains data for the PromptWindowView.
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class PromptData {
		
		private var _title:String;
		private var _content:String;
		private var _callback:Function;
		private var _id:String;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PromptData</code>.
		 */
		public function PromptData(title:String, label:String, callback:Function, id:String) {
			_id = id;
			_callback = callback;
			_content = label;
			_title = title;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/***
		 * Prompt window's title
		 */
		public function get title():String { return _title; }
		
		/**
		 * Prompt window's content
		 */
		public function get content():String { return _content; }
		
		/**
		 * Metho called when submit button is clicked
		 */
		public function get callback():Function { return _callback; }
		
		/**
		 * Prompt action ID.
		 * Used to remember if a specific prompt should be ignore and
		 * automatically submitted.
		 */
		public function get actionID():String { return _id; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}