package com.twinoid.kube.quest.editor.components.menu {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.menu.char.CharItem;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.vo.CharItemData;
	import com.twinoid.kube.quest.graphics.AddBigIcon;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	
	/**
	 * Displays the characters creator.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuCharsContent extends AbstractMenuContent {
		
		private var _items:Vector.<CharItem>;
		private var _addItem:GraphicButtonKube;
		private var _dataToItem:Dictionary;
		private var _label:CssTextField;
		private var _itemsHolder:Sprite;
		
		
		
		
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
		/**
		 * Called on model's update
		 */
		override public function update(model:Model):void {
			if(model.charactersUpdate) {
				refreshList(model.characters);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize(event:Event):void {
			super.initialize(event);
			
			_label		= _holder.addChild(new CssTextField("menu-label")) as CssTextField;
			_itemsHolder= _holder.addChild(new Sprite()) as Sprite;
			_addItem	= _itemsHolder.addChild(new GraphicButtonKube(new AddBigIcon())) as GraphicButtonKube;
			_items		= new Vector.<CharItem>();
			_dataToItem	= new Dictionary();
			
			_title.text = Label.getLabel("menu-chars");
			_label.text = Label.getLabel("menu-chars-details");
			var ref:CharItem = new CharItem();
			_addItem.width = ref.width;
			_addItem.height = ref.height;
			ref.dispose();
			
			_addItem.addEventListener(MouseEvent.CLICK, clickAddHandler);
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			_label.width = _width - 15;
			var items:Array = VectorUtils.toArray(_items);
			items.push(_addItem);
			PosUtils.hDistribute(items, _width - 15, 5, 15);
			
			_itemsHolder.y = Math.round(_label.height) + 15;
			
			super.computePositions(event);
		}
		
		/**
		 * Creates the default faces
		 */
		private function refreshList(data:Vector.<CharItemData>):void {
			//Destroy dead items
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				if (_items[i].data.isKilled()) {
					_items[i].dispose();
					_items[i].removeEventListener(Event.CLOSE, deleteItemHandler);
					_itemsHolder.removeChild(_items[i]);
					_items.splice(i, 1);
					i --;
					len --;
				}
			}
			
			//Create new items
			len = data.length;
			for(i = 0; i < len; ++i) {
				if(_dataToItem[ data[i] ] == undefined) {
					addItem(data[i]);
				}
			}
			computePositions();
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function addItem(data:CharItemData = null):CharItem {
			var item:CharItem = new CharItem(data);
			item.addEventListener(Event.CLOSE, deleteItemHandler);
			_itemsHolder.addChild(item);
			_items.push( item );
			_dataToItem[data] = item;
			return item;
		}
		
		/**
		 * Called when an item is delete
		 */
		private function deleteItemHandler(event:Event):void {
			var data:CharItemData = CharItem(event.currentTarget).data;
			_dataToItem[data] = null;
			delete _dataToItem[data];
			FrontControler.getInstance().deleteCharacter(data);
		}
		
		/**
		 * Adds an item to the list.
		 */
		private function clickAddHandler(event:MouseEvent):void {
			FrontControler.getInstance().addCharacter();
		}
		
	}
}