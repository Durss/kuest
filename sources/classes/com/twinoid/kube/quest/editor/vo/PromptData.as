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
		private var _callbackCancel : Function;
		private var _canIgnore : Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PromptData</code>.
		 */
		public function PromptData(title:String, label:String, callback:Function, id:String, callbackCancel:Function = null, canIgnore:Boolean = true) {
			_callbackCancel = callbackCancel;
			_id = id;
			_callback = callback;
			_content = label;
			_title = title;
			_canIgnore = canIgnore;
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
		 * Method called when submit button is clicked
		 */
		public function get callback():Function { return _callback; }

		/**
		 * Method called when cancel button is clicked
		 */
		public function get callbackCancel():Function { return _callbackCancel; }
		
		/**
		 * Prompt action ID.
		 * Used to remember if a specific prompt should be ignore and
		 * automatically submitted.
		 */
		public function get actionID() : String {
			return _id;
		}
		
		/**
		 * Gets if the user can ignore the prompt.
		 */
		public function get canIgnore() : Boolean {
			return _canIgnore;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}