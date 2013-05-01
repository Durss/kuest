package com.twinoid.kube.quest.components.date.calendar {
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.date.DateUtils;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.graphics.CalendarNextMonthIcon;
	import com.twinoid.kube.quest.graphics.CalendarPrevMonthIcon;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 4 févr. 2013;
	 */
	public class Calendar extends Sprite {
		
		private const CELL_SIZE:int = 35;
		private const CELL_GAP:int = 1;
		private const COLS:int = 7;
		private const ROWS:int = 5;
		private const HEAD_HEIGHT:int = 25;
		private const DAYS_HEIGHT:int = 20;
		
		private var _prevMonthBt:GraphicButton;
		private var _nextMonthBt:GraphicButton;
		private var _monthLabel:BaseButton;
		private var _daysLabels:Vector.<BaseButton>;
		private var _daysItems:Vector.<CalendarItem>;
		private var _monthsOffset:int;
		private var _todayDate:Date;
		private var _currentDate:Date;
		private var _dateToState:Object;
		private var _pressed:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Calendar</code>.
		 */
		public function Calendar() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the selected dates.
		 */
		public function get selectedDates():Vector.<Date> {
			var ret:Vector.<Date> = new Vector.<Date>();
			for (var key:String in _dateToState) {
				ret.push(_dateToState[key] as Date);
			}
			return ret;
		}
		
		/**
		 * Sets the selected dates
		 */
		public function set selectedDates(value:Vector.<Date>):void {
			_dateToState = {};
			var i:int, len:int;
			len = value == null? 0 : value.length;
			for(i = 0; i < len; ++i) {
				_dateToState[value[i].toString()] = value[i];
			}
			
			render();
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
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_monthLabel = addChild(new BaseButton("", "calendarMonth")) as BaseButton;
			_prevMonthBt = addChild(new GraphicButton(createRect(), new CalendarPrevMonthIcon())) as GraphicButton;
			_nextMonthBt = addChild(new GraphicButton(createRect(), new CalendarNextMonthIcon())) as GraphicButton;
			
			_daysLabels = new Vector.<BaseButton>();
			_daysItems = new Vector.<CalendarItem>();
			_dateToState = {};
			
			_todayDate = new Date();
			_monthsOffset = 0;
			_monthLabel.text = Label.getLabel("month1");
			
			var i:int, d:BaseButton, item:CalendarItem;
			for(i = 0; i < 7; ++i) {
				d = addChild(new BaseButton("", "calendarDay")) as BaseButton;
				d.text = Label.getLabel("day"+(i+1));
				d.width = CELL_SIZE;
				d.addEventListener(MouseEvent.MOUSE_DOWN, clickDayHandler);
				d.addEventListener(MouseEvent.MOUSE_OVER, overDayHandler);
				_daysLabels.push(d);
			}
			
			for(i = 0; i < COLS*ROWS; ++i) {
				item = addChild(new CalendarItem((i+1).toString())) as CalendarItem;
				item.addEventListener(Event.CHANGE, toggleItemHandler);
				_daysItems.push(item);
			}
			
			_nextMonthBt.width = _prevMonthBt.width = HEAD_HEIGHT;
			_nextMonthBt.height = _prevMonthBt.height = HEAD_HEIGHT - 3;
			_nextMonthBt.iconAlign = _prevMonthBt.iconAlign = IconAlign.CENTER;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_monthLabel.addEventListener(MouseEvent.CLICK, clickMonthHandler);
			
			computePositions();
			render();
		}
		
		/**
		 * Called when month label is clicked.
		 */
		private function clickMonthHandler(event:MouseEvent):void {
			var i:int, len:int;
			len = _daysItems.length;
			for(i = 0; i < len; ++i) {
				if(_daysItems[i].enabled) _daysItems[i].selected = !_daysItems[i].selected;
			}
		}
		
		/**
		 * Called when a day label is clicked
		 */
		private function clickDayHandler(event:MouseEvent):void {
			var bt:BaseButton = event.currentTarget as BaseButton;
			var i:int, len:int, index:int;
			len = _daysLabels.length;
			for(i = 0; i < len; ++i) if(_daysLabels[i] == bt) break;
			index = i;
			
			len = _daysItems.length;
			for(i = 0; i < len; ++i) {
				if(i%7 == index && _daysItems[i].enabled) {
					_daysItems[i].selected = !_daysItems[i].selected;
				}
			}
			_pressed = true;
		}
		
		/**
		 * Called when a day item is rolled over.
		 * If an item is pressed, the other days can be selected simply by
		 * rolling over them to make it easier to select columns.
		 */
		private function overDayHandler(event:MouseEvent):void {
			if(_pressed) clickDayHandler(event);
		}
		
		/**
		 * Called when mouse is released to put the pressed flag to false.
		 */
		private function mouseUpHandler(event:MouseEvent):void { _pressed = false; }
		
		/**
		 * Called when an item is toggled.
		 */
		private function toggleItemHandler(event:Event):void {
			var item:CalendarItem = event.currentTarget as CalendarItem;
			var d:Date = dateFromItem(item);
			var id:String = d.toString();
			if(item.selected) {
				_dateToState[id] = d;
			}else{
				delete _dateToState[id];
			}
		}
		
		/**
		 * Builds a unique ID from an item.
		 */
		private function dateFromItem(item:CalendarItem):Date {
			var date:Date = new Date(_currentDate.toString());
			date.setDate(parseInt(item.label));
			return date;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var w:int = (CELL_SIZE+CELL_GAP) * COLS;
			var h:int = (CELL_SIZE+CELL_GAP) * ROWS;
			
			graphics.clear();
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(0, 0, w - 1, HEAD_HEIGHT + DAYS_HEIGHT + h + CELL_GAP);
			graphics.beginFill(0x2D89B0, 1);
			graphics.drawRect(0, 0, w, HEAD_HEIGHT);
			graphics.beginFill(0xA2D3E7, 1);
			graphics.drawRect(0, HEAD_HEIGHT + CELL_GAP, w, DAYS_HEIGHT);
			
			PosUtils.vCenterIn(_monthLabel, HEAD_HEIGHT);
			_nextMonthBt.x = w - _nextMonthBt.width;
			_monthLabel.width = w - _nextMonthBt.width - _prevMonthBt.width - 20;
			_monthLabel.x = _prevMonthBt.width + 10;
			
			var i:int, len:int, d:BaseButton, item:CalendarItem, offsetY:int;
			
			len = _daysLabels.length;
			for(i = 0; i < len; ++i) {
				d = _daysLabels[i];
				d.x = i * (CELL_SIZE+CELL_GAP) + Math.round((CELL_SIZE - d.width) * .5);
				d.y = HEAD_HEIGHT + Math.round((DAYS_HEIGHT - d.height) * .5);
			}
			
			offsetY = HEAD_HEIGHT + 1 + DAYS_HEIGHT + 1;
			len = _daysItems.length;
			for(i = 0; i < len; ++i) {
				item = _daysItems[i];
				item.x = (i%COLS) * (CELL_SIZE + CELL_GAP);
				item.y = offsetY + Math.floor(i/COLS) * (CELL_SIZE + CELL_GAP);
			}
		}
		
		/**
		 * Called when a button is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _nextMonthBt) {
				_monthsOffset ++;
				render();
			}else if(event.target == _prevMonthBt) {
				_monthsOffset --;
				render();
			}
		}
		
		/**
		 * Updates the cells rendering.
		 */
		private function render():void {
			_currentDate = new Date(_todayDate.getFullYear(), _todayDate.getMonth() + _monthsOffset, 1);
			_monthLabel.text = Label.getLabel("month"+(_currentDate.getMonth()+1)) + " " + _currentDate.getFullYear();

			var firstDay:Number = _currentDate.getDay() - 1;
			if(firstDay < 0) firstDay += 7;
			var lastDay:Number = DateUtils.getMonthNumberOfDays(_currentDate.getMonth(), _currentDate.getFullYear()) + firstDay;
			
			var i:int, len:int;
			len = _daysItems.length;
			for(i = 0; i < len; ++i) {
				_daysItems[i].enabled = (i >= firstDay && i < lastDay);
				_daysItems[i].label = (i-firstDay+1).toString();
				_daysItems[i].selected = _dateToState[dateFromItem(_daysItems[i])] !== undefined;
			}
		}
		
	}
}