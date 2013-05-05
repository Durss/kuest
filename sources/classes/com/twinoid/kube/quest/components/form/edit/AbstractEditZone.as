package com.twinoid.kube.quest.components.form.edit {
	import flash.utils.setTimeout;
	import flash.events.MouseEvent;
	import com.nurun.components.button.GraphicButton;
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

		protected var _buttons:Vector.<ToggleButtonKube>;
		protected var _contents:Vector.<Sprite>;
		protected var _group:FormComponentGroup;
		
		private var _title:CssTextField;
		private var _titleStr:String;
		private var _contentsHolder:Sprite;
		private var _buttonsHolder:Sprite;
		private var _contentsMask:Shape;
		private var _width:int;
		private var _itemToIndex:Dictionary;
		private var _openCloseBt:GraphicButton;
		private var _closed:Boolean;
		private var _currentContent:Sprite;

		
		
		
		
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
		
		/**
		 * Gets the currently selected button index
		 */
		public function get selectedIndex():Number { return _itemToIndex[ _group.selectedItem ]; }
		
		/**
		 * Sets the currently selected button index
		 */
		public function set selectedIndex(value:Number):void { 
			var i:int, len:int;
			len = _buttons.length;
			for(i = 0; i < len; ++i) {
				if(i == value) {
					_buttons[i].select();
					_group.selectedItem = _buttons[i];
				}
				else _buttons[i].unSelect();
			}
			changeSelectionHandler();
		}



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
			}else{
				//This addchild followed by a removechild simply provides a
				//way to force the rendering of the contents before they are
				//displayed. This prevent from lags for complex contents when
				//they are displayed the first time. Like the calendar.
				addChild(content);
				setTimeout(removeChild, 0, content);//Wait one frame to be sure rendering is done.
			}
			
			_buttons[0].x = _width - bt.width * _buttons.length;
			PosUtils.hPlaceNext(0, VectorUtils.toArray(_buttons) );
			
			len = _contents.length;
			for(i = 0; i < len; ++i) {
				Sprite(_contents[i]).x = i * _width;
			}
			
			if(_currentContent == null) _currentContent = content;
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
			
			_title = addChild(new CssTextField("editWindow-zoneTitle")) as CssTextField;
			_openCloseBt = addChild(new GraphicButton(createRect())) as GraphicButton;
			_contentsHolder = addChild(new Sprite()) as Sprite;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			_contentsMask = addChild(createRect(0xffff0000, _width, 100)) as Shape;
			
			_closed = true;
			_title.text = _titleStr;
			_title.background = true;
			_title.backgroundColor = 0x8BC9E2;
			_openCloseBt.buttonMode = true;
			
			_contentsMask.height = 0;
			_contentsHolder.mask = _contentsMask;
			
			_openCloseBt.addEventListener(MouseEvent.CLICK, openCloseHandler);
			_buttonsHolder.addEventListener(MouseEvent.CLICK, changeSelectionHandler);
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		protected function computePositions():void {
			_title.width = _width;
			_contentsHolder.y = _contentsMask.y = Math.round(_title.height) + 5;
			
			_openCloseBt.width = _width;
			_openCloseBt.height = _title.height;
		}
		
		/**
		 * Toggles the open state of the tab.
		 */
		private function openCloseHandler(event:MouseEvent):void {
			_closed = !_closed;
			var e:Event = new Event(Event.RESIZE, true);
			TweenLite.killTweensOf(_contentsMask);
			TweenLite.to(_contentsMask, .25, {height:_closed? 0 : _currentContent.height, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * Called when a new item is selected
		 */
		protected function changeSelectionHandler(event:Event = null):void {
			var index:int = selectedIndex;
//			_currentContent.cacheAsBitmap = true;
			_currentContent = _contents[index];
			_contentsHolder.addChild(_contents[index]);
			var e:Event = new Event(Event.RESIZE, true);
			var endX:int = -index * _width + Math.round((_width - _currentContent.width) * .5);
			
			TweenLite.killTweensOf(_contentsMask);
			TweenLite.killTweensOf(_contentsHolder);
			
			if(event != null) {
				_closed = false;
				TweenLite.to(_contentsMask, .25, {height:_contents[index].height, onUpdate:dispatchEvent, onUpdateParams:[e]});
				TweenLite.to(_contentsHolder, .25, {x:endX, onComplete:removeInvisibleItems, onCompleteParams:[index]});
			}else{
				//No transition if not called from a user input.
				if(!_closed) {
					_contentsMask.height = _contents[index].height;
					dispatchEvent(e);
				}
				_contentsHolder.x = endX;
				removeInvisibleItems(index);
			}
		}
		
		/**
		 * Removes the invisible items from the stage to prevent from
		 * incoherent focus on TAB navigation.
		 * Without that the invisible forms would be navigable through the TAB key.
		 */
		private function removeInvisibleItems(indexToKeep:int):void {
			for(var i:int = 0; i < _contents.length; ++i) {
				if(i != indexToKeep && _contentsHolder.contains(_contents[i])) _contentsHolder.removeChild(_contents[i]);
			}
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
	}
}