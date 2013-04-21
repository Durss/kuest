package com.twinoid.kube.quest.components.menu.char {
	import com.nurun.core.lang.Disposable;
	import flash.events.MouseEvent;
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.components.char.CharFace;
	import com.twinoid.kube.quest.components.form.input.InputKube;
	import flash.display.Sprite;
	import flash.events.Event;
	
	//Fired when the char is full filled
	[Event(name="submit", type="com.nurun.components.form.events.FormComponentEvent")]
	
	//Fired when delete button is clicked
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Displays a character's form
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class CharItem extends Sprite implements Disposable {
		private var _face:CharFace;
		private var _nameInput:InputKube;
		private var _deleteBt:GraphicButtonKube;
		
		
		
		
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
		override public function get width():Number {
			return _face.width;
		}
		
		override public function get height():Number {
			return _nameInput.y + _nameInput.height;
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
			
			_nameInput.removeEventListener(Event.CHANGE, changeHandler);
			_face.removeEventListener(Event.CHANGE, changeHandler);
			_deleteBt.removeEventListener(MouseEvent.CLICK, clickHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_face = addChild(new CharFace(true)) as CharFace;
			_nameInput = addChild(new InputKube(Label.getLabel("menu-chars-add-name"))) as InputKube;
			_deleteBt = addChild(new GraphicButtonKube(new CancelIcon(), false)) as GraphicButtonKube;
			
			_nameInput.addEventListener(Event.CHANGE, changeHandler);
			_face.addEventListener(Event.CHANGE, changeHandler);
			_deleteBt.addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Called when delete button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.vPlaceNext(2, _face, _nameInput);
			_nameInput.width = _face.width;
			_deleteBt.x = Math.round(_face.width - _deleteBt.width);
		}
		
		/**
		 * Called when a value changes.
		 */
		private function changeHandler(event:Event):void {
			if(StringUtils.trim(_nameInput.value as String).length > 0 && _face.isDefined) {
				dispatchEvent(new FormComponentEvent(FormComponentEvent.SUBMIT));
			}
			if(event.currentTarget == _face) {
				stage.focus = _nameInput;
			}
		}
		
	}
}