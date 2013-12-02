package com.twinoid.kube.quest.editor.views {
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.display.CapsStyle;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;


	/**
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class BoxDebugView extends AbstractView {
		private var _data:KuestData;
		private var _ks:KeyboardSequenceDetector;
		private var _enabled:Boolean;
		private const _scale:Number = .1;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxDebugView</code>.
		 */
		public function BoxDebugView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
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
			_data = model.kuestData;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			filters = [new GlowFilter(0xffffff, 1, 6, 6, 2, 2)];
			
			_ks = new KeyboardSequenceDetector(stage);
			_ks.addSequence("debug", KeyboardSequenceDetector.DEBUG_CODE);
			_ks.addSequence("f5", [Keyboard.F5]);
			_ks.addSequence("clear", "clear");
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, sequenceHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Called when debug sequence is detected.
		 */
		private function sequenceHandler(event:KeyboardSequenceEvent):void {
			if(event.sequenceId == "f5" && !_enabled) return;
			
			if(event.sequenceId == "clear") {
				_enabled = false;
				graphics.clear();
				return;
			}
			
			_enabled = true;
			var i:int, len:int, d:KuestEvent, w:int, h:int;
			var nodes:Vector.<KuestEvent> = _data.nodes;
			
			len = nodes.length;
			w = BackgroundView.CELL_SIZE * 8 * _scale;
			h = BackgroundView.CELL_SIZE * 3 * _scale;
			
			graphics.clear();
			graphics.beginFill(0xff0000, 1);
			for(i = 0; i < len; ++i) {
				d = nodes[i];
				graphics.moveTo(d.boxPosition.x * _scale, d.boxPosition.y * _scale);
				graphics.drawRect(d.boxPosition.x * _scale, d.boxPosition.y * _scale, w, h);
				var j:int, lenJ:int;
				lenJ = d.getDependencies().length;
				for(j = 0; j < lenJ; ++j) {
					graphics.lineStyle(2, 0x0000ff, 1, false, "normal", CapsStyle.NONE);
					graphics.moveTo(d.boxPosition.x * _scale, d.boxPosition.y * _scale + h * .5);
					graphics.lineTo(d.getDependencies()[j].event.boxPosition.x * _scale + w, d.getDependencies()[j].event.boxPosition.y * _scale + h * .5);
					graphics.lineStyle(0, 0, 0);
				}
			}

			enterFrameHandler();
		}
		
		/**
		 * Called on enter frame event to move the holder relatively to the grid
		 */
		private function enterFrameHandler(event:Event = null):void {
			if (!_enabled) return;
			var view:BoxesView = ViewLocator.getInstance().locateViewByType(BoxesView) as BoxesView;
			
			x = view.offsetX * _scale + stage.stageWidth * .5;
			y = view.offsetY * _scale + stage.stageHeight * .5;
			
		}
	}
}