package com.twinoid.kube.quest.player.views {
	import com.twinoid.kube.quest.editor.components.window.BackWindow;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Debug view to simulate a game action.
	 * 
	 * @author Francois
	 * @date 22 mai 2013;
	 */
	public class ActionSimulatorView extends Sprite {
		
		private var _inputX:InputKube;
		private var _inputY:InputKube;
		private var _inputZ:InputKube;
		private var _submit:ButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ActionSimulatorView</code>.
		 */
		public function ActionSimulatorView() {
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
			_inputX = addChild(new InputKube("X", true, -99999999*32, 99999999*3)) as InputKube;
			_inputY = addChild(new InputKube("Y", true, -99999999*32, 99999999*3)) as InputKube;
			_inputZ = addChild(new InputKube("Z", true, -99999999*32, 99999999*3)) as InputKube;
			_submit = addChild(new ButtonKube("GO")) as ButtonKube;
			
			_inputX.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_inputY.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_inputZ.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}

		private function submitHandler(event:Event):void {
			if(isEmpty(_inputX.value) || isEmpty(_inputY.value)) return;
			
			if(isEmpty(_inputZ.value)) {
				DataManager.getInstance().simulateZoneChange(_inputX.numValue, _inputY.numValue);
			}else{
				DataManager.getInstance().simulateForumChange(_inputX.numValue, _inputY.numValue, _inputZ.numValue);
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			_inputX.width = _inputY.width = _inputZ.width = 50;
			_inputX.height = _inputY.height = _inputZ.height = 19;
			_inputX.validate();
			_inputY.validate();
			_inputZ.validate();
			_submit.height = _inputX.height;
			PosUtils.hPlaceNext(5, _inputX, _inputY, _inputZ, _submit);
			x = stage.stageWidth - BackWindow.CELL_WIDTH - width;
			y = BackWindow.CELL_WIDTH + 1;
		}
		
	}
}