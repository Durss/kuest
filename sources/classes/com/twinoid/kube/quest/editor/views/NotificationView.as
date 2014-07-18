package com.twinoid.kube.quest.editor.views {
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;

	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	
	/**
	 * Singleton ToastView
	 * 
	 * @author Durss
	 * @date 18 juil. 2014;
	 */
	public class NotificationView extends Sprite {
		
		private static var _instance:NotificationView;
		private var _label:CssTextField;
		private var _opened : Boolean;
		private var _success : Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToastView</code>.
		 */
		public function NotificationView(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():NotificationView {
			if(_instance == null)_instance = new  NotificationView(new SingletonEnforcer());
			return _instance;	
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function notify(label:String, success:Boolean = true):void {
			_label.text = label;
			
			visible	= true;
			_success = success;
			
			computePositions();
			
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {y:0});
			TweenLite.to(this, .25, {y:-height - 5, delay:label.length * .1, onComplete:onClose});
			
			_opened = true;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible	= false;
			_label	= addChild(new CssTextField('notification')) as CssTextField;
			filters = [new DropShadowFilter(4, 90, 0, .35, 4, 4, 1, 3)];
			
			mouseChildren = false;
			buttonMode = true;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int = 5;
			graphics.clear();
			graphics.beginFill(_success? 0x69AF3B : 0xC6352D, 1);
			graphics.drawRect(0, -10, _label.width + margin * 4, _label.height + margin * 2 + 10);//10 is a margin to prevent from a fuckin half pixel of emptyness that remains sometimes at the top
			graphics.endFill();
			
			_label.x = margin * 2;
			_label.y = margin;
			
			x = Math.round((stage.stageWidth - width) * .5);
			y = _opened? 0 : -height - 5;
		}
		
		/**
		 * Called when closing animation completes
		 */
		private function onClose():void {
			_opened = false;
			visible = false;
		}
		
		/**
		 * Called when view is clicked to close it.
		 */
		private function clickHandler(event:MouseEvent):void {
			TweenLite.killTweensOf(this);
		}
		
	}
}

internal class SingletonEnforcer{}