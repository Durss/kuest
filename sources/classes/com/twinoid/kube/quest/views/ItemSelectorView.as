package com.twinoid.kube.quest.views {
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.utils.Closable;
	import com.nurun.utils.pos.PosUtils;
	import gs.TweenLite;

	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.form.ScrollbarKube;
	import com.twinoid.kube.quest.components.selector.SelectorItem;
	import com.twinoid.kube.quest.components.window.PromptWindow;
	import com.twinoid.kube.quest.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.vo.ObjectItemData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class ItemSelectorView extends AbstractView implements Closable {
		
		private var _window:PromptWindow;
		private var _disableLayer:Sprite;
		private var _callback:Function;
		private var _scrollpane:ScrollPane;
		private var _charsList:Vector.<CharItemData>;
		private var _objectList:Vector.<ObjectItemData>;
		private var _engine:TileEngine2DSwipeWrapper;
		private var _closed:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ItemSelectorView</code>.
		 */
		public function ItemSelectorView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			_charsList = model.characters;
			_objectList = model.objects;
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			_closed = true;
			TweenLite.to(this, .25, {autoAlpha:0});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible = false;
			_disableLayer = addChild(new Sprite()) as Sprite;
			_engine = new TileEngine2DSwipeWrapper(SelectorItem, (SelectorItem.WIDTH+5) * 5, SelectorItem.HEIGHT * 5, SelectorItem.WIDTH, SelectorItem.HEIGHT);
			_scrollpane = new ScrollPane(_engine, new ScrollbarKube());
			_window = addChild(new PromptWindow("", _scrollpane)) as PromptWindow;
			
			_engine.lockX = true;
			_engine.lockToLimits = true;
			makeEscapeClosable(this, 1);
			
			ViewLocator.getInstance().addEventListener(ItemSelectorEvent.SELECT_ITEM, openSelectorHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler, true, 2);
		}
		
		/**
		 * Called when something's clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _disableLayer) close();
			event.stopPropagation();
		}
		
		/**
		 * Called when a view fires an ItemSelectorEvent
		 */
		private function openSelectorHandler(event:ItemSelectorEvent):void {
			visible = true;
			_closed = false;
			_callback = event.callback;
			_window.label = Label.getLabel("selector-"+event.itemType);
			//Event if the item's vector are IITemData, flash doesn't accept
			//a vector of item in place of a vector of IITemData.
			//So i convert the vector to an array, so that it doesn't break by balls
			//event if it's stupid...
			switch(event.itemType){
				case ItemSelectorEvent.ITEM_TYPE_CHAR:
					populate( VectorUtils.toArray(_charsList) );
					break;
				case ItemSelectorEvent.ITEM_TYPE_OBJECT:
					populate( VectorUtils.toArray(_objectList) );
					break;
				default:
			}
			alpha = 1;
			visible = true;
			TweenLite.from(this, .25, {autoAlpha:0});
		}
		
		/**
		 * Populates the list.
		 */
		private function populate(list:Array):void {
			var i:int, len:int, data:IItemData, line:Array;
			len = list.length;
			var cols:int = _engine.hVisibleItems;
			for(i = 0; i < len; ++i) {
				if(i%cols == 0) {
					if(i > 0) _engine.addLine(line);
					line = [];
				}
				data = list[i] as IItemData;
				line.push(data);
			}
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_disableLayer.graphics.beginFill(0, .35);
			_disableLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disableLayer.graphics.endFill();
			
			_window.width = _engine.visibleWidth + 60;
			PosUtils.centerInStage(_window);
		}
	}
}