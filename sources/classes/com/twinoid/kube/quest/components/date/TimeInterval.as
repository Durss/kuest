package com.twinoid.kube.quest.components.date {
	import com.nurun.utils.pos.roundPos;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.components.form.input.InputKube;
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class TimeInterval extends Sprite {
		private var _startLabel:CssTextField;
		private var _endLabel:CssTextField;
		private var _startHour:InputKube;
		private var _startMinutes:InputKube;
		private var _endHour:InputKube;
		private var _endMinutes:InputKube;
		private var _startHLabel:CssTextField;
		private var _startMLabel:CssTextField;
		private var _endHLabel:CssTextField;
		private var _endMLabel:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>HourInterval</code>.
		 */
		public function TimeInterval() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the start time in seconds
		 */
		public function get startTime():int {
			return _startMinutes.numValue + _startHour.numValue * 60;
		}
		
		/**
		 * Gets the end time in seconds
		 */
		public function get endTime():int {
			return _endMinutes.numValue + _endHour.numValue * 60;
		}
		
		/**
		 * Sets the start time in seconds
		 */
		public function set startTime(value:int):void {
			_startMinutes.text = value%60+"";
			_startHour.text = Math.floor(value / 60)+"";
		}
		
		/**
		 * Sets the end time in seconds
		 */
		public function set endTime(value:int):void {
			_endMinutes.text = value%60+"";
			_endHour.text = Math.floor(value / 60)+"";
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
			_startLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_endLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_startHLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_startMLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_endHLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_endMLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_endLabel = addChild(new CssTextField("editWindow-label")) as CssTextField;
			_startHour = addChild(new InputKube("0", true, 0, 23)) as InputKube;
			_startMinutes = addChild(new InputKube("0", true, 0, 59)) as InputKube;
			_endHour = addChild(new InputKube("0", true, 0, 23)) as InputKube;
			_endMinutes = addChild(new InputKube("0", true, 0, 59)) as InputKube;
			
			_startLabel.text = Label.getLabel("editWindow-time-hourIntervalStart");
			_endLabel.text = Label.getLabel("editWindow-time-hourIntervalEnd");
			
			_startHLabel.text = Label.getLabel("editWindow-time-hourInterval-hoursLabel");
			_startMLabel.text = Label.getLabel("editWindow-time-hourInterval-miutesLabel");
			
			_endHLabel.text = Label.getLabel("editWindow-time-hourInterval-hoursLabel");
			_endMLabel.text = Label.getLabel("editWindow-time-hourInterval-miutesLabel");
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var ox:int		= Math.max(_startLabel.width, _endLabel.width) + 5;
			_startHour.x	= _endHour.x		= ox;
			_startHLabel.x	= _endHLabel.x		= _startHour.x + _startHour.width;
			_startMinutes.x	= _endMinutes.x		= _startHLabel.x + _startHLabel.width + 10;
			_startMLabel.x	= _endMLabel.x		= _startMinutes.x + _startMinutes.width;
			
			_endLabel.y = _endHour.y = _endHLabel.y = _endMinutes.y = _endMLabel.y = _startHour.height + 5;
			
			roundPos(_startHLabel, _startHour, _startLabel, _startMinutes, _startMLabel, _endHLabel, _endHour, _endLabel, _endMinutes, _endMLabel);
		}
		
	}
}