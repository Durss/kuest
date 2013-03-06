package com.twinoid.kube.quest.views {
	import gs.TweenLite;

	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.components.buttons.SideMenuButton;
	import com.twinoid.kube.quest.components.menu.MenuCharsContent;
	import com.twinoid.kube.quest.components.menu.MenuFileContent;
	import com.twinoid.kube.quest.components.menu.MenuObjectContent;
	import com.twinoid.kube.quest.graphics.MenuCharactersIconGraphic;
	import com.twinoid.kube.quest.graphics.MenuFileIconGraphic;
	import com.twinoid.kube.quest.graphics.MenuObjectIconGraphic;
	import com.twinoid.kube.quest.model.Model;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;

	/**
	 * Displays the side menu with file, objects and characters menus.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class SideMenuView extends AbstractView {
		private var _buttons:Vector.<SideMenuButton>;
		private var _contents:Vector.<Sprite>;
		private var _width:int;
		private var _buttonsHolder:Sprite;
		private var _group:FormComponentGroup;
		private var _buttonToIndex:Dictionary;
		private var _opened:Boolean;
		private var _selectedIndex:int;
		
		
		
		
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model;
		}

		private function open():void {
			if(_opened) return;
			_opened = true;
			TweenLite.to(this, .25, {x:0});
		}

		private function close():void {
			if(!_opened) return;
			_opened = false;
			TweenLite.to(this, .25, {x:-_width});
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_width = 305;
			_group = new FormComponentGroup();
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			
			var icons:Array = [new MenuFileIconGraphic(), new MenuObjectIconGraphic(), new MenuCharactersIconGraphic()];
			var contents:Array = [new MenuFileContent(_width), new MenuObjectContent(_width), new MenuCharsContent(_width)];
			
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
			}
			
			_opened = true;
			_buttons[0].selected = true;
			
			computePositions();
			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0x47A9D1, 1);
			graphics.drawRect(0, 0, _width, stage.stageHeight);
			graphics.endFill();
			
			PosUtils.vPlaceNext(1, VectorUtils.toArray(_buttons));
			
			_buttonsHolder.x = _width;
			_buttonsHolder.y = Math.round((stage.stageHeight - _buttonsHolder.height) * .5);
			
		}
		
		/**
		 * Called when a component is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
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