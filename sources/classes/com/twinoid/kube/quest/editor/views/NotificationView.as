package com.twinoid.kube.quest.editor.views {
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;

	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	
	/**
	 * Singleton NotificationView
	 * 
	 * @author Durss
	 * @date 18 juil. 2014;
	 */
	public class NotificationView extends Sprite {
		
		private static var _instance:NotificationView;
		private var _label:CssTextField;
		private var _opened : Boolean;
		private var _success : Boolean;
		private var _displayLoader : Boolean;
		private var _spin : LoaderSpinning;
		
		
		
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
		public function notify(label:String, success:Boolean = true, displayLoader:Boolean = false):void {
			_label.text = label;
			_displayLoader = displayLoader;
			
			visible	= true;
			_success = success;
			
			if(_displayLoader) addChild(_spin);
			else if(contains(_spin)) removeChild(_spin);
			
			computePositions();
			
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {y:0});
			if(!_displayLoader) {
				TweenLite.to(this, .25, {y:-height - 5, delay:label.length * .1, onComplete:onClose});
			}else{
				_spin.open();
			}
			
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
			_spin	= new LoaderSpinning();
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
			var w:int = _displayLoader? Math.max(_label.width, _spin.width) : _label.width;
			var h:int = _displayLoader? Math.max(_label.height, _spin.height) : _label.height;
			graphics.clear();
			graphics.beginFill(_success? 0x69AF3B : 0xC6352D, 1);
			graphics.drawRect(0, -10, w + margin * 4, h + margin * 2 + 10);//10 is a margin to prevent from a fuckin half pixel of emptyness that remains sometimes at the top
			graphics.endFill();
			
			_label.x = margin * 2;
			_label.y = margin;
			
			_spin.x = _spin.width * .5 + margin * 2;
			_spin.y = _spin.height * .5 + margin;
			
			var menu:SideMenuView = ViewLocator.getInstance().locateViewByType(SideMenuView) as SideMenuView;
			if(menu != null) {
				x = menu.x + menu.width + Math.round((stage.stageWidth - (menu.x + menu.width) - width) * .5);
			}else{
				x = Math.round((stage.stageWidth - width) * .5);
			}
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
			TweenLite.to(this, .25, {y:-height - 5, onComplete:onClose});
		}
		
	}
}

internal class SingletonEnforcer{}