package com.twinoid.kube.quest.views {
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.twinoid.kube.quest.model.Model;

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
			var src:Shape = new Shape();
			src.graphics.beginFill(0x8FC7DE);
			src.graphics.drawRect(0, 0, CELL_SIZE, 1);
			src.graphics.drawRect(0, 0, 1, CELL_SIZE);
			_pattern = new BitmapData(CELL_SIZE, CELL_SIZE, false, 0xffBBDDEC);
			_pattern.draw(src);
			
			_scale = 1;
			_matrix = new Matrix();
//			_matrix.rotate(Math.PI*.25);
			_default = _matrix.clone();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
		
	}
}