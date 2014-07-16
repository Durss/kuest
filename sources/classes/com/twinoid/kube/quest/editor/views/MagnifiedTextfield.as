package com.twinoid.kube.quest.editor.views {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import gs.TweenLite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.MagnifyableTextfield;
	import com.twinoid.kube.quest.editor.components.form.input.TextArea;
	import com.twinoid.kube.quest.editor.components.window.TitledWindow;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * 
	 * @author Durss
	 * @date 4 avr. 2014;
	 */
	public class MagnifiedTextfield extends Sprite {
		private var _window:TitledWindow;
		private var _content:Sprite;
		private var _textarea:TextArea;
		private var _dimmer:Shape;
		private var _currentTarget : MagnifyableTextfield;
		private var _infos : CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MagnifiedTextfield</code>.
		 */
		public function MagnifiedTextfield() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
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
		private function initialize(event:Event):void {
			visible		= false;
			_dimmer		= addChild(createRect(0x55000000)) as Shape;
			_content	= new Sprite();
			_textarea	= _content.addChild(new TextArea('', '', false)) as TextArea;
			_infos		= _content.addChild(new CssTextField('window-content-smallCenter')) as CssTextField;
			_window		= addChild(new TitledWindow('', _content)) as TitledWindow;
			
			_infos.text	= Label.getLabel('global-magnifiedTextfieldInfo');
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			_textarea.textfield.addEventListener(Event.CHANGE, changeHandler);
			stage.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, true, 0xffffff);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			_textarea.width		= stage.stageWidth * .4;
			_textarea.height	= stage.stageHeight * .5;
			_infos.y			= _textarea.y + _textarea.height;
			_infos.x			= Math.round((_textarea.width - _infos.width) * .5);
			_infos.width		= _textarea.width;
			_dimmer.width		= stage.stageWidth;
			_dimmer.height		= stage.stageHeight;
			_textarea.validate();
			_window.updateSizes();
			
			PosUtils.centerInStage(_window);
		}
		
		/**
		 * Detects focus on a magnifyable textfields.
		 */
		private function focusInHandler(event:FocusEvent):void {
			var target:MagnifyableTextfield = event.target as MagnifyableTextfield;
			if(target != null) {
				_currentTarget	= target;
				_window.title	= _currentTarget.title;
				setTimeout(configureWindow, 0);//Need a fuckin one frame delay so the focus and caretIndex work.
			}
		}
		
		/**
		 * Called when textarea's value changes
		 */
		private function changeHandler(event:Event):void {
			if(_currentTarget != null) {
				_currentTarget.text = _textarea.text;
			}
		}
		
		/**
		 * Configures the window when a magnifiable textfield receives focus
		 */
		private function configureWindow():void {
			_textarea.textfield.style		= _currentTarget.style;
			_textarea.textfield.text		= _currentTarget.text;
			_textarea.textfield.maxChars	= _currentTarget.maxChars;
			stage.focus						= _textarea.textfield;
			open();
			_textarea.textfield.setSelection(_currentTarget.caretIndex, _currentTarget.caretIndex);
			var p1:Point = _currentTarget.localToGlobal(new Point());
			var p2:Point = _textarea.textfield.localToGlobal(new Point());
			p2 = _window.globalToLocal(p2);
			
			var w:int = (_currentTarget.parent is TextArea)? _currentTarget.parent.width : _currentTarget.width;
			
			_dimmer.alpha = 1;
			TweenLite.from(_dimmer, .25, {alpha:0});
			TweenLite.from(_textarea, .25, {width:w, height:_currentTarget.height, onUpdate:_textarea.validate, delay:.1});
			TweenLite.from(_infos, .25, {width:w, y:_currentTarget.height, onUpdate:_textarea.validate, delay:.1});
			TweenLite.from(_window, .25, {x:p1.x - p2.x, y:p1.y - p2.y, onUpdate:_window.updateSizes, delay:.1});
		}
		
		/**
		 * Listens for CTRL+Enter or ESCAPE to close the view.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if( (event.keyCode == Keyboard.ENTER && event.ctrlKey) || event.keyCode == Keyboard.ESCAPE) {
				event.stopImmediatePropagation();
				close();
			}
		}
		
		/**
		 * Called when a component is clicked.
		 * Detect click on dimmer
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target != _window && !_window.contains(event.target as DisplayObject)) {
				close();
			}
		}
		
		/**
		 * Opens the view
		 */
		private function open():void {
			visible = true;
			computePositions();
		}
		
		/**
		 * Closes the view
		 */
		private function close():void {
			if(_currentTarget != null) _currentTarget.text = _textarea.text;
			_currentTarget = null;
			visible = false;
		}
		
	}
}