package com.twinoid.kube.quest.components.form.edit {
	import com.twinoid.kube.quest.components.calendar.Calendar;
	import com.twinoid.kube.quest.graphics.EventTimeStartIcon;
	import com.twinoid.kube.quest.graphics.EventTimeCalendarIcon;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.graphics.EventTimeNoneIcon;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class EditEventTime extends AbstractEditZone {
		
		private var _width:int;
		private var _calendarHolder:Sprite;
		private var _periodicHolder:Sprite;
		private var _calendar:Calendar;
		
		

		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventTime</code>.
		 */
		public function EditEventTime(width:int) {
			_width = width;
			super(Label.getLabel("editWindow-time-title"), width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			buildCalendar();
			buildPeriodic();
			
			addEntry(new EventTimeNoneIcon(), new Sprite(), Label.getLabel("editWindow-time-noneTT"));
			addEntry(new EventTimeCalendarIcon(), _calendarHolder, Label.getLabel("editWindow-time-calendarTT"));
			addEntry(new EventTimeStartIcon(), _periodicHolder, Label.getLabel("editWindow-time-periodicTT"));
		}

		private function buildCalendar():void {
			_calendarHolder = new Sprite();
			_calendar = _calendarHolder.addChild(new Calendar()) as Calendar;
		}

		private function buildPeriodic():void {
			_periodicHolder = new Sprite();
		}
		
	}
}