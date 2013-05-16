package com.twinoid.kube.quest.editor.views {
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.CheckBoxKube;
	import com.twinoid.kube.quest.editor.components.window.TitledWindow;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.vo.PromptData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.ui.Keyboard;
	import gs.TweenLite;



	/**
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class PromptWindowView extends AbstractView implements Closable {
		
		private var _holder:Sprite;
		private var _window:TitledWindow;
		private var _label:CssTextField;
		private var _yes:ButtonKube;
		private var _no:ButtonKube;
		private var _disable:Sprite;
		private var _data:PromptData;
		private var _closed:Boolean;
		private var _ignore:CheckBoxKube;
		private var _so:SharedObject;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PromptWindowView</code>.
		 */
		public function PromptWindowView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			_so = model.sharedObjects;
			ViewLocator.getInstance().removeView(this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_data != null && _data.callbackCancel != null) _data.callbackCancel();
			_data = null;
			_closed = true;
			TweenLite.to(this, .25, {autoAlpha:0});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			alpha	= 0;
			visible	= false;
			_holder	= new Sprite();
			_label	= _holder.addChild(new CssTextField("window-content")) as CssTextField;
			_yes	= _holder.addChild(new ButtonKube(Label.getLabel("prompt-window-submit"), new SubmitIcon())) as ButtonKube;
			_no		= _holder.addChild(new ButtonKube(Label.getLabel("prompt-window-cancel"), new CancelIcon())) as ButtonKube;
			_ignore	= _holder.addChild(new CheckBoxKube(Label.getLabel("prompt-window-ignore"))) as CheckBoxKube;
			_disable= addChild(new Sprite()) as Sprite;
			_window	= addChild(new TitledWindow("", _holder)) as TitledWindow;
			
			_label.selectable = true;
			
			makeEscapeClosable(this);
			
			ViewLocator.getInstance().addEventListener(ViewEvent.PROMPT, promptHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var w:int = 350;
			_label.width = w;
			_yes.x = w * .4 - _yes.width;
			_no.x = w * .6;
			_yes.y = _no.y = _label.y + _label.height + 10;
			_ignore.y = _yes.y + _yes.height + 10;
			
			roundPos(_label, _yes, _no, _ignore);
			
			_window.updateSizes();
			
			_disable.graphics.clear();
			_disable.graphics.beginFill(0, .25);
			_disable.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disable.graphics.endFill();
			
			PosUtils.centerInStage(_window);
		}
		
		/**
		 * Called when something should be prompted
		 */
		private function promptHandler(event:ViewEvent):void {
			if(!(event.data is PromptData)) {
				throw new Error("Invalid data type! Should be a 'PromptData' instance.");
				return;
			}
			
			_data = event.data as  PromptData;
			
			//If user asked to ignore si kind of action and automatically submit it
			//submit it without asking anything.
			if(_so.data["ignoredPromptActions"] != null && _so.data["ignoredPromptActions"][_data.actionID] === true) {
				submit();
				return;
			}
			
			_closed = false;
			_label.text = _data.content;
			_window.label = _data.title;
			_ignore.selected = false;
			computePositions();
			TweenLite.to(this, .25, {autoAlpha:1});
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_closed || _data == null) return;
			if(event.target == _no || event.target == _disable) {
				close();
			}else if(event.target == _yes){
				submit();
			}
		}
		
		/**
		 * Submits the form when SPACE or ENTER key is released.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(_data == null) return;
			if(event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.SPACE) {
				submit();
			}
		}
		
		private function submit():void {
			if(_ignore.selected) {
				if(_so.data["ignoredPromptActions"] == undefined) {
					_so.data["ignoredPromptActions"] = {};
					_so.flush();
				}
				_so.data["ignoredPromptActions"][_data.actionID] = true;
				_so.flush();
			}
			
			_data.callback();
			_data = null;
			
			close();
		}
		
	}
}