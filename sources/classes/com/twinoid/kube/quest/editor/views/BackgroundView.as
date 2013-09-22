package com.twinoid.kube.quest.editor.views {
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;


	/**
	 * Draws the application's background
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class BackgroundView extends AbstractView {
		
		public static const CELL_SIZE:int = 29;
		
		private var _pattern:BitmapData;
		private var _matrix:Matrix;
		private var _default:Matrix;
		private var _scale:Number;
		private var _backup:BitmapData;
		private var _emptyPoint:Point;
		private var _debugFilter:ColorMatrixFilter;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BackgroundView</code>.
		 */
		public function BackgroundView() {
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
			model;
		}
		
		/**
		 * Scrolls the background
		 */
		public function scrollTo(x:int, y:int):void {
			//Prevents from a whole screen's rendering when un-necessary
			if(_matrix.tx == x%(CELL_SIZE*_scale) && _matrix.ty == y%(CELL_SIZE*_scale)) return;
			
			_matrix.tx = x%(CELL_SIZE*_scale);
			_matrix.ty = y%(CELL_SIZE*_scale);
			computePositions();
		}

		public function setScale(value:Number):void {
			_scale = value;
			_matrix.a = _default.a;
			_matrix.b = _default.b;
			_matrix.c = _default.c;
			_matrix.d = _default.d;
			_matrix.scale(value, value);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_emptyPoint = new Point();
			var src:Shape = new Shape();
			src.graphics.beginFill(0x8FC7DE);
			src.graphics.drawRect(0, 0, CELL_SIZE, 1);
			src.graphics.drawRect(0, 0, 1, CELL_SIZE);
			_pattern = new BitmapData(CELL_SIZE, CELL_SIZE, false, 0xffBBDDEC);
			_pattern.draw(src);
			_pattern.lock();
			_backup = _pattern.clone();
			_backup.lock();
			
			_debugFilter = new ColorMatrixFilter([-0.4945659935474396,1.3561458587646484,0.13842006027698517,0,-5.999999046325684,0.41543397307395935,0.4461459517478943,0.138419970870018,0,-5.999999523162842,0.41543394327163696,1.3561460971832275,-0.7715799808502197,0,-6,0,0,0,1,0]);
			
			_scale = 1;
			_matrix = new Matrix();
//			_matrix.rotate(Math.PI*.25);
			_default = _matrix.clone();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.DEBUG_MODE_CHANGE, debugModeStateChangeHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginBitmapFill(_pattern, _matrix, true, true);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		/**
		 * Called when debug state changes to update background's color
		 */
		private function debugModeStateChangeHandler(event:ViewEvent):void {
			_pattern.copyPixels(_backup, _backup.rect, _emptyPoint);
			if(event.data === true) {
				_pattern.applyFilter(_pattern, _pattern.rect, _emptyPoint, _debugFilter);
			}
			computePositions();
		}
		
	}
}