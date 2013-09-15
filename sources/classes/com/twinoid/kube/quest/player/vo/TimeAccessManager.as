package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.utils.getTimer;
	
	/**
	 * Defines if an event is accessible on time.
	 * 
	 * @author Francois
	 * @date 14 sept. 2013;
	 */
	public class TimeAccessManager {
		
		private var _time:int;
		private var _testMode:Boolean;
		private var _date:Date;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TimeAccessManager</code>.
		 */
		public function TimeAccessManager() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the current date
		 */
		public function get currentDate():Date {
			if(_testMode) return new Date();
			_date.time = _time + getTimer();
			return _date;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initializes the manager
		 */
		public function initialize(time:int, testMode:Boolean):void {
			_time		= time;
			_date		= new Date();
			_testMode	= testMode;
		}
		
		/**
		 * Checks if an event is accessible or not.
		 */
		public function isEventAccessible(event:KuestEvent):Boolean {
			var i:int, len:int, allowed:Boolean;
			var today:Date = currentDate;
			var timestamp:int = today.hours * 60 + today.minutes;
			var dates:Vector.<Date> = event.actionDate.dates;
			
			//DATES TEST
			if (dates != null && dates.length > 0 ) {
				len = dates.length;
				allowed = false;
				for(i = 0; i < len; ++i) {
					//Allowed date, break this loop and continue.
					if(dates[i].date == today.date && dates[i].fullYear == today.fullYear && dates[i].month == dates[i].month) {
						allowed = true;
						break;
					}
				}
				//Today not found in dates, skip this loop turn
				if(!allowed) return false;
			}
			
			//DAYS AND HOURS TEST
			var days:Array = event.actionDate.days;
			if (days != null && days.length > 0 ) {
				len = days.length;
				allowed = false;
				for(i = 0; i < len; ++i) {
					if (days[i] == today.day) {
						var start:int = event.actionDate.startTime;
						var end:int = event.actionDate.endTime;
						if(start > end) {
							if(timestamp >= start || timestamp < end) {
								allowed = true;
								break;
							}
						}else
						if(timestamp >= start && timestamp < end) {
							allowed = true;
							break;
						}
					}
				}
				//Day and hours not found, skip this loop turn
				if(!allowed) return false;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}