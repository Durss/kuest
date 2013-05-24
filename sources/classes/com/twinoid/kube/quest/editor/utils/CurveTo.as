package com.twinoid.kube.quest.editor.utils {
	import flash.display.Graphics;
	import fl.motion.BezierSegment;

	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 23 mai 2013;
	 */
	public class CurveTo {
		
		private static var _target:Graphics;
		private static var _points:Vector.<Point>;
		private static var _controlPointsA:Array;
		private static var _controlPointsB:Array;
		private static var _closedCurve:Boolean;
		private static var _curvness:Number;
		private static var _drawControls:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CurveTo</code>.
		 */
		public function CurveTo() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public static function drawPath(target:Graphics, points:Vector.<Point>, curvness:Number = .35, closedCurve:Boolean = false, drawControls:Boolean = false):void {
			_drawControls = drawControls;
			_closedCurve = closedCurve;
			_curvness = curvness;
			_points = points;
			_target = target;
			calculateControlPoints();
			connectDots();
		}


		
		
		/* ******* *
		 * private static *
		 * ******* */
		
		private static function calculateControlPoints(): void {
			//Two Control Points for each control point
			_controlPointsA = new Array(_points.length);
			_controlPointsB = new Array(_points.length);
			
			
			//calculating first and last point for iteration
			var firstPtIndex:int = 1;
			var lastPtIndex:int = _points.length - 1;
			if(_closedCurve && _points.length>2) {
				//If this is a closed curve
				firstPtIndex = 0;
				lastPtIndex = _points.length;
			}
			//Looping thru all curve points to calculate control points
			//We loop from  2nd point to 2nd to last point
			//first point and last point are edge cases we come to later
			for( var i:int=firstPtIndex ; i<lastPtIndex ; i++ ) {
				//The prev, current and next point in our iteration
				var p0:Point = ((i-1 < 0) ? _points[_points.length-2] : _points[i-1])as Point;
				var p1:Point = _points[i]   as Point;
				var p2:Point = ((i+1 == _points.length) ?  _points[1] :_points[i+1]) as Point;
				
				//Calculating the distance of points and using a min length
				var a:Number = Point.distance(p0, p1);	a = Math.max(a, 0.01);
				var b:Number = Point.distance(p1, p2);	b = Math.max(b, 0.01);
				var c:Number = Point.distance(p2, p0);	c = Math.max(c, 0.01);
				//Angle between the 2 sides of the triangle
//				var C:Number = Math.acos((b*b + a*a - c*c)/(2*b*a));
				
				//Relative set of points
				var aPt:Point = new Point(p0.x - p1.x, p0.y - p1.y);
				var bPt:Point = new Point(p1.x, p1.y);
				var cPt:Point = new Point(p2.x - p1.x, p2.y - p1.y);
				
				if( a>b ) {
					aPt.normalize(b);
				} else if( b>a ) {
					cPt.normalize(a);
				}
				
				//Since the points are normalized
				//we put them back to their original position
				aPt.offset(p1.x, p1.y);
				cPt.offset(p1.x, p1.y);
				
				//Calculating vectors ba and bc
				var ax:Number = bPt.x - aPt.x;
				var ay:Number = bPt.y - aPt.y;
				var bx:Number = bPt.x - cPt.x;
				var by:Number = bPt.y - cPt.y;
				//Adding the two vectors gives the line perpendicular to the
				//control point line
				var rx:Number = ax + bx;
				var ry:Number = ay + by;
//				var r:Number = Math.sqrt(rx*rx + ry*ry);	//not reqd
				var theta:Number = Math.atan(ry/rx);
				
				
				var controlDist:Number = Math.min(a, b)*_curvness;
//				var controlScaleFactor:Number = C/Math.PI;
				//controlDist *= ((1-angleFactor)) + (angleFactor*controlScaleFactor));
				var controlAngle:Number = theta + Math.PI/2;
				
				var cp1:Point = Point.polar(controlDist, controlAngle + Math.PI);
				var cp2:Point = Point.polar(controlDist, controlAngle);
				//offset these control points to put them in the right place
				cp1.offset(p1.x, p1.y);
				cp2.offset(p1.x, p1.y);
				
				//ensureing P1 and P2 are not switched
				if(Point.distance(cp2, p2) > Point.distance(cp1, p2)) {
					//swap cp1 and cp2
					var dummyX:Number = cp1.x;	cp1.x = cp2.x;	cp2.x = dummyX;
					var dummyY:Number = cp1.y;	cp1.y = cp2.y;	cp2.y = dummyY;
				}
				
				_controlPointsA[i] = cp1;
				_controlPointsB[i] = cp2;
				
				if(_drawControls) {
//					_target.lineStyle(0,0xBBBBBB,0.6);
					_target.drawCircle(cp1.x, cp1.y, 10);
					_target.drawCircle(cp2.x, cp2.y, 10);
				}
			}
		}
		
		private static function connectDots(): void {
			if(_points.length <= 1) {
				//do nothing
			}else if(_points.length == 2) {
				drawLine();
			}else {
				drawCurve();
			}
		}
		
		private static function drawLine(): void {
			_target.moveTo((_points[0] as Point).x, (_points[0] as Point).y);
			_target.lineTo((_points[1] as Point).x, (_points[1] as Point).y);
		}
		
		private static function drawCurve(): void {
			//Calculating First and Last Points
			var firstPtIndex:int = 1;
			var lastPtIndex:int = _points.length - 1;
			if(_closedCurve) {
				//If this is a closed curve
				firstPtIndex = 0;
				lastPtIndex = _points.length+1;
			}
		
			//Drawing the Curve
			_target.moveTo((_points[0] as Point).x, (_points[0] as Point).y);
			
			//If this isnt a closed line
			if(firstPtIndex == 1) {
				//If this is a closed curve
				//Drawing a regular quadratic bezier curve from first to second point
				//using control point of the second point
				_target.curveTo((_controlPointsA[1] as Point).x, (_controlPointsA[1] as Point).y, (_points[1] as Point).x, (_points[1] as Point).y);
			}
			
			//Looping thru various points for drawing cubic bezzier curves
			for( var i:int=firstPtIndex; i<lastPtIndex-1 ; i++ ) {
				//var prevIndex:int = ((i-1 < 0) ? _points.length-2 : i-1);
				var nextIndex:int = ((i+1 == _points.length) ?  0 : i+1);
				drawBezzFromFourPoints(_points[i], _controlPointsB[i], _controlPointsA[nextIndex], _points[nextIndex]);
			}
			//If this isnt a closed curve 
			if(lastPtIndex == _points.length-1) { 
				//make the last curve and make it quadratic
				_target.curveTo((_controlPointsB[_points.length-2] as Point).x, (_controlPointsB[_points.length-2] as Point).y, (_points[_points.length-1] as Point).x, (_points[_points.length-1] as Point).y);
			}
		}
		
		private static function drawBezzFromFourPoints(p1:Point, p2:Point, p3:Point, p4:Point): void {
			//Util-ish function
			//This function can be optimized to use less than/more than 
			//100 points every time, based on the curvature of the curve
			var bs:BezierSegment = new BezierSegment(p1, p2, p3, p4);
			for( var t:Number=0.01 ; t<1.01 ; t+=0.01 ) {
				var val:Point = bs.getValue(t);
				_target.lineTo(val.x, val.y);
			}
		}
		
	}
}