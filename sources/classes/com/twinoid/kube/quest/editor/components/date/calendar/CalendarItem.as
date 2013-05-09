package com.twinoid.kube.quest.editor.components.date.calendar {
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.twinoid.kube.quest.graphics.CalendarDisabledItemGraphic;
	import com.twinoid.kube.quest.graphics.CalendarItemGraphic;
	import com.twinoid.kube.quest.graphics.CalendarSelectedItemGraphic;

	import flash.display.DisplayObject;
	
	/**
	 * Pre-skined calendar button
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class CalendarItem extends ToggleButton {
		private var _bgDefaultSave:DisplayObject;
		private var _bgSelectedSave:DisplayObject;
		private var _bgDisabledSave:CalendarDisabledItemGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CalendarItem</code>.
		 */
		public function CalendarItem(label:String) {
			super(label, "calendarItem", "calendarItem-selected", new CalendarItemGraphic(), new CalendarSelectedItemGraphic());
			applyDefaultFrameVisitorNoTween(this, defaultBackground, selectedBackground);
			accept(new CssVisitor());
			textAlign = TextAlign.CENTER;
			width = height = 35;
			
			_bgDefaultSave = defaultBackground;
			_bgSelectedSave = selectedBackground;
			_bgDisabledSave = new CalendarDisabledItemGraphic();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if(value) {
				defaultBackground = _bgDefaultSave;
				selectedBackground = _bgSelectedSave;
			}else{
				defaultBackground = _bgDisabledSave;
				selectedBackground = _bgDisabledSave;
			}
			
			_labelTxt.visible = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}