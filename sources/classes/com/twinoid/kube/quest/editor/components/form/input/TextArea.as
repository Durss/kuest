package com.twinoid.kube.quest.editor.components.form.input {
	import com.muxxu.kub3dit.graphics.InputSkin;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableTextField;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import flash.events.FocusEvent;
	import flash.text.TextFieldType;
	
	/**
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class TextArea extends ScrollPane {
		private var _back:InputSkin;
		private var _tf:ScrollableTextField;
		private var _defaultLabel:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TextArea</code>.
		 */

		public function TextArea(css:String = "textarea", defaultLabel:String = "") {
			_defaultLabel = defaultLabel;
			_tf = new ScrollableTextField("", css);
			_tf.type = TextFieldType.INPUT;
			_tf.autoWrap = false;
			_tf.text = _defaultLabel;
			_back = addChild(new InputSkin()) as InputSkin;
			super(_tf, new ScrollbarKube(), new ScrollbarKube());
			autoHideScrollers = true;
			if(_defaultLabel != null && _defaultLabel.length > 0) {
				addEventListener(FocusEvent.FOCUS_IN, focusHandler);
				addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function get text():String {
			if(_tf.text == _defaultLabel) return "";
			return _tf.text;
		}
		
		public function get textfield():CssTextField {
			return _tf;
		}
		
		public function set text(value:String):void {
			_tf.text = (StringUtils.trim(value).length == 0)? _defaultLabel : value;
		}



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
		/**
		 * Called when textfield receives or looses the focus.
		 */
		private function focusHandler(event:FocusEvent):void {
			if(event.type == FocusEvent.FOCUS_IN) {
				if(_tf.text == _defaultLabel) _tf.text = "";
			}else{
				if(StringUtils.trim(_tf.text).length == 0) _tf.text = _defaultLabel;
			}
		}
		
	}
}