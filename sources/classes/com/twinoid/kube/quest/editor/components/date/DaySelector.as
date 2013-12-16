package com.twinoid.kube.quest.editor.components.date {
	import flash.events.MouseEvent;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.graphics.DaySelectorItemSelectedSkinGraphic;
	import com.twinoid.kube.quest.graphics.DaySelectorItemSkinGraphic;

	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class DaySelector extends Sprite {
		private var _width:Number;
		private var _items:Vector.<ToggleButton>;
		private var _pressed:Boolean;
		private var _pressedItem:ToggleButton;
		
		
		
		
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
		
		/**
		 * Gets the selected days.
		 */
		public function get days():Array {
			var i:int, len:int, ret:Array;
			len = _items.length;
			ret = [];
			for(i = 0; i < len; ++i) {
				if(_items[i].selected) {
					ret.push( (i+1) % 7);//+1 and %7 are here to compensate the fact that day 0 is sunday, not monday
				}
			}
			return ret;
		}
		
		/**
		 * Sets the selected days.
		 */
		public function set days(value:Array):void {
			var i:int, len:int;
			if(value == null) {
				len = _items.length;
				for(i = 0; i < len; ++i) _items[ i ].selected = true;
			}else{
				//Unselect all
				len = _items.length;
				for(i = 0; i < len; ++i) _items[ i ].selected = false;
				//Select enabled ones
				len = value.length;
				for(i = 0; i < len; ++i) _items[ (value[i]+6)%7 ].selected = true;//+6 and %7 are here to compensate the fact that day 0 is sunday, not monday
			}
		}
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				_items[i].tabIndex = value + i;
			}
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
				item.selected = true;
				item.height = Math.round(item.height);
				item.addEventListener(MouseEvent.ROLL_OVER, overItemHandler);
				item.validate();
				
				_items[i] = item;
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			computePositions();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			if(_items == null) return;
			
			PosUtils.hDistribute(_items, _width*2, 10);
		}
		
		/**
		 * Called when an item is rolled over to select it if we're in drag select mode.
		 */
		private function overItemHandler(event:MouseEvent):void {
			if(_pressed) {
				if(_pressedItem !=  null) {
					_pressedItem.selected = !_pressedItem.selected;
					_pressedItem = null;
				}
				ToggleButton(event.currentTarget).selected = !ToggleButton(event.currentTarget).selected;
			}
		}
		
		/**
		 * Called when a component is pressed.
		 * Start the drag selection.
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(event.target is ToggleButton) {
				_pressed = true;
				_pressedItem = event.target as ToggleButton;
			}
		}
		
		/**
		 * Called when the mouse is released to stop the drag selection
		 */
		private function mouseUpHandler(event:MouseEvent):void { _pressed = false; }
		
	}
}