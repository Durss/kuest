package com.twinoid.kube.quest.editor.components.menu.debugger {
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.editor.vo.ActionChoices;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.MoneyIcon;
	import com.twinoid.kube.quest.player.utils.enrichText;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	//Fired when an answer is selected.
	[Event(name="select", type="flash.events.Event")]
	
	/**
	 * Displays a KuestEvent data.
	 * Displays the image, the text, and the optionnal choices
	 * 
	 * @author Francois
	 * @date 21 sept. 2013;
	 */
	public class KuestEventDisplay extends Sprite {
		
		private var _image:ItemPlaceholder;
		private var _label:CssTextField;
		private var _answersSpool:Vector.<ButtonKube>;
		private var _currentEvent:KuestEvent;
		private var _width:int;
		private var _answerToIndex:Dictionary;
		private var _selectedAnswerIndex:int;
		private var _money : int;
		private var _input : InputKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestEventDisplay</code>.
		 */
		public function KuestEventDisplay(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the selected answer index.
		 */
		public function get selectedAnswerIndex():int {
			return _selectedAnswerIndex;
		}
		
		/**
		 * Gets the input's content or null if it's not a textual answer
		 */
		public function get textualAnswer():String {
			if(!contains(_input)) return null;
			return _input.text;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component with an event's data
		 */
		public function populate(event:KuestEvent, money:int):void {
			_money = money;
			if (event == null) {
				clear();
				return;
			}
			if(event.isEmpty()) {
				_image.visible = false;
				_label.text = Label.getLabel('menu-debug-emptyEvent');
				visible = true;
				computePositions();
				return;
			}
			visible = true;
			_currentEvent = event;
			if(event.actionType.getItem() != null) {
				_image.visible = true;
				_image.data = event.actionType.getItem();
			}else{
				_image.visible = false;
				_image.clear();
			}
			_label.text = enrichText(event.actionType.text);
			buildChoices();
		}
		
		/**
		 * Clears the view's content
		 */
		public function clear():void {
			visible = false;
			var i:int, len:int;
			len = _answersSpool.length;
			for(i = 0; i < len; ++i) if(contains(_answersSpool[i])) removeChild(_answersSpool[i]);
			_label.text = "";
			_image.clear();
		}
		
		/**
		 * Makes the input blink red
		 */
		public function flashErrorInput():void {
			_input.errorFlash();
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_image	= addChild(new ItemPlaceholder()) as ItemPlaceholder;
			_label	= addChild(new CssTextField('menu-label')) as CssTextField;
			_input	= addChild(new InputKube(Label.getLabel('player-inputAnswerPlaceholder'))) as InputKube;
			_answersSpool = new Vector.<ButtonKube>();
			_answerToIndex = new Dictionary();
			
			computePositions();
			addEventListener(MouseEvent.CLICK, clickHandler);
			_input.addEventListener(FormComponentEvent.SUBMIT, submitInputHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.hCenterIn(_image, _width);
			_label.width = _width;
			_label.y = _image.visible? _image.height + 5 : _image.y;
			
			var i:int, len:int, py:int;
			len = _answersSpool.length;
			py = _label.y + _label.height + 5;
			
			
			if(contains(_input)) {
				_input.y = py;
				py = _input.y + _input.height + 5;
			}
			for(i = 0; i < len; ++i) {
				_answersSpool[i].y = py;
				_answersSpool[i].width = _width;
				py += _answersSpool[i].height + 5;
				roundPos(_answersSpool[i]);
			}
			
			_input.width = _width;
			
			roundPos(_label, _image);
		}
		
		/**
		 * Builds the choices buttons
		 */
		private function buildChoices():void {
			var i:int, len:int, bt:ButtonKube, hasAnInputChoice:Boolean;
			len = _answersSpool.length;
			//Remove everyone
			for(i = 0; i < len; ++i) if(contains(_answersSpool[i])) removeChild(_answersSpool[i]);
			
			len = _currentEvent.actionChoices.choices.length;
			for(i = 0; i < len; ++i) {
				if (_currentEvent.actionChoices.choicesModes != null
				&& _currentEvent.actionChoices.choicesModes.length > i
				&& (_currentEvent.actionChoices.choicesModes[i] == null
				|| _currentEvent.actionChoices.choicesModes[i] != ActionChoices.MODE_CHOICE)) {
					hasAnInputChoice = true;
					continue;//Don't create button ! Just need the input.
				}
				
				if(_answersSpool.length <= i) {
					bt = new ButtonKube('');
					_answersSpool.push(bt);
					_answerToIndex[bt] = i;
				}else{
					bt = _answersSpool[i];
				}
				addChild(bt);
				bt.label = _currentEvent.actionChoices.choices[i];
				bt.enabled = true;
				bt.icon = null;
				if(_currentEvent.actionChoices.choicesCost.length > i && _currentEvent.actionChoices.choicesCost[i] != 0) {
					bt.icon = new MoneyIcon();
					bt.iconAlign = IconAlign.LEFT;
					bt.icon.scaleX = bt.icon.scaleY = 2;
					bt.label = '(x'+_currentEvent.actionChoices.choicesCost[i]+')    '+bt.label;
					bt.enabled = _money >= _currentEvent.actionChoices.choicesCost[i];
				}
			}
			
			//Add/remove input field
			if(hasAnInputChoice) addChild(_input);
			else if(contains(_input)) removeChild(_input);
			
			if(len == 0) {
				if(_answersSpool.length <= i) {
					bt = new ButtonKube('');
					_answersSpool.push(bt);
					_answerToIndex[bt] = 0;
				}else{
					bt = _answersSpool[i];
				}
				bt.enabled = true;
				bt.icon = null;
				addChild(bt);
				bt.label = Label.getLabel('player-next');
			}
			
			computePositions();
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_answerToIndex[ event.target ] == undefined) return;
			_selectedAnswerIndex = _answerToIndex[ event.target ];
			dispatchEvent(new Event(Event.SELECT));
		}
		
		/**
		 * Called when user submits an answer from the input
		 */
		private function submitInputHandler(event:FormComponentEvent):void {
			dispatchEvent(new Event(Event.SELECT));
		}
		
	}
}