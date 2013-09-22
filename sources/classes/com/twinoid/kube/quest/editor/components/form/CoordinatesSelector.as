package com.twinoid.kube.quest.editor.components.form {
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.vo.Point3D;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	//Fired when form is submitted
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	/**
	 * Displays a coordinates selector.
	 * 
	 * @author Francois
	 * @date 22 sept. 2013;
	 */
	public class CoordinatesSelector extends Sprite {
		private var _inputX:InputKube;
		private var _inputY:InputKube;
		private var _inputZ:InputKube;
		private var _label:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CoordinatesSelector</code>.
		 */
		public function CoordinatesSelector() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the coordinates
		 * 
		 * @return a Point or Point3D instance
		 */
		public function get coordinates():* {
			var coordinates:*;
			if(isEmpty(_inputZ.value)) {
				coordinates = new Point(_inputX.numValue, _inputY.numValue);
			}else{
				coordinates = new Point3D(_inputX.numValue, _inputY.numValue, _inputZ.numValue);
			}
			return coordinates;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			_inputX.tabIndex = value++;
			_inputY.tabIndex = value++;
			_inputZ.tabIndex = value++;
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
			_label	= addChild(new CssTextField('menu-label-bold')) as CssTextField;
			_inputX	= addChild(new InputKube('X', true, -99999999*32, 99999999*3)) as InputKube;
			_inputY	= addChild(new InputKube('Y', true, -99999999*32, 99999999*3)) as InputKube;
			_inputZ	= addChild(new InputKube('Z', true, -99999999*32, 99999999*3)) as InputKube;
			
			_label.text = Label.getLabel('menu-debug-simulateZone');
			
			_inputX.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_inputY.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_inputZ.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions():void {
			for(var i:int = 0; i < numChildren; ++i) if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			
			_inputX.width = _inputY.width = _inputZ.width = 50;
			_inputX.validate();
			_inputY.validate();
			_inputZ.validate();
			PosUtils.hPlaceNext(5, _label, _inputX, _inputY, _inputZ);
		}
		
		/**
		 * Called when an input is submitted via ENTER key
		 */
		private function submitHandler(event:Event):void {
			if(isEmpty(_inputX.value) || isEmpty(_inputY.value)) return;
			dispatchEvent(event);
		}
		
	}
}