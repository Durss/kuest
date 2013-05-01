package com.twinoid.kube.quest.components.menu {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.components.menu.char.CharItem;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.graphics.AddBigIcon;
	import com.twinoid.kube.quest.vo.CharItemData;

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Displays the characters creator.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuCharsContent extends AbstractMenuContent {
		
		[Embed(source="../../../../../../../assets/spritesheet_chars.jpg")]
		private var _sheetBmp:Class;
		
		private var _items:Vector.<CharItem>;
		private var _addItem:GraphicButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuCharsContent</code>.
		 */
		public function MenuCharsContent(width:int) {
			super(width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize(event:Event):void {
			super.initialize(event);
			
			_addItem = _holder.addChild(new GraphicButtonKube(new AddBigIcon())) as GraphicButtonKube;
			_items = new Vector.<CharItem>();
			
			createDefaultFaces();
			_label.text = Label.getLabel("menu-chars");
			_addItem.width = _items[0].width;
			_addItem.height = _items[0].height;
			
			_addItem.addEventListener(MouseEvent.CLICK, clickAddHandler);
			computePositions();
		}
		
		/**
		 * Creates the default faces
		 */
		private function createDefaultFaces():void {
			var names:Array = ["Florence", "Carole", "Louis", "Richard", "Rahema", "Le pêcheur", "Vincent", "Florent", "Arthur", "Win", "Adana", "Marion", "Marya"];//TODO localise
			var bmp:Bitmap = new _sheetBmp() as Bitmap;
			var src:BitmapData = bmp.bitmapData;
			var i:int, len:int, bmd:BitmapData, rect:Rectangle, pt:Point;
			len = names.length;
			rect = new Rectangle(0, 0, 100, 100);
			pt = new Point();
			for(i = 0; i < len; ++i) {
				rect.x = i * 100;
				bmd = new BitmapData(100, 100, true, 0);
				bmd.copyPixels(src, rect, pt);
				bmd.lock();
				var item:CharItem = addItem();
				item.image = bmd;
				item.name = names[i];
			}
			refreshObjectListOnModel();
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function addItem():CharItem {
			var item:CharItem = new CharItem();
			item.addEventListener(Event.CLOSE, deleteItemHandler);
			item.addEventListener(FormComponentEvent.SUBMIT, submitItemHandler);
			item.addEventListener(Event.CHANGE, submitItemHandler);
			_holder.addChild(item);
			_items.push( item );
			return item;
		}
		
		/**
		 * Called when an item's value changes and is valid.
		 */
		private function submitItemHandler(event:Event):void {
			refreshObjectListOnModel();
		}
		
		/**
		 * Called when an item is delete
		 */
		private function deleteItemHandler(event:Event):void {
			var item:CharItem = event.currentTarget as CharItem;
			item.dispose();
			item.removeEventListener(Event.CLOSE, deleteItemHandler);
			item.removeEventListener(Event.CHANGE, submitItemHandler);
			_holder.removeChild(item);
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				if(_items[i] == item) {
					_items.splice(i, 1);
					i--;
					len --;
				}
			}
			computePositions();
			refreshObjectListOnModel();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			var items:Array = VectorUtils.toArray(_items);
			items.push(_addItem);
			PosUtils.hDistribute(items, _width, 5, 20, true);
			
			super.computePositions(event);
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function clickAddHandler(event:MouseEvent):void {
			addItem();
			computePositions();
		}
		
		/**
		 * Sends the new items to the model.
		 */
		private function refreshObjectListOnModel():void {
			var i:int, len:int, res:Vector.<CharItemData>;
			res = new Vector.<CharItemData>();
			len = _items.length;
			for(i = 0; i < len; ++i) {
				if(_items[i].data.isValid()) {
					res.push(_items[i].data);
				}
			}
			
			FrontControler.getInstance().refreshCharsList(res);
		}
		
	}
}