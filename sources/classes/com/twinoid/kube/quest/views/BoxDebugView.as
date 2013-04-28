package com.twinoid.kube.quest.views {
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;
	import com.nurun.utils.pos.PosUtils;
	import flash.geom.Rectangle;
	import flash.display.CapsStyle;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.KuestData;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.events.Event;

	/**
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class BoxDebugView extends AbstractView {
		private var _data:KuestData;
		private var _ks:KeyboardSequenceDetector;
		private var _enabled:Boolean;
		
		
		
		
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
		}
		
		/**
		 * Called when debug sequence is detected.
		 */
		private function sequenceHandler(event:KeyboardSequenceEvent):void {
			if(event.sequenceId == "f5" && !_enabled) return;
			
			if(event.sequenceId == "clear") {
				graphics.clear();
				return;
			}
			
			_enabled = true;
			var nodes:Vector.<KuestEvent> = _data.nodes;
			var i:int, len:int, d:KuestEvent, scale:Number, w:int, h:int;
			len = nodes.length;
			scale = .2;
			w = BackgroundView.CELL_SIZE * 8 * scale;
			h = BackgroundView.CELL_SIZE * 3 * scale;
			
			graphics.clear();
			graphics.beginFill(0xff0000, 1);
			for(i = 0; i < len; ++i) {
				d = nodes[i];
				graphics.moveTo(d.boxPosition.x * scale, d.boxPosition.y * scale);
				graphics.drawRect(d.boxPosition.x * scale, d.boxPosition.y * scale, w, h);
				var j:int, lenJ:int;
				lenJ = d.dependencies.length;
				for(j = 0; j < lenJ; ++j) {
					graphics.lineStyle(2, 0x0000ff, 1, false, "normal", CapsStyle.NONE);
					graphics.moveTo(d.boxPosition.x * scale, d.boxPosition.y * scale + h * .5);
					graphics.lineTo(d.dependencies[j].boxPosition.x * scale + w, d.dependencies[j].boxPosition.y * scale + h * .5);
					graphics.lineStyle(0, 0, 0);
				}
			}

			var bounds:Rectangle = getBounds(this);
			PosUtils.centerInStage(this);
			x -= bounds.x;
			y -= bounds.y;
		}
	}
}