package com.twinoid.kube.quest.editor.components.menu.debugger {
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.date.TimeSelector;
	import com.twinoid.kube.quest.editor.components.form.CoordinatesSelector;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Fired when form is submitted
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	/**
	 * Displays the zone and date/time form to simulate walk inside the game
	 * and date/time progression.
	 * 
	 * @author Francois
	 * @date 22 sept. 2013;
	 */
	public class GameContextSimulatorForm extends Sprite {

		private var _time:TimeSelector;
		private var _width:int;
		private var _submit:ButtonKube;
		private var _place:CoordinatesSelector;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GameContextSimulatorForm</code>.
		 */
		public function GameContextSimulatorForm(width:int) {
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
			_time.tabIndex = value;
			_place.tabIndex = value + 10;
			_submit.tabIndex = value + 20;
		}
		
		/**
		 * Gets the date.
		 */
		public function get date():Date { return _time.date; }
		
		/**
		 * Gets the coordinates
		 * 
		 * @return a Point or Point3D instance
		 */
		public function get coordinates():* { return _place.coordinates; }



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
			_submit	= addChild(new ButtonKube("GO")) as ButtonKube;
			_place	= addChild(new CoordinatesSelector()) as CoordinatesSelector;
			_time	= addChild(new TimeSelector(_width)) as TimeSelector;
			
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_time.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_place.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions():void {
			_place.y		= _time.height + 5;
			_submit.height	= Math.round(_place.y + _place.height);
			_submit.x		= Math.max(_place.width, _time.width) + 10;
			roundPos(_place, _submit);
		}
		
		/**
		 * Called when the form is submitted.
		 */
		private function submitHandler(event:Event):void {
			dispatchEvent(new FormComponentEvent(FormComponentEvent.SUBMIT));
		}
		
	}
}