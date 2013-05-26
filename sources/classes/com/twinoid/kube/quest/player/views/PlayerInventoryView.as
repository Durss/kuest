package com.twinoid.kube.quest.player.views {
	import gs.TweenLite;
	import gs.easing.Sine;

	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.touch.SwipeManager;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.graphics.MenuObjectIconGraphic;
	import com.twinoid.kube.quest.player.components.InventoryItem;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;
	import com.twinoid.kube.quest.player.vo.InventoryObject;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 mai 2013;
	 */
	public class PlayerInventoryView extends Sprite {
		
		private var _width:int;
		private var _inventoryBt:ButtonKube;
		private var _splitter:Splitter;
		private var _engine:TileEngine2DSwipeWrapper;
		private var _swiper:SwipeManager;
		private var _opened:Boolean;
		private var _scrollpane:ScrollPane;
		private var _emptyTf:CssTextField;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerInventoryView</code>.
		 */

		public function PlayerInventoryView(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number {
			return _opened ? _scrollpane.y + _scrollpane.height + 25 : _inventoryBt.height;
		}
		
		public function get opened():Boolean { return _opened; }



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function toggle():void {
			_opened = !_opened;
			var e:Event = new Event(Event.RESIZE, true);
			dispatchEvent(e);
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .35, {scrollRect:{height:height}, ease:Sine.easeInOut});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_splitter		= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			_engine			= new TileEngine2DSwipeWrapper(InventoryItem, _width, 100, 100, 100, 5, 0);
			var w:int		= _engine.visibleWidth;
			var h:int		= _engine.visibleHeight;
			_scrollpane		= addChild(new ScrollPane(_engine, null, new ScrollbarKube())) as ScrollPane;
			_inventoryBt	= addChild(new ButtonKube(Label.getLabel("player-inventory"), new MenuObjectIconGraphic())) as ButtonKube;
			_swiper			= new SwipeManager(_engine, new Rectangle());
			_emptyTf		= addChild(new CssTextField("kuest-inventoryEmpty")) as CssTextField;
			
			_emptyTf.text			= Label.getLabel("player-inventoryEmpty");
			_inventoryBt.iconAlign	= IconAlign.LEFT;
			_inventoryBt.textAlign	= TextAlign.LEFT;
//			_engine.lockY			= true;
//			_swiper.lockY			= true;
			_engine.lockToLimits	= true;
			_swiper.roundXValue		= _engine.itemWidth + _engine.hMargin;
			_scrollpane.width		= w;
			_scrollpane.height		= h + 15;//15 = scrollbar's height;
			_swiper.viewport.width	= w;
			_swiper.viewport.height	= h;
			_engine.addLine([]);
			
			computePositions();
			
			scrollRect = new Rectangle(0, 0, _width, height);
			
			addEventListener(MouseEvent.CLICK, clickButtonHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.NEW_EVENT, refreshInventoryHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, refreshInventoryHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, refreshInventoryHandler);
			_scrollpane.hScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
//			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_inventoryBt.x		= Math.round((_width - _inventoryBt.width) * .5);
			_splitter.width		= _width;
			_splitter.y			= _inventoryBt.height + 1;
			_scrollpane.y		= _splitter.y + _splitter.height;
			_swiper.start(false, false);
			
			_emptyTf.x = Math.round((_width - _emptyTf.width) * .5);
			_emptyTf.y = Math.round((_scrollpane.height - _emptyTf.height) * .5) + _scrollpane.y - 15;
			
			_scrollpane.update();
			
			roundPos(_inventoryBt, _splitter, _scrollpane);
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
		 * Called when a new event is available or when loading completes to refresh the inventory
		 */
		private function refreshInventoryHandler(event:DataManagerEvent):void {
			var objs:Vector.<InventoryObject> = DataManager.getInstance().objects;
			_engine.clear();
			if(objs.length > 0) {
				_engine.addLine(VectorUtils.toArray(objs));
			}
			_engine.validate();
			_emptyTf.visible = objs.length == 0;
		}
		
		/**
		 * Called when inventory button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.target == _inventoryBt) {
				toggle();
			} else if (event.target is InventoryItem) {
				var item:InventoryItem = InventoryItem(event.target);
				DataManager.getInstance().useObject(item.data);
			}
		}
		
	}
}