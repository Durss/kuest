package com.twinoid.kube.quest.editor.components.menu.file {
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
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
	 * Displays the load panel.
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
		public function populate(data:Vector.<KuestInfo>, currentKuest:KuestInfo = null):void {
			_label.text = data == null || data.length == 0? Label.getLabel("menu-file-load-empty") : Label.getLabel("menu-file-load-title");
			
			while(_holder.numChildren > 0) {
				if(_holder.getChildAt(0) is Disposable) Disposable(_holder.getChildAt(0)).dispose();
				_holder.removeChildAt(0);
			}
			
			var i:int, len:int, py:int, item:ButtonKube, deleteBt:GraphicButtonKube;
			len = data == null? 0 : data.length;
			_itemToData = new Dictionary();
			for(i = 0; i < len; ++i) {
				if (data[i].isSample) continue;
				deleteBt		= _holder.addChild(new GraphicButtonKube(new CancelIcon())) as GraphicButtonKube;
				item			= _holder.addChild(new ButtonKube(data[i].title, null, currentKuest == data[i])) as ButtonKube;
				item.textAlign	= TextAlign.LEFT;
				item.width		= _width - deleteBt.width - 12;
				item.y			= py;
				item.x			= deleteBt.width + 0;
				deleteBt.y		= py;
				deleteBt.height	= item.height;
				_itemToData[item]		= data[i];
				_itemToData[deleteBt]	= data[i];
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
			if (_itemToData[event.target] != null) {
				var deleteLabel:String  = (KuestInfo(_itemToData[event.target]).amITheOwner)? 'menu-file-delete-buttonTT' : 'menu-file-delete-self-buttonTT';
				var label:String = (event.target is GraphicButtonKube)? Label.getLabel(deleteLabel) : KuestInfo(_itemToData[event.target]).description;
				InteractiveObject(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.RIGHT));
			}
		}

		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			var target:Object = event.target;
			if(_itemToData[target] != null) {
				if(event.target is GraphicButtonKube) {
					FrontControler.getInstance().deleteSave(_itemToData[target] as KuestInfo);
				}else{
					if(FrontControler.getInstance().load(_itemToData[target] as KuestInfo, onLoad, onLoadCancel)) {
						mouseEnabled = mouseChildren = false;
						_spinning.open(Label.getLabel("loader-loading"));
					}
				}
			}
		}

		private function onLoadCancel():void {
			_spinning.close();
			mouseEnabled = mouseChildren = true;
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