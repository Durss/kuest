package com.twinoid.kube.quest.components.box {
	import com.nurun.utils.math.MathUtils;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BoxLink extends Sprite {

		private var _startEntry:Box;
		private var _endEntry:Box;
		private var _tmpPt:Point;
		
		
		
		
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

		public function set startEntry(startEntry:Box):void { _startEntry = startEntry; }

		public function get endEntry():Box { return _endEntry; }

		public function set endEntry(endEntry:Box):void { _endEntry = endEntry; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Draws a link from the starting box to the mouse
		 */
		public function drawToMouse():void {
			x = _startEntry.x + _startEntry.width;
			y = _startEntry.y + _startEntry.height * .5;
			
			var distMin:int = 25;
			var endX:int = mouseX;
			var endY:int = mouseY;
			_tmpPt.x = stage.mouseX;
			_tmpPt.y = stage.mouseY;
			
			//Search for a box target as end point
			var objs:Array = stage.getObjectsUnderPoint(_tmpPt);
			if(objs.length > 0) {
				var top:DisplayObject = objs[objs.length - 1];
				//Search for a Box instance
				while(!(top is Box) && !(top is Stage)) top = top.parent;
				if(top is Box && top.x > x + distMin * 2.5) {//Refuse boxes that are not far enough to get a good line rendering
					endX = top.x - x;
					endY = top.y + top.height * .5 - y;
				}
			}
			
			//Compute control points
			var ctrl1X:int = endX * .35;
			var ctrl1Y:int = 0;
			var ctrl2X:int = endX * .65;
			var ctrl2Y:int = endY;
			//Restrict the curve not to get a fucked up rendering
			if(ctrl1X < distMin)			ctrl1X = distMin;
			if(Math.abs(ctrl2X) < distMin)	ctrl2X = distMin * MathUtils.sign(ctrl2X);
			if(ctrl2X < ctrl1X + distMin)	ctrl2X = ctrl1X + distMin;
			if(endX < ctrl2X + distMin)		endX = ctrl2X + distMin;
			var halfX:int = endX * .5;
			var halfY:int = endY * .5;
			
			var a:Number = 0;//Math.atan2(mouseY, mouseX);
			var m:Matrix = new Matrix();
			var g:Graphics = graphics;
			g.clear();
			g.moveTo(0, 0);
			g.lineStyle(10, 0xffffff, 1);
			
			m.createGradientBox(halfX, halfY, a);
			g.lineGradientStyle(GradientType.LINEAR, [0xCD4B4B, 0xCFC149], [1, 1], [0, 0xff], m);
			g.curveTo(ctrl1X, ctrl1Y, halfX, halfY);
			
			m.createGradientBox(halfX, halfY, a, halfX, halfY);
			g.lineGradientStyle(GradientType.LINEAR, [0xCFC149, 0x5AB035], [1, 1], [0, 0xff], m);
			g.curveTo(ctrl2X, ctrl2Y, endX, endY);
			
//			g.lineStyle(0, 0, 0);
//			g.beginFill(0x00ff00);
//			g.drawCircle( ctrl1X, ctrl1Y, 5);
//			g.beginFill(0x0000ff);
//			g.drawCircle( ctrl2X, ctrl2Y, 5);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_tmpPt = new Point();
		}
		
	}
}