package com.twinoid.kube.quest.editor.components.menu.debugger {
	import com.nurun.structure.environnement.label.Label;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.nurun.components.text.CssTextField;
	import com.twinoid.kube.quest.editor.components.item.ItemPlaceholder;
	import flash.display.Sprite;
	
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component with an event's data
		 */
		public function populate(event:KuestEvent):void {
			visible = true;
			_currentEvent = event;
			_image.data = event.actionType.getItem();
			_label.text = event.actionType.text;
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_image	= addChild(new ItemPlaceholder()) as ItemPlaceholder;
			_label	= addChild(new CssTextField('menu-label')) as CssTextField;
			_answersSpool = new Vector.<ButtonKube>();
			_answerToIndex = new Dictionary();
			
			computePositions();
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.hCenterIn(_image, _width);
			_label.width = _width;
			_label.y = _image.height + 5;
			
			var i:int, len:int, py:int;
			len = _answersSpool.length;
			py = _label.y + _label.height + 5;
			for(i = 0; i < len; ++i) {
				_answersSpool[i].y = py;
				_answersSpool[i].width = _width;
				py += _answersSpool[i].height + 5;
				roundPos(_answersSpool[i]);
			}
			
			roundPos(_label, _image);
		}
		
		/**
		 * Builds the choices buttons
		 */
		private function buildChoices():void {
			var i:int, len:int, bt:ButtonKube;
			len = _answersSpool.length;
			//Remove everyone
			for(i = 0; i < len; ++i) if(contains(_answersSpool[i])) removeChild(_answersSpool[i]);
			
			len = _currentEvent.actionChoices.choices.length;
			for(i = 0; i < len; ++i) {
				if(_answersSpool.length <= i) {
					bt = new ButtonKube('');
					_answersSpool.push(bt);
					_answerToIndex[bt] = i;
				}else{
					bt = _answersSpool[i];
				}
				addChild(bt);
				bt.label = _currentEvent.actionChoices.choices[i];
			}
			
			if(len == 0) {
				if(_answersSpool.length <= i) {
					bt = new ButtonKube('');
					_answersSpool.push(bt);
					_answerToIndex[bt] = 0;
				}else{
					bt = _answersSpool[i];
				}
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
		
	}
}