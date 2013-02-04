package com.twinoid.kube.quest.views {
	import com.twinoid.kube.quest.vo.KuestEvent;
	import flash.display.Sprite;
	import flash.geom.Point;
	import com.twinoid.kube.quest.controler.FrontControler;
	import gs.TweenLite;
	import gs.easing.Back;

	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.twinoid.kube.quest.components.box.Box;
	import com.twinoid.kube.quest.model.Model;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
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
				_boxesHolder.addChild( item );
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_dataToBox = new Dictionary();
			_tempBox = new Sprite();
			_boxesHolder = addChild(new Sprite()) as Sprite;
			
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
			
			_scrollOffset = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
			
			_boxesHolder.x = _scrollOffset.x;
			_boxesHolder.y = _scrollOffset.y;
			
			computePositions();
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
			if(event.target != this) return;
			
			_canceled = false;
			clearTimeout(_timeout);
			_timeout = setTimeout(addTempItem, 250);
		}
		
		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			clearTimeout(_timeout);
			_tempBox.stopDrag();
			if(!_canceled && _boxesHolder.contains(_tempBox)) {
				_boxesHolder.removeChild(_tempBox);
				
				//Add an item to the tree
				FrontControler.getInstance().addEntryPoint(_tempBox.x - _tempBox.width *.5, _tempBox.y - _tempBox.height *.5);
			}
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
	}
}