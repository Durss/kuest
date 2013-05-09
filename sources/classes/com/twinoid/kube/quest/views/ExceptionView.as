package com.twinoid.kube.quest.views {
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import flash.events.MouseEvent;
	import com.nurun.utils.pos.PosUtils;
	import gs.TweenLite;
	import com.twinoid.kube.quest.utils.Closable;
	import com.twinoid.kube.quest.error.KuestException;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.components.window.TitledWindow;
	import flash.events.UncaughtErrorEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 mai 2013;
	 */
	public class ExceptionView extends Sprite implements Closable {
		
		private var _label:CssTextField;
		private var _window:TitledWindow;
		private var _closed:Boolean;
		private var _disable:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ExceptionView</code>.
		 */
		public function ExceptionView() {
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
		/**
		 * @inheritDoc
		 */
		public function open():void {
			_closed = false;
			computePositions();
			TweenLite.to(this, .25, {autoAlpha:1});
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
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
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			
			alpha = 0;
			_closed = true;
			visible = false;
			
			_disable	= addChild(new Sprite()) as Sprite;
			_label		= addChild(new CssTextField("window-content")) as CssTextField;
			_window		= addChild(new TitledWindow(Label.getLabel("exception-title"), _label)) as TitledWindow;
			
			makeEscapeClosable(this);
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			_disable.graphics.clear();
			_disable.graphics.beginFill(0, .3);
			_disable.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disable.graphics.endFill();
			
			_label.width = 300;
			_window.updateSizes();
			
			PosUtils.centerInStage(_window);
		}
		
		/**
		 * Called when disable layer is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			close();
		}
		
		/**
		 * Called if an uncaught exception occurs.
		 */
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			if (event.error is KuestException) {
				event.preventDefault();
				event.stopImmediatePropagation();
				_label.text = KuestException(event.error).message;
				open();
			}
		}
		
	}
}