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
		private var _pattern:BitmapData;
		private var _matrix:Matrix;
		
		
		
		
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
			if(_matrix.tx == x && _matrix.ty == y) return;
			
			_matrix.tx = x;
			_matrix.ty = y;
			computePositions();
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
			src.graphics.drawRect(0, 0, 29, 1);
			src.graphics.drawRect(0, 0, 1, 29);
			_pattern = new BitmapData(29, 29, false, 0xffBBDDEC);
			_pattern.draw(src);
			
			_matrix = new Matrix();
			_matrix.rotate(Math.PI*.25);
			
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
			graphics.beginBitmapFill(_pattern, _matrix);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
	}
}