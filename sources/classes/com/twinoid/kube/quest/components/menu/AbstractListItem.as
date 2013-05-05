package com.twinoid.kube.quest.components.menu {
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.components.form.input.InputKube;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.utils.prompt;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.vo.SerializableBitmapData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	
	//Fired when the item is full filled
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	//Fired when delete button is clicked
	[Event(name="close", type="flash.events.Event")]
	
	//Fired when validation state changes
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Abstract list item.
	 * 
	 * @author Francois
	 * @date 1 mai 2013;
	 */
	public class AbstractListItem extends Sprite implements Disposable {
		
		protected var _image:ItemPlaceholder;
		protected var _nameInput:InputKube;
		protected var _deleteBt:GraphicButtonKube;
		protected var _data:IItemData;
		protected var _errorFilter:Array;
		private var _promptTitle:String;
		private var _promptContent:String;
		private var _promptActionID:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstractListItem</code>.
		 */
		public function AbstractListItem(promptTitle:String, promptContent:String, promptActionID:String) {
			_promptContent = promptContent;
			_promptTitle = promptTitle;
			_promptActionID = promptActionID;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function get width():Number { return _image.width; }
		
		/**
		 * @inheritDoc
		 */
		override public function get height():Number { return _nameInput.y + _nameInput.height; }
		
		/**
		 * Gets if the item is valid. i.e : fully filled.
		 */
		public function get isValid():Boolean {
			return StringUtils.trim(_nameInput.value as String).length > 0 && _image.isDefined;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_image.removeEventListener(Event.CHANGE, changeHandler);
			_deleteBt.removeEventListener(MouseEvent.CLICK, clickHandler);
			_nameInput.removeEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			_nameInput.removeEventListener(FormComponentEvent.SUBMIT, changeHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize():void {
			_image = addChild(new ItemPlaceholder(true)) as ItemPlaceholder;
			_nameInput = addChild(new InputKube()) as InputKube;
			_deleteBt = addChild(new GraphicButtonKube(new CancelIcon(), false)) as GraphicButtonKube;
			
			var matrix:Array = [ .25,.25,.25,0,0,
						          .25,.25,.25,0,0,
						          .25,.25,.25,0,0,
						          .25,.25,.25,1,0 ];
			_errorFilter = [new ColorMatrixFilter(matrix)];
			
			if (_data != null && _data.image != null && _data.name != null) {
				_image.image = _data.image.getConcreteBitmapData();
				_nameInput.text = _data.name;
			}else{
				filters = _errorFilter;
			}
			
			_image.addEventListener(Event.CHANGE, changeHandler);
			_deleteBt.addEventListener(MouseEvent.CLICK, clickHandler);
			_nameInput.addEventListener(Event.CHANGE, changeHandler);
			_nameInput.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			_nameInput.addEventListener(FormComponentEvent.SUBMIT, changeHandler);
			
			computePositions();
		}
		
		/**
		 * Called when delete button is clicked
		 */
		protected function clickHandler(event:MouseEvent):void {
			prompt(_promptTitle, _promptContent, onDelete, _promptActionID);
		}
		
		/**
		 * Deletes the item after confirmation.
		 */
		private function onDelete():void {
			dispatchEvent(new Event(Event.CLOSE));
		}

		
		/**
		 * Resizes and replaces the elements.
		 */
		protected function computePositions():void {
			PosUtils.vPlaceNext(2, _image, _nameInput);
			_nameInput.width = _image.width;
			_deleteBt.x = Math.round(_image.width - _deleteBt.width);
		}
		
		/**
		 * Called when a value changes.
		 */
		protected function changeHandler(event:Event):void {
			var n:String = _nameInput.value as String;
			var bmd:SerializableBitmapData = new SerializableBitmapData();
			bmd.fromBitmapData(_image.image);
			_data.image	= bmd;
			_data.name	= StringUtils.trim(n).length == 0? null : n;
			if(isValid) {
				filters = [];
			}else{
				filters = _errorFilter;
			}
			if(event.currentTarget == _image) {
				stage.focus = _nameInput;
			}
		}
		
	}
}