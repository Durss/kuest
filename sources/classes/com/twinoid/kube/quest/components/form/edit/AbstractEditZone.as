package com.twinoid.kube.quest.components.form.edit {
	import gs.TweenLite;

	import com.nurun.components.button.IconAlign;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.ToggleButtonKube;
	import com.twinoid.kube.quest.utils.setToolTip;
	import com.twinoid.kube.quest.vo.ToolTipAlign;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Makes it easier to build an edition category.
	 * Automatically builds the title, places the switch buttons and manage
	 * the transition between the difference contents.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class AbstractEditZone extends Sprite {

		private var _title:CssTextField;
		private var _titleStr:String;
		private var _buttons:Vector.<ToggleButtonKube>;
		private var _contents:Vector.<Sprite>;
		private var _contentsHolder:Sprite;
		private var _buttonsHolder:Sprite;
		private var _contentsMask:Shape;
		private var _width:int;
		private var _group:FormComponentGroup;
		private var _itemToIndex:Dictionary;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstracctEditZone</code>.
		 */

		public function AbstractEditZone(title:String, width:int) {
			_width = width;
			_titleStr = title;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function get width():Number { return _width; }
		override public function get height():Number { return _contentsMask.y + _contentsMask.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds an entry to the 
		 */
		public function addEntry(icon:DisplayObject, content:Sprite, tooltip:String):void {
			var bt:ToggleButtonKube = new ToggleButtonKube("", icon, icon);
			bt.contentMargin = new Margin(0, 0, 0, 0);
			bt.iconAlign = IconAlign.CENTER;
			bt.width = 22;
			bt.height = Math.round(_title.height);
			setToolTip(bt, tooltip, ToolTipAlign.TOP_RIGHT);
			
			_itemToIndex[bt] = _buttons.length;
			
			//Validate all the children to be sure to get the right size of the content
			var i:int, len:int;
			len = content.numChildren;
			for(i = 0; i < len; ++i) {
				if(content.getChildAt(i) is Validable) Validable(content.getChildAt(i)).validate();
			}
			
			_buttons.push(bt);
			_contents.push(content);
			_group.add(bt);
			
			_buttonsHolder.addChild(bt);
			if(_contents.length == 1) {
				_contentsHolder.addChild(content);
			}
			
			_buttons[0].x = _width - bt.width * _buttons.length;
			PosUtils.hPlaceNext(0, VectorUtils.toArray(_buttons) );
			
			len = _contents.length;
			for(i = 0; i < len; ++i) {
				Sprite(_contents[i]).x = i * _width;
			}
			
			_contentsMask.height = _contents[0].height;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize():void {
			_buttons = new Vector.<ToggleButtonKube>();
			_contents = new Vector.<Sprite>();
			_group = new FormComponentGroup();
			_itemToIndex = new Dictionary();
			
			_title = addChild(new CssTextField("promptWindowContentZoneTitle")) as CssTextField;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			_contentsHolder = addChild(new Sprite()) as Sprite;
			_contentsMask = addChild(createRect(0xffff0000, _width, 100)) as Shape;
			
			_title.text = _titleStr;
			_title.background = true;
			_title.backgroundColor = 0x8BC9E2;
			
			_contentsHolder.mask = _contentsMask;
			
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		protected function computePositions():void {
			_title.width = _width;
			_contentsHolder.y = _contentsMask.y = Math.round(_title.height) + 5;
		}
		
		/**
		 * Called when a new item is selected
		 */
		protected function changeSelectionHandler(event:FormComponentGroupEvent):void {
			//Add all the content back to the stage
			for(var i:int = 0; i < _contents.length; ++i) _contentsHolder.addChild(_contents[i]);
			
			var index:int = _itemToIndex[_group.selectedItem];
			_contents[index].mouseEnabled = _contents[index].mouseChildren = true;
			var e:Event = new Event(Event.RESIZE, true);
			
			TweenLite.killTweensOf(_contentsMask);
			TweenLite.killTweensOf(_contentsHolder);
			
			TweenLite.to(_contentsMask, .25, {height:_contents[index].height, onUpdate:dispatchEvent, onUpdateParams:[e]});
			TweenLite.to(_contentsHolder, .25, {x:-index * _width, onComplete:removeInvisibleItems, onCompleteParams:[index]});
		}
		
		/**
		 * Removes the invisible items from the stage to prevent from
		 * incoherent focus on TAB navigation.
		 * Without that the invisible forms would be navigable through the TAB key.
		 */
		private function removeInvisibleItems(indexToKeep:int):void {
			for(var i:int = 0; i < _contents.length; ++i) {
				if(i != indexToKeep) _contentsHolder.removeChild(_contents[i]);
			}
		}
		
	}
}