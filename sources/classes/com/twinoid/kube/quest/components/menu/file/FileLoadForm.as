package com.twinoid.kube.quest.components.menu.file {
	import com.twinoid.kube.quest.vo.ToolTipAlign;
	import com.twinoid.kube.quest.events.ToolTipEvent;
	import flash.display.InteractiveObject;
	import com.nurun.components.button.TextAlign;
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.twinoid.kube.quest.components.LoaderSpinning;
	import com.twinoid.kube.quest.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.utils.Closable;
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.vo.KuestInfo;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 mai 2013;
	 */
	public class FileLoadForm extends Sprite implements Closable {
		
		private var _width:int;
		private var _closed:Boolean;
		private var _mask:Shape;
		private var _spinning:LoaderSpinning;
		private var _label:CssTextField;
		private var _holder:Sprite;
		private var _itemToData:Dictionary;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileLoadForm</code>.
		 */
		public function FileLoadForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _mask.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(data:Vector.<KuestInfo>):void {
			_label.text = data == null || data.length == 0? Label.getLabel("menu-file-load-empty") : Label.getLabel("menu-file-load-title");
			
			while(_holder.numChildren > 0) {
				if(_holder.getChildAt(0) is Disposable) Disposable(_holder.getChildAt(0)).dispose();
				_holder.removeChildAt(0);
			}
			
			var i:int, len:int, py:int, item:ButtonKube;
			len = data == null? 0 : data.length;
			_itemToData = new Dictionary();
			for(i = 0; i < len; ++i) {
				item = _holder.addChild(new ButtonKube(data[i].title)) as ButtonKube;
				item.textAlign = TextAlign.LEFT;
				item.width = _width - 10;
				item.y = py;
				_itemToData[item] = data[i];
				py += item.height + 3;
			}
			
			computePositions();
		}
		
		/**
		 * Toggles the open state.
		 */
		public function toggle():void {
			if(_closed) open();
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open():void {
			if(!_closed) return;
			_closed = false;
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:1, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			_closed = true;
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:0, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mask			= addChild(createRect()) as Shape;
			_label			= addChild(new CssTextField("menu-label")) as CssTextField;
			_holder			= addChild(new Sprite()) as Sprite;
			_spinning		= addChild(new LoaderSpinning()) as LoaderSpinning;
			mask			= _mask;
			
			makeEscapeClosable(this);
			
			computePositions();
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			
			_closed = true;
			_mask.scaleY = 0;
		}
		
		/**
		 * Called when an item is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(_itemToData[event.target] != null) {
				InteractiveObject(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, KuestInfo(_itemToData[event.target]).description, ToolTipAlign.RIGHT));
			}
		}

		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			var target:Object = event.target;
			if(_itemToData[target] != null) {
				mouseEnabled = mouseChildren = false;
				_spinning.open(Label.getLabel("loader-loading"));
				FrontControler.getInstance().load(_itemToData[target] as KuestInfo, onLoad);
			}
		}
		
		/**
		 * Called when a kuest loading completes or fail.
		 */
		private function onLoad(success:Boolean, errorID:String = ""):void {
			errorID;
			mouseEnabled = mouseChildren = true;
			if(success) {
				_spinning.close(Label.getLabel("loader-loadingOK"));
			}else{
				_spinning.close(Label.getLabel("loader-loadingKO"));
			}
		}

		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var margin:int = 5;
			_label.width = _width - margin * 2;
			_label.x = _holder.x = margin;
			_holder.y = Math.round(_label.height + margin);
			
			var h:int = Math.round(_holder.y + _holder.height) + margin * 2;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(0, 0, _width, h);
			_mask.graphics.endFill();
			
			graphics.clear();
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h - 1);
			graphics.endFill();
			
			_spinning.x = _width * .5;
			_spinning.y = h * .5;
		}
		
	}
}