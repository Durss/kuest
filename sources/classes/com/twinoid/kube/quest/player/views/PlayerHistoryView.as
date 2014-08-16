package com.twinoid.kube.quest.player.views {
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import gs.TweenLite;
	import gs.easing.Sine;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.GroupableFormComponent;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.touch.SwipeManager;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.buttons.ToggleButtonKube;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.graphics.MenuHistoryIconGraphic;
	import com.twinoid.kube.quest.player.components.HistoryFavoritesTileItem;
	import com.twinoid.kube.quest.player.components.HistoryTileItem;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 14 déc. 2013;
	 */
	public class PlayerHistoryView extends Sprite implements GroupableFormComponent {
		
		private var _width:int;
		private var _historyBt:ToggleButtonKube;
		private var _splitter:Splitter;
		private var _opened:Boolean;
		private var _engine1:TileEngine2DSwipeWrapper;
		private var _scrollpane1:ScrollPane;
		private var _swiper1:SwipeManager;
		private var _engine2:TileEngine2DSwipeWrapper;
		private var _scrollpane2:ScrollPane;
		private var _swiper2:SwipeManager;
		private var _favLabel:CssTextField;
		private var _searchField:InputKube;
		private var _splitterSearch:Splitter;
		private var _dataHistory:Vector.<KuestEvent>;
		private var _dataFavorites : Vector.<KuestEvent>;
		private var _timeoutSearch : uint;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerHistoryView</code>.
		 */
		public function PlayerHistoryView(width:int) {
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
			var ref:ScrollPane = _engine2.numCols == 0 ? _scrollpane1 : _scrollpane2;
			return _opened && _engine1.numCols > 0 ? ref.y + ref.height : _historyBt.height;
		}
		
		/**
		 * Gets the inventory button's height
		 */
		public function get buttonHeight():Number { return _historyBt.height; }
		
		public function get opened():Boolean { return _opened; }

		public function get selected():Boolean {
			return _opened;
		}

		public function set selected(value:Boolean):void {
			_opened = value;
			_historyBt.selected = value;
			
			dispatchEvent(new Event(Event.RESIZE, true));
			TweenLite.to(this, .35, {scrollRect:{height:height}, ease:Sine.easeInOut, overwrite:2});
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		public function toggle():void {
			selected = !selected;
		}

		public function select():void {
			selected = true;
		}

		public function unSelect():void {
			selected = false;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			var icon:MenuHistoryIconGraphic = new MenuHistoryIconGraphic();
			_splitter		= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			_historyBt		= addChild(new ToggleButtonKube(Label.getLabel("player-history"), icon, icon)) as ToggleButtonKube;
			_engine1		= new TileEngine2DSwipeWrapper(HistoryTileItem, _width, 50, 50, 50, 5, 0);
			_engine2		= new TileEngine2DSwipeWrapper(HistoryFavoritesTileItem, _width, 50, 50, 50, 5, 0);
			var w:int		= _engine1.visibleWidth;
			var h:int		= _engine1.visibleHeight;
			_scrollpane1	= addChild(new ScrollPane(_engine1, null, new ScrollbarKube())) as ScrollPane;
			_scrollpane2	= addChild(new ScrollPane(_engine2, null, new ScrollbarKube())) as ScrollPane;
			_swiper1		= new SwipeManager(_engine1, new Rectangle());
			_swiper2		= new SwipeManager(_engine2, new Rectangle());
			_favLabel		= addChild(new CssTextField('kuest-favoritesLabel')) as CssTextField;
			_splitterSearch	= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			_searchField	= addChild(new InputKube(Label.getLabel('player-historySearchField'))) as InputKube;
			
			_favLabel.text			= Label.getLabel('player-historyFav');
			_favLabel.width			= _width;
			_favLabel.background	= true;
			_favLabel.backgroundColor= 0x2D89B0;
			
			_historyBt.enabled		= false;
			_historyBt.iconAlign	= IconAlign.LEFT;
			_historyBt.textAlign	= TextAlign.LEFT;
			
			_engine1.lockToLimits	= true;
			_engine1.lockY			= true;
			_swiper1.roundXValue	= _engine1.itemWidth + _engine1.hMargin;
			_scrollpane1.width		= w;
//			_scrollpane1.autoHideScrollers = true;
			_swiper1.viewport.width	= w;
			_swiper1.viewport.height= h;
			_engine1.addLine([]);
			
			_engine2.lockToLimits	= true;
			_engine2.lockY			= true;
			_swiper2.roundXValue	= _engine2.itemWidth + _engine2.hMargin;
			_scrollpane2.width		= w;
//			_scrollpane2.autoHideScrollers = true;
			_swiper2.viewport.width	= w;
			_swiper2.viewport.height= h;
			_engine2.addLine([]);
			
			scrollRect = new Rectangle(0, 0, _width, height);
			
			addEventListener(MouseEvent.CLICK, clickButtonHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, historyUpdateHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.HISTORY_UPDATE, historyUpdateHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, historyUpdateHandler);
			_scrollpane1.hScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane1.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			_scrollpane2.hScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane2.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
			_searchField.addEventListener(Event.CHANGE, searchChangeHandler);
			_searchField.addEventListener(KeyboardEvent.KEY_UP, keyUpSearchHandler);
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
			_historyBt.x			= Math.round(_width * .5);
			_searchField.width		= _width;
			_splitter.width			= _width;
			_splitter.y				= _historyBt.height + 1;
			_searchField.y			= _splitter.y + _splitter.height;
			_splitterSearch.width	= _width;
			_splitterSearch.y		= _searchField.y + _searchField.height + 1;
			
			_scrollpane1.height	= _engine1.itemHeight;
			if(DisplayObject(_scrollpane1.hScroll).visible) {
				_scrollpane1.height += DisplayObject(_scrollpane1.hScroll).width;
			}
			_scrollpane2.height	= _engine2.itemHeight;
			if(DisplayObject(_scrollpane2.hScroll).visible) {
				_scrollpane2.height += DisplayObject(_scrollpane2.hScroll).width;
			}
			
			_scrollpane1.y		= _splitterSearch.y + _splitterSearch.height;
			_favLabel.y			= _scrollpane1.y + _scrollpane1.height;
			_scrollpane2.y		= _favLabel.y + _favLabel.height;
			_swiper1.start(false, false);
			_swiper2.start(false, false);
			
			_scrollpane1.update();
			_scrollpane2.update();
			
			roundPos(_historyBt, _splitter, _scrollpane1, _scrollpane2);
			
			graphics.clear();
			graphics.beginFill(0x47A9D1, 1);
			graphics.drawRect(0, _scrollpane1.y, _width, _scrollpane2.y + _scrollpane2.height);
			graphics.endFill();
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
			trace('T: ' + (event.currentTarget));
			if (event.currentTarget == _scrollpane1 || event.currentTarget == _scrollpane1.hScroll) {
				_swiper1.syncWithContent();
			}
			if(event.currentTarget == _scrollpane2 || event.currentTarget == _scrollpane2.hScroll) {
				_swiper2.syncWithContent();
			}
		}
		
		/**
		 * Called when inventory button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.target == _historyBt) {
				toggle();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Called when history needs to be updated
		 */
		private function historyUpdateHandler(event:DataManagerEvent):void {
			var items:Vector.<KuestEvent> = DataManager.getInstance().history;
			var i:int, len:int, prevScroll:Number;
			len = items.length;
			_dataHistory = new Vector.<KuestEvent>();
			prevScroll = _engine1.scrollX;
			for(i = len-1; i >= 0; --i) {
				if(items[i] == null) continue;//Dunno where these "null" sometimes come from :(
				_dataHistory.push(items[i]);
			}
			_engine1.clear();
			_engine1.addLine(VectorUtils.toArray(_dataHistory));
			_engine1.scrollX = prevScroll;
			_swiper1.syncWithContent();
			
			_historyBt.enabled = _dataHistory.length > 0;
			if(!_historyBt.enabled && _historyBt.selected) {
				_opened = false;
			}
			
			
			items = DataManager.getInstance().historyFavorites;
			len = items.length;
			_dataFavorites = new Vector.<KuestEvent>();
			prevScroll = _engine2.scrollX;
			for(i = len-1; i >= 0; --i) {
				if(items[i] == null) continue;//Not sure there are "null" on favorites but... just in case...
				_dataFavorites.push(items[i]);
			}
			_engine2.clear();
			_engine2.addLine(VectorUtils.toArray(_dataFavorites));
			_engine2.scrollX = prevScroll;
			_swiper2.syncWithContent();
			
			_scrollpane1.validate();
			_scrollpane2.validate();
			
			selected = selected;//Forces resize
		}
		
		/**
		 * Called when user writes something on the search input
		 */
		private function searchChangeHandler(event:Event):void {
			if(_searchField.text.length > 2) {
				clearTimeout(_timeoutSearch);
				_timeoutSearch = setTimeout(onRefreshSearchHandler, 100);
			}
		}
		
		/**
		 * Refreshes the search results
		 */
		private function onRefreshSearchHandler():void {
			var i:int, len:int, d:KuestEvent, data:Array, search:String;
			data = [];
			search = _searchField.text.toLowerCase();
			len = _dataHistory.length;
			for(i = 0; i < len; ++i) {
				d = _dataHistory[i];
				if(d.actionType.text.toLowerCase().indexOf(search) > -1
				|| d.actionType.getItem().name.toLowerCase().indexOf(search) > -1) {
					data.push(d);
				}
			}
			_engine1.clear();
			_engine1.addLine(data);
			_engine1.scrollX = 0;
			_swiper1.syncWithContent();
			
			data = [];
			search = _searchField.text.toLowerCase();
			len = _dataFavorites.length;
			for(i = 0; i < len; ++i) {
				d = _dataFavorites[i];
				if(d.actionType.text.toLowerCase().indexOf(search) > -1
				|| d.actionType.getItem().name.toLowerCase().indexOf(search) > -1) {
					data.push(d);
				}
			}
			_engine2.clear();
			_engine2.addLine(data);
			_engine2.scrollX = 0;
			_swiper2.syncWithContent();
		}
		
		/**
		 * Called when the user kills its current search 
		 */
		private function keyUpSearchHandler(events:KeyboardEvent):void {
			if(events.keyCode == Keyboard.ESCAPE ||
				(
					(events.keyCode == Keyboard.DELETE || events.keyCode == Keyboard.BACKSPACE)
					&& _searchField.text.length < 3
				)
			) {
				if(events.keyCode == Keyboard.ESCAPE) {
					_searchField.textfield.text = '';
				}
				_engine1.clear();
				_engine1.addLine(VectorUtils.toArray(_dataHistory));
				_engine1.scrollX = 0;
				_swiper1.syncWithContent();
				
				_engine2.clear();
				_engine2.addLine(VectorUtils.toArray(_dataHistory));
				_engine2.scrollX = 0;
				_swiper2.syncWithContent();
			}
		}
		
	}
}