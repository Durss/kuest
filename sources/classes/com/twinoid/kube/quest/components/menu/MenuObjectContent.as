package com.twinoid.kube.quest.components.menu {
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.components.menu.obj.ObjectItem;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.graphics.AddBigIcon;
	import com.twinoid.kube.quest.vo.ObjectItemData;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuObjectContent extends AbstractMenuContent {
		
		[Embed(source="../../../../../../../assets/spritesheet_objs.png")]
		private var _sheetBmp:Class;
		
		private var _addItem:GraphicButtonKube;
		private var _items:Vector.<ObjectItem>;
		
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuObjectContent</code>.
		 */
		public function MenuObjectContent(width:int) {
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
			_items = new Vector.<ObjectItem>();
			
			createDefaultObjects();
			_label.text = Label.getLabel("menu-objects");
			_addItem.width = _items[0].width;
			_addItem.height = _items[0].height;
			
			_addItem.addEventListener(MouseEvent.CLICK, clickAddHandler);
			computePositions();
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
		 * Creates the default faces
		 */
		private function createDefaultObjects():void {
			var names:Array = ["Cerpe", "Arrosoir", "Canne à pèche", "Coffre", "Binette", "Graines", "Clef", "Bijou", "Argent"];
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
				var item:ObjectItem = addItem();
				item.image = bmd;
				item.name = names[i];
			}
			refreshObjectListOnModel();
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function addItem():ObjectItem {
			var item:ObjectItem = new ObjectItem();
			item.addEventListener(Event.CLOSE, deleteItemHandler);
			item.addEventListener(FormComponentEvent.SUBMIT, submitItemHandler);
			_holder.addChild(item);
			_items.push( item );
			return item;
		}
		
		/**
		 * Called when an item's value changes and is valid.
		 */
		private function submitItemHandler(event:FormComponentEvent):void {
			refreshObjectListOnModel();
		}
		
		/**
		 * Called when an item is delete
		 */
		private function deleteItemHandler(event:Event):void {
			var item:ObjectItem = event.currentTarget as ObjectItem;
			item.dispose();
			item.removeEventListener(Event.CLOSE, deleteItemHandler);
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
			var i:int, len:int, res:Vector.<ObjectItemData>;
			res = new Vector.<ObjectItemData>();
			len = _items.length;
			for(i = 0; i < len; ++i) {
				if(_items[i].data.isValid) {
					res.push(_items[i].data);
				}
			}
			
			FrontControler.getInstance().refreshObjectsList(res);
		}
		
	}
}