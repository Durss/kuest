package com.twinoid.kube.quest.components.selector {
	import com.nurun.utils.text.CssManager;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.ITileEngineItem2D;
	import com.nurun.components.tile.TileEngine2D;
	import com.nurun.core.lang.Disposable;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.vo.EmptyItemData;
	import com.twinoid.kube.quest.vo.IItemData;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class SelectorItem extends Sprite implements ITileEngineItem2D {
		
		public static const WIDTH:int = 105;
		public static const HEIGHT:int = 125;
		private var _image:ItemPlaceholder;
		private var _label:CssTextField;
		private var _data:IItemData;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SelectorItem</code>.
		 */
		public function SelectorItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the object's data.
		 */
		public function get data():IItemData { return _data; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component.
		 */
		public function populate(data:*, engineRef:TileEngine2D):void {
			_data = data as IItemData;
			if (data is EmptyItemData) {
				_image.image = null;
				_label.text = "";
				visible = false;
				buttonMode = false;
				return;
			}
			_image.image = _data.image;
			_label.text = _data.name;
			_label.y = WIDTH;
			_label.width = WIDTH;
			var size:int = CssManager.getInstance().getTextFormatOf(_label.style).size as int;
			while(_label.numLines > 1) {
				_label.text = "<font size='"+(--size)+"'>"+_data.name+"</font>";
			}
			visible = true;
			buttonMode = true;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_image = addChild(new ItemPlaceholder()) as ItemPlaceholder;
			_label = addChild(new CssTextField("item-label")) as CssTextField;
			
			_image.x = _image.y = 5;
			
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		}

		private function rollOverHandler(event:MouseEvent):void {
			if(_data is EmptyItemData || _data == null) return;
			
			var margin:int = 5;
			graphics.beginFill(0x266884, 1);
			graphics.drawRect(0, 0, _image.width + margin * 2 + 1, _label.y + _label.height + margin * 2);
			graphics.endFill();
		}

		private function rollOutHandler(event:MouseEvent):void {
			graphics.clear();
		}
		
	}
}