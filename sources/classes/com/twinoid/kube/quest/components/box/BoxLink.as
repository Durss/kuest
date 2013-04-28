package com.twinoid.kube.quest.components.box {
	import com.twinoid.kube.quest.graphics.ScissorsGraphic;
	import com.nurun.core.lang.Disposable;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	import flash.display.CapsStyle;
	import flash.events.Event;
	import gs.TweenLite;

	import com.twinoid.kube.quest.graphics.WarningGraphic;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxLink extends Sprite implements Disposable {

		private var _startEntry:Box;
		private var _endEntry:Box;
		private var _tmpPt:Point;
		private var _warning:WarningGraphic;
		private var _scisors:ScissorsGraphic;
		private var _isOver:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxLink</code>.
		 */
		public function BoxLink(startEntry:Box, endEntry:Box) {
			_endEntry = endEntry;
			_startEntry = startEntry;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get startEntry():Box { return _startEntry; }

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

		public function set endEntry(value:Box):void { _endEntry = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Draws a link from the starting box to the mouse
		 */
		public function drawToMouse():void {
//			var distMin:int = 25;
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
				if(top is Box) {// && top.x > x + distMin * 2.5) {//Refuse boxes that are not far enough to get a good line rendering
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
			return new BoxLink(startEntry, endEntry);
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
			y = _startEntry.y + _startEntry.height * .5;
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
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			graphics.clear();
			if(_scisors != null) _scisors.filters = [];
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
//			filters = [new BevelFilter(5,135,0xffffff,.3,0,.25,5,5,1,2)];//Potential perf killer.?
			
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
			_endEntry.data.removeDependent(_startEntry.data);
			//self clear/dispose. BoxView has no hard reference to this
			//component (at this time at least..) so we can do that safely.
			dispose();
			Mouse.show();
		}
		
		/**
		 * Called when link is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(_scisors == null) {
				_scisors = new ScissorsGraphic();
				_scisors.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
			}
			addChild(_scisors);
			Mouse.hide();
			_scisors.x = mouseX;
			_scisors.y = mouseY;
			_scisors.startDrag();
			_isOver = true;
			update();
		}
		
		/**
		 * Called when link is rolled out
		 */
		private function rollOutHandler(event:MouseEvent):void {
			_isOver = false;
			Mouse.show();
			removeChild(_scisors);
			_scisors.stopDrag();
			update();
		}
		
		/**
		 * Draws the link to a specific end point.
		 */
		private function drawLink(endX:int, endY:int):void {
			x = _startEntry.x + _startEntry.width;
			y = _startEntry.y + _startEntry.height * .5;
			alpha = startEntry != null && endEntry != null? 1 : .45;
			
			//Compute control points
			var ctrl1X:int = endX * .35;
			var ctrl1Y:int = 0;
			var ctrl2X:int = endX * .65;
			var ctrl2Y:int = endY;
			//Restrict the curve not to get a fucked up rendering
//			if(ctrl1X < distMin)			ctrl1X = distMin;
//			if(Math.abs(ctrl2X) < distMin)	ctrl2X = distMin * MathUtils.sign(ctrl2X);
//			if(ctrl2X < ctrl1X + distMin)	ctrl2X = ctrl1X + distMin;
//			if(endX < ctrl2X + distMin)		endX = ctrl2X + distMin;
			var halfX:int = endX * .5;
			var halfY:int = endY * .5;
			var colors:Array = !_isOver? [0xCD4B4B, 0x348CB1, 0x5AB035] : [0xdf8c8c, 0x7abcd8, 0xa0db88];
			
			var a:Number = 0;//Math.atan2(mouseY, mouseX);
			var m:Matrix = new Matrix();
			var g:Graphics = graphics;
			g.clear();
			if(alpha == 1) {
				//Hit zone
				g.moveTo(0, 0);
				g.lineStyle(30, 0xffffff, 0, false, "normal", CapsStyle.NONE);
				g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
				g.curveTo(ctrl2X, ctrl2Y, endX, endY);
			}
			
			//Borders
			g.moveTo(0, 0);
			g.lineStyle(14, 0xffffff, 1, false, "normal", CapsStyle.NONE);
			g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
			g.curveTo(ctrl2X, ctrl2Y, endX, endY);
			
			//Draw gradient line
			g.moveTo(0, 0);
			g.lineStyle(10, 0xffffff, 1, false, "normal", CapsStyle.NONE);
			
			m.createGradientBox(halfX, halfY, a);
			g.lineGradientStyle(GradientType.LINEAR, [colors[0], colors[1]], [1, 1], [0, 0xff], m);
			g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
			
			m.createGradientBox(halfX, halfY, a, halfX, halfY);
			g.lineGradientStyle(GradientType.LINEAR, [colors[1], colors[2]], [1, 1], [0, 0xff], m);
			g.curveTo(ctrl2X, ctrl2Y, endX, endY);
			
//			g.lineStyle(0, 0, 0);
//			g.beginFill(0x00ff00);
//			g.drawCircle( ctrl1X, ctrl1Y, 5);
//			g.beginFill(0x0000ff);
//			g.drawCircle( ctrl2X, ctrl2Y, 5);
		}
		
	}
}