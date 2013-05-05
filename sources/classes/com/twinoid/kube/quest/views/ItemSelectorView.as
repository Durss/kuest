package com.twinoid.kube.quest.views {
	import gs.TweenLite;

	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.touch.SwipeManager;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.components.selector.SelectorItem;
	import com.twinoid.kube.quest.components.window.TitledWindow;
	import com.twinoid.kube.quest.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.utils.Closable;
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.vo.EmptyItemData;
	import com.twinoid.kube.quest.vo.IItemData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class ItemSelectorView extends AbstractView implements Closable {
		
		private var _window:TitledWindow;
		private var _disableLayer:Sprite;
		private var _callback:Function;
		private var _scrollpane:ScrollPane;
		private var _engine:TileEngine2DSwipeWrapper;
		private var _closed:Boolean;
		private var _swiper:SwipeManager;
		private var _model:Model;
		
		
		
		
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
			_model = event.model as Model;
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
			_window = addChild(new TitledWindow("", _scrollpane)) as TitledWindow;
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
		 * Catches MOUSE_UP and DOWN event.
		 * This prevents from the EditBoxView to close when selecting an item.
		 */
		private function catchEventHandler(event:MouseEvent):void {
			if(isClosed) return;
			event.stopPropagation();
			event.stopImmediatePropagation();
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
					populate( VectorUtils.toArray(_model.characters) );
					break;
				case ItemSelectorEvent.ITEM_TYPE_OBJECT:
					populate( VectorUtils.toArray(_model.objects) );
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
			//Add first empty item.
			list.unshift(new EmptyItemData(true));
			var i:int, len:int, data:IItemData, line:Array, empty:EmptyItemData;
			var cols:int = 5;
			len = list.length;
			empty = new EmptyItemData();
			line = [];
			for(i = 0; i < len; ++i) {
				data = list[i] as IItemData;
				//Ignore unfilled items
				if(data is EmptyItemData || (!(data is EmptyItemData) && data.name != null)) line.push(data);
				if(line.length == cols) {
					_engine.addLine(line);
					line = [];
				}
			}
			
			//add missing empty items to fill the last line
			if(line.length > 0) {
				len = cols - line.length;
				for(i = 0; i < len; ++i) line.push(empty);
				_engine.addLine(line);
			}
			
			//If lines are missing to fill the minimum rows., add empty.
			if(_engine.numRows < 3) {
				line = [];
				for(i = 0; i < cols; ++i) line.push(empty);
				len = 3 - _engine.numRows;
				for(i = 0; i < len; ++i) _engine.addLine(line);
			}
			computePositions();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.MOUSE_UP, catchEventHandler, true, 2);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, catchEventHandler, true, 2);
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