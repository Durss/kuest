package com.twinoid.kube.quest.editor.components.item {
	import flash.display.CapsStyle;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.commands.BrowseForFileCmd;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.editor.vo.EmptyItemData;
	import com.twinoid.kube.quest.editor.vo.IItemData;
	import com.twinoid.kube.quest.graphics.AddBigIcon;
	import com.twinoid.kube.quest.graphics.BrowseIcon;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;

	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Displays an item's image.
	 * If in browseMode, provides a way to select an image file on the
	 * user's hard drive by clicking on the component.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class ItemPlaceholder extends Sprite implements Disposable {
		
		private const WIDTH:int = 100;
		private const HEIGHT:int = 100;
		
		private var _browseMode:Boolean;
		private var _selectMode:Boolean;
		private var _frame:Shape;
		private var _img:ImageResizer;
		private var _icon:DisplayObject;
		private var _browseCmd:BrowseForFileCmd;
		private var _selectType:String;
		private var _data:IItemData;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ItemPlaceholder</code>.
		 */

		public function ItemPlaceholder(browseMode:Boolean = false, selectMode:Boolean = false, selectType:String = ItemSelectorEvent.ITEM_TYPE_CHAR) {
			_selectType = selectType;
			_selectMode = selectMode;
			_browseMode = browseMode;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if an image has been defined or not
		 */
		public function get isDefined():Boolean {
			return _img.image != null;
		}
		
		/**
		 * Gets the image's reference.
		 */
		public function get image():BitmapData {
			var bmd:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);
			bmd.draw(_img);
			bmd.lock();
			return bmd;
		}
		
		/**
		 * Sets the image.
		 */
		public function set image(value:BitmapData):void {
			if (value == null) {
				_img.visible = false;
				return;
			}
			_img.clear();
			_img.visible = true;
			_img.setBitmapData(value);
			if(_icon != null && contains(_icon)) removeChild(_icon); 
		}
		
		/**
		 * Gets the selected data.
		 */
		public function get data():IItemData { return _data; }
		
		/**
		 * Sets the selected data.
		 */
		public function set data(value:IItemData):void {
			selectCallback(value);
		}
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _img.width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _img.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_frame.graphics.clear();
			if(_browseMode) {
				_browseCmd.removeEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
				_icon.filters = [];
				removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_frame = addChild(new Shape()) as Shape;
			_frame.graphics.lineStyle(0, 0x2D89B0, 1, false, "normal", CapsStyle.NONE);
			_frame.graphics.beginFill(0x7EC3DF, 1);
			_frame.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			_frame.graphics.endFill();
			
			if(_browseMode) {
				_browseCmd = new BrowseForFileCmd("Image", "*.jpg;*.jpeg;*.png", true);
				_browseCmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
				_icon = addChild(new BrowseIcon()) as BrowseIcon;
				_icon.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, clickHandler);
				computePositions();
			}
			
			if(_selectMode) {
				_icon = addChild(new AddBigIcon()) as AddBigIcon;
				MovieClip(_icon).stop();
				_icon.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, clickHandler);
				computePositions();
			}
			
			_img = addChild(new ImageResizer(null, true, true)) as ImageResizer;
			_img.width = WIDTH;
			_img.height = HEIGHT;
			_img.defaultTweenEnabled = false;
		}
		
		/**
		 * Called when the component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_selectMode){
				ViewLocator.getInstance().dispatchToViews(new ItemSelectorEvent(ItemSelectorEvent.SELECT_ITEM, _selectType, selectCallback));
			}else{
				_browseCmd.execute();
			}
		}
		
		/**
		 * Called when an image's loading completes
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			if(contains(_icon)) removeChild(_icon);
			_img.setBitmapData(event.data as BitmapData);
			_img.validate();
			var bmd:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0xff7EC3DF);
			bmd.draw(_img);
			bmd.lock();
			_img.setBitmapData(bmd);
			_img.validate();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Called when an item is selected inside the ItemSelectorView.
		 */
		private function selectCallback(data:IItemData):void {
			_data = data;
			if(data is EmptyItemData || data == null) {
				_img.clear();
				addChild(_icon);
			}else{
				if(data.image == null) {
					_img.clear();
				}else{
					_img.setBitmapData(data.image.getConcreteBitmapData());
				}
				if(_icon != null && contains(_icon)) removeChild(_icon);
			}
		}

		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.centerIn(_icon, _frame);
		}
		
	}
}