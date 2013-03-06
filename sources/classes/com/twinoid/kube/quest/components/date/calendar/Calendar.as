package com.twinoid.kube.quest.components.date.calendar {
	import com.nurun.utils.date.DateUtils;
	import flash.events.MouseEvent;
	import com.nurun.utils.draw.createRect;
	import com.nurun.components.button.IconAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.graphics.CalendarNextMonthIcon;
	import com.twinoid.kube.quest.graphics.CalendarPrevMonthIcon;

	import flash.display.Sprite;
	
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
		private var _monthLabel:CssTextField;
		private var _daysLabels:Vector.<CssTextField>;
		private var _daysItems:Vector.<CalendarItem>;
		private var _monthOffset:int;
		private var _currentDate:Date;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Calendar</code>.
		 */
		public function Calendar() {
			initialize();
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
		private function initialize():void {
			_monthLabel = addChild(new CssTextField("calendarMonth")) as CssTextField;
			_prevMonthBt = addChild(new GraphicButton(createRect(), new CalendarPrevMonthIcon())) as GraphicButton;
			_nextMonthBt = addChild(new GraphicButton(createRect(), new CalendarNextMonthIcon())) as GraphicButton;
			
			_daysLabels = new Vector.<CssTextField>();
			_daysItems = new Vector.<CalendarItem>();
			
			_currentDate = new Date();
			_monthOffset = 0;
			_monthLabel.text = Label.getLabel("month1");
			
			var i:int, d:CssTextField, item:CalendarItem;
			for(i = 0; i < 7; ++i) {
				d = addChild(new CssTextField("calendarDay")) as CssTextField;
				d.text = Label.getLabel("day"+(i+1));
				d.width = CELL_SIZE;
				_daysLabels.push(d);
			}
			
			for(i = 0; i < COLS*ROWS; ++i) {
				item = addChild(new CalendarItem((i+1).toString())) as CalendarItem;
				_daysItems.push(item);
			}
			
			_nextMonthBt.width = _prevMonthBt.width = HEAD_HEIGHT;
			_nextMonthBt.height = _prevMonthBt.height = HEAD_HEIGHT - 3;
			_nextMonthBt.iconAlign = _prevMonthBt.iconAlign = IconAlign.CENTER;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
			render();
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
			
			_monthLabel.width = w;
			PosUtils.vCenterIn(_monthLabel, HEAD_HEIGHT);
			_nextMonthBt.x = w - _nextMonthBt.width;
			
			var i:int, len:int, d:CssTextField, item:CalendarItem, offsetY:int;
			
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
				_monthOffset ++;
				render();
			}else if(event.target == _prevMonthBt) {
				_monthOffset --;
				render();
			}
		}
		
		/**
		 * Updates the cells rendering.
		 */
		private function render():void {
			var date:Date = new Date(_currentDate.getFullYear(), _currentDate.getMonth() + _monthOffset, 1);
			_monthLabel.text = Label.getLabel("month"+(date.getMonth()+1)) + " " + date.getFullYear();

			var firstDay:Number = date.getDay() - 1;
			if(firstDay < 0) firstDay += 7;
			var lastDay:Number = DateUtils.getMonthNumberOfDays(date.getMonth(), date.getFullYear()) + firstDay;
			
			var i:int, len:int;
			len = _daysItems.length;
			for(i = 0; i < len; ++i) {
				_daysItems[i].enabled = (i >= firstDay && i < lastDay);
				_daysItems[i].label = (i-firstDay+1).toString();
			}
		}
		
	}
}