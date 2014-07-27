package com.twinoid.kube.quest.editor.views {
	import com.twinoid.kube.quest.editor.vo.TodoData;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.box.BoxTodo;
	import com.nurun.components.button.AbstractNurunButton;
	import flash.text.TextField;
	import gs.TweenLite;
	import gs.easing.Back;
	import gs.easing.Sine;

	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;
	import com.twinoid.kube.quest.editor.components.box.Box;
	import com.twinoid.kube.quest.editor.components.box.BoxLink;
	import com.twinoid.kube.quest.editor.components.box.BoxesComments;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.BoxEvent;
	import com.twinoid.kube.quest.editor.events.BoxesCommentsEvent;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.ScissorsGraphic;
	import com.twinoid.kube.quest.player.utils.computeTreeGUIDs;

	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;



	/**
	 * Manages the boxes and links rendering.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxesView extends AbstractView {
		
		private const DRAG_GAP:int = 150;
		
		private var _dataToBox:Dictionary;
		private var _tempBox:Box;
		private var _scrollOffset:Point;
		private var _boxesHolder:Sprite;
		private var _stagePressed:Boolean;
		private var _dragOffset:Point;
		private var _mouseOffset:Point;
		private var _background:BackgroundView;
		private var _endX:Number;
		private var _endY:Number;
		private var _prevMousePos:Point;
		private var _draggingBoard:Boolean;
		private var _tempLink:BoxLink;
		private var _draggedItem:Sprite;
		private var _startDragInGap:Boolean;
		private var _dragItemOffset:Point;
		private var _currentDataGUID:int;
		private var _spacePressed:Boolean;
		private var _comments:BoxesComments;
		private var _scisors:ScissorsGraphic;
		private var _linksHolder:Sprite;
		private var _nodes:Vector.<KuestEvent>;
		private var _tree:Dictionary;
		private var _lastOverEvent:KuestEvent;
		private var _debugMode:Boolean;
		private var _debugFilter:Array;
		private var _selectMode:Boolean;
		private var _selectHolder:Sprite;
		private var _selectRect:Rectangle;
		private var _selectedBoxes:Vector.<Box>;
		private var _selectionDone:Boolean;
		private var _boxes:Vector.<Box>;
		private var _highlightFilter:Array;
		private var _dragSelection:Boolean;
		private var _dragOffsets:Vector.<Point>;
		private var _initDependencies:Vector.<Box>;
		private var _initDataToBox:Dictionary;
		private var _timeout:uint;
		private var _loadingPercent:Shape;
		private var _debugSelectFilters:Array;
		private var _debugChildFilters:Array;
		private var _previousDebugTarget : Box;
		private var _todoTimeout : uint;
		private var _todosHolder : Sprite;
		private var _todoCreated : Boolean;
		private var _selectedTodos : Vector.<BoxTodo>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxesView</code>.
		 */
		public function BoxesView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
		
		}
		
		//Gets board's offset X
		public function get offsetX():Number { return _boxesHolder.x; }
		//Gets board's offset Y
		public function get offsetY():Number { return _boxesHolder.y; }

		public function get scrollX():Number { return _endX; }

		public function set scrollX(endX:Number):void { _endX = endX; }

		public function get scrollY():Number { return _endY; }

		public function set scrollY(endY:Number):void { _endY = endY; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;

			var lastItem:KuestEvent = model.kuestData.lastItemAdded;
			if(lastItem != null) {
				createItem(lastItem);
			}
			
			if(model.kuestData.guid != _currentDataGUID) {
				_currentDataGUID = model.kuestData.guid;
				_comments.load(model.comments, model.commentsViewports);
				clear();
				buildFromCollection(model.kuestData.nodes);
				buildTodosFromCollection(model.kuestData.todos);
			}
			
			if(_background == null) {
				_background = ViewLocator.getInstance().locateViewByType(BackgroundView) as BackgroundView;
				_scrollOffset = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
				
				_boxesHolder.x = _endX = _scrollOffset.x;
				_boxesHolder.y = _endY = _scrollOffset.y;
				_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
				computePositions();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mouseOffset	= new Point();
			_dragOffset		= new Point();
			_prevMousePos	= new Point();
			_dragItemOffset	= new Point();
			_selectRect		= new Rectangle();
			_dataToBox		= new Dictionary();
			_boxes			= new Vector.<Box>();
			
			_tempBox		= new Box();
			_scisors		= new ScissorsGraphic();
			_comments		= addChild(new BoxesComments()) as BoxesComments;
			_linksHolder	= addChild(new Sprite()) as Sprite;
			_boxesHolder	= addChild(new Sprite()) as Sprite;
			_selectHolder	= addChild(new Sprite()) as Sprite;
			_todosHolder	= addChild(new Sprite()) as Sprite;
			_loadingPercent	= addChild(new Shape()) as Shape;
			_tempLink		= _linksHolder.addChild(new BoxLink(null, null)) as BoxLink;
			
			_scisors.filters		= [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
			_scisors.mouseChildren	= false;
			_scisors.mouseEnabled	= false;
			_highlightFilter		= [new ColorMatrixFilter([1,0,0,0,25, 0,1,0,0,25, 0,0,1,0,25, 0,0,0,1,0 ])];
			_debugFilter			= [new ColorMatrixFilter([0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0,0,0,1,0])];
			_debugSelectFilters		= [new GlowFilter(0xffffff, 1, 10, 10)];
			_debugChildFilters		= [new ColorMatrixFilter([1.0308935642242432,0.2900744080543518,0.03903200477361679,0,-22.85999870300293,0.14689362049102783,1.1740742921829224,0.03903200477361679,0,-22.860000610351563,0.14689362049102783,0.2900744080543518,0.9230319857597351,0,-22.860000610351563,0,0,0,1,0])];
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(BoxEvent.SEARCH_TODO, searchTodoHandler);
			_boxesHolder.addEventListener(BoxEvent.ACTIVATE_DEBUG, debugEventHandler);
			_comments.addEventListener(BoxesCommentsEvent.ENTER_EDIT_MODE, editCommentsStateChangeHandler);
			_comments.addEventListener(BoxesCommentsEvent.LEAVE_EDIT_MODE, editCommentsStateChangeHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.DEBUG_MODE_CHANGE, debugModeStateChangeHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			//If mouse right button is supported (player >= 11.2)
			//In order to work, this needs "-swf-version=15" in compiler arguments !
			if (MouseEvent.RIGHT_MOUSE_DOWN != null) {
				addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseRightDownHandler);
				addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseRightUpHandler);
			}
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			//Used for mouse hit
			graphics.clear();
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
		}
		
		/**
		 * Called on ENTER_FRAME event
		 */
		private function enterFrameHandler(event:Event):void {
			//Manage board's drag if mouse isn't over anything else
			var hasMoved:Boolean = Math.abs(_dragOffset.x - _boxesHolder.x) > 2 || Math.abs(_dragOffset.x - _boxesHolder.x) > 2;
			if(!_spacePressed) {
				if(_stagePressed && _draggedItem == null && !_dragSelection) {
					if(hasMoved) _draggingBoard = true;
					_endX = _dragOffset.x + stage.mouseX - _mouseOffset.x;
					_endY = _dragOffset.y + stage.mouseY - _mouseOffset.y;
				}
				
				if(_selectMode && !_selectionDone) {
					_selectRect.width = _selectHolder.mouseX - _selectRect.x;
					_selectRect.height = _selectHolder.mouseY - _selectRect.y;
					_selectHolder.graphics.clear();
					_selectHolder.graphics.lineStyle(2, 0xffffff, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 2);
					_selectHolder.graphics.beginFill(0xffffff, .15);
					_selectHolder.graphics.drawRect(_selectRect.x, _selectRect.y, _selectRect.width, _selectRect.height);
					_selectHolder.graphics.endFill();
				}
			}else if(_stagePressed && _draggedItem == null) {
				_comments.startDraw();
			}
			
			//Moves the board when dragging something on the borders
			var addX:Number = 0, addY:Number = 0, maxSpeed:int = 10;
			var size:int = BackgroundView.CELL_SIZE;
			if(_draggedItem != null || _tempLink.startEntry != null || (_selectMode && !_selectionDone) || _dragSelection) {
				if(stage.mouseX < DRAG_GAP)						addX = (1-stage.mouseX / DRAG_GAP);
				if(stage.mouseX > stage.stageWidth - DRAG_GAP)	addX = -(stage.mouseX - stage.stageWidth + DRAG_GAP) / DRAG_GAP;
				if(stage.mouseY < DRAG_GAP)						addY = (1-stage.mouseY / DRAG_GAP);
				if(stage.mouseY > stage.stageHeight - DRAG_GAP)	addY = -(stage.mouseY - stage.stageHeight + DRAG_GAP) / DRAG_GAP;
				if(_startDragInGap && addX == 0 && addY == 0) _startDragInGap = false;//Allow drag again if we leave the drag zone.
				if(!_startDragInGap && (addX != 0 || addY != 0)) {
					if(addX!=0) addX = Math.pow(maxSpeed, Math.abs(addX) * 1.2 + 1) * MathUtils.sign(addX);
					if(addY!=0) addY = Math.pow(maxSpeed, Math.abs(addY) * 1.2 + 1) * MathUtils.sign(addY);
					_endX = _boxesHolder.x + addX * _boxesHolder.scaleX;
					_endY = _boxesHolder.y + addY * _boxesHolder.scaleY;
				}
			}
			
			//Drag a specific item
			if(_draggedItem != null) {
				_draggedItem.x = Math.round( (_boxesHolder.mouseX - _dragItemOffset.x) / size) * size;
				_draggedItem.y = Math.round( (_boxesHolder.mouseY - _dragItemOffset.y) / size) * size;
			}
			
			//Move the board
			_boxesHolder.x += (_endX - _boxesHolder.x) * .5;
			_boxesHolder.y += (_endY - _boxesHolder.y) * .5;
			_linksHolder.x = _selectHolder.x = _todosHolder.x = _boxesHolder.x;
			_linksHolder.y = _selectHolder.y = _todosHolder.y = _boxesHolder.y;
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			_comments.scrollTo(_boxesHolder.x, _boxesHolder.y);
			
			//Drag a group of items
			if(_dragSelection) {
				var i:int, len:int;
				len = _selectedBoxes.length;
				for(i = 0; i < len; ++i) {
					_selectedBoxes[i].x = Math.round( (_boxesHolder.mouseX + _dragOffsets[i].x - _dragItemOffset.x) / size) * size;
					_selectedBoxes[i].y = Math.round( (_boxesHolder.mouseY + _dragOffsets[i].y - _dragItemOffset.y) / size) * size;
				}
				
				var len2:int = _selectedTodos.length;
				for(i = 0; i < len2; ++i) {
					_selectedTodos[i].x = Math.round( (_todosHolder.mouseX + _dragOffsets[i +  len].x - _dragItemOffset.x) / size) * size;
					_selectedTodos[i].y = Math.round( (_todosHolder.mouseY + _dragOffsets[i +  len].y - _dragItemOffset.y) / size) * size;
				}
				
				_selectRect.x = Math.round( (_boxesHolder.mouseX - _dragItemOffset.x) / size) * size;
				_selectRect.y = Math.round( (_boxesHolder.mouseY - _dragItemOffset.y) / size) * size;
				_selectHolder.graphics.clear();
				_selectHolder.graphics.lineStyle(2, 0xffffff, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 2);
				_selectHolder.graphics.beginFill(0xffffff, .5);
				_selectHolder.graphics.drawRect(_selectRect.x, _selectRect.y, _selectRect.width, _selectRect.height);
				_selectHolder.graphics.endFill();
			}
			
			_prevMousePos.x = stage.mouseX;
			_prevMousePos.y = stage.mouseY;
			
			//Draw the links
			if(_tempLink.startEntry != null) {
				_tempLink.drawToMouse();
			}
		}
		
		/**
		 * Starts a link's creation.
		 */
		private function createLinkHandler(event:BoxEvent):void {
			_tempLink.choiceIndex = event.choiceIndex;
			_tempLink.startEntry = event.currentTarget as Box;
			_tempLink.drawToMouse();
			_linksHolder.addChild(_tempLink);
			//Prevents from scrolling n borders if we actually start to frag the
			//item on the drag_gap zone.
			_startDragInGap = (stage.mouseX < DRAG_GAP || stage.mouseY < DRAG_GAP
								|| stage.mouseX > stage.stageWidth - DRAG_GAP
								|| stage.mouseY > stage.stageHeight - DRAG_GAP);
		}
		
		/**
		 * Called when a box is delete
		 */
		private function deleteBoxHandler(event:BoxEvent):void {
			var target:Box = event.currentTarget as Box;
			target.removeEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
			target.removeEventListener(BoxEvent.DELETE, deleteBoxHandler);
			target.removeEventListener(BoxEvent.DUPLICATE, duplicateBoxHandler);
			
			var i:int, len:int, item:DisplayObject, link:BoxLink;
			len = _boxes.length;
			for(i = 0; i < len; ++i) {
				//Remove eventual dependencies
				//Should actually be done in the model.
				_boxes[i].data.removeDependency(target.data);
				
				//Clear item's reference
				if(_boxes[i] == target) {
					_boxes.splice(i, 1);
					i--;
					len--;
				}
			}
			//Remove it from view
			_boxesHolder.removeChild(target);
			
			//Clear its eventual links references
			len = _linksHolder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _linksHolder.getChildAt(i);
				link = item as BoxLink;
				if(link.startEntry == target || link.endEntry == target) {
					link.deleteLink();
					i--;
					len--;
				}
			}
			
			FrontControler.getInstance().deleteNode(target.data);
		}
		
		/**
		 * Called when duplicate button is clicked on a box.
		 */
		private function duplicateBoxHandler(event:BoxEvent):void {
			var ref:Box = event.currentTarget as Box;
			FrontControler.getInstance().addEntryPoint(ref.x + BackgroundView.CELL_SIZE * 2, ref.y + BackgroundView.CELL_SIZE, ref.data);
		}
		
		/**
		 * Clears everything.
		 */
		private function clear():void {
			var item:DisplayObject;
			_boxes = new Vector.<Box>();
			//Clear boxes
			while(_boxesHolder.numChildren > 0) _boxesHolder.removeChild(_boxesHolder.getChildAt(0));
			
			//Clear links
			while(_linksHolder.numChildren > 0) {
				item = _linksHolder.getChildAt(0);
				if(item != _tempLink) {
					if(item is Disposable) Disposable(item).dispose();
					item.removeEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
					item.removeEventListener(BoxEvent.DELETE, deleteBoxHandler);
					item.removeEventListener(BoxEvent.DUPLICATE, duplicateBoxHandler);
				}
				_linksHolder.removeChild(item);
			}
			
			while(_todosHolder.numChildren > 0) {
				item = _todosHolder.getChildAt(0);
				if(item is Disposable) Disposable(item).dispose();
//				_todosHolder.removeChild(item);//No need to remove it! It self removes on dispose !
			}
			_linksHolder.addChild(_tempLink);
		}
		
		/**
		 * Builds the items from a collection of items.
		 */
		private function buildFromCollection(nodes:Vector.<KuestEvent>, offset1:Number = -1, offset2:Number = -1, offset3:Number = -1):void {
			if(offset1 == -1) {
				mouseChildren = false;
				_initDependencies = new Vector.<Box>();
				_initDataToBox = new Dictionary();
			}
			
			_loadingPercent.graphics.clear();
			_loadingPercent.graphics.beginFill(0, .5);
			
			clearTimeout(_timeout);
			_nodes = nodes;
			var i:int, len:int, box:Box;
			var j:int, lenJ:int;
			var s:int = getTimer();
			len = nodes.length;
			//Create the items and registers all the items to find back their dependencies faster.
			for(i = Math.max(0, offset1); i < len; ++i) {
				box = createItem(nodes[i], false);
				_initDataToBox[box.data] = box;
				if(nodes[i].dependencies.length > 0) {
					_initDependencies.push(box);
				}
				if(getTimer()-s > 80) {
					_timeout = setTimeout(buildFromCollection, 35, nodes, i + 1);
					_loadingPercent.graphics.drawRect(0, 0, stage.stageWidth * ((1 - i/len) * .75 + .25), stage.stageHeight);
					return;
				}
			}
			
			//Creates the links
			len = _initDependencies.length;
			for(i = Math.max(0, offset2); i < len; ++i) {
				lenJ = _initDependencies[i].data.dependencies.length;
				for(j = Math.max(0, offset3); j < lenJ; ++j) {
					var link:BoxLink = new BoxLink( _initDataToBox[ _initDependencies[i].data.dependencies[j].event ], _initDependencies[i], _initDependencies[i].data.dependencies[j].choiceIndex );
					_linksHolder.addChild(link);
					link.startEntry.addlink(link);
					link.endEntry.addlink(link);
				}
				if(getTimer()-s > 80) {
					_timeout = setTimeout(buildFromCollection, 35, nodes, int.MAX_VALUE, i + 1, 0);
					_loadingPercent.graphics.drawRect(0, 0, stage.stageWidth * .25 * (1 - i/len), stage.stageHeight);
					return;
				}
			}
			
			if(nodes.length > 0 ) {
				_endX = _boxesHolder.x = -nodes[0].boxPosition.x * _boxesHolder.scaleX + stage.stageWidth * .5;
				_endY = _boxesHolder.y = -nodes[0].boxPosition.y * _boxesHolder.scaleY + stage.stageHeight * .5;
				_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
				_comments.scrollTo(_boxesHolder.x, _boxesHolder.y);
			}
			mouseChildren		= true;
			_initDataToBox		= null;
			_initDependencies	= null;
			_loadingPercent.graphics.clear();
		}
		
		/**
		 * Builds the todo items from a vector when anew quest is loaded
		 */
		private function buildTodosFromCollection(todos:Vector.<TodoData>):void {
			var i:int, len:int;
			len = todos.length;
			for(i = 0; i < len; ++i) {
				_todosHolder.addChild(new BoxTodo(todos[i]));
			}
		}
		
		/**
		 * Creates a todo instance
		 */
		private function createTodo(offsetX:Number, offsetY:Number):void {
			if(Math.sqrt(Math.pow(_boxesHolder.y-offsetY, 2) + Math.pow(_boxesHolder.x-offsetX, 2)) > 4) return;//Board has moved!
			
			_todoCreated = true;
			_stagePressed = false;//prevents from draging the board after creation
			var todo:BoxTodo = _todosHolder.addChild(new BoxTodo()) as BoxTodo;
			todo.moveTo(_todosHolder.mouseX, _todosHolder.mouseY);
			roundPos(todo);
			todo.open();
		}
		
		/**
		 * Creates a box item.
		 */
		private function createItem(data:KuestEvent, tween:Boolean = true):Box {
			var item:Box = new Box(data);
			item.buttonMode = true;
			item.addEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
			item.addEventListener(BoxEvent.DELETE, deleteBoxHandler);
			item.addEventListener(BoxEvent.DUPLICATE, duplicateBoxHandler);
			_boxesHolder.addChild( item );
			_boxes.push(item);
			
			if(tween) {
				TweenLite.from(item, .25, {transformAroundCenter:{scaleX:0, scaleY:0}, ease:Back.easeOut});
			}
			
			return item;
		}
		
		/**
		 * Clears the selection
		 */
		private function clearSelection():void {
			_selectMode		= false;
			_selectionDone	= false;
			_dragSelection	= false;
			_selectHolder.graphics.clear();
			_boxesHolder.mouseChildren = true;
			_linksHolder.mouseChildren = true;
			Mouse.cursor = MouseCursor.HAND;
			
			var i:int, len:int;
			len = _selectedBoxes.length;
			for(i = 0; i < len; ++i) {
				_selectedBoxes[0].filters = [];
				_selectedBoxes.splice(0, 1);
			}
			len = _selectedTodos.length;
			for(i = 0; i < len; ++i) {
				_selectedTodos[0].filters = [];
				_selectedTodos.splice(0, 1);
			}
		}

		
		
		
		
		//__________________________________________________________ MOUSE/KEYBOARD EVENTS
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(event.target is TextField || event.target is AbstractNurunButton) return;
			
			if(!_stagePressed && !_spacePressed && event.keyCode == Keyboard.SPACE) {
				//check if a box or link is between the stage and the mouse.
				var objs:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
				var top:DisplayObject = objs[objs.length - 1];
				if(top == null) return;
				if (top == this || _linksHolder.contains(top) || _scisors.contains(top)) {
					_spacePressed = true;
					Mouse.cursor = MouseCursor.ARROW;
					addChild(_comments);
					
					//Remove scisors just in case we were over a link
					if(contains(_scisors)) {
						Mouse.show();
						removeChild(_scisors);
						_scisors.stopDrag();
					}
				}
			}
			
			if(event.keyCode == Keyboard.LEFT)	_endX += BackgroundView.CELL_SIZE * 2;
			if(event.keyCode == Keyboard.RIGHT)	_endX -= BackgroundView.CELL_SIZE * 2;
			if(event.keyCode == Keyboard.UP)	_endY += BackgroundView.CELL_SIZE * 2;
			if(event.keyCode == Keyboard.DOWN)	_endY -= BackgroundView.CELL_SIZE * 2;
			if(event.keyCode == Keyboard.MINUS ||
			event.keyCode == Keyboard.NUMPAD_SUBTRACT)	wheelHandler(null, -1);
			if(event.keyCode == Keyboard.NUMPAD_ADD)	wheelHandler(null, 1);
		}
		
		/**
		 * Called when a key is released.
		 * Used to cancel temp box.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.SPACE) {
				if (_spacePressed) {
					addChildAt(_comments, 0);
					var objs:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
					var top:DisplayObject = objs[objs.length - 1];
					if(top == this) {
						Mouse.cursor = MouseCursor.HAND;
					}
				}
				_spacePressed = false;
			}
			if(event.keyCode == Keyboard.ESCAPE) {
				if(event.shiftKey) {
					computeTreeGUIDs(_nodes, onComputeTreeComplete);
				}else {
					_boxesHolder.graphics.clear();
				}
			}
		}

		
		/**
		 * Called when user scrolls its mouse wheel to zoom in/out the board.
		 * Also called when +/- keys are pressed
		 */
		private function wheelHandler(event:MouseEvent, delta:int = 0):void {
			if(delta == 0) delta = MathUtils.sign(event.delta);
			var p:Point;
			if(event == null){
				p = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
				p = _boxesHolder.globalToLocal(p);
			}else{
				p = new Point(_boxesHolder.mouseX, _boxesHolder.mouseY);
			}
			_boxesHolder.x += (event == null? stage.stageWidth * .5 : stage.mouseX) - p.x;
			_boxesHolder.y += (event == null? stage.stageHeight * .5 : stage.mouseY) - p.y;
			_boxesHolder.scaleX = _boxesHolder.scaleY += delta * .15;
			_boxesHolder.scaleX = _boxesHolder.scaleY = 
			_linksHolder.scaleX = _linksHolder.scaleY =
			_selectHolder.scaleX = _selectHolder.scaleY = 
			_todosHolder.scaleX = _todosHolder.scaleY = MathUtils.restrict(_boxesHolder.scaleX, 1/10, 1);
			
			p = _boxesHolder.localToGlobal(p);
			_boxesHolder.x += (event == null? stage.stageWidth * .5 : stage.mouseX) - p.x;
			_boxesHolder.y += (event == null? stage.stageHeight * .5 : stage.mouseY) - p.y;
			_linksHolder.x = _selectHolder.x = _todosHolder.x = _boxesHolder.x;
			_linksHolder.y = _selectHolder.y = _todosHolder.y = _boxesHolder.y;
			_endX = Math.round(_boxesHolder.x);
			_endY = Math.round(_boxesHolder.y);
			_background.setScale(_boxesHolder.scaleX);
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			_comments.setScale(_boxesHolder.scaleX);
			_comments.scrollTo(_boxesHolder.x, _boxesHolder.y);
		}
		
		/**
		 * Called when mouse is pressed.
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			clearTimeout(_todoTimeout);
			
			//Detect Box dragging
			if(!_spacePressed && event.target != this && event.target != _selectHolder && event.target != _comments) {
				if (_boxesHolder.contains(event.target as DisplayObject)) {
					//Go up until we find a box (or the stage..)
					var target:DisplayObject = event.target as DisplayObject;
					while(!(target is Box) && !(target is Stage)) target = target.parent;
					//If a box is found, drag it.
					if(target is Box) {
						Box(target).startDrag();
						_draggedItem = target as Sprite;
						_dragItemOffset.x = _draggedItem.mouseX;
						_dragItemOffset.y = _draggedItem.mouseY;
						_boxesHolder.addChild(target);//Bring it to front
						//Prevents from scrolling on borders if we actually start to drag the
						//item from the drag_gap zone.
						_startDragInGap = (stage.mouseX < DRAG_GAP || stage.mouseY < DRAG_GAP
											|| stage.mouseX > stage.stageWidth - DRAG_GAP
											|| stage.mouseY > stage.stageHeight - DRAG_GAP);
					}
				}
				return;
			}
			
			_dragSelection	= false;
			_dragOffset.x	= _boxesHolder.x;
			_dragOffset.y	= _boxesHolder.y;
			_mouseOffset.x	= _prevMousePos.x = stage.mouseX;
			_mouseOffset.y	= _prevMousePos.x = stage.mouseY;
			_stagePressed	= true;
			_draggingBoard	= false;
			
			//If we were supposed to drag a selection but we actually clicked
			//outside the selection, we unselect everything.
			if(_selectionDone && event.target != _selectHolder) {
				clearSelection();
				_selectionDone = true;//reset seldct mode so that on mouseUp we can know we were moving a selection 
			}
			
			//Start selection drag
			if(event.target == _selectHolder) {
				var i:int, len:int;
				len					= _selectedBoxes.length;
				_dragOffsets		= new Vector.<Point>();
				_dragItemOffset.x	= _boxesHolder.mouseX - _selectRect.x;
				_dragItemOffset.y	= _boxesHolder.mouseY - _selectRect.y;
				for(i = 0; i < len; ++i) {
					_selectedBoxes[i].startDrag();
					_dragOffsets[i] = new Point(_selectedBoxes[i].x - _selectRect.x, _selectedBoxes[i].y - _selectRect.y);
				}
				
				var len2:int = _selectedTodos.length;
				for(i = 0; i < len2; ++i) {
					_dragOffsets[i+len] = new Point(_selectedTodos[i].x - _selectRect.x, _selectedTodos[i].y - _selectRect.y);
				}
				_dragSelection = true;
				
				//Prevents from scrolling on borders if we actually start to drag the
				//item from the drag_gap zone.
				_startDragInGap = (stage.mouseX < DRAG_GAP || stage.mouseY < DRAG_GAP
									|| stage.mouseX > stage.stageWidth - DRAG_GAP
									|| stage.mouseY > stage.stageHeight - DRAG_GAP);
			}else if(!_spacePressed){
				_todoTimeout = setTimeout(createTodo, 250, _boxesHolder.x, _boxesHolder.y);
			}
			
			if(_spacePressed) _comments.startDraw();
		}
		
		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			clearTimeout(_todoTimeout);
			_comments.stopDraw();
			
			//Prevents from creating a box after a todo creation
			if(_todoCreated) {
				_todoCreated = false;
				return;
			}
			
			_stagePressed = false;
			
			if(_spacePressed) return;
			
			//If we were dragging the board, throw it.
			if(_draggingBoard) {
				_endX += (stage.mouseX - _prevMousePos.x) * 5;
				_endY += (stage.mouseY - _prevMousePos.y) * 5;
				_draggingBoard = false;
			
			//If we were selecting or moving a selection, clear the selection
			}else if(_selectionDone && !_dragSelection) {
				clearSelection();
				return;
			
			//If we were dragging a selection, stop its drag
			}else if(_dragSelection) {
				//update the selected boxes positions
				var i:int, len:int;
				len = _selectedBoxes.length;
				for(i = 0; i < len; ++i) {
					_selectedBoxes[i].data.boxPosition.x = _selectedBoxes[i].x;
					_selectedBoxes[i].data.boxPosition.y = _selectedBoxes[i].y;
				}
				
				//Update todos positions
				len = _selectedTodos.length;
				for(i = 0; i < len; ++i) {
					_selectedTodos[i].data.pos.x = _selectedTodos[i].x;
					_selectedTodos[i].data.pos.y = _selectedTodos[i].y;
				}
				_dragSelection = false;
				FrontControler.getInstance().flagChange();
				return;
				
			//If we weren't dragging the board, create a new item
			}else if(_draggedItem == null && Point.distance(_mouseOffset, _prevMousePos) < 2 && !event.ctrlKey && !_spacePressed && !_debugMode){
				var size:int = BackgroundView.CELL_SIZE;
				var px:Number = Math.round((_boxesHolder.mouseX - _tempBox.width * .5) / size) * size;
				var py:Number = Math.round((_boxesHolder.mouseY - _tempBox.height * .5) / size) * size;
				//Add an item to the tree
				FrontControler.getInstance().addEntryPoint(px, py);
			
			//If we were dragging an item, update its position
			}else if (_draggedItem != null) {
				Box(_draggedItem).data.boxPosition.x = _draggedItem.x;
				Box(_draggedItem).data.boxPosition.y = _draggedItem.y;
				_draggedItem.stopDrag();
				_draggedItem = null;
				FrontControler.getInstance().flagChange();
			}
			
			//If a link has just been created correctly, try to create the link
			var success:Boolean = true;
			if (_tempLink.endEntry != null) {
				success = _tempLink.endEntry.data.addDependency(_tempLink.startEntry.data, _tempLink.choiceIndex);
				if(!success) {
					_tempLink.showError();
					_linksHolder.addChild(_tempLink);
				} else {
					var link:BoxLink = _tempLink.clone();
					_linksHolder.addChild(link);
					link.startEntry.addlink(link);
					link.endEntry.addlink(link);
					FrontControler.getInstance().flagChange();
				}
			}
			_tempLink.startEntry = null;
			_tempLink.endEntry = null;
			//success test prevents from instant line clearing if the link
			//is actually displaying an error. In this case, the link self clears after showing its warning.
			if(success) _tempLink.update();
			
			//When a link is deleted it's not captured here. It does its things
			//on its side. We show the mouse and hide the scisors here just in case.
			if(contains(_scisors)) {
				removeChild(_scisors);
				_scisors.stopDrag();
			}
		}
		
		/**
		 * Called when an element is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_spacePressed) return;
			
			//If a link has been clicked delete it
			if(event.target is BoxLink && !_debugMode) {
				prompt("editor-linkDelPromptTitle", "editor-linkDelPromptContent", BoxLink(event.target).deleteLink, "deleteLink");
			}
			
			if(_debugMode) {
				if (event.target is Box) {
					event.stopImmediatePropagation();
					event.stopPropagation();
					FrontControler.getInstance().setDebugStart(Box(event.target).data);
				}
			}
		}

		/**
		 * Called when a component is rolled over.
		 * Shows the scisors if necessary.
		 */
		private function overHandler(event:MouseEvent):void {
			if(event.ctrlKey || _spacePressed) return;
			
			if (event.target is BoxLink && event.target != _tempLink && !_debugMode) {
				Mouse.hide();
				_scisors.x = mouseX;
				_scisors.y = mouseY;
				_scisors.startDrag();
				addChild(_linksHolder);
				addChild(_scisors);
			}else 
			
			if(DisplayObject(event.target).parent is Box && !_debugMode) {
				_lastOverEvent = (DisplayObject(event.target).parent as Box).data;
				computeTreeGUIDs(_nodes, onComputeTreeOverComplete, true);
			}else{
				Mouse.cursor = _selectMode && !_selectionDone? MouseCursor.AUTO :
								((event.target is Box || event.target is BoxTodo || event.target is AbstractNurunButton)? MouseCursor.BUTTON : MouseCursor.HAND);
			}
		}
		
		/**
		 * Called when a component is rolled out.
		 * Hide the scisors if necessary.
		 */
		private function outHandler(event:MouseEvent):void {
			if(_debugMode) {
				Mouse.cursor = MouseCursor.AUTO;
				return;
			}
			
			if(DisplayObject(event.target).parent is Box) {
				_lastOverEvent = null;
				var i:int, len:int;
				len = _boxes.length;
				for(i = 0; i < len; ++i) {
					_boxes[i].filters = [];
				}
			}
			
			if(event.target is BoxLink) {
				Mouse.show();
				if(contains(_scisors)) {
					removeChild(_scisors);
					_scisors.stopDrag();
					addChild(_boxesHolder);
					addChild(_selectHolder);
				}
			}else{
				Mouse.cursor = MouseCursor.AUTO;
			}
			addChild(_todosHolder);
		}
		
		/**
		 * Called when mouse right button is pressed
		 */
		private function mouseRightDownHandler(event:MouseEvent):void {
			if(_debugMode || _spacePressed || _debugMode) return;
			_selectMode = true;
			_selectRect.x = _selectHolder.mouseX;
			_selectRect.y = _selectHolder.mouseY;
			_selectionDone = false;
			_boxesHolder.mouseChildren = false;
			_linksHolder.mouseChildren = false;
			Mouse.cursor = MouseCursor.AUTO;
		}

		/**
		 * Called when mouse right button is released
		 */
		private function mouseRightUpHandler(event:MouseEvent):void {
			if(_debugMode) return;
			
			var i:int, len:int, box:Box, minX:int, minY:int, maxX:int, maxY:int, item:DisplayObject;
			minX	= Math.min(_selectRect.x, _selectRect.right) - Box.COLS * BackgroundView.CELL_SIZE;
			minY	= Math.min(_selectRect.y, _selectRect.bottom) - Box.ROWS* BackgroundView.CELL_SIZE;
			maxX	= Math.max(_selectRect.right, _selectRect.left);
			maxY	= Math.max(_selectRect.bottom, _selectRect.top);
			len		= _boxes.length;
			var topLeft:Point		= new Point(int.MAX_VALUE, int.MAX_VALUE);
			var botRight:Point		= new Point(int.MIN_VALUE, int.MIN_VALUE);
			_selectedBoxes			= new Vector.<Box>();
			_selectedTodos			= new Vector.<BoxTodo>();
			var selectionOn:Array	= _highlightFilter;
			var selectionOff:Array	= [];
			for(i = 0; i < len; ++i) {
				box = _boxes[i];
				if(box.x > minX && box.y > minY
				&& box.x < maxX && box.y < maxY) {
					box.filters = selectionOn;
					_selectedBoxes.push(box);
					topLeft.x	= Math.min(topLeft.x, box.x);
					topLeft.y	= Math.min(topLeft.y, box.y);
					botRight.x	= Math.max(botRight.x, box.x);
					botRight.y	= Math.max(botRight.y, box.y);
				}else{
					box.filters = selectionOff;
				}
			}
			
			len = _todosHolder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _todosHolder.getChildAt(i);
				if(item.x > minX && item.y > minY
				&& item.x < maxX && item.y < maxY) {
					item.filters = selectionOn;
					_selectedTodos.push(item);
				}
			}
			
			if(_selectedBoxes.length == 0 && _selectedTodos.length == 0) {
				clearSelection();
			}else{
				_selectionDone		= true;
				_selectRect.x		= topLeft.x;
				_selectRect.y		= topLeft.y;
				_selectRect.right	= botRight.x + Box.COLS * BackgroundView.CELL_SIZE;
				_selectRect.bottom	= botRight.y + Box.ROWS * BackgroundView.CELL_SIZE;
				_selectHolder.graphics.clear();
				_selectHolder.graphics.lineStyle(2, 0xffffff, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 2);
				_selectHolder.graphics.beginFill(0xffffff, .5);
				_selectHolder.graphics.drawRect(_selectRect.x, _selectRect.y, _selectRect.width, _selectRect.height);
				_selectHolder.graphics.endFill();
			}
		}
		
		
		
		
		
		//__________________________________________________________ OTHER EVENTS...
		
		/**
		 * Called when trees are computed on roll over.
		 */
		private function onComputeTreeOverComplete(tree:Dictionary):void {
			_tree = tree;
			if(_lastOverEvent == null) return;
			var id:int, k:KuestEvent;
			for(var j:* in _tree) {
				k = j as KuestEvent;
				id = _tree[k];
				k.setTreeID(id);
			}
			var treeID:int = _lastOverEvent.getTreeID();
			var i:int, len:int, b:Box;
			len = _boxes.length;
			for(i = 0; i < len; ++i) {
				b = _boxes[i];
				b.filters = _tree[b.data] == treeID? _highlightFilter : [];
			}
		}
		
		/**
		 * Called when tree GUIDs computation completes
		 */
		private function onComputeTreeComplete(tree:Dictionary):void {
			_tree = tree;
			var idToMinX:Array = [];
			var idToMaxX:Array = [];
			var idToMinY:Array = [];
			var idToMaxY:Array = [];
			var id:int, k:KuestEvent;
			for(var j:* in _tree) {
				k = j as KuestEvent;
				id = _tree[k];
				k.setTreeID(id);
				if(idToMinX[ id ] == undefined) {
					idToMinX[ id ] = k.boxPosition.x;
					idToMaxX[ id ] = k.boxPosition.x + BackgroundView.CELL_SIZE * 8;
					idToMinY[ id ] = k.boxPosition.y;
					idToMaxY[ id ] = k.boxPosition.y + BackgroundView.CELL_SIZE * 3;
				}else{
					idToMinX[ id ] = Math.min(idToMinX[ id ], k.boxPosition.x);
					idToMaxX[ id ] = Math.max(idToMaxX[ id ], k.boxPosition.x + BackgroundView.CELL_SIZE * 8);
					idToMinY[ id ] = Math.min(idToMinY[ id ], k.boxPosition.y);
					idToMaxY[ id ] = Math.max(idToMaxY[ id ], k.boxPosition.y + BackgroundView.CELL_SIZE * 3);
				}
			}
			_boxesHolder.graphics.clear();
			_boxesHolder.graphics.lineStyle(.5, 0xff0000, 1);
			var i:int, len:int, margin:int = 20;
			len = idToMaxX.length;
			for(j in idToMaxX) {
				i = j as int;
				_boxesHolder.graphics.beginFill(0x55555 + Math.random() * 0xAAAAAA, .2);
				_boxesHolder.graphics.drawRect(idToMinX[i] - margin, idToMinY[i] - margin, idToMaxX[i] - idToMinX[i] + margin * 2, idToMaxY[i] - idToMinY[i] + margin * 2);
			}
		}
		
		/**
		 * Called when user starts/ends to edit comments. (drawings on the board)
		 */
		private function editCommentsStateChangeHandler(event:BoxesCommentsEvent):void {
			if(event.type == BoxesCommentsEvent.ENTER_EDIT_MODE) {
				addChild(_comments);
			}else{
				addChildAt(_comments, 0);
			}
			addChild(_todosHolder);
		}
		
		/**
		 * Called when debug mode state changes
		 */
		private function debugModeStateChangeHandler(event:ViewEvent):void {
			_debugMode = event.data as Boolean;
			_previousDebugTarget = null;
			var i:int, len:int;
			len = _boxes.length;
			for(i = 0; i < len; ++i) {
				_boxes[i].filters = _debugMode? _debugFilter : [];
				_boxes[i].debugMode = _debugMode;
			}
			len = _linksHolder.numChildren;
			for(i = 0; i < len; ++i) {
				_linksHolder.getChildAt(i).filters = _debugMode? _debugFilter : [];
			}
		}
		
		/**
		 * Called when a new event should be enabled on debugger
		 */
		private function debugEventHandler(event:Event):void {
			var i:int, len:int, noFilter:Array;
			len = _boxes.length;
			for(i = 0; i < len; ++i) {
				_boxes[i].filters = _debugFilter;
			}
			len = _linksHolder.numChildren;
			for(i = 0; i < len; ++i) {
				_linksHolder.getChildAt(i).filters = _debugFilter;
			}
			
			var target:Box = event.target as Box;
			target.filters = _debugSelectFilters;
			len = target.links.length;
			noFilter = [];
			for(i = 0; i < len; ++i) {
				if(target.links[i].startEntry == target) {
					target.links[i].endEntry.filters = _debugChildFilters;
					target.links[i].filters = noFilter;
				}
			}
			
			//If there was a previous event, search if the new event
			//is a child of it, and animate the link between them.
			if(_previousDebugTarget != null) {
				len = _previousDebugTarget.links.length;
				for(i = 0; i < len; ++i) {
					if(_previousDebugTarget.links[i].endEntry == target) {
						_previousDebugTarget.links[i].filters = noFilter;
						_previousDebugTarget.links[i].animateDebug(_debugFilter);
					}
				}
			}
			
			var endX:Number = -target.x * _boxesHolder.scaleX + stage.stageWidth * .5;
			var endY:Number = -target.y * _boxesHolder.scaleY + stage.stageHeight * .5;
			TweenLite.to(this, .75, {scrollX:endX, scrollY:endY, ease:Sine.easeInOut});
			
			_previousDebugTarget = target;
		}
		
		/**
		 * Called when the user searches for a todo from the menu
		 */
		private function searchTodoHandler(event:BoxEvent):void {
			var item:BoxTodo = event.target as BoxTodo;
			
			if(item != null) {
				var menu:SideMenuView = ViewLocator.getInstance().locateViewByType(SideMenuView) as SideMenuView;
				if(menu != null) {
					_endX = menu.x + menu.width + Math.round((stage.stageWidth - (menu.x + menu.width)) * .5 - item.x * _todosHolder.scaleX);
				}else{
					_endX = -item.x * _todosHolder.scaleX + stage.stageWidth * .5;
				}
				
				_endY = -item.y * _todosHolder.scaleY + stage.stageHeight * .5;
			}
		}
	}
}