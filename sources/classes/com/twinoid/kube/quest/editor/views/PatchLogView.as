package com.twinoid.kube.quest.editor.views {
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.window.TitledWindow;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.text.TextFieldAutoSize;



	/**
	 * DIsplays the patch log view
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class PatchLogView extends AbstractView implements Closable {
		
		private var _isClosed:Boolean;
		private var _window:TitledWindow;
		private var _so:SharedObject;
		private var _label:CssTextField;
		private var _holder:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PatchLogView</code>.
		 */
		public function PatchLogView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _isClosed; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			_so = model.sharedObjects;
			var tutorial:TutorialView = ViewLocator.getInstance().locateViewByType(TutorialView) as TutorialView;
			ViewLocator.getInstance().removeView(this);
			
			//If no log related to the current version has been seen by the user.
			if(_so.data["log_"+Config.getVariable("version")+"_Seen"] == undefined) {
				//A label related to the current version exists
				if( !/^\[missing.*]/gi.test( Label.getLabel("patchlog"+Config.getVariable("version")+"-content")) ) {
					//If tutorial has been seen.
					if(tutorial == null) {
						//Show log !
						open();
					}else{
						//Wait for tutorial to be seen before opening this view
						tutorial.addEventListener(Event.CLOSE, open);
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			_isClosed = true;
			_so.data["log_"+Config.getVariable("version")+"_Seen"] = true;
			_so.flush();
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {autoAlpha:0});
		}
		
		/**
		 * Opens the view
		 */
		public function open(...args):void {
			_isClosed = false;
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {autoAlpha:1});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_holder		= new Sprite();
			_label		= _holder.addChild(new CssTextField("window-content")) as CssTextField;
			_window		= addChild(new TitledWindow(Label.getLabel("patchlog-title"), _holder)) as TitledWindow;
			
			alpha = 0;
			visible = false;
			_isClosed = true;
			_label.y = -5;
			_label.selectable = true;
			_label.text = Label.getLabel("patchlog"+Config.getVariable("version")+"-content").replace(/\r|\n|\t/gi, "");
			_label.autoWrap = true;
			
			makeEscapeClosable(this);
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0, .4);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			_label.autoSize = TextFieldAutoSize.LEFT;
			if(_label.width > 500) _label.width = 500;
			
			_window.updateSizes();
			
			PosUtils.centerInStage(_window);
		}
		
		/**
		 * Called when something is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target != _window && !_window.contains(event.target as DisplayObject)) {
				close();
			}
		}
		
	}
}