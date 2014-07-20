package com.twinoid.kube.quest.editor.components.menu.file {
	import gs.TweenLite;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.draw.createRect;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.graphics.DeleteIcon;
	import com.twinoid.kube.quest.graphics.HelpSmallIcon;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Durss
	 * @date 19 juil. 2014;
	 */
	public class FileConfigForm extends Sprite implements Closable {
		
		private var _width:int;
		private var _closed:Boolean;
		private var _mask:Shape;
		private var _resetPromptsBt:ButtonKube;
		private var _helpBt:GraphicButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileConfigForm</code>.
		 */
		public function FileConfigForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _mask.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Toggles the open state.
		 */
		public function toggle():void {
			if (_closed) open();
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open():void {
			_closed = false;
			var oldH:int = _mask.height;
			_mask.scaleY = 1;
			var h:int = _mask.height;
			_mask.height = oldH;
			computePositions();
			TweenLite.killTweensOf(_mask);
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {height:h, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			_closed = true;
			TweenLite.killTweensOf(_mask);
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:0, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mask			= addChild(createRect()) as Shape;
			_resetPromptsBt	= addChild(new ButtonKube(Label.getLabel("menu-file-config-prompts"), new DeleteIcon())) as ButtonKube;
			_helpBt			= addChild(new GraphicButtonKube(new HelpSmallIcon(), false)) as GraphicButtonKube;
			
			mask			= _mask;
			_closed			= true;
			_mask.scaleY	= 0;
			setToolTip(_helpBt, Label.getLabel('menu-file-config-promptsHelpTT'));
			
			
			makeEscapeClosable(this, 1);
			
			computePositions();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when help button is clicked to display a confirmation sample.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _helpBt) {
				prompt('menu-file-config-prompts-sampleTitle', 'menu-file-config-prompts-sampleContent', null, 'confirmationSample_'+Math.random());
			}else if(event.target == _resetPromptsBt) {
				ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.PROMPT_RESET));
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var margin:int = 5;
			graphics.clear();
			
			_resetPromptsBt.x	= 
			_resetPromptsBt.y	= margin;
			if(_resetPromptsBt.width > _width - _helpBt.width - margin * 3) {
				_resetPromptsBt.width = _width - _helpBt.width - margin * 3;
				_resetPromptsBt.validate();
			}
			_helpBt.x = _width - _helpBt.width - margin;
			_helpBt.y = Math.round(_resetPromptsBt.y + (_resetPromptsBt.height - _helpBt.height) * .5);
			_helpBt.validate();
			
			var h:int = super.height + margin;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(0, 0, _width, h);
			_mask.graphics.endFill();
			
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h - 1);
			graphics.endFill();
		}
		
	}
}