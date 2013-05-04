package com.twinoid.kube.quest.components.menu {
	import com.twinoid.kube.quest.model.Model;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.twinoid.kube.quest.components.form.ScrollbarKube;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	
	/**
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class AbstractMenuContent extends Sprite {
		
		protected var _scrollpane:ScrollPane;
		protected var _holder:ScrollableDisplayObject;
		protected var _width:int;
		protected var _label:CssTextField;
		
		
		
		
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
			_scrollpane = addChild(new ScrollPane(_holder, new ScrollbarKube())) as ScrollPane;
			_label = addChild(new CssTextField("menu-title")) as CssTextField;
			
			_label.background = true;
			_label.backgroundColor = 0x2D89B0;
			_label.filters = [new DropShadowFilter(3,90,0,.4,0,5,1,3)];
			
			_scrollpane.autoHideScrollers = true;
			
			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(Event.ADDED_TO_STAGE, computePositions);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		 protected function computePositions(event:Event = null):void {
			if(stage == null) return;
			
			_label.width = _width;
			
			_scrollpane.y = _label.height + 10;
			_scrollpane.width = _width;
			_scrollpane.height = stage.stageHeight - _scrollpane.y;
			_scrollpane.validate();
		}
		
	}
}