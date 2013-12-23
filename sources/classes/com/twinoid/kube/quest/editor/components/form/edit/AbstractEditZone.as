package com.twinoid.kube.quest.editor.components.form.edit {
	import gs.TweenLite;

	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ToggleButtonKube;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.ToggleSwitchGraphic;
	import com.twinoid.kube.quest.graphics.ToggleSwitchSelectedGraphic;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
		
		protected var _title:CssTextField;
		protected var _titleStr:String;
		protected var _contentsHolder:Sprite;
		protected var _buttonsHolder:Sprite;
		protected var _contentsMask:Shape;
		protected var _width:int;
		protected var _itemToIndex:Dictionary;
		protected var _openCloseBt:GraphicButton;
		protected var _closed:Boolean;
		protected var _currentContent:Sprite;
		protected var _toggle:ToggleButton;
		protected var _toggleAble:Boolean;
		private var _selectedIndex:Number;
		private var _loadingMode:Boolean;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstracctEditZone</code>.
		 */
		public function AbstractEditZone(title:String, width:int, toggleAble:Boolean) {
			_toggleAble = toggleAble;
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
			if(value == _selectedIndex) return;
			
			_selectedIndex = value;
			 
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
		
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			if(_toggleAble) _toggle.tabIndex = value++;
			var i:int, len:int;
			len = _buttons.length;
			for(i = 0; i < len; ++i) {
				_buttons[i].tabIndex = value++;
			}
		}
		
		/**
		 * Gets if the etry is enabled
		 */
		public function get enabled():Boolean {
			return _toggleAble? _toggle.selected : true;
		}
		
		/**
		 * Sets if the etry is enabled
		 */
		public function set enabled(value:Boolean):void {
			if(value == _toggle.selected) return;
			_toggle.selected = value;
			toggleHandler();
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
			
			_buttons.push(bt);
			_contents.push(content);
			_group.add(bt);
			
			_buttonsHolder.addChild(bt);
			_buttonsHolder.visible = _buttons.length > 1;
			
			_buttons[0].x = _width - bt.width * _buttons.length;
			PosUtils.hPlaceNext(0, VectorUtils.toArray(_buttons) );
			
			var i:int, len:int;
			len = _contents.length;
			for(i = 0; i < len; ++i) {
				Sprite(_contents[i]).x = i * _width;
			}
			
			if(_currentContent == null) _currentContent = content;
		}
		
		/**
		 * Opens the tab
		 */
		public function open():void { toggle(true); }
		
		/**
		 * Closes the tab
		 */
		public function close():void { toggle(false); }
		
		/**
		 * Toggles the tab opening
		 */
		public function toggle(open:Boolean):void {
			_closed = !open;
			if(!_closed) addChild(_contentsHolder);
			TweenLite.killTweensOf(_contentsMask);
			TweenLite.killTweensOf(_contentsHolder);
			var e:Event = new Event(Event.RESIZE, true);
			TweenLite.killTweensOf(_contentsMask);
			if(!_loadingMode) {
				TweenLite.to(_contentsMask, .25, {height:_closed? 0 : _currentContent.height, onUpdate:dispatchEvent, onUpdateParams:[e], onComplete:onOpenCloseComplete});
			}else{
				_contentsMask.height = _closed? 0 : _currentContent.height;
				dispatchEvent(e);
				onOpenCloseComplete();
			}
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize():void {
			_buttons		= new Vector.<ToggleButtonKube>();
			_contents		= new Vector.<Sprite>();
			_group			= new FormComponentGroup();
			_itemToIndex	= new Dictionary();
			
			_title			= addChild(new CssTextField("editWindow-zoneTitle")) as CssTextField;
			_openCloseBt	= addChild(new GraphicButton(createRect(0x00ff0000))) as GraphicButton;
			_buttonsHolder	= addChild(new Sprite()) as Sprite;
			_contentsMask	= addChild(createRect(0xffff0000, _width, 100)) as Shape;
			_contentsHolder	= new Sprite();
			if(_toggleAble) {
				_toggle		= addChild(new ToggleButton('', '', '', new ToggleSwitchGraphic(), new ToggleSwitchSelectedGraphic())) as ToggleButton;
				applyDefaultFrameVisitorNoTween(_toggle, _toggle.defaultBackground, _toggle.selectedBackground);
				_toggle.addEventListener(Event.CHANGE, toggleHandler);
				toggleHandler();
			}
			
			_closed					= true;
			_title.text				= _titleStr;
			_title.background		= true;
			_title.backgroundColor	= 0x8BC9E2;
			_openCloseBt.buttonMode	= true;
			
			_contentsMask.height = 0;
			_contentsHolder.mask = _contentsMask;
			
			_openCloseBt.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			_openCloseBt.addEventListener(MouseEvent.CLICK, openCloseHandler);
			_buttonsHolder.addEventListener(MouseEvent.CLICK, changeSelectionHandler);
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			
			computePositions();
		}
		
		/**
		 * Called when mouse wheel is used
		 */
		protected function wheelHandler(event:MouseEvent):void {
			if (_buttons.length > 1) {
				var index:Number = selectedIndex;
				index += event.delta > 0? -1 : 1;
				index = MathUtils.restrict(index, 0, _buttons.length - 1);
				_buttons[index].selected = true;
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		protected function computePositions():void {
			_title.width = _width;
			_contentsHolder.y = _contentsMask.y = Math.round(_title.height) + 5;
			if(_toggleAble) {
				_toggle.width = _toggle.height = _title.height;
				_title.width -= _toggle.width;
				_title.x = Math.round(_toggle.width);
			}
			
			_openCloseBt.width = _width;
			_openCloseBt.height = _title.height;
		}
		
		/**
		 * Toggles the open state of the tab.
		 */
		protected function openCloseHandler(event:MouseEvent):void {
			toggle(_closed);
		}
		
		/**
		 * Called when opening/closing completes
		 */
		protected function onOpenCloseComplete():void {
			if(_closed && contains(_contentsHolder)) removeChild(_contentsHolder);
		}
		
		/**
		 * Called when a new item is selected
		 */
		protected function changeSelectionHandler(event:Event = null):void {
//			if(_closed) return;
			
			var index:int = selectedIndex;
//			_currentContent.cacheAsBitmap = true;
			_currentContent = _contents[index];
			_contentsHolder.addChild(_currentContent);
			var e:Event = new Event(Event.RESIZE, true);
			var endX:int = -index * _width + Math.round((_width - _currentContent.width) * .5);
			
			if(event != null) {
				open();
				TweenLite.to(_contentsHolder, .25, {x:endX, onComplete:removeInvisibleItems, onCompleteParams:[index]});
			}else{
				//No transition if not called from a user input.
				if(!_closed) {
					_contentsMask.height = _currentContent.height;
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
		protected function removeInvisibleItems(indexToKeep:int):void {
			for(var i:int = 0; i < _contents.length; ++i) {
				if(i != indexToKeep && _contentsHolder.contains(_contents[i])) _contentsHolder.removeChild(_contents[i]);
			}
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Called when checkbox state changes
		 */
		protected function toggleHandler(event:Event = null):void {
			_openCloseBt.enabled = 
			_buttonsHolder.mouseEnabled =
			_buttonsHolder.tabChildren = 
			_buttonsHolder.tabEnabled = 
			_buttonsHolder.mouseChildren = _toggle.selected;
			
			_title.alpha =
			_buttonsHolder.alpha = _toggle.selected? 1 : .4;
			
			if(!_toggle.selected) close();
			else open();
		}
		
		/**
		 * Called when loading completes to set the enabled and selectedIndex values.
		 */
		protected function onload(enabled:Boolean, selectedIndex:int):void {
			_loadingMode = true;
			this.selectedIndex = selectedIndex;
			if(_toggleAble) this.enabled = enabled;
			_loadingMode = false;
		}
		
	}
}