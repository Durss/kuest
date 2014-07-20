package com.twinoid.kube.quest.editor.components.menu.file {
	import gs.TweenLite;

	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.draw.createRect;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.vo.KuestInfo;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;

	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * Displays the help form
	 * 
	 * @author Francois
	 * @date 3 juin 2013;
	 */
	public class FileHelpForm extends Sprite implements Closable {
		
		private var _width:int;
		private var _mask:Shape;
		private var _closed:Boolean;
		private var _populated:Boolean;
		private var _itemToData:Dictionary;
		private var _tutorialBt:ButtonKube;
		private var _samplesLabel:CssTextField;
		private var _spinning:LoaderSpinning;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileHelpForm</code>.
		 */
		public function FileHelpForm(width:int) {
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
		 * Toggles the open state.
		 */
		public function toggle():void {
			if (_closed) open();
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open():void {
			_closed = false;
			var oldH:int = _mask.height;
			_mask.scaleY = 1;
			var h:int = _mask.height;
			_mask.height = oldH;
			computePositions();
			TweenLite.killTweensOf(_mask);
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {height:h, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			_closed = true;
			TweenLite.killTweensOf(_mask);
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:0, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * Sets the users
		 */
		public function populate(data:Vector.<KuestInfo>):void {
			if(data == null || _populated) return;
			
			_populated = true;
			var i:int, len:int, py:int, item:ButtonKube;
			len = data.length;
			_itemToData = new Dictionary();
			py = _samplesLabel.y + _samplesLabel.height + 4;
			for(i = 0; i < len; ++i) {
				item			= addChild(new ButtonKube(data[i].title)) as ButtonKube;
				item.textAlign	= TextAlign.LEFT;
				item.width		= _width - 10;
				item.x			= 5;
				item.y			= py;
				item.validate();
				_itemToData[item]= data[i];
				py += item.height + 3;
			}
			
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mask			= addChild(createRect()) as Shape;
			_tutorialBt		= addChild(new ButtonKube(Label.getLabel("menu-file-help-tuto"))) as ButtonKube;
			_samplesLabel	= addChild(new CssTextField("menu-label")) as CssTextField;
			_spinning		= addChild(new LoaderSpinning()) as LoaderSpinning;
			
			mask					= _mask;
			_closed					= true;
			_mask.scaleY			= 0;
			_samplesLabel.text		= Label.getLabel("menu-file-help-samples");
			_tutorialBt.validate();
			
			makeEscapeClosable(this, 1);
			
			computePositions();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var margin:int = 5;
			graphics.clear();
			
			_tutorialBt.y		= margin;
			_samplesLabel.y		= Math.round(_tutorialBt.y + _tutorialBt.height + 9);
			_samplesLabel.width	= _width;
			_tutorialBt.width	= _width - margin * 2;
			_tutorialBt.x		= margin;
			
			var h:int = super.height + margin;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(0, 0, _width, h);
			_mask.graphics.endFill();
			
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h - 1);
			graphics.endFill();
			
			graphics.lineStyle(0,0,0);
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(margin, Math.round(_tutorialBt.y + _tutorialBt.height + 6), _width - margin * 2, 1);
			graphics.endFill();
		}
		
		/**
		 * Called when an item is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(_itemToData[event.target] != null) {
				var label:String = KuestInfo(_itemToData[event.target]).description;
				InteractiveObject(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.RIGHT));
			}
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _tutorialBt) {
				ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.TUTORIAL));
			}else
			
			if(_itemToData[event.target] != undefined) {
				if(FrontControler.getInstance().load(_itemToData[event.target], onLoad, onLoadSampleCancel)) {
					mouseEnabled = mouseChildren = false;
					_spinning.open(Label.getLabel("loader-loading"));
					_spinning.x = _width * .5;
					_spinning.y = height * .5;
					addChild(_spinning);
				}
			}
		}

		/**
		 * Called when a kuest loading completes or fail.
		 */
		private function onLoad(success:Boolean, errorID:String = "", progress:Number = NaN):void {
			if(!isNaN(progress)) {
				_spinning.label = Label.getLabel("loader-loading")+" "+Math.round(progress*100)+"%";
				return;
			}
			mouseEnabled = mouseChildren = true;
			if(success) {
				_spinning.close(Label.getLabel("loader-loadingOK"));
			}else{
				_spinning.close(Label.getLabel("loader-loadingKO" + (errorID == "read"? "Read" : "")));
			}
		}
		
		/**
		 * Called if loading is canceled
		 */
		private function onLoadSampleCancel():void {
			_spinning.close();
			mouseEnabled = mouseChildren = true;
		}
		
	}
}