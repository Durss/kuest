package com.twinoid.kube.quest.components.form.input {
	import com.muxxu.kub3dit.graphics.InputSkin;
	import flash.text.TextFieldType;
	import com.twinoid.kube.quest.components.form.ScrollbarKube;
	import com.nurun.components.scroll.scrollable.ScrollableTextField;
	import com.nurun.components.scroll.ScrollPane;
	
	/**
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class TextArea extends ScrollPane {
		private var _back:InputSkin;
		private var _tf:ScrollableTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TextArea</code>.
		 */
		public function TextArea(css:String = "input") {
			_tf = new ScrollableTextField("", css);
			_tf.type = TextFieldType.INPUT;
			_tf.autoWrap = false;
			_back = addChild(new InputSkin()) as InputSkin;
			super(_tf, new ScrollbarKube(), new ScrollbarKube());
			autoHideScrollers = true;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		override public function validate():void {
			super.validate();
			_back.width = _tf.width;
			_back.height = _tf.height;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}