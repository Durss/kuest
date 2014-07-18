package com.twinoid.kube.quest.editor.components.form {
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
		private var _toggle:ToggleButton;
		private var _inputMoney:InputKube;
		
		
		
		
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
			return _toggle.selected;
		}
		
		/**
		 * Gets how much the choice costs
		 */
		public function get choiceCost():uint {
			return _inputMoney.numValue;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function reset():void {
			_input.text = _input.defaultLabel;
			_toggle.selected = false;
			_inputMoney.text = '0';
			_inputMoney.scaleX = 0;
			computePositions();
		}
		
		/**
		 * Populates the component
		 */
		public function populate(label:String, cost:uint):void {
			_input.text = label;
			_toggle.selected = cost > 0;
			_inputMoney.text = cost.toString();
			_inputMoney.scaleX = cost > 0? 1 : 0;
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_input		= addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, (_index+1).toString()))) as InputKube;
			_inputMoney	= addChild(new InputKube('0', true, 0, 9999999999)) as InputKube;
			_toggle		= addChild(new ToggleButton('', '', '', null, null, new MoneyIcon(), new MoneyIcon())) as ToggleButton;
			
			_input.textfield.maxChars = 100;
			_toggle.defaultIcon.alpha = .5;
			_inputMoney.width = 50;
			_inputMoney.scaleX = 0;
			
			setToolTip(_toggle, Label.getLabel('editWindow-choice-payingChoice'), ToolTipAlign.TOP_LEFT);
			
			computePositions();
			
			_toggle.addEventListener(Event.CHANGE, toggleMoneyHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_toggle.icon.scaleX	= _toggle.selectedIcon.scaleX	= 
			_toggle.icon.scaleY	= _toggle.selectedIcon.scaleY	= 1;
			_toggle.icon.scaleX	= _toggle.selectedIcon.scaleX	= 
			_toggle.icon.scaleY	= _toggle.selectedIcon.scaleY	= _input.height / _toggle.icon.height;
			
			_input.x		= 11;
			_input.width	= _width - _input.x - _toggle.width - 5 - ((_inputMoney.width+5) * _inputMoney.scaleX);
			_toggle.x		= _input.x + _input.width;
			_inputMoney.x	= _toggle.x + _toggle.width + 5;
			_inputMoney.validate();
			
			graphics.clear();
			graphics.beginFill(_color, 1);
			graphics.drawRect(0, 0, 10, _input.height);
			graphics.endFill();
		}
		
		/**
		 * Called when money form is toggled
		 */
		private function toggleMoneyHandler(event:Event):void {
			if(_toggle.selected) {
				TweenLite.to(_inputMoney, .25, {scaleX:1, onUpdate:computePositions});
			}else{
				TweenLite.to(_inputMoney, .25, {scaleX:0, onUpdate:computePositions});
			}
		}
		
	}
}