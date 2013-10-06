package com.twinoid.kube.quest.editor.components.menu.debugger {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.utils.touch.SwipeManager;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.player.components.InventoryTileItem;
	import com.twinoid.kube.quest.player.vo.InventoryObject;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	//Fired when an object is selected
	[Event(name="select", type="flash.events.Event")]
	
	/**
	 * Displays the debugger's inventory.
	 * 
	 * @author Francois
	 * @date 6 oct. 2013;
	 */
	public class GameInventorySimulatorForm extends Sprite {
		
		private var _width:int;
		private var _label:CssTextField;
		private var _engine:TileEngine2DSwipeWrapper;
		private var _scrollpane:ScrollPane;
		private var _swiper:SwipeManager;
		private var _objectUsed:InventoryObject;
		
		

		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GameInventorySimulatorForm</code>.
		 */
		public function GameInventorySimulatorForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the last selected object
		 */
		public function get objectUsed():InventoryObject { return _objectUsed; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(objs:Vector.<InventoryObject>):void {
			_engine.clear();
			if(objs.length > 0) {
				_engine.addLine(VectorUtils.toArray(objs));
			}
			_engine.validate();
			_scrollpane.update();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label			= addChild(new CssTextField('menu-label-bold')) as CssTextField;
			_engine			= new TileEngine2DSwipeWrapper(InventoryTileItem, _width, 50, 50, 50, 1, 0);
			var w:int		= _engine.visibleWidth;
			var h:int		= _engine.visibleHeight;
			_scrollpane		= addChild(new ScrollPane(_engine, null, new ScrollbarKube())) as ScrollPane;
			_swiper			= new SwipeManager(_engine, new Rectangle());
			
			_label.text				= Label.getLabel('menu-debug-inventory');
			_engine.lockToLimits	= true;
			_swiper.roundXValue		= _engine.itemWidth + _engine.hMargin;
			_scrollpane.width		= w;
			_scrollpane.height		= h + 15;//15 = scrollbar's height
			_swiper.viewport.width	= w;
			_swiper.viewport.height	= h;
			
			addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_scrollpane.hScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_scrollpane.y = Math.round(_label.y + _label.height);
			_swiper.start(false, false);
//			graphics.beginFill(0xff0000, 0);
//			graphics.drawRect(0, 0, _width, _height);
//			graphics.endFill();
		}
		
		/**
		 * Scroll problem patch.
		 * By default the scrollpane doesn't works very well with TileEngine2DSwipeWrapper.
		 * The SwipeManager moves the content constantly to an "end" position.
		 * If that end position isn't updated when the mouse wheel is used over
		 * the scrollpane, the scrollpane will scroll the content, but right
		 * after, the SwipeManager will move it back to its previous "end"
		 * position.
		 * Here we force the SwipeManager to synch with the content's position.
		 */
		private function scrollHandler(event:Event):void {
			_swiper.syncWithContent();
		}
		
		/**
		 * Called when inventory button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if (event.target is InventoryTileItem) {
				_objectUsed = InventoryTileItem(event.target).data;
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		
	}
}