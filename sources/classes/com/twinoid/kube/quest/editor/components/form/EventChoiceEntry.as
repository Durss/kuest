package com.twinoid.kube.quest.editor.components.form {
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import flash.events.MouseEvent;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.graphics.ChoiceModeIcon;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import gs.TweenLite;
	import flash.events.Event;
	import com.nurun.components.form.ToggleButton;
	import com.twinoid.kube.quest.graphics.MoneyIcon;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 22 déc. 2013;
	 */
	public class EventChoiceEntry extends Sprite {
		
		private var _index:int;
		private var _width:int;
		private var _color:uint;
		private var _input:InputKube;
		private var _toggleMoney:ToggleButton;
		private var _inputMoney : InputKube;
		private var _mode : ChoiceModeIcon;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EventChoiceEntry</code>.
		 */
		public function EventChoiceEntry(index:int, width:int, color:uint) {
			_color = color;
			_width = width;
			_index = index;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function get text():String{
			return _input.text;
		}
		
		public function set text(value:String):void {
			_input.text = value;
		}
		
		public function get value():*{
			return _input.value;
		}
		
		override public function set tabIndex(value:int):void {
			_input.tabIndex = value;
		}
		
		/**
		 * Gets if the choice is a paying one
		 */
		public function get payingChoice():Boolean {
			return _toggleMoney.selected;
		}
		
		/**
		 * Gets how much the choice costs
		 */
		public function get choiceCost():uint {
			return _inputMoney.numValue;
		}
		
		/**
		 * Gets the current choice mode (choice, strict, tolerant)
		 */
		public function get choiceMode():String {
			return _mode.currentFrameLabel;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function reset():void {
			_input.text = _input.defaultLabel;
			_toggleMoney.selected = false;
			_inputMoney.text = '0';
			_inputMoney.scaleX = 0;
			computePositions();
		}
		
		/**
		 * Populates the component
		 */
		public function populate(label:String, cost:uint, mode:String):void {
			_input.text = label;
			_toggleMoney.selected = cost > 0;
			_inputMoney.text = cost.toString();
			_inputMoney.scaleX = cost > 0? 1 : 0;
			_mode.gotoAndStop( mode );
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_input			= addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, (_index+1).toString()))) as InputKube;
			_inputMoney		= addChild(new InputKube('0', true, -999999999, 999999999)) as InputKube;
			_toggleMoney	= addChild(new ToggleButton('', '', '', null, null, new MoneyIcon(), new MoneyIcon())) as ToggleButton;
			_mode			= addChild(new ChoiceModeIcon()) as ChoiceModeIcon;
			
			_mode.stop();
			_input.textfield.maxChars = 100;
			_toggleMoney.defaultIcon.alpha = .5;
			_inputMoney.width = 50;
			_inputMoney.scaleX = 0;
			_mode.buttonMode = true;
			
			setToolTip(_toggleMoney, Label.getLabel('editWindow-choice-payingChoice'), ToolTipAlign.TOP_LEFT);
			
			computePositions();
			
			_mode.addEventListener(MouseEvent.CLICK, clickModeHandler);
			_mode.addEventListener(MouseEvent.ROLL_OVER, rollOverModeHandler);
			_toggleMoney.addEventListener(Event.CHANGE, toggleMoneyHandler);
		}
		
		/**
		 * Called when "mode" icon is rolled over to display a tooltip
		 */
		private function rollOverModeHandler(event:MouseEvent):void {
			_mode.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel('editWindow-choice-mode_' + _mode.currentFrameLabel)));
		}

		/**
		 * Called when "mode" icon is clicked to switch answer mode
		 */
		private function clickModeHandler(event:MouseEvent):void {
			_mode.gotoAndStop( _mode.currentFrame % _mode.totalFrames + 1 );
			rollOverModeHandler(event);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_toggleMoney.icon.scaleX	= _toggleMoney.selectedIcon.scaleX	= 
			_toggleMoney.icon.scaleY	= _toggleMoney.selectedIcon.scaleY	= 1;
			_toggleMoney.icon.scaleX	= _toggleMoney.selectedIcon.scaleX	= 
			_toggleMoney.icon.scaleY	= _toggleMoney.selectedIcon.scaleY	= _input.height / _toggleMoney.icon.height;
			
			_input.x			= 11;
			_input.width		= _width - _input.x - _toggleMoney.width - 5 - ((_inputMoney.width+5) * _inputMoney.scaleX) - _mode.width - 5;
			_toggleMoney.x		= _input.x + _input.width;
			_inputMoney.x		= _toggleMoney.x + _toggleMoney.width + 5;
			_inputMoney.validate();
			_mode.x				= _width - _mode.width - 5;
			
			roundPos(_input, _inputMoney, _toggleMoney, _mode);
			
			graphics.clear();
			graphics.beginFill(_color, 1);
			graphics.drawRect(0, 0, 10, _input.height);
			graphics.endFill();
		}
		
		/**
		 * Called when money form is toggled
		 */
		private function toggleMoneyHandler(event:Event):void {
			if(_toggleMoney.selected) {
				TweenLite.to(_inputMoney, .25, {scaleX:1, onUpdate:computePositions});
			}else{
				TweenLite.to(_inputMoney, .25, {scaleX:0, onUpdate:computePositions});
			}
		}
		
	}
}