package com.twinoid.kube.quest.vo {
	
	/**
	 * Contains an event's dates
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class ActionDate {
		
		private var _dates:Vector.<Date>;
		private var _days:Array;
		private var _startTime:int;
		private var _endTime:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionDate</code>.
		 */
		public function ActionDate() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the dates when an action is enabled
		 */
		public function get dates():Vector.<Date> { return _dates; }

		/**
		 * Sets the dates when an action is enabled
		 */
		public function set dates(dates:Vector.<Date>):void { _dates = dates; }
		
		/**
		 * Gets the days in a week when the action is enabled
		 */
		public function get days():Array { return _days; }

		/**
		 * Sets the days in a week when the action is enabled
		 */
		public function set days(days:Array):void { _days = days; }
		
		/**
		 * Gets the start time (in seconds) of the action (used daysMode is true)
		 */
		public function get startTime():int { return _startTime; }

		/**
		 * Sets the start time (in seconds) of the action (used daysMode is true)
		 */
		public function set startTime(startTime:int):void { _startTime = startTime; }

		/**
		 * Gets the end time (in seconds) of the action (used daysMode is true)
		 */
		public function get endTime():int { return _endTime; }

		/**
		 * Sets the end time (in seconds) of the action (used daysMode is true)
		 */
		public function set endTime(endTime:int):void { _endTime = endTime; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[ActionDate :: dates="+dates+", days="+days+", startTime="+startTime+", endTime="+endTime+", alwaysEnabled="+getAlwaysEnabled()+"]";
		}
		
		public function dispose():void {
			_dates = null;
			_days = null;
		}
		
		/**
		 * Gets if the data are stored in days mode, or not.
		 * DaysMode means that the action is enabled in specific days of the
		 * week during a specific hour range. If not in days mode, the action
		 * is enabled only at sepecifc dates.
		 */
		public function getDaysMode():Boolean { return dates == null; }
		
		/**
		 * Gets if the action is alays enabled or not.
		 * If not, then the action is enabled only at specific dates, or only
		 * specific days of the week during a specific time range (daysMode=true).
		 */
		public function getAlwaysEnabled():Boolean { return getDaysMode() && days == null; }


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}