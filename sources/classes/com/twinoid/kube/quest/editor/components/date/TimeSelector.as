package com.twinoid.kube.quest.editor.components.date {
	import flash.filters.DropShadowFilter;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.date.DateUtils;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.date.calendar.Calendar;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.TimeSimulatorCalendarGraphic;
	import com.twinoid.kube.quest.graphics.TimeSimulatorSwitchClockGraphic;
	import com.twinoid.kube.quest.graphics.TimeSimulatorSwitchClockSelectedGraphic;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Fired when form is submitted
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	/**
	 * Allows the user to select a time (H:m).
	 * 
	 * @author Francois
	 * @date 22 sept. 2013;
	 */
	public class TimeSelector extends Sprite {
		private var _hour:InputKube;
		private var _minute:InputKube;
		private var _clockSwitch:ToggleButton;
		private var _hoursLabel:CssTextField;
		private var _minutesLabel:CssTextField;
		private var _label:CssTextField;
		private var _calendar:Calendar;
		private var _calendarBt:GraphicButtonKube;
		private var _width:int;
		private var _date:Date;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TimeSelector</code>.
		 */
		public function TimeSelector(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			_hour.tabIndex = value++;
			_minute.tabIndex = value++;
			_clockSwitch.tabIndex = value++;
		}
		
		/**
		 * Gets the date.
		 */
		public function get date():Date {
			if(_clockSwitch.selected) {
				return new Date();
			}
			_date = _calendar.selectedDates.length == 0? getToday() : _calendar.selectedDates[0];
			_date.minutes = _minute.numValue;
			_date.hours = _hour.numValue;
			return _date;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label			= addChild(new CssTextField('menu-label-bold')) as CssTextField;
			_hoursLabel		= addChild(new CssTextField('editWindow-label')) as CssTextField;
			_minutesLabel	= addChild(new CssTextField('editWindow-label')) as CssTextField;
			_hour			= addChild(new InputKube('0', true, 0, 23)) as InputKube;
			_minute			= addChild(new InputKube('0', true, 0, 59)) as InputKube;
			_clockSwitch	= addChild(new ToggleButton('', '', '', null, null, new TimeSimulatorSwitchClockGraphic(), new TimeSimulatorSwitchClockSelectedGraphic())) as ToggleButton;
			_calendarBt		= addChild(new GraphicButtonKube(new TimeSimulatorCalendarGraphic(), false)) as GraphicButtonKube;
			_calendar		= new Calendar(false);
			
			_label.text			= Label.getLabel('menu-debug-simulateDate');
			_hoursLabel.text	= Label.getLabel('editWindow-time-hourInterval-hoursLabel');
			_minutesLabel.text	= Label.getLabel('editWindow-time-hourInterval-miutesLabel');
			_clockSwitch.activateDefaultVisitor();
			setToolTip(_clockSwitch, Label.getLabel('menu-debug-switchClockTT'));
			
			_clockSwitch.filters = [new DropShadowFilter(0,0,0,.4,4,4,2,2)];
			
			computePositions();
			_hour.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_minute.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_clockSwitch.addEventListener(Event.CHANGE, changeSwitchHandler);
			_calendarBt.addEventListener(MouseEvent.CLICK, clickCalendarBtHandler);
			_calendarBt.addEventListener(MouseEvent.ROLL_OVER, overCalendarBtHandler);
			_calendar.addEventListener(Event.CHANGE, changeCalendarValueHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			_clockSwitch.selected = true;
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			for(var i:int = 0; i < numChildren; ++i) if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			PosUtils.hPlaceNext(5, _label, _hour, _hoursLabel, _minute, _minutesLabel, _calendarBt, _clockSwitch);
			PosUtils.vCenterIn(_clockSwitch, _hour);
		}
		
		/**
		 * Called when an input is submitted via ENTER key
		 */
		private function submitHandler(event:Event):void {
			dispatchEvent(event);
		}
		
		/**
		 * Called when the clock switch state changes
		 */
		private function changeSwitchHandler(event:Event):void {
			_hour.enabled = _minute.enabled = _calendarBt.enabled = !_clockSwitch.selected;
			_label.alpha = _hoursLabel.alpha = _minutesLabel.alpha = _clockSwitch.selected? .4 : 1;
			_clockSwitch.alpha = _clockSwitch.selected? 1 : .4;
		}
		
		/**
		 * Called when calendar's value changes
		 */
		private function changeCalendarValueHandler(event:Event):void {
			_date = _calendar.selectedDates[0];
			if(contains(_calendar)) removeChild(_calendar);
		}
		
		/**
		 * Called when calendar button is clicked
		 */
		private function clickCalendarBtHandler(event:MouseEvent):void {
			addChild(_calendar);
			_calendar.y = _calendarBt.y;
			_calendar.x = (_width - _calendar.width) * .5;
			if(_calendar.selectedDates.length == 0) {
				_calendar.selectedDates = new <Date>[ getToday() ];
			}
			_calendarBt.dispatchEvent(new ToolTipEvent(ToolTipEvent.CLOSE));
			roundPos(_calendar);
		}
		
		/**
		 * Gets today's date
		 */
		private function getToday():Date {
			var date:Date = new Date();
			date = new Date(date.getFullYear(), date.getMonth(), date.getDate());
			return date;
		}
		
		/**
		 * Called when the stage is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(!_calendar.contains(event.target as DisplayObject) && event.target != _calendarBt) {
				if(contains(_calendar)) removeChild(_calendar);
			}
		}
		
		/**
		 * Called when callendar button is rolled over
		 */
		private function overCalendarBtHandler(event:MouseEvent):void {
			var date:Date = (_calendar.selectedDates.length == 0)? getToday() : _calendar.selectedDates[0];
			var dateStr:String = DateUtils.format(date, Config.getVariable("dateFormat"));
			_calendarBt.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, dateStr, ToolTipAlign.TOP));
		}
		
	}
}