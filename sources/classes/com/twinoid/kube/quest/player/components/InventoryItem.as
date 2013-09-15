package com.twinoid.kube.quest.player.components {
	import gs.TweenLite;

	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.ITileEngineItem2D;
	import com.nurun.components.tile.TileEngine2D;
	import com.nurun.core.lang.Disposable;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.player.vo.InventoryObject;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	
	/**
	 * Used for TileEngine2D !
	 * 
	 * @author Francois
	 * @date 25 mai 2013;
	 */
	public class InventoryItem extends Sprite implements ITileEngineItem2D {
		private var _image:ImageResizer;
		private var _label:CssTextField;
		private var _maxX:Number;
		private var _engineRef:TileEngine2D;
		private var _data:InventoryObject;
		private var _frame:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>InventoryItem</code>.
		 */
		public function InventoryItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set x(value:Number):void {
			super.x = value;
			if(_engineRef != null) {
				visible = value - _engineRef.scrollX < _maxX && _maxX > 0;
			}
		}

		public function get data():InventoryObject {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(data:*, engineRef:TileEngine2D):void {
			_engineRef = engineRef;
			_maxX = (engineRef.itemWidth + engineRef.hMargin) * engineRef.numCols;
			x = x;//Refresh visible state
			if(!visible) return;
			
			if(_data != null) {
				_data.vo.image.removeEventListener(Event.CHANGE, imageUpdateHandler);
			}
			
			_data = data as InventoryObject;
			
			if(_data == null) {
				visible = false;
				return;
			}
			//Images are loaded asynchronously at the quest init, wait for it just in case
			_data.vo.image.addEventListener(Event.CHANGE, imageUpdateHandler);
			
			_label.text		= "x"+_data.total;
			_label.y		= 100 - _label.height;
			_label.width	= 100;
			mouseEnabled	= _data.total > 0;
			
			if(_data.total == 0) {
				//Bug if the filter is set on the holder.. doesn't works without a second refresh :/
				_image.filters = [new ColorMatrixFilter([ .5,.5,.5,0,0, .5,.5,.5,0,0, .5,.5,.5,0,0, .5,.5,.5,.5,0 ])];
			}else{
				_image.filters = [];
			}
			
			imageUpdateHandler();
			
//			graphics.clear();
//			var margin:int = 5;
//			graphics.beginFill(0x266884, 1);
//			graphics.drawRect(0, 0, _image.width + margin * 2 + 1, _label.y + _label.height + margin * 2 - 1);
//			graphics.endFill();
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			_data = null;
			_engineRef = null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible = false;
			
			_image = addChild(new ImageResizer(null, true, false, 100, 100)) as ImageResizer;
			_label = addChild(new CssTextField("kuest-objectCount")) as CssTextField;
			_frame = addChild(new Shape()) as Shape;
			
			_image.defaultTweenEnabled = false;
			_label.filters = [new DropShadowFilter(0,0,0,1,2,2,10,2)];
			
			var size:int = 5;
			_frame.alpha = 0;
			_frame.graphics.clear();
			_frame.graphics.beginFill(0x55b7ff, 1);
			_frame.graphics.drawRect(0, 0, 100, size);
			_frame.graphics.drawRect(100 - size, size, size, 100 - size);
			_frame.graphics.drawRect(0, 100 - size, 100 - size, size);
			_frame.graphics.drawRect(0, size, size, 100 - size * 2);
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, rollOverHandler);
		}

		private function mouseDownHandler(event:MouseEvent):void {
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:.5}});
		}

		private function rollOverHandler(event:MouseEvent):void {
			TweenLite.to(_frame, .25, {autoAlpha:1});
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:1.25}});
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _data.vo.name, ToolTipAlign.TOP));
		}

		private function rollOutHandler(event:MouseEvent):void {
			TweenLite.to(_frame, .25, {autoAlpha:0});
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:1, remove:true}});
		}

		private function imageUpdateHandler(event:Event = null):void {
			_image.clear();
			_image.setBitmapData(_data.vo.image.getConcreteBitmapData());
		}
		
	}
}