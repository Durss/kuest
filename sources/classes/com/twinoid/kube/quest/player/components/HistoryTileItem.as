package com.twinoid.kube.quest.player.components {
	import com.nurun.structure.environnement.label.Label;
	import gs.TweenLite;

	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.tile.ITileEngineItem2D;
	import com.nurun.components.tile.TileEngine2D;
	import com.nurun.core.lang.Disposable;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.FavoriteIcon;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	/**
	 * Used for TileEngine2D !
	 * 
	 * @author Francois
	 * @date 25 mai 2013;
	 */
	public class HistoryTileItem extends Sprite implements ITileEngineItem2D {
		protected var _image:ImageResizer;
		protected var _label:CssTextField;
		protected var _maxX:Number;
		protected var _engineRef:TileEngine2D;
		protected var _data:KuestEvent;
		protected var _frame:Shape;
		protected var _favBt:GraphicButtonKube;
		private var _holder:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>HistoryTileItem</code>.
		 */
		public function HistoryTileItem() {
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

		public function get data():KuestEvent {
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
			
			if(_data != null && _data.actionType.getItem() != null && _data.actionType.getItem().image != null) {
				_data.actionType.getItem().image.removeEventListener(Event.CHANGE, imageUpdateHandler);
			}
			
			_data = data as KuestEvent;
			
			if(_data == null) {
				visible = false;
				return;
			}
			//Images are loaded asynchronously at the quest init, wait for it just in case
			if(_data.actionType.getItem() != null && _data.actionType.getItem().image != null) {
				_data.actionType.getItem().image.addEventListener(Event.CHANGE, imageUpdateHandler, false, 0, true);
			}
			
			_label.text		= _data.actionPlace.getAsLabel();
			_label.y		= _engineRef.itemHeight - _label.height;
			_label.width	= _engineRef.itemWidth;
			
			imageUpdateHandler();
			
			_image.width = _engineRef.itemWidth;
			_image.height = _engineRef.itemHeight;
			_image.validate();
			
			_favBt.width = _engineRef.itemWidth;
			_favBt.y = _engineRef.itemHeight - _favBt.height;
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
		protected function initialize():void {
			visible = false;
			
			_holder		= addChild(new Sprite()) as Sprite;
			_image		= _holder.addChild(new ImageResizer(null, true, false, 50, 50)) as ImageResizer;
			_label		= _holder.addChild(new CssTextField("kuest-historyItemLabel")) as CssTextField;
			_frame		= _holder.addChild(new Shape()) as Shape;
			_favBt		= addChild(new GraphicButtonKube(new FavoriteIcon())) as GraphicButtonKube;
			
			_image.defaultTweenEnabled = false;
			_label.filters = [new DropShadowFilter(0,0,0,1,1.25,1.25,100,2)];
			_image.filters = [new DropShadowFilter(0,0,0x265367,1,1.1,1.1,100,1,true)];
			
			_frame.alpha = 0;
			
			_holder.buttonMode = true;
			_holder.mouseChildren = false;
			
			_favBt.visible = false;
			
			_holder.graphics.beginFill(0xff0000, 0);
			_holder.graphics.drawRect(0, 0, 50, 50);
			_holder.graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			_holder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_holder.addEventListener(MouseEvent.MOUSE_UP, rollOverHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when the component is clicked.
		 */
		protected function clickHandler(event:MouseEvent):void {
			if (event.target == _favBt) {
				DataManager.getInstance().addToFavorites(_data);
			}else{
				DataManager.getInstance().simulateEvent(_data);
			}
		}
		
		/**
		 * Called when the mouse is pressed
		 */
		protected function mouseDownHandler(event:MouseEvent):void {
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:.5}});
		}

		/**
		 * Called when the component is rolled over
		 */
		protected function rollOverHandler(event:MouseEvent):void {
			if(event.target == _holder) {
				var size:int = 5;
				_frame.graphics.clear();
				_frame.graphics.beginFill(0x55b7ff, 1);
				_frame.graphics.drawRect(0, 0, _engineRef.itemWidth, size);
				_frame.graphics.drawRect(_engineRef.itemWidth - size, size, size, _engineRef.itemHeight - size);
				_frame.graphics.drawRect(0, _engineRef.itemHeight - size, _engineRef.itemWidth - size, size);
				_frame.graphics.drawRect(0, size, size, _engineRef.itemWidth - size * 2);
				
				TweenLite.to(_frame, .25, {autoAlpha:1});
				TweenLite.to(this, .25, {colorMatrixFilter:{brightness:1.25}});
				if(_data.actionType.getItem() != null) {
					dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _data.actionType.getItem().name, ToolTipAlign.TOP));
				}
			}else{
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel('player-historyFavTT'), ToolTipAlign.TOP));
			}
			_favBt.visible = true;
		}
		
		/**
		 * Called when the component is rolled out
		 */
		protected function rollOutHandler(event:MouseEvent):void {
			_favBt.visible = false;
			TweenLite.to(_frame, .25, {autoAlpha:0});
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:1, remove:true}});
		}
		
		/**
		 * Called when the image is updated
		 */
		protected function imageUpdateHandler(event:Event = null):void {
			_image.clear();
			if(_data.actionType.getItem() != null && _data.actionType.getItem().image != null) {
				_image.setBitmapData(_data.actionType.getItem().image.getConcreteBitmapData());
			}
		}
		
	}
}