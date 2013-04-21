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
		private var _daysMode:Boolean;
		private var _alwaysEnabled:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionDate</code>.
		 */
		public function ActionDate(dates:Vector.<Date> = null, days:Array = null, startTime:int = 0, endTime:int = 0) {
			_endTime = endTime;
			_startTime = startTime;
			_days = days;
			_dates = dates;
			_daysMode = dates == null;
			_alwaysEnabled = _daysMode && days == null;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the dates when an action is enabled
		 */
		public function get dates():Vector.<Date> { return _dates; }
		
		/**
		 * Gets the days in a week when the action is enabled
		 */
		public function get days():Array { return _days; }
		
		/**
		 * Gets the start time (in seconds) of the action (used daysMode is true)
		 */
		public function get startTime():int { return _startTime; }

		/**
		 * Gets the end time (in seconds) of the action (used daysMode is true)
		 */
		public function get endTime():int { return _endTime; }
		
		/**
		 * Gets if the data are stored in days mode, or not.
		 * DaysMode means that the action is enabled in specific days of the
		 * week during a specific hour range. If not in days mode, the action
		 * is enabled only at sepecifc dates.
		 */
		public function get daysMode():Boolean { return _daysMode; }
		
		/**
		 * Gets if the action is alays enabled or not.
		 * If not, then the action is enabled only at specific dates, or only
		 * specific days of the week during a specific time range (daysMode=true).
		 */
		public function get alwaysEnabled():Boolean { return _alwaysEnabled; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}