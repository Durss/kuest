package com.twinoid.kube.quest.editor.components.box {
	import gs.TweenLite;

	import com.nurun.core.lang.Disposable;
	import com.twinoid.kube.quest.editor.views.BackgroundView;
	import com.twinoid.kube.quest.graphics.WarningGraphic;

	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxLink extends Sprite implements Disposable {
		
		public static const COLORS:Array = [0xCA4F4F, 0xDD7600, 0xDDDD00, 0x9BDD00, 0x00DD58, 0x007FDD];
		public static const COLORS_OVER:Array = [0xdf8c8c, 0xFD9935, 0xEEEE33, 0xaffb00, 0x00f462, 0x55b7ff];

		private var _startEntry:Box;
		private var _endEntry:Box;
		private var _choiceIndex:int;
		private var _tmpPt:Point;
		private var _warning:WarningGraphic;
		private var _isOver:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxLink</code>.
		 */
		public function BoxLink(startEntry:Box, endEntry:Box, choiceIndex:int = 0) {
			_endEntry = endEntry;
			_startEntry = startEntry;
			_choiceIndex = choiceIndex;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the starting box of the link
		 */
		public function get startEntry():Box { return _startEntry; }
		
		/**
		 * Sets the starting box of the link
		 */
		public function set startEntry(value:Box):void { 
			_startEntry = value;
			if(value != null && _warning != null && contains(_warning)) {
				removeChild(_warning);
			}
		}

		/**
		 * Gets the end box target.
		 * 
		 * In case of edition mode, this will contain the snapped box.
		 * When user creates a links from a box, if he rolls another box, the
		 * link will snap to it and this property will contain the reference
		 * to that snapped box.
		 */
		public function get endEntry():Box { return _endEntry; }

		/**
		 * Sets the end box target.
		 */
		public function set endEntry(value:Box):void { _endEntry = value; }
		
		/**
		 * Gets the choice index from which this link starts.
		 */
		public function get choiceIndex():int { return _choiceIndex; }

		/**
		 * Sets the choice index from which this link starts.
		 */
		public function set choiceIndex(choiceIndex:int):void { _choiceIndex = choiceIndex; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Draws a link from the starting box to the mouse
		 */
		public function drawToMouse():void {
			var endX:int = mouseX;
			var endY:int = mouseY;
			_tmpPt.x = stage.mouseX;
			_tmpPt.y = stage.mouseY;
			
			//Search for a box target as end point
			endEntry = null;
			var objs:Array = stage.getObjectsUnderPoint(_tmpPt);
			if(objs.length > 0) {
				var i:int = objs.length - 1;
				var top:DisplayObject = objs[i];
				
				while(top is BoxLink) top = objs[--i];
				//Search for a Box instance different than the start entry point
				while(!(top is Box) && !(top is Stage) && top != null || top == _startEntry) top = top.parent;
				if(top is Box) {
					endX = top.x - x;
					endY = top.y + top.height * .5 - y;
					endEntry = top as Box;
				}
			}
			
			drawLink(endX, endY);
		}
		
		/**
		 * Displays an error and clears the link.
		 * Called if the link cannot be created due to a looped reference
		 */
		public function showError():void {
			if(_warning == null) _warning = new WarningGraphic();
			var bounds:Rectangle = getBounds(this);
			_warning.alpha = 1;
			_warning.x = bounds.x + bounds.width * .5;
			_warning.y = bounds.y + bounds.height * .5;
			_warning.filters = [new DropShadowFilter(5,135,0,.35,5,5,1,2)]; 
			addChild(_warning);
			TweenLite.from(_warning, .25, {alpha:0});
			TweenLite.to(_warning, .25, {alpha:0, delay:1, removeChild:true, onComplete:graphics.clear});
		}
		
		/**
		 * Clones the link and returns a new instance.
		 */
		public function clone():BoxLink {
			return new BoxLink(startEntry, endEntry, choiceIndex);
		}
		
		/**
		 * Updates the link's rendering.
		 */
		public function update(...args):void {
			if(_startEntry == null || _endEntry == null) {
				graphics.clear();
				return;
			}
			
			x = _startEntry.x + _startEntry.width;
			y = _startEntry.y + _startEntry.getChoiceIndexPosition(_choiceIndex);
			var endX:Number = _endEntry.x - x;
			var endY:Number = _endEntry.y + _endEntry.height * .5 - y;
			drawLink(endX, endY);
		}
		
		/**
		 * Starts the link's auto update
		 */
		public function startAutoUpdate():void {
			if(!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		/**
		 * Stops the link's auto update
		 */
		public function stopAutoUpdate():void {
			removeEventListener(Event.ENTER_FRAME, update);
			update();
		}
		
		/**
		 * Deletes the link.
		 * Removes itself from its related data.
		 */
		public function deleteLink():void {
			_endEntry.data.removeDependency(_startEntry.data, _choiceIndex);
			//self clear/dispose. BoxView has no hard reference to this
			//component (for now at least..) so we can do that safely.
			dispose();
			parent.removeChild(this);
			Mouse.show();
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			graphics.clear();
			if(_warning != null) _warning.filters = [];
			
			_tmpPt = null;
			_endEntry = _startEntry = null;
			
			removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(Event.ENTER_FRAME, update);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_tmpPt = new Point();
			
			if (_startEntry != null && _endEntry != null) {
				update();
				mouseChildren = false;
				addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				addEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
		
		/**
		 * Called when link is clicked to cut it
		 */
		private function clickHandler(event:MouseEvent):void {
			deleteLink();
		}
		
		/**
		 * Called when link is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(event.ctrlKey) return;
			_isOver = true;
			update();
		}
		
		/**
		 * Called when link is rolled out
		 */
		private function rollOutHandler(event:MouseEvent):void {
			if(event.ctrlKey) return;
			_isOver = false;
			update();
		}
		
		/**
		 * Draws the link to a specific end point.
		 */
		private function drawLink(endX:int, endY:int):void {
			x = _startEntry.x + _startEntry.width;
			y = _startEntry.y + _startEntry.getChoiceIndexPosition(_choiceIndex);
			alpha = startEntry != null && endEntry != null? 1 : .45;
			
			//Compute control points
			var ctrl1X:int = endX * .4;
			var ctrl1Y:int = 0;
			var ctrl2X:int = endX * .6;
			var ctrl2Y:int = endY;
			var halfX:int = endX * .5;
			var halfY:int = endY * .5;
			if(endX < BackgroundView.CELL_SIZE) {
				ctrl1X = Math.min((100 - endX)*.5, 300);
				ctrl2X = endX-ctrl1X;
				if(endY == 0 && alpha == 1) halfY = 50;
				ctrl1Y = ctrl2Y = halfY;
			}
			var colors:Array = !_isOver? [COLORS[0], 0x5AB035] : [0xdf8c8c, 0xa0db88];
			if(_choiceIndex > 0) {
				colors[0] = !_isOver? COLORS[_choiceIndex] : COLORS_OVER[_choiceIndex];
			}
			
			var a:Number = 0;//Math.atan2(endY, endX);
			var m:Matrix = new Matrix();
			var g:Graphics = graphics;
			g.clear();
	//			var points:Vector.<Point> = new <Point>[new Point(0,0), new Point(ctrl1X, ctrl1Y), new Point(ctrl2X, ctrl2Y), new Point(endX, endY)];
			if(alpha == 1) {
				//Hit zone
				g.moveTo(0, 0);
				g.lineStyle(30, 0xffffff, 0, false, "normal", CapsStyle.NONE);
	//				CurveTo.drawPath(g, points);
				g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
				g.curveTo(ctrl2X, ctrl2Y, endX, endY);
			}
			
			//Borders
			g.moveTo(0, 0);
			g.lineStyle(14, 0xffffff, 1, false, "normal", CapsStyle.NONE);
			g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
			g.curveTo(ctrl2X, ctrl2Y, endX, endY);
	//			CurveTo.drawPath(g, points);
			
			//Draw gradient line
			g.moveTo(0, 0);
			g.lineStyle(10, 0xffffff, 1, false, "normal", CapsStyle.NONE);
			
			m.createGradientBox(endX, endY, a);
			g.lineGradientStyle(GradientType.LINEAR, colors, [1, 1], [0x10, 0xf0], m);
			g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
//			
//			m.createGradientBox(halfX, halfY, a, halfX, halfY);
//			g.lineGradientStyle(GradientType.LINEAR, [colors[1], colors[2]], [1, 1], [0, 0xff], m);
			g.curveTo(ctrl2X, ctrl2Y, endX, endY);

	//			m.createGradientBox(endX, endY, a, x, y);
	//			g.lineGradientStyle(GradientType.LINEAR, [colors[0], colors[2]], [1, 1], [0, 0xff], m);
	//			CurveTo.drawPath(g, points);
			
//			g.lineStyle(0, 0, 0);
//			g.beginFill(0x00ff00);
//			g.drawCircle( ctrl1X, ctrl1Y, 5);
//			g.beginFill(0x0000ff);
			// g.drawCircle( ctrl2X, ctrl2Y, 5);
		}
		
	}
}