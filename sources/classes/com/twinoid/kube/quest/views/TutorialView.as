package com.twinoid.kube.quest.views {
	import flash.utils.setTimeout;
	import flash.net.SharedObject;
	import com.twinoid.kube.quest.model.Model;
	import gs.TweenLite;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.components.window.TitledWindow;
	import com.twinoid.kube.quest.events.ViewEvent;
	import com.twinoid.kube.quest.graphics.TutorialGraphic;
	import com.twinoid.kube.quest.utils.Closable;
	import com.twinoid.kube.quest.utils.makeEscapeClosable;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	/**
	 * 
	 * @author Francois
	 * @date 5 mai 2013;
	 */
	public class TutorialView extends AbstractView implements Closable {
		
		private var _tutorial:TutorialGraphic;
		private var _isClosed:Boolean;
		private var _window:TitledWindow;
		private var _so:SharedObject;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TutorialView</code>.
		 */
		public function TutorialView() {
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
			ViewLocator.getInstance().removeView(this);
			
			if(_so.data["tutorialSeen"] == undefined) {
				setTimeout(open, 1000);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			_isClosed = true;
			TweenLite.to(this, .25, {autoAlpha:0});
		}
		
		/**
		 * Opens the view
		 */
		public function open():void {
			_isClosed = false;
			_tutorial.gotoAndPlay(1);
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
			
			_tutorial = new TutorialGraphic();
			_window = addChild(new TitledWindow(Label.getLabel("tutorial-title"), _tutorial)) as TitledWindow;
			
			alpha = 0;
			visible = false;
			_isClosed = true;
			_tutorial.stop();
			_tutorial.scrollRect = new Rectangle(0,0,600,450);
			_window.width = 600;
			_window.height = 450;
			
			makeEscapeClosable(this);
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			_tutorial.addFrameScript(_tutorial.totalFrames - 1, onTutorialComplete);
			ViewLocator.getInstance().addEventListener(ViewEvent.TUTORIAL, tutorialHandler);
			
			computePositions();
		}
		
		/**
		 * Called when tutorial is completely seen.
		 */
		private function onTutorialComplete():void {
			_so.data["tutorialSeen"] = true;
			_so.flush();
		}

		
		/**
		 * Called when a key is released.
		 * Detects for F1 key to open help.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.F1) {
				open();
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0, .4);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			_window.updateSizes();
			
			PosUtils.centerInStage(_window);
		}
		
		/**
		 * Called when tutorial needs to be displayed
		 */
		private function tutorialHandler(event:ViewEvent):void {
			open();
		}
		
		/**
		 * Called when something is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			close();
		}
		
	}
}