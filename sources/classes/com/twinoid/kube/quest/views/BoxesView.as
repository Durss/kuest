package com.twinoid.kube.quest.views {
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
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxesView extends AbstractView {
		private var _dataToBox:Dictionary;
		private var _timeout:uint;
		private var _tempBox:Sprite;
		private var _scrollOffset:Point;
		private var _boxesHolder:Sprite;
		private var _canceled:Boolean;
		private var _pressed:Boolean;
		private var _dragOffset:Point;
		private var _mouseOffset:Point;
		private var _background:BackgroundView;
		private var _endX:Number;
		private var _endY:Number;
		private var _prevMousePos:Point;
		private var _draggingBoard:Boolean;
		private var _tempLink:BoxLink;
		
		
		
		
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
			_dataToBox		= new Dictionary();
			
			_tempBox		= new Sprite();
			_boxesHolder	= addChild(new Sprite()) as Sprite;
			_tempLink		= _boxesHolder.addChild(new BoxLink(null, null)) as BoxLink;
			
			var b:Box = new Box();
			b.x = -b.width * .5;
			b.y = -b.height * .5;
			_tempBox.addChild(b);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			_scrollOffset = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
			
			_boxesHolder.x = _scrollOffset.x;
			_boxesHolder.y = _scrollOffset.y;
			_background.scrollTo(_boxesHolder.x, _boxesHolder.y);
			
			computePositions();
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
					if(Mouse.cursor != MouseCursor.HAND) Mouse.cursor = MouseCursor.HAND;
					if(_pressed) {
						if(Math.abs(_dragOffset.x - _boxesHolder.x) > 5 || Math.abs(_dragOffset.x - _boxesHolder.x) > 5) {
							clearTimeout(_timeout);//Cancel item's creation
							_tempBox.stopDrag();
							_draggingBoard = true;
						}
						_endX = _dragOffset.x + stage.mouseX - _mouseOffset.x;
						_endY = _dragOffset.y + stage.mouseY - _mouseOffset.y;
					}
				}else if(Mouse.cursor != MouseCursor.AUTO){
					Mouse.cursor = MouseCursor.AUTO;
				}
			}else if(Mouse.cursor != MouseCursor.AUTO){
				Mouse.cursor = MouseCursor.AUTO;
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
			_tempBox.startDrag();
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
			if(event.target != this) {
				if (_boxesHolder.contains(event.target as DisplayObject)) {
					//Go up until we find a box (or the stage..)
					var target:DisplayObject = event.target as DisplayObject;
					while(!(target is Box) && !(target is Stage)) target = target.parent;
					//If a box is found, drag it.
					if(target is Box) {
						Box(target).startDrag();
						_boxesHolder.addChild(target);
					}
				}
				return;
			}
			
			_dragOffset.x = _boxesHolder.x;
			_dragOffset.y = _boxesHolder.y;
			_mouseOffset.x = _prevMousePos.x = stage.mouseX;
			_mouseOffset.y = _prevMousePos.x = stage.mouseY;
			_pressed = true;
			_canceled = false;
			_draggingBoard = false;
			clearTimeout(_timeout);
			_timeout = setTimeout(addTempItem, 250);
		}
		
		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_pressed = false;
			if(_draggingBoard) {
				_endX += (stage.mouseX - _prevMousePos.x) * 5;
				_endY += (stage.mouseY - _prevMousePos.y) * 5;
			}
			_draggingBoard = false;
			_tempLink.startEntry = null;
			
			clearTimeout(_timeout);
			_tempBox.stopDrag();
			if(!_canceled && _boxesHolder.contains(_tempBox)) {
				_boxesHolder.removeChild(_tempBox);
				
				//Add an item to the tree
				FrontControler.getInstance().addEntryPoint(_tempBox.x - _tempBox.width *.5, _tempBox.y - _tempBox.height *.5);
			}
		}
		
		/**
		 * Starts a link's creation.
		 */
		private function createLinkHandler(event:BoxEvent):void {
			_tempLink.startEntry = event.currentTarget as Box;
		}
	}
}