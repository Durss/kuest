package com.twinoid.kube.quest.editor.components.menu {
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.touch.SwipeManager;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.editor.model.Model;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;

	
	/**
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class AbstractMenuContent extends Sprite {
		
		protected var _scrollpane:ScrollPane;
		protected var _holder:ScrollableDisplayObject;
		protected var _width:int;
		protected var _title:CssTextField;
		private var _swiper:SwipeManager;
		private var _backTitle:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstractMenuContent</code>.
		 */
		public function AbstractMenuContent(width:int) {
			_width = width;
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		public function update(model:Model):void {
			
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			_holder = new ScrollableDisplayObject();
			_backTitle = addChild(new Shape()) as Shape;
			_scrollpane = addChild(new ScrollPane(_holder, new ScrollbarKube())) as ScrollPane;
			_title = addChild(new CssTextField("menu-title")) as CssTextField;
			
			_swiper = new SwipeManager(_holder.content, new Rectangle(0,0,_width, 500));
			_swiper.start();
			_swiper.lockX = true;
			
			_backTitle.filters = [new DropShadowFilter(3,90,0,.4,0,5,1,3)];
			_title.filters = [new DropShadowFilter(2,135,0,.35,2,2,2,2)];
			
			_scrollpane.autoHideScrollers = true;
			
			_scrollpane.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			_scrollpane.vScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(Event.ADDED_TO_STAGE, computePositions);
			addEventListener(MouseEvent.CLICK, catchEvent, true);
			addEventListener(MouseEvent.MOUSE_UP, catchEvent, true);
		}

		private function scrollHandler(event:Event):void {
			_swiper.syncWithContent();
		}

		private function catchEvent(event:MouseEvent):void {
			if(_swiper.hasMovedMoreThan()) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				_swiper.transmitMouseUp(event);
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		 protected function computePositions(event:Event = null):void {
			if(stage == null) return;
			
			_backTitle.graphics.clear();
			_backTitle.graphics.beginFill(0x2D89B0, 1);
			_backTitle.graphics.drawRect(0, 0, _width, Math.round(_title.height));
			_backTitle.graphics.endFill();
			
			_title.width = _width;
			
			_holder.content.graphics.clear();
			
			_scrollpane.y = _title.height + 10;
			_scrollpane.width = _width;
			_scrollpane.height = stage.stageHeight - _scrollpane.y;
			_scrollpane.validate();
			
			_swiper.viewport.height = _scrollpane.height;
			_swiper.viewport.width = _width;
			_swiper.start(true);
			_swiper.syncWithContent();
			
			//Hit zone for swipe manager.
			_holder.content.graphics.beginFill(0xff0000, 0);
			_holder.content.graphics.drawRect(0, 0, _holder.content.width, _holder.content.height);
			_holder.content.graphics.endFill();
		}
		
	}
}