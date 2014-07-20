package com.twinoid.kube.quest.editor.components.menu.file {
	import flash.events.FocusEvent;
	import gs.TweenLite;

	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.touch.SwipeManager;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.components.menu.todo.TodoItem;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.TodoData;
	import com.twinoid.kube.quest.graphics.HelpSmallIcon;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * 
	 * @author Durss
	 * @date 20 juil. 2014;
	 */
	public class FileTodosForm extends Sprite implements Closable {
		
		private var _width:int;
		private var _margin:int = 5;
		private var _closed:Boolean;
		private var _mask:Shape;
		private var _details:CssTextField;
		private var _helpBt:GraphicButtonKube;
		private var _searchField:InputKube;
		private var _todos:Vector.<TodoData>;
		private var _resultList:TileEngine2DSwipeWrapper;
		private var _swiper:SwipeManager;
		private var _scrollpane:ScrollPane;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileTodosForm</code>.
		 */
		public function FileTodosForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _mask.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Toggles the open state.
		 */
		public function toggle():void {
			if (_closed) open();
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open():void {
			_closed = false;
			
			//No need to do the opening transition here !
			//It's actually done by the searchValueChangeHandler() method
			//as it's called when the input receives focus.
			
			stage.focus = _searchField;
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			_closed = true;
			TweenLite.killTweensOf(_mask);
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:0, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * Populates the component
		 */
		public function populate(value:Vector.<TodoData>):void {
			_todos = value;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_details		= addChild(new CssTextField('menu-label')) as CssTextField;
			_helpBt			= addChild(new GraphicButtonKube(new HelpSmallIcon(), false)) as GraphicButtonKube;
			_searchField	= addChild(new InputKube(Label.getLabel('menu-file-todosSearchPlaceholder'))) as InputKube;
			_resultList		= new TileEngine2DSwipeWrapper(TodoItem, _width - _margin * 2, TodoItem.HEIGHT * 10, _width - _margin * 2, TodoItem.HEIGHT, 0, 0);
			_scrollpane		= addChild(new ScrollPane(_resultList, new ScrollbarKube())) as ScrollPane;
			_mask			= addChild(createRect()) as Shape;
			_swiper			= new SwipeManager(_resultList, new Rectangle());
			
			_resultList.lockX	= true;
			_resultList.lockToLimits= true;
			_scrollpane.width	= _width - _margin * 2;
			_scrollpane.height	= 300;
			_resultList.width	= _scrollpane.width - DisplayObject(_scrollpane.vScroll).width - 10;
			_details.text		= Label.getLabel('menu-file-todosDetails');
			setToolTip(_helpBt, Label.getLabel('menu-file-todosDetailsTT'));
			
			mask			= _mask;
			_closed			= true;
			_mask.scaleY	= 0;
			
			makeEscapeClosable(this, 1);
			
			computePositions();
			_searchField.addEventListener(FocusEvent.FOCUS_IN, searchValueChangeHandler);
			_searchField.addEventListener(Event.CHANGE, searchValueChangeHandler);
			_searchField.textfield.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, int.MAX_VALUE);//overpasses the Escape closer
			_resultList.addEventListener(MouseEvent.CLICK, selectItemHandler);
			_scrollpane.vScroll.addEventListener(ScrollerEvent.SCROLLING, scrollHandler);
			_scrollpane.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			graphics.clear();
			
			_details.x	= 
			_details.y	= _margin;
			_details.width = _width - _helpBt.width - _margin * 3;
			_helpBt.x = _width - _helpBt.width - _margin;
			_helpBt.y = Math.round(_details.y + (_details.height - _helpBt.height) * .5);
			_helpBt.validate();
			
			_searchField.x = _margin;
			_searchField.width = _width - _margin * 2;
			_searchField.y = Math.round(_details.y + _details.height + _margin);
			_searchField.validate();
			
			_scrollpane.x = _margin;
			_scrollpane.y = Math.round(_searchField.y + _searchField.height) + _margin;
			
			var h:int = Math.min(TodoItem.HEIGHT * 10, _resultList.numRows * TodoItem.HEIGHT);
			
			_scrollpane.height = h;
			
			_swiper.viewport.width = _resultList.width;
			_swiper.viewport.height = _scrollpane.height;
			
			h += _scrollpane.y + _margin * 2;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(0, 0, _width, h);
			_mask.graphics.endFill();
			
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h - 1);
			graphics.endFill();
		}
		
		/**
		 * Called when user searches for a todo
		 */
		private function searchValueChangeHandler(event:Event = null):void {
			var i:int, len:int, d:TodoData, ref:String;
			ref = _searchField.text.toLowerCase();
			_resultList.clear();
			
			len = _todos.length;
			var all:Boolean = ref.length < 2;
			for(i = 0; i < len; ++i) {
				d = _todos[i];
				if(all || d.text.toLowerCase().indexOf(ref) > -1) {
					_resultList.addLine([d]);
				}
			}
			
			var h:int = Math.min(TodoItem.HEIGHT * 10, _resultList.numRows * TodoItem.HEIGHT);
			_swiper.viewport.height = h;
			
			var prevH:int = _mask.height;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(0, 0, _width, h + _scrollpane.y + _margin * 2);
			_mask.graphics.endFill();
			_mask.height = prevH;
			
			graphics.clear();
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h + _scrollpane.y + _margin * 2 - 1);
			graphics.endFill();
			
			//Disable until i resolve the conflict when a swipeManager
			//is inside another...
//			_swiper.start(false, false);
			
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_scrollpane, .25, {height:h, onUpdate:_scrollpane.validate});
			TweenLite.to(_mask, .25, {scaleY:1, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * Called when an item is clicked on the results list
		 */
		private function selectItemHandler(event:MouseEvent):void {
			if(event.target is TodoItem) {
				(event.target as TodoItem).data.searchForIt();
			}
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
		 * Called when a key is released inside the search field.
		 * Detects for Escape key to reset the search
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.ESCAPE) {
				_searchField.text = "";
				_searchField.textfield.setSelection(0, 0);//reset caret at begining
				stage.focus = _searchField;//Hack to clean off the default label. Should actually be managed by the component.
				searchValueChangeHandler();
				event.stopPropagation();
				event.stopImmediatePropagation();
			}
		}
		
	}
}