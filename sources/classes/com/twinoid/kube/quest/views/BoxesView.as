package com.twinoid.kube.quest.views {
	import com.nurun.utils.math.MathUtils;
	import gs.TweenLite;
	import gs.easing.Back;

	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.components.box.Box;
	import com.twinoid.kube.quest.components.box.BoxLink;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.events.BoxEvent;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Manages the boxes and links rendering.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxesView extends AbstractView {
		
		private const DRAG_GAP:int = 100;
		
		private var _dataToBox:Dictionary;
		private var _createTimeout:uint;
		private var _tempBox:Sprite;
		private var _scrollOffset:Point;
		private var _boxesHolder:Sprite;
		private var _canceled:Boolean;
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
		private var _overBoard:Boolean;
		private var _mousePressed:Boolean;
		private var _startDragInGap:Boolean;
		private var _dragItemOffset:Point;
		
		
		
		
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
				var item:Box = new Box(lastItem);
				item.buttonMode = true;
				item.addEventListener(BoxEvent.CREATE_LINK, createLinkHandler);
				_boxesHolder.addChild( item );
			}
			if(_background == null) {
				_background = ViewLocator.getInstance().locateViewByType(BackgroundView) as BackgroundView;
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
			
			_tempBox		= new Sprite();
			_boxesHolder	= addChild(new Sprite()) as Sprite;
			_tempLink		= _boxesHolder.addChild(new BoxLink(null, null)) as BoxLink;
			
			var b:Box = new Box();
			b.x = -b.width * .5;
			b.y = -b.height * .5;
			_tempBox.addChild(b);
			_tempBox.mouseChildren = false;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler2, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK, doubleClick);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			doubleClickEnabled = true;
			_scrollOffset = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
			
			_boxesHolder.x = _endX = _scrollOffset.x;
			_boxesHolder.y = _endY = _scrollOffset.y;
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			computePositions();
		}
		
		/**
		 * Create a box on double click
		 */
		private function doubleClick(event:MouseEvent):void {
			if(event.target != this) return;
			addTempItem();
		}
		
		/**
		 * Called when user scrolls its mouse wheel to zoom in/out the board
		 */
		private function wheelHandler(event:MouseEvent):void {
			var p:Point = new Point(_boxesHolder.mouseX, _boxesHolder.mouseY);
			_boxesHolder.scaleX = _boxesHolder.scaleY += MathUtils.sign(event.delta) * .15;
			_boxesHolder.scaleX = _boxesHolder.scaleY = MathUtils.restrict(_boxesHolder.scaleX, .25, 1);
			p = _boxesHolder.localToGlobal(p);
			_endX = _boxesHolder.x += stage.mouseX - p.x;
			_endY = _boxesHolder.y += stage.mouseY - p.y;
			_background.setScale(_boxesHolder.scaleX);
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
		}
		
		/**
		 * Called on ENTER_FRAME event
		 */
		private function enterFrameHandler(event:Event):void {
			var objs:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
			var top:DisplayObject = objs[objs.length - 1];
			
			//Manage board's drag if mouse isn't over anything else
			if(top != null && contains(top)) {
				if(top == this) {
					_overBoard = true;
					if(Mouse.cursor != MouseCursor.HAND) Mouse.cursor = MouseCursor.HAND;
					if(_stagePressed) {
						if(Math.abs(_dragOffset.x - _boxesHolder.x) > 2 || Math.abs(_dragOffset.x - _boxesHolder.x) > 2) {
							clearTimeout(_createTimeout);//Cancel item's creation
							_tempBox.stopDrag();
							_draggingBoard = true;
						}
						_endX = _dragOffset.x + stage.mouseX - _mouseOffset.x;
						_endY = _dragOffset.y + stage.mouseY - _mouseOffset.y;
					}
				}else if(Mouse.cursor != MouseCursor.AUTO){
					Mouse.cursor = MouseCursor.AUTO;
				}
			}else if(_overBoard){
				Mouse.cursor = MouseCursor.AUTO;
				_overBoard = false;
			}
			
			//Moves the board when dragging something on the borders
			if(_mousePressed && !_stagePressed) {
				var addX:int, addY:int;
				if(stage.mouseX < DRAG_GAP)						addX = (1-stage.mouseX / DRAG_GAP) * 50;
				if(stage.mouseX > stage.stageWidth - DRAG_GAP)	addX = -(stage.mouseX - stage.stageWidth + DRAG_GAP) / DRAG_GAP * 50;
				if(stage.mouseY < DRAG_GAP)						addY = (1-stage.mouseY / DRAG_GAP) * 50;
				if(stage.mouseY > stage.stageHeight - DRAG_GAP)	addY = -(stage.mouseY - stage.stageHeight + DRAG_GAP) / DRAG_GAP * 50;
				if(_startDragInGap && addX == 0 && addY == 0) _startDragInGap = false;//Allow drag again if we leav the drag zone.
				if(!_startDragInGap && (addX != 0 || addY != 0)) {
					if(_draggedItem != null) {
						_draggedItem.x -= addX;
						_draggedItem.y -= addY;
					}
					_endX = _boxesHolder.x += addX * _boxesHolder.scaleX;
					_endY = _boxesHolder.y += addY * _boxesHolder.scaleY;
				}
			}
			
			if(_draggedItem != null) {
				var size:int = BackgroundView.CELL_SIZE;
				_draggedItem.x = Math.round( (_boxesHolder.mouseX - _dragItemOffset.x) / size) * size;
				_draggedItem.y = Math.round( (_boxesHolder.mouseY - _dragItemOffset.y) / size) * size;
				
				//The default item is atually a sprite containing a centered box.
				//The fact the box is centered fucks up the rounded position.
				if (_draggedItem == _tempBox) {
					var inner:DisplayObject = _draggedItem.getChildAt(0);
					_draggedItem.x -= inner.x%size;
					_draggedItem.y -= inner.y%size;
				}
			}
			
			//Move the board
			_prevMousePos.x = stage.mouseX;
			_prevMousePos.y = stage.mouseY;
			_boxesHolder.x += (_endX - _boxesHolder.x) * .35;
			_boxesHolder.y += (_endY - _boxesHolder.y) * .35;
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			
			//Draw the links
			if(_tempLink.startEntry != null) {
				_tempLink.drawToMouse();
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
		 * Adds a temporary item
		 */
		private function addTempItem():void {
			_boxesHolder.addChild(_tempBox);
			_tempBox.alpha = .5;
			_tempBox.x = _boxesHolder.mouseX;
			_tempBox.y = _boxesHolder.mouseY;
			_tempBox.scaleX = 1;
			_tempBox.scaleY = 1;
			TweenLite.from(_tempBox, .25, {scaleX:0, scaleY:0, ease:Back.easeOut});
			_draggedItem = _tempBox;
			_dragItemOffset.x = _draggedItem.mouseX;
			_dragItemOffset.y = _draggedItem.mouseY;
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when a key is released.
		 * Used to cancel temp box.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(_boxesHolder.contains(_tempBox) && event.keyCode == Keyboard.ESCAPE) {
				_canceled = true;
				TweenLite.to(_tempBox, .25, {scaleX:0, scaleY:0, ease:Back.easeIn, removeChild:true});
			}
		}
		
		/**
		 * Called when mouse is pressed.
		 * Start timer to add a new item
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if (event.target == _tempBox) return;
			if(event.target != this) {
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
					}
				}
				return;
			}
			
			_dragOffset.x = _boxesHolder.x;
			_dragOffset.y = _boxesHolder.y;
			_mouseOffset.x = _prevMousePos.x = stage.mouseX;
			_mouseOffset.y = _prevMousePos.x = stage.mouseY;
			_stagePressed = true;
			_canceled = false;
			_draggingBoard = false;
			clearTimeout(_createTimeout);
			_createTimeout = setTimeout(addTempItem, 300);
		}
		
		/**
		 * The Box instance stops the MOUSE_DOWN propagation if we create a link.
		 * This prevents from moving the box when we actually want to create a
		 * link between another box.
		 * This second handler listen for the event at the "capture" level of
		 * the event flow so it receives it.
		 */
		private function mouseDownHandler2(event:MouseEvent):void {
			//Do not allow scroll dragging if the element is already inside
			//the DRAG_GAP zone. That would be borring.
			_startDragInGap = (stage.mouseX < DRAG_GAP || stage.mouseY < DRAG_GAP
								|| stage.mouseX > stage.stageWidth - DRAG_GAP
								|| stage.mouseY > stage.stageHeight - DRAG_GAP);
			_mousePressed = true;
		}
		
		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_mousePressed = false;
			_stagePressed = false;
			if(_draggingBoard) {
				_endX += (stage.mouseX - _prevMousePos.x) * 5;
				_endY += (stage.mouseY - _prevMousePos.y) * 5;
				_draggingBoard = false;
			}
			
			
			//If a link has just been created correctly, try to create the link
			var success:Boolean = true;
			if (_tempLink.endEntry != null) {
				success = _tempLink.endEntry.data.addDependent(_tempLink.startEntry.data);
				if(!success) {
					_tempLink.showError();
				} else {
					var link:BoxLink = _tempLink.clone();
					_boxesHolder.addChildAt(link, 0);
					link.startEntry.addlink(link);
					link.endEntry.addlink(link);
				}
			}
			_tempLink.startEntry = null;
			_tempLink.endEntry = null;
			//success test prevents from instant line clearing if the link
			//is actually displaying an error. In this case, the link self clears.
			if(success) _tempLink.update();
			
			
			//If the user just created a new item.
			if(!_canceled && _boxesHolder.contains(_tempBox)) {
				_boxesHolder.removeChild(_tempBox);
				//Add an item to the tree
				FrontControler.getInstance().addEntryPoint(_tempBox.x - _tempBox.width *.5, _tempBox.y - _tempBox.height *.5);
			}
			
			
			//Clean stuffs that need to be
			clearTimeout(_createTimeout);
			if (_draggedItem != null) _draggedItem.stopDrag();
			_draggedItem = null;
		}
		
		/**
		 * Starts a link's creation.
		 */
		private function createLinkHandler(event:BoxEvent):void {
			_tempLink.startEntry = event.currentTarget as Box;
			_tempLink.drawToMouse();
			_boxesHolder.addChildAt(_tempLink, 0);
		}
	}
}