package com.twinoid.kube.quest.views {
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.twinoid.kube.quest.vo.EmptyItemData;
	import flash.geom.Rectangle;
	import com.nurun.utils.touch.SwipeManager;
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.utils.Closable;
	import com.nurun.utils.pos.PosUtils;
	import gs.TweenLite;

	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.components.selector.SelectorItem;
	import com.twinoid.kube.quest.components.window.PromptWindow;
	import com.twinoid.kube.quest.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.vo.ObjectItemData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class ItemSelectorView extends AbstractView implements Closable {
		
		private var _window:PromptWindow;
		private var _disableLayer:Sprite;
		private var _callback:Function;
		private var _scrollpane:ScrollPane;
		private var _charsList:Vector.<CharItemData>;
		private var _objectList:Vector.<ObjectItemData>;
		private var _engine:TileEngine2DSwipeWrapper;
		private var _closed:Boolean;
		private var _swiper:SwipeManager;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ItemSelectorView</code>.
		 */
		public function ItemSelectorView() {
			initialize();
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
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			_charsList = model.characters;
			_objectList = model.objects;
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
		private function initialize():void {
			alpha = 0;
			visible = false;
			_closed = true;
			
			_disableLayer = addChild(new Sprite()) as Sprite;
			_engine = new TileEngine2DSwipeWrapper(SelectorItem, (SelectorItem.WIDTH+5) * 5, (SelectorItem.HEIGHT+5) * 3, SelectorItem.WIDTH, SelectorItem.HEIGHT);
			_scrollpane = new ScrollPane(_engine, new ScrollbarKube());
			_window = addChild(new PromptWindow("", _scrollpane)) as PromptWindow;
			_swiper = new SwipeManager(_engine, new Rectangle());
			
//			_scrollpane.autoHideScrollers = true;
			
			_engine.addLine([]);//Without that, no rendering of items
//			_engine.lockX = true;
			_engine.lockToLimits = true;
			_swiper.roundYValue = SelectorItem.HEIGHT + 5;
			_scrollpane.width = _engine.visibleWidth + 15;//15 = scrollbar's width
			_scrollpane.height = _engine.visibleHeight;
			_engine.validate();
			makeEscapeClosable(this, 1);
			
			ViewLocator.getInstance().addEventListener(ItemSelectorEvent.SELECT_ITEM, openSelectorHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler, true, 2);
			_scrollpane.vScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
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
		 * Called when something's clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _disableLayer) close();
			event.stopPropagation();
			
			if (event.target is SelectorItem && !_swiper.hasMovedMoreThan()) {
				var item:SelectorItem = event.target as SelectorItem;
				if( ( !(item.data is EmptyItemData) || EmptyItemData(item.data).isDefined ) && item.data != null ) {
					_callback(item.data);
					close();
				}
			}
		}
		
		/**
		 * Called when a view fires an ItemSelectorEvent
		 */
		private function openSelectorHandler(event:ItemSelectorEvent):void {
			visible = true;
			_closed = false;
			_callback = event.callback;
			_window.label = Label.getLabel("selector-"+event.itemType);
			//Event if the item's vector are IITemData, flash doesn't accept
			//a vector of item in place of a vector of IITemData.
			//So i convert the vector to an array, so that it doesn't break by balls
			//event if it's stupid...
			switch(event.itemType){
				case ItemSelectorEvent.ITEM_TYPE_CHAR:
					populate( VectorUtils.toArray(_charsList) );
					break;
				case ItemSelectorEvent.ITEM_TYPE_OBJECT:
					populate( VectorUtils.toArray(_objectList) );
					break;
				default:
			}
			alpha = 1;
			visible = true;
			TweenLite.from(this, .25, {autoAlpha:0});
		}
		
		/**
		 * Populates the list.
		 */
		private function populate(list:Array):void {
			_engine.clear();
			
			var i:int, len:int, data:IItemData, line:Array, empty:EmptyItemData;
			var cols:int = 5;//_engine.hVisibleItems;
			len = Math.max(Math.ceil(list.length/cols) * cols, 15);
			empty = new EmptyItemData();
			
			for(i = 0; i <= len; ++i) {
				if(i == 0 || line.length == cols) {
					if(i > 0) _engine.addLine(line);
					line = [];
					if(i == 0) line.push(new EmptyItemData(true));
				}
				data = (i > list.length-1)? empty : list[i] as IItemData;
				line.push(data);
			}
			computePositions();
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
			_disableLayer.graphics.clear();
			_disableLayer.graphics.beginFill(0, .35);
			_disableLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disableLayer.graphics.endFill();
			
			_swiper.viewport.width = _engine.visibleWidth;
			_swiper.viewport.height = _engine.visibleHeight;
			_swiper.start(true, true);
			_scrollpane.update();
			
			_window.forcedContentHeight = _scrollpane.height + 20;
			_window.updateSizes();
			PosUtils.centerInStage(_window);
		}
	}
}