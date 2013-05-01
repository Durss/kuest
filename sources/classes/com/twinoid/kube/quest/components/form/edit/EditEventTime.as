package com.twinoid.kube.quest.components.form.edit {
	import com.twinoid.kube.quest.vo.ActionDate;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.components.date.DaySelector;
	import com.twinoid.kube.quest.components.date.TimeInterval;
	import com.twinoid.kube.quest.components.date.calendar.Calendar;
	import com.twinoid.kube.quest.graphics.EventTimeCalendarIcon;
	import com.twinoid.kube.quest.graphics.EventTimeNoneIcon;
	import com.twinoid.kube.quest.graphics.EventTimeStartIcon;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.display.Sprite;

	
	/**
	 * DIsplays the time management panel.
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class EditEventTime extends AbstractEditZone {
		
		private var _width:int;
		private var _calendarHolder:Sprite;
		private var _periodicHolder:Sprite;
		private var _calendar:Calendar;
		private var _periodicDaySel:DaySelector;
		private var _periodicTimeInterval:TimeInterval;
		
		

		
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
		/**
		 * Saves the configurations to the value object
		 */
		public function save(data:KuestEvent):void {
			switch(selectedIndex){
				case 0:
					data.actionDate = new ActionDate();
					break;
				case 1:
					data.actionDate = new ActionDate();
					data.actionDate.dates = _calendar.selectedDates;
					break;
				case 2:
					data.actionDate = new ActionDate();
					data.actionDate.days = _periodicDaySel.days;
					data.actionDate.startTime = _periodicTimeInterval.startTime;
					data.actionDate.endTime = _periodicTimeInterval.endTime;
					break;
				default:
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			if(data.actionDate == null) {
				selectedIndex = 0;
				_calendar.selectedDates = null;
				_periodicDaySel.days = null;
				_periodicTimeInterval.startTime = 0;
				_periodicTimeInterval.endTime = 0;
				return;
			}
			
			if(data.actionDate.dates == null && data.actionDate.days == null) selectedIndex = 0;
			if(data.actionDate.dates != null && data.actionDate.days == null) selectedIndex = 1;
			if(data.actionDate.dates == null && data.actionDate.days != null) selectedIndex = 2;
			
			_calendar.selectedDates = data.actionDate.dates;
			
			_periodicDaySel.days = data.actionDate.days;
			_periodicTimeInterval.startTime = data.actionDate.startTime;
			_periodicTimeInterval.endTime = data.actionDate.endTime;
		}


		
		
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
			_periodicDaySel = _periodicHolder.addChild(new DaySelector()) as DaySelector;
			_periodicDaySel.width = _width;
			_periodicTimeInterval = _periodicHolder.addChild(new TimeInterval()) as TimeInterval;
			_periodicTimeInterval.y = Math.round(_periodicDaySel.height + 10);
		}
		
	}
}