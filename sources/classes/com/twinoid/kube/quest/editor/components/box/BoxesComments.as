package com.twinoid.kube.quest.editor.components.box {
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.utils.Simplify;
	import com.twinoid.kube.quest.graphics.RubberCursorGraphic;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	
	/**
	 * Manages the drawing and display of comments over the board.
	 * 
	 * @author Francois
	 * @date 4 mai 2013;
	 */
	public class BoxesComments extends Sprite {
		
		private var _drawing:Boolean;
		private var _start:Point;
		private var _points:Vector.<Point>;
		private var _tmpDrawing:Shape;
		private var _paths:Vector.<GraphicsPath>;
		private var _lastDrawingTime:Number;
		private var _mergeWithPrevious:Boolean;
		private var _viewPorts:Vector.<Rectangle>;
		private var _currentViewPort:Rectangle;
		private var _eraseMode:Boolean;
		private var _topLeft:Point;
		private var _bottomRight:Point;
		private var _itemToIndex:Dictionary;
		private var _shadow:Array;
		private var _drawingData:Vector.<IGraphicsData>;
		private var _chunksHolder:Sprite;
		private var _rubberIcon:RubberCursorGraphic;
		private var _drawingDataHit:Vector.<IGraphicsData>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxesComments</code>.
		 */
		public function BoxesComments() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the drawing of a comment
		 */
		public function startDraw():void {
			if(_drawing || _eraseMode) return;
			_drawing = true;
			_start.x = mouseX;
			_start.y = mouseY;
			_points = new Vector.<Point>();
			_points.push(_start);
			
			_currentViewPort.left = _currentViewPort.right = _start.x;
			_currentViewPort.top = _currentViewPort.bottom = _start.y;
			
			//If previous drawing has been done less than X seconds ago, merge it.
			_mergeWithPrevious = getTimer() - _lastDrawingTime < 5000;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Stops the drawing.
		 * Smooth the line and merge it to the previous if necessary.
		 */
		public function stopDraw():void {
			if(!_drawing) return;
			_drawing = false;
			_tmpDrawing.graphics.clear();
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			//Ignore too small drawings
			if (_points.length < 3) return;

			var data:GraphicsPath = smoothLines(Simplify.simplifyDouglasPeucker(_points, 50));
			//Merge data with previous drawing
			if (_mergeWithPrevious && _viewPorts.length > 0) {
				var vp:Rectangle = _viewPorts[ _viewPorts.length - 1 ];
				var cmds:Vector.<int> = _paths[ _paths.length - 1 ].commands.concat(data.commands);
				var path:Vector.<Number> = _paths[ _paths.length - 1 ].data.concat(data.data);
				var newData:GraphicsPath = new GraphicsPath(cmds, path);
				_paths[ _paths.length - 1 ] = newData;
				
				if(_currentViewPort.left < vp.left)		vp.left = _currentViewPort.left;
				if(_currentViewPort.right > vp.right)	vp.right = _currentViewPort.right;
				if(_currentViewPort.top < vp.top)		vp.top = _currentViewPort.top;
				if(_currentViewPort.bottom > vp.bottom)	vp.bottom = _currentViewPort.bottom;
				
			}else{
				_paths.push( data );
				_viewPorts.push( _currentViewPort.clone() );
			}
			
			_drawingData[1] = data;
			graphics.drawGraphicsData( _drawingData );
			
			_lastDrawingTime = getTimer();
			
			FrontControler.getInstance().saveComments(_paths, _viewPorts);
		}
		
		/**
		 * Scrolls to a specific position
		 */
		public function scrollTo(px:Number, py:Number):void {
			if(Math.abs(x-px) < 1 && Math.abs(y-py) < 1) {
				x = px;
				y = py;
				return;
			}
			
			x = px;
			y = py;
			
			clipDrawings();
		}
		
		/**
		 * Scrolls to a specific position
		 */
		public function setScale(value:Number):void {
			scaleX = scaleY = value;
			GraphicsStroke(_drawingData[0]).thickness = 3 / value;
			GraphicsStroke(_drawingDataHit[0]).thickness = 50 / value;
			clipDrawings();
		}
		
		/**
		 * Loads comments data.
		 * Used when loading a new kuest
		 */
		public function load(comments:Vector.<GraphicsPath>, viewports:Vector.<Rectangle>):void {
			if(comments != null) {
				_paths = comments;
				_viewPorts = viewports;
			}else{
				_paths = new Vector.<GraphicsPath>();
				_viewPorts = new Vector.<Rectangle>();
			}
			clipDrawings();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_start = new Point();
			_lastDrawingTime = int.MIN_VALUE;
			
			_paths = new Vector.<GraphicsPath>();
			_viewPorts = new Vector.<Rectangle>();
			_currentViewPort = new Rectangle();
			_shadow = [new DropShadowFilter(0,0,0,1,5,5,1,2)];
			
			_drawingData = new Vector.<IGraphicsData>();
			var stroke:GraphicsStroke = new GraphicsStroke(3);
			stroke.fill = new GraphicsSolidFill(0xffffff, 1);
			_drawingData.push(stroke);
			
			_drawingDataHit = new Vector.<IGraphicsData>();
			stroke = new GraphicsStroke(50);
			stroke.fill = new GraphicsSolidFill(0xffffff, 0);
			_drawingDataHit.push(stroke);
			
			_tmpDrawing		= addChild(new Shape()) as Shape;
			_chunksHolder	= addChild(new Sprite()) as Sprite;
			_rubberIcon		= addChild(new RubberCursorGraphic()) as RubberCursorGraphic;
			
			_rubberIcon.visible = false;
			_rubberIcon.mouseEnabled = false;
			_rubberIcon.mouseChildren = false;
			_rubberIcon.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Called when a key is pressed.
		 * Listens for F5 to draw debug.
		 * CTRL or SHIFT for erasing.
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			//Draw bounding boxes
			if(event.keyCode == Keyboard.F5) {
				graphics.clear();
				var i:int, len:int;
				len = _paths.length;
				for(i = 0; i < len; ++i) {
					_drawingData[1] = _paths[i];
					graphics.drawGraphicsData( _drawingData );
				}
				
				var vp:Rectangle;
				len = _viewPorts.length;
				graphics.lineStyle(3 / scaleX, 0xff0000);
				for(i = 0; i < len; ++i) {
					vp = _viewPorts[i];
					graphics.drawRect(vp.x, vp.y, vp.width, vp.height);
				}
			}
			
			//Detect CTRL or SHIFT key
			if(event.keyCode == Keyboard.CONTROL || event.keyCode == Keyboard.SHIFT) {
				if(!_eraseMode && !_drawing) {
					splitGraphics();
					_eraseMode = true;
					_rubberIcon.visible = true;
					_rubberIcon.x = mouseX;
					_rubberIcon.y = mouseY;
					_rubberIcon.startDrag();
					Mouse.hide();
				}
			}
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.CONTROL || event.keyCode == Keyboard.ALTERNATE || event.keyCode == Keyboard.SHIFT) {
				_eraseMode = false;
				clearSplittedGraphics();
				_rubberIcon.visible = false;
				_rubberIcon.stopDrag();
				Mouse.show();
				clipDrawings();
			}
		}
		
		/**
		 * Clears the splitted graphics.
		 */
		private function clearSplittedGraphics():void {
			while(_chunksHolder.numChildren > 0) {
				disposeItem(_chunksHolder.getChildAt(0) as Sprite);
			}
		}
		
		/**
		 * Splits the graphics ito seperate items to be able to delete them.
		 */
		private function splitGraphics():void {
			graphics.clear();
			var i:int, len:int, item:Sprite;
			len = _viewPorts.length;
			_itemToIndex = new Dictionary();
			
			for(i = 0; i < len; ++i) {
				if(viewPortVisible(_viewPorts[i])) {
					_drawingData[1] = _paths[i];
					_drawingDataHit[1] = _paths[i];
					item = _chunksHolder.addChild(new Sprite()) as Sprite;
//					item.graphics.beginFill(0xff0000, 0);
//					item.graphics.drawRect(_viewPorts[i].x, _viewPorts[i].y, _viewPorts[i].width, _viewPorts[i].height);
//					item.graphics.endFill();
					item.graphics.drawGraphicsData(_drawingDataHit);
					item.graphics.drawGraphicsData(_drawingData);
					item.buttonMode = true;
					item.addEventListener(MouseEvent.CLICK, clickItemHandler);
					item.addEventListener(MouseEvent.ROLL_OVER, rollItemHandler);
					item.addEventListener(MouseEvent.ROLL_OUT, rollItemHandler);
					
					_itemToIndex[item] = i;
				}
			}
		}
		
		/**
		 * Called when an item is clicked
		 */
		private function clickItemHandler(event:MouseEvent):void {
			var index:int = _itemToIndex[event.currentTarget];
			disposeItem(event.currentTarget as Sprite);
			_paths.splice(index, 1);
			_viewPorts.splice(index, 1);
			FrontControler.getInstance().saveComments(_paths, _viewPorts);
			_lastDrawingTime = int.MIN_VALUE;
			clearSplittedGraphics();
			splitGraphics();
		}
		
		/**
		 * Disposes an item.
		 */
		private function disposeItem(item:Sprite):void {
			item.filters = [];
			item.graphics.clear();
			item.buttonMode = false;
			item.removeEventListener(MouseEvent.CLICK, clickItemHandler);
			item.removeEventListener(MouseEvent.ROLL_OVER, rollItemHandler);
			item.removeEventListener(MouseEvent.ROLL_OUT, rollItemHandler);
			_chunksHolder.removeChild(item);
		}
		
		/**
		 * Called when an item is rolled over/out
		 */
		private function rollItemHandler(event:MouseEvent):void {
			var item:Sprite = event.currentTarget as Sprite;
			if(event.type == MouseEvent.ROLL_OVER) {
				item.filters = _shadow;
			}else{
				item.filters = [];
			}
		}
		
		/**
		 * Called on enter frame event to draw shits.
		 */
		private function enterFrameHandler(event:Event):void {
			var newPos:Point = new Point(mouseX, mouseY);
			
			if(Point.distance(newPos, _points[_points.length-1]) > 2) { 
				_points.push(newPos);
			}
			
			var i:int, len:int;
			len = _points.length;
			_tmpDrawing.graphics.clear();
			_tmpDrawing.graphics.lineStyle(3 / scaleX, 0xffffff, 1);
			_tmpDrawing.graphics.moveTo(_points[0].x, _points[0].y);
			for(i = 1; i < len; ++i) {
				_tmpDrawing.graphics.lineTo(_points[i].x, _points[i].y);
			}
			
			if(mouseX < _currentViewPort.left) _currentViewPort.left = mouseX;
			if(mouseX > _currentViewPort.right) _currentViewPort.right = mouseX;
			if(mouseY < _currentViewPort.top) _currentViewPort.top = mouseY;
			if(mouseY > _currentViewPort.bottom) _currentViewPort.bottom = mouseY;
		}
		
		/**
		 * Smooths the drawing
		 */
		public function smoothLines(points:Vector.<Point>):GraphicsPath {
			var p1:Point, p2:Point, prevMidPoint:Point, midPoint:Point;
			var pathCmds:Vector.<int> = new Vector.<int>();
			var pathCoords:Vector.<Number> = new Vector.<Number>();
			
			prevMidPoint = null;
			midPoint = null;
			for (var i: int = 1; i < points.length; i++) {
				p1 = points[i - 1];
				p2 = points[i];
				
				midPoint = new Point(p1.x + (p2.x - p1.x) / 2, p1.y + (p2.y - p1.y) / 2);
				
				// draw the curves:
				if (prevMidPoint) {
					pathCmds.push(GraphicsPathCommand.MOVE_TO);
					pathCoords.push(prevMidPoint.x, prevMidPoint.y);
					pathCmds.push(GraphicsPathCommand.CURVE_TO);
					pathCoords.push(p1.x, p1.y, midPoint.x, midPoint.y);
				} else {
					// draw start segment:
					pathCmds.push(GraphicsPathCommand.MOVE_TO);
					pathCoords.push(p1.x, p1.y);
					pathCmds.push(GraphicsPathCommand.LINE_TO);
					pathCoords.push(midPoint.x, midPoint.y);
				}
				prevMidPoint = midPoint;
				//draw last stroke
				if (i == points.length - 1) {
					pathCmds.push(GraphicsPathCommand.LINE_TO);
					pathCoords.push(points[i].x, points[i].y);
				}
			}
			
			return new GraphicsPath(pathCmds, pathCoords);
		}
		
		/**
		 * Draws only the necessary comments
		 */
		private function clipDrawings():void {
			graphics.clear();
			
			_topLeft = globalToLocal(new Point(0, 0));
			_bottomRight = globalToLocal(new Point(stage.stageWidth, stage.stageHeight));
			
			var i:int, len:int;
			len = _viewPorts.length;
			var count:int = 0;
			for(i = 0; i < len; ++i) {
				//Test drawing's visibility
				if( viewPortVisible(_viewPorts[i]) ) {
					_drawingData[1] = _paths[i];
					graphics.drawGraphicsData( _drawingData );
					count ++;
				}
			}
		}
		
		/**
		 * Checks if a viewport is visible
		 */
		private function viewPortVisible(viewport:Rectangle):Boolean {
			return viewport.right > _topLeft.x && viewport.left < _bottomRight.x && viewport.bottom > _topLeft.y && viewport.top < _bottomRight.y;
		}
		
	}
}