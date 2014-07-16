package com.twinoid.kube.quest.editor.components {
	import com.nurun.components.scroll.scrollable.ScrollableTextField;
	
	/**
	 * Simple CssTextfield that opens a up a bigger popin to edit its content.
	 * 
	 * @author Durss
	 * @date 4 avr. 2014;
	 */
	public class MagnifyableTextfield extends ScrollableTextField {
		
		private var _title:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MagnifyableTextfield</code>.
		 */
		public function MagnifyableTextfield(title:String, css:String = "textarea") {
			_title = title;
			super('', css);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the titleto be displayed in the magnified window.
		 */
		public function get title():String { return _title; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}