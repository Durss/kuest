package com.twinoid.kube.quest.components.menu.char {
	import flash.display.BitmapData;
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.components.form.input.InputKube;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.vo.CharItemData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	//Fired when the char is full filled
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	//Fired when delete button is clicked
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Displays a character's form
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class CharItem extends Sprite implements Disposable {
		
		private var _image:ItemPlaceholder;
		private var _nameInput:InputKube;
		private var _deleteBt:GraphicButtonKube;
		private var _data:CharItemData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharItem</code>.
		 */
		public function CharItem() {
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
		 * Gets the item's data
		 */
		public function get data():CharItemData { return _data; }
		
		/**
		 * Sets the image.
		 */
		public function set image(value:BitmapData):void {
			_data.image = value;
			_image.image = value;
		}
		
		/**
		 * Sets the image.
		 */
		override public function set name(value:String):void {
			_data.name = value;
			_nameInput.text = value;
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
		private function initialize():void {
			_data = new CharItemData();
			
			_image = addChild(new ItemPlaceholder(true)) as ItemPlaceholder;
			_nameInput = addChild(new InputKube(Label.getLabel("menu-chars-add-name"))) as InputKube;
			_deleteBt = addChild(new GraphicButtonKube(new CancelIcon(), false)) as GraphicButtonKube;
			
			_image.addEventListener(Event.CHANGE, changeHandler);
			_deleteBt.addEventListener(MouseEvent.CLICK, clickHandler);
			_nameInput.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			_nameInput.addEventListener(FormComponentEvent.SUBMIT, changeHandler);
			
			computePositions();
		}
		
		/**
		 * Called when delete button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			_data.kill();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.vPlaceNext(2, _image, _nameInput);
			_nameInput.width = _image.width;
			_deleteBt.x = Math.round(_image.width - _deleteBt.width);
		}
		
		/**
		 * Called when a value changes.
		 */
		private function changeHandler(event:Event):void {
			_data.image	= _image.image;
			_data.name	= _nameInput.text;
			if(StringUtils.trim(_nameInput.value as String).length > 0 && _image.isDefined) {
				dispatchEvent(new FormComponentEvent(FormComponentEvent.SUBMIT));
			}
			if(event.currentTarget == _image) {
				stage.focus = _nameInput;
			}
		}
		
	}
}