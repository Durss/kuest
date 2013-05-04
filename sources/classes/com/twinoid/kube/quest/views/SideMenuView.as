package com.twinoid.kube.quest.views {
	import gs.TweenLite;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.SideMenuButton;
	import com.twinoid.kube.quest.components.menu.AbstractMenuContent;
	import com.twinoid.kube.quest.components.menu.MenuCharsContent;
	import com.twinoid.kube.quest.components.menu.MenuCreditsContent;
	import com.twinoid.kube.quest.components.menu.MenuFileContent;
	import com.twinoid.kube.quest.components.menu.MenuObjectContent;
	import com.twinoid.kube.quest.graphics.MenuCharactersIconGraphic;
	import com.twinoid.kube.quest.graphics.MenuCreditsIconGraphic;
	import com.twinoid.kube.quest.graphics.MenuFileIconGraphic;
	import com.twinoid.kube.quest.graphics.MenuObjectIconGraphic;
	import com.twinoid.kube.quest.model.Model;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;

	/**
	 * Displays the side menu with file, objects and characters menus.
	 * 
	 * File menu displays classic save/load possibilities.
	 * 
	 * Objects menu provides a way to define the objects that can be grabbed
	 * and put during the quest.
	 * 
	 * Characters menu provides a way to create characters that will talk to us
	 * during the quest.
	 * 
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class SideMenuView extends AbstractView {
		
		private var _width:int = 335;
		
		private var _buttons:Vector.<SideMenuButton>;
		private var _contents:Vector.<Sprite>;
		private var _buttonsHolder:Sprite;
		private var _group:FormComponentGroup;
		private var _buttonToIndex:Dictionary;
		private var _opened:Boolean;
		private var _selectedIndex:int;
		private var _back:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SideMenuView</code>.
		 */
		public function SideMenuView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			
			var i:int, len:int;
			len = _contents.length;
			for(i = 0; i < len; ++i) {
				AbstractMenuContent(_contents[i]).update(model);
			}
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_group = new FormComponentGroup();
			_back = addChild(new Shape()) as Shape;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			
			var icons:Array = [new MenuFileIconGraphic(), new MenuCharactersIconGraphic(), new MenuObjectIconGraphic(), new MenuCreditsIconGraphic()];
			var contents:Array = [new MenuFileContent(_width), new MenuCharsContent(_width), new MenuObjectContent(_width), new MenuCreditsContent(_width)];
			
			var i:int, len:int;
			len = icons.length;
			
			_buttonToIndex = new Dictionary();
			_buttons = new Vector.<SideMenuButton>(len, true);
			_contents = new Vector.<Sprite>(len, true);
			
			for(i = 0; i < len; ++i) {
				DisplayObject(icons[i]).filters = [ new DropShadowFilter(2,135,0,.3,3,3,1,2) ];
				_buttons[i] = _buttonsHolder.addChild( new SideMenuButton(icons[i]) ) as SideMenuButton;
				_contents[i] = contents[i];
				_group.add( _buttons[i] );
				_buttonToIndex[ _buttons[i] ] = i;
				
				//These two stupid lines  provides a way to initialize the
				//contents directly. Which is necessary as Chars and Objects
				//menus creates the default items at their initialize.
				//Without that the ItemSelectorView would be empty.
				//Yup, I actually should initialize those default items in
				//the model not in the views...
				addChild(_contents[i]);
				removeChild(_contents[i]);
			}
			
			_back.filters = [new DropShadowFilter(4, 0, 0, .35, 5, 0, 1, 2)];
			
			_opened = true;
			_buttons[0].selected = true;
			addChild(_contents[0]);
			
			computePositions();
			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			_back.graphics.clear();
			_back.graphics.beginFill(0x47A9D1, 1);
			_back.graphics.drawRect(0, 0, _width, stage.stageHeight);
			_back.graphics.endFill();
			
			PosUtils.vPlaceNext(1, VectorUtils.toArray(_buttons));
			
			_buttonsHolder.x = _width;
			_buttonsHolder.y = Math.round((stage.stageHeight - _buttonsHolder.height) * .5);
		}
		
		/**
		 * Opens the view
		 */
		private function open():void {
			if(_opened) return;
			_opened = true;
			TweenLite.to(this, .25, {x:0});
		}
		
		/**
		 * Closes the view
		 */
		private function close():void {
			if(!_opened) return;
			_opened = false;
			TweenLite.to(this, .25, {x:-_width});
		}
		
		/**
		 * Called when a component is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_buttonToIndex[ event.target ] == null) return;
			
			var index:int = _buttonToIndex[ event.target ];
			if(index == _selectedIndex) {
				if(_opened) close(); else open();
			}else{
				open();
			}
			
			var i:int, len:int;
			len = _contents.length;
			//Removes the contents from the stage and add the selected one.
			for(i = 0; i < len; ++i) {
				_contents[i].visible = i == index;
				if(i == index) addChild( _contents[i] );
				else if(contains( _contents[i] )) removeChild( _contents[i] );
			}
			
			_selectedIndex = index;
		}
		
	}
}