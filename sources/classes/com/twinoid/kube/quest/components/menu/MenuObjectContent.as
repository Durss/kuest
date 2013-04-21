package com.twinoid.kube.quest.components.menu {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.components.menu.obj.ObjectItem;
	import com.twinoid.kube.quest.graphics.AddBigIcon;

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuObjectContent extends AbstractMenuContent {
		
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
			addItem();
			_label.text = Label.getLabel("menu-objects");
			_addItem.width = _items[0].width;
			_addItem.height = _items[0].height;
			
			_addItem.addEventListener(MouseEvent.CLICK, clickAddHandler);
			computePositions();
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function addItem():void {
			var item:ObjectItem = new ObjectItem();
			item.addEventListener(Event.CLOSE, deleteItemHandler);
			_holder.addChild(item);
			_items.push( item );
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
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			super.computePositions(event);
			
			var items:Array = VectorUtils.toArray(_items);
			items.push(_addItem);
			PosUtils.hDistribute(items, _width, 5, 20, true);
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function clickAddHandler(event:MouseEvent):void {
			addItem();
			computePositions();
		}
		
	}
}