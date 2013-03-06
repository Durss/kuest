package com.twinoid.kube.quest.components.date {
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.graphics.DaySelectorItemSelectedSkinGraphic;
	import com.twinoid.kube.quest.graphics.DaySelectorItemSkinGraphic;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class DaySelector extends Sprite {
		private var _width:Number;
		private var _items:Vector.<ToggleButton>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DaySelector</code>.
		 */
		public function DaySelector() {
			_width = 200;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			var i:int, len:int, item:ToggleButton;
			len = 7;
			_items = new Vector.<ToggleButton>(len, true);
			for(i = 0; i < len; ++i) {
				item = addChild(new ToggleButton(Label.getLabel("day"+(i+1)),
												"daySelector-item",
												"daySelector-item_selected",
												new DaySelectorItemSkinGraphic(),
												new DaySelectorItemSelectedSkinGraphic()) ) as ToggleButton;
				applyDefaultFrameVisitorNoTween(item, item.defaultBackground, item.selectedBackground);
				item.textBoundsMode = false;
				item.validate();
				item.height = Math.round(item.height);
				
				_items[i] = item;
			}
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.hDistribute(_items, _width*2, 10);
		}
		
	}
}