package com.twinoid.kube.quest.editor.components.form.input {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import com.muxxu.kub3dit.graphics.ComboboxBackgroundGraphic;
	import com.muxxu.kub3dit.graphics.ComboboxIconGraphic;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.ComboBox;
	import com.nurun.components.form.events.ListEvent;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.graphics.ComboboxIconUpGraphic;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;



	/**
	 * Fired when an item is selected
	 *
	 * @eventType com.nurun.components.form.events.ListEvent.SELECT_ITEM
	 */
	[Event(name="onSelectItem", type="com.nurun.components.form.events.ListEvent")]
	
	/**
	 * 
	 * @author Francois DURSUS for Nurun
	 * @date 7 juin 2011;
	 */
	public class ComboboxKube extends ComboBox {

		private var _label:String;
		private var _listHeightMax:int;
		private var _keyHistory:Array;
		private var _lastKeyTime:int;
		private var _prevHolder:DisplayObjectContainer;
		private var _prevPos:Point;
		private var _displayItemLabelOnSelect:Boolean;
		private var _listWidth:int;
		private var _labelRenderer:Function;
		private var _closeTimeout : uint;
		private var _selectableItems:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeCombobox</code>.
		 */
		public function ComboboxKube(label:String, openToTop:Boolean = false, displayItemLabelOnSelect:Boolean = false, selectableItems:Boolean = true) {
			_displayItemLabelOnSelect = displayItemLabelOnSelect;
			_selectableItems = selectableItems;
			_label = label;
			super(new ButtonKube(label, openToTop ? new ComboboxIconUpGraphic() : new ComboboxIconGraphic()), new ScrollbarKube(), null, new ComboboxBackgroundGraphic(), openToTop);
			_list.filters = [new DropShadowFilter(2,90,0,.2,0,2,1,3)];
			ButtonKube(_button).textAlign = TextAlign.LEFT;
			ButtonKube(_button).iconAlign = IconAlign.RIGHT;
			ButtonKube(_button).iconSpacing = 10;
			autoSize = false;
			autosizeItems = true;
			_keyHistory = [];
			_lastKeyTime = 0;
			_listHeightMax = 300;
			_listWidth = -1;
			_labelRenderer = renderLabel;
			
			addEventListener(MouseEvent.ROLL_OUT, rolloutHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets if multiple items can be selected
		 */
		public function set allowMultipleSelection(value:Boolean):void {
			list.scrollableList.group.allowNoSelection = value;
			list.scrollableList.allowMultipleSelection = value;
			list.scrollableList.selectedDatas = [];
			list.scrollableList.selectedIndexes = [];
			ButtonKube(button).label = _label + " (0)";
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set listHeight(value:int):void {
			super.listHeight = value;
			_listHeightMax = value;
		}
		
		public function set listWidth(value:int):void {
			_listWidth = value;
			list.width = value;
		}
		
		public function set selectedDatas(value:Array):void {
			list.scrollableList.selectedDatas = value;
			_labelRenderer();
		}
		
		override public function set selectedIndex(value:int):void {
			super.selectedIndex = value;
			_labelRenderer();
		}
		
		override public function set enabled(value:Boolean):void {
			ButtonKube(_button).enabled = value;
		}

		public function set labelRenderer(value:Function):void {
			_labelRenderer = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds a pre-skinned item
		 */
		public function addSkinnedItem(label:String, data:*):void {
			addItem(new ComboboxItem(label, _selectableItems), data);
		}
		
		/**
		 * Opens the list.
		 */
		override public function open():void {
			listHeight = Math.min(_list.scrollableList.heightMax, _listHeightMax);
			super.open();
			_button.filters = [new DropShadowFilter(2, openToTop ? 270 : 90, 0, .2, 0, 2, 1, 3)];
			_prevHolder = parent;
			_prevPos = new Point(x, y);
			var pos:Point = localToGlobal(new Point());
			stage.addChild(this);
			x = pos.x;
			y = pos.y;
			if(_listWidth != -1) {
				var i:int, len:int;
				len = list.scrollableList.items.length;
				for(i = 0; i < len; ++i) {
					DisplayObject(list.scrollableList.items[i]).width = _listWidth;
				}
				list.width = _listWidth;
			}
			clearTimeout(_closeTimeout);
		}
		
		/**
		 * Closes the list.
		 */
		override public function close():void {
			super.close();
			clearTimeout(_closeTimeout);
			_closeTimeout = setTimeout(onCloseComplete, 250);
			if(_listWidth != -1){
				var i:int, len:int;
				len = list.scrollableList.items.length;
				for(i = 0; i < len; ++i) {
					DisplayObject(list.scrollableList.items[i]).width = _listWidth;
				}
				list.width = _listWidth;
			}
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * @inheritDoc
		 */
		override protected function addedToStageHandler(e:Event):void {
			super.addedToStageHandler(e);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownStageHandler, true, 0xff);
		}

		private function rolloutHandler(event:MouseEvent):void {
			event.stopPropagation();
		}
		
		/**
		 * Called when key is released over the stage.
		 * Closes the combobox and stops the event's propagation.
		 */
		private function keyDownStageHandler(event:KeyboardEvent):void {
			if(_opened) {
				if(getTimer() - _lastKeyTime > 500) _keyHistory = [];
				_keyHistory.push(String.fromCharCode(event.charCode));
				var ref:String = _keyHistory.join("").toLowerCase();
				_lastKeyTime = getTimer();
				
				//Search for an item that starts with the typed keys.
				var i:int, len:int, items:Array;
				items = list.scrollableList.items;
				len = items.length;
				var itemFound:Boolean = false;
				for(i = 0; i < len; ++i) {
					ComboboxItem(items[i]).rollOut();
					if(!itemFound && ComboboxItem(items[i]).label.toLowerCase().replace(/\s/g, " ").indexOf(ref) == 0) {
						list.scrollableList.scrollToItem(items[i]);
						ComboboxItem(items[i]).rollOver();
						itemFound = true;
					}
				}
				
//				if(!itemFound) {
//					trace(ref)
					event.stopPropagation();
					event.stopImmediatePropagation();
//				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function keyUpHandler(event:KeyboardEvent):void {
			super.keyUpHandler(event);
			if(event.keyCode == Keyboard.ESCAPE && _opened) {
				close();
				event.stopPropagation();
				event.stopImmediatePropagation();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function selectItemHandler(e:ListEvent):void {
			super.selectItemHandler(e);
			_labelRenderer();
		}
		
		/**
		 * Method called to render the combobox label
		 */
		private function renderLabel():void {
			if(_displayItemLabelOnSelect) {
				ButtonKube(button).label = ComboboxItem(list.scrollableList.getItemAt(list.scrollableList.selectedIndex)).label;
			}else if(_selectableItems){
				ButtonKube(button).label = _label + " ("+list.scrollableList.selectedIndexes.length+")";
			}
		}
		
		/**
		 * Called when close animation completes
		 */
		private function onCloseComplete():void {
			_button.filters = [];
			if(_prevHolder != null) {
				_prevHolder.addChild(this);
				x = _prevPos.x;
				y = _prevPos.y;
			}
		}
		
	}
}