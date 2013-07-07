package com.twinoid.kube.quest.editor.views {
	import flash.filters.ColorMatrixFilter;
	import com.twinoid.kube.quest.player.utils.computeTreeGUIDs;
	import gs.TweenLite;
	import gs.easing.Back;

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
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.ScissorsGraphic;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;



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
			_dataToBox		= new Dictionary();
			
			_tempBox		= new Box();
			_scisors		= new ScissorsGraphic();
			_comments		= addChild(new BoxesComments()) as BoxesComments;
			_linksHolder	= addChild(new Sprite()) as Sprite;
			_boxesHolder	= addChild(new Sprite()) as Sprite;
			_tempLink		= _linksHolder.addChild(new BoxLink(null, null)) as BoxLink;
			
			_scisors.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
			_scisors.mouseChildren = false;
			_scisors.mouseEnabled = false;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_comments.addEventListener(BoxesCommentsEvent.ENTER_EDIT_MODE, editCommentsStateChangeHandler);
			_comments.addEventListener(BoxesCommentsEvent.LEAVE_EDIT_MODE, editCommentsStateChangeHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
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
			if(_spacePressed) {
				if(_stagePressed && _draggedItem == null) {
					if(hasMoved) _draggingBoard = true;
					_endX = _dragOffset.x + stage.mouseX - _mouseOffset.x;
					_endY = _dragOffset.y + stage.mouseY - _mouseOffset.y;
				}
			}else if(_stagePressed && _draggedItem == null) {
				_comments.startDraw();
			}
			
			//Moves the board when dragging something on the borders
			if(_draggedItem != null || _tempLink.startEntry != null) {
				var addX:Number = 0, addY:Number = 0, maxSpeed:int = 10;
				if(stage.mouseX < DRAG_GAP)						addX = (1-stage.mouseX / DRAG_GAP);
				if(stage.mouseX > stage.stageWidth - DRAG_GAP)	addX = -(stage.mouseX - stage.stageWidth + DRAG_GAP) / DRAG_GAP;
				if(stage.mouseY < DRAG_GAP)						addY = (1-stage.mouseY / DRAG_GAP);
				if(stage.mouseY > stage.stageHeight - DRAG_GAP)	addY = -(stage.mouseY - stage.stageHeight + DRAG_GAP) / DRAG_GAP;
				if(_startDragInGap && addX == 0 && addY == 0) _startDragInGap = false;//Allow drag again if we leave the drag zone.
				if(!_startDragInGap && (addX != 0 || addY != 0)) {
					if(addX!=0) addX = Math.pow(maxSpeed, Math.abs(addX) * 1.2 + 1) * MathUtils.sign(addX);
					if(addY!=0) addY = Math.pow(maxSpeed, Math.abs(addY) * 1.2 + 1) * MathUtils.sign(addY);
					if(_draggedItem != null) {
						_draggedItem.x -= addX;
						_draggedItem.y -= addY;
					}
					_endX = _boxesHolder.x + addX * _boxesHolder.scaleX;
					_endY = _boxesHolder.y + addY * _boxesHolder.scaleY;
				}
			}
			
			if(_draggedItem != null) {
				var size:int = BackgroundView.CELL_SIZE;
				_draggedItem.x = Math.round( (_boxesHolder.mouseX - _dragItemOffset.x) / size) * size;
				_draggedItem.y = Math.round( (_boxesHolder.mouseY - _dragItemOffset.y) / size) * size;
			}
			
			//Move the board
			_boxesHolder.x += (_endX - _boxesHolder.x) * .5;
			_boxesHolder.y += (_endY - _boxesHolder.y) * .5;
			_linksHolder.x = _boxesHolder.x;
			_linksHolder.y = _boxesHolder.y;
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			_comments.scrollTo(_boxesHolder.x, _boxesHolder.y);
			
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
			
			_boxesHolder.removeChild(target);
			
			var i:int, len:int, item:DisplayObject, box:Box, link:BoxLink;
			len = _boxesHolder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _boxesHolder.getChildAt(i);
				box = item as Box;
				//Should actually be done in the model.
				box.data.removeDependency(target.data);//remove eventual dependencies
			}
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
		 * Clears everything.
		 */
		private function clear():void {
			var item:DisplayObject;
			//Clear boxes
			while(_boxesHolder.numChildren > 0) _boxesHolder.removeChild(_boxesHolder.getChildAt(0));
			
			//Clear links
			while(_linksHolder.numChildren > 0) {
				item = _linksHolder.getChildAt(0);
				if(item != _tempLink) {
					if(item is Disposable) Disposable(item).dispose();
					item.removeEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
					item.removeEventListener(BoxEvent.DELETE, deleteBoxHandler);
				}
				_linksHolder.removeChild(item);
			}
			_linksHolder.addChild(_tempLink);
		}
		
		/**
		 * Builds the items from a collection of items.
		 */
		private function buildFromCollection(nodes:Vector.<KuestEvent>):void {
			_nodes = nodes;
			var i:int, len:int, box:Box;
			var j:int, lenJ:int;
			len = nodes.length;
			//Create the items and registers all the items to find back their dependencies faster.
			var dependencies:Vector.<Box> = new Vector.<Box>();
			var dataToBox:Dictionary = new Dictionary();
			for(i = 0; i < len; ++i) {
				box = createItem(nodes[i], false);
				dataToBox[box.data] = box;
				if(nodes[i].dependencies.length > 0) {
					dependencies.push(box);
				}
			}
			
			//Creates the links
			len = dependencies.length;
			for(i = 0; i < len; ++i) {
				lenJ = dependencies[i].data.dependencies.length;
				for(j = 0; j < lenJ; ++j) {
					var link:BoxLink = new BoxLink( dataToBox[ dependencies[i].data.dependencies[j].event ], dependencies[i], dependencies[i].data.dependencies[j].choiceIndex );
					_linksHolder.addChild(link);
					link.startEntry.addlink(link);
					link.endEntry.addlink(link);
				}
			}
			
			if(nodes.length > 0 ) {
				_endX = _boxesHolder.x = -nodes[0].boxPosition.x * _boxesHolder.scaleX + stage.stageWidth * .5;
				_endY = _boxesHolder.y = -nodes[0].boxPosition.y * _boxesHolder.scaleY + stage.stageHeight * .5;
				_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
				_comments.scrollTo(_boxesHolder.x, _boxesHolder.y);
			}
		}
		
		/**
		 * Creates a box item.
		 */
		private function createItem(data:KuestEvent, tween:Boolean = true):Box {
			var item:Box = new Box(data);
			item.buttonMode = true;
			item.addEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
			item.addEventListener(BoxEvent.DELETE, deleteBoxHandler);
			_boxesHolder.addChild( item );
			
			if(tween) {
				TweenLite.from(item, .25, {transformAroundCenter:{scaleX:0, scaleY:0}, ease:Back.easeOut});
			}
			
			return item;
		}

		
		
		
		
		//__________________________________________________________ MOUSE/KEYBOARD EVENTS
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(!_stagePressed && !_spacePressed && event.keyCode == Keyboard.SPACE) {
				var objs:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
				var top:DisplayObject = objs[objs.length - 1];
				if(top != null && contains(top)) {
					_spacePressed = top == this || _comments.contains(top);
					if(_spacePressed) Mouse.cursor = MouseCursor.HAND;
				}
			}
		}
		
		/**
		 * Called when a key is released.
		 * Used to cancel temp box.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.SPACE) {
				if (_spacePressed) Mouse.cursor = MouseCursor.AUTO;
				_spacePressed = false;
			}
			if(event.keyCode == Keyboard.ESCAPE) {
				if(event.shiftKey) {
					_tree = new Dictionary();
					computeTreeGUIDs(_nodes, _tree, onComputeTreeComplete);
				}else {
					_boxesHolder.graphics.clear();
				}
			}
		}
		
		/**
		 * Called when tree GUIDs computation completes
		 */
		private function onComputeTreeComplete():void {
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
		 * Called when user scrolls its mouse wheel to zoom in/out the board
		 */
		private function wheelHandler(event:MouseEvent):void {
			var p:Point = new Point(_boxesHolder.mouseX, _boxesHolder.mouseY);
			_boxesHolder.scaleX = _boxesHolder.scaleY += MathUtils.sign(event.delta) * .15;
			_boxesHolder.scaleX = _boxesHolder.scaleY = MathUtils.restrict(_boxesHolder.scaleX, .25, 1);
			_linksHolder.scaleX = _linksHolder.scaleY = _boxesHolder.scaleX;
			
			p = _boxesHolder.localToGlobal(p);
			_boxesHolder.x += stage.mouseX - p.x;
			_boxesHolder.y += stage.mouseY - p.y;
			_linksHolder.x = _boxesHolder.x;
			_linksHolder.y = _boxesHolder.y;
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
			if(!_spacePressed && event.target != this && event.target != _comments) {
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
						//Prevents from scrolling n borders if we actually start to frag the
						//item on the drag_gap zone.
						_startDragInGap = (stage.mouseX < DRAG_GAP || stage.mouseY < DRAG_GAP
											|| stage.mouseX > stage.stageWidth - DRAG_GAP
											|| stage.mouseY > stage.stageHeight - DRAG_GAP);
					}
				}
				return;
			}
			
			_dragOffset.x = _boxesHolder.x;
			_dragOffset.y = _boxesHolder.y;
			_mouseOffset.x = _prevMousePos.x = stage.mouseX;
			_mouseOffset.y = _prevMousePos.x = stage.mouseY;
			_stagePressed = true;
			_draggingBoard = false;
			
			if(!_spacePressed) _comments.startDraw();
		}
		
		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_stagePressed = false;
			_comments.stopDraw();
			
			//If we were dragging the board, throw it.
			if(_draggingBoard) {
				_endX += (stage.mouseX - _prevMousePos.x) * 5;
				_endY += (stage.mouseY - _prevMousePos.y) * 5;
				_draggingBoard = false;
			
			}else if(_draggedItem == null && Point.distance(_mouseOffset, _prevMousePos) < 2 && !event.ctrlKey && !_spacePressed){
				//If we weren't dragging the board, create a new item
				var size:int = BackgroundView.CELL_SIZE;
				var px:Number = Math.round((_boxesHolder.mouseX - _tempBox.width * .5) / size) * size;
				var py:Number = Math.round((_boxesHolder.mouseY - _tempBox.height * .5) / size) * size;
				//Add an item to the tree
				FrontControler.getInstance().addEntryPoint(px, py);
			}
			
			//If a link has just been created correctly, try to create the link
			var success:Boolean = true;
			if (_tempLink.endEntry != null) {
				success = _tempLink.endEntry.data.addDependency(_tempLink.startEntry.data, _tempLink.choiceIndex);
				if(!success) {
					_tempLink.showError();
				} else {
					var link:BoxLink = _tempLink.clone();
					_linksHolder.addChild(link);
					link.startEntry.addlink(link);
					link.endEntry.addlink(link);
				}
			}
			_tempLink.startEntry = null;
			_tempLink.endEntry = null;
			//success test prevents from instant line clearing if the link
			//is actually displaying an error. In this case, the link self clears.
			if(success) _tempLink.update();
			
			//Clean stuffs that need to be
			if (_draggedItem != null) {
				Box(_draggedItem).data.boxPosition.x = _draggedItem.x;
				Box(_draggedItem).data.boxPosition.y = _draggedItem.y;
				_draggedItem.stopDrag();
			}
			_draggedItem = null;
			
			//When a link is deleted it's not captured here. It does its things
			//on its side. We show the mouse and hide the scisors here just in case.
			if(contains(_scisors)) {
				removeChild(_scisors);
				_scisors.stopDrag();
			}
		}
		
		/**
		 * Called when a component is rolled out.
		 * Hide the scisors if necessary.
		 */
		private function outHandler(event:MouseEvent):void {
			if(DisplayObject(event.target).parent is Box) {
				_lastOverEvent = null;
				var i:int, len:int, b:Box;
				len = _boxesHolder.numChildren;
				for(i = 0; i < len; ++i) {
					b = _boxesHolder.getChildAt(i) as Box;
					b.filters = [];
				}
			}
			
			if(event.ctrlKey || _spacePressed) return;
			
			if(event.target is BoxLink) {
				Mouse.show();
				if(contains(_scisors)) removeChild(_scisors);
				_scisors.stopDrag();
				addChild(_boxesHolder);
			}
		}

		/**
		 * Called when a component is rolled over.
		 * Shows the scisors if necessary.
		 */
		private function overHandler(event:MouseEvent):void {
			if(event.ctrlKey || _spacePressed) return;
			
			if (event.target is BoxLink && event.target != _tempLink) {
				Mouse.hide();
				_scisors.x = mouseX;
				_scisors.y = mouseY;
				_scisors.startDrag();
				addChild(_linksHolder);
				addChild(_scisors);
			}else 
			
			if(DisplayObject(event.target).parent is Box) {
				_lastOverEvent = (DisplayObject(event.target).parent as Box).data;
				_tree = new Dictionary();
				computeTreeGUIDs(_nodes, _tree, onComputeTreeOverComplete, true);
			}
		}
		
		/**
		 * Called when trees are computed on roll over.
		 */
		private function onComputeTreeOverComplete():void {
			if(_lastOverEvent == null) return;
			var id:int, k:KuestEvent;
			for(var j:* in _tree) {
				k = j as KuestEvent;
				id = _tree[k];
				k.setTreeID(id);
			}
			var treeID:int = _lastOverEvent.getTreeID();
			var i:int, len:int, b:Box;
			len = _boxesHolder.numChildren;
			for(i = 0; i < len; ++i) {
				b = _boxesHolder.getChildAt(i) as Box;
				b.filters = _tree[b.data] == treeID? [new ColorMatrixFilter([1,0,0,0,50, 0,1,0,0,50, 0,0,1,0,50, 0,0,0,1,0 ])] : [];
			}
		}
		
		/**
		 * Called when user starts/ends to edit comments.
		 */
		private function editCommentsStateChangeHandler(event:BoxesCommentsEvent):void {
			if(event.type == BoxesCommentsEvent.ENTER_EDIT_MODE) {
				addChild(_comments);
			}else{
				addChildAt(_comments, 0);
			}
		}
	}
}