package com.twinoid.kube.quest.editor.components.menu.file {
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.components.form.input.TextArea;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import gs.TweenLite;


	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Displays the "new" form
	 * 
	 * @author Francois
	 * @date 8 mai 2013;
	 */
	public class FileSaveForm extends Sprite implements Closable {

		private var _nameLabel:CssTextField;
		private var _nameInput:InputKube;
		private var _descriptionLabel:CssTextField;
		private var _descriptionInput:TextArea;
		private var _width:int;
		private var _submit:ButtonKube;
		private var _closed:Boolean;
		private var _mask:Shape;
		private var _spinning:LoaderSpinning;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileSaveForm</code>.
		 */
		public function FileSaveForm(width:int) {
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
		
		/**
		 * Gets the kuest title
		 */
		public function get title():String { return _nameInput.text; }
		
		/**
		 * Gets the kuest description
		 */
		public function get description():String { return _descriptionInput.text; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
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
			stage.focus = _nameInput;
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
			_mask				= addChild(createRect()) as Shape;
			_nameLabel			= addChild(new CssTextField("menu-label")) as CssTextField;
			_nameInput			= addChild(new InputKube()) as InputKube;
			_descriptionLabel	= addChild(new CssTextField("menu-label")) as CssTextField;
			_descriptionInput	= addChild(new TextArea()) as TextArea;
			_submit				= addChild(new ButtonKube(Label.getLabel("menu-file-new-submit"), new SubmitIcon())) as ButtonKube;
			_spinning			= addChild(new LoaderSpinning()) as LoaderSpinning;
			
			mask					= _mask;
			_nameInput.style		= "input-menu";
			_nameLabel.text			= Label.getLabel("menu-file-new-name");
			_descriptionLabel.text	= Label.getLabel("menu-file-new-description");
			makeEscapeClosable(this);
			
			computePositions();
			
			_closed = true;
			_mask.scaleY = 0;
			_submit.enabled = false;
			_nameInput.textfield.maxChars = 30;
			_descriptionInput.textfield.maxChars = 255;
			
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_nameInput.addEventListener(Event.CHANGE, changeHandler);
			_descriptionInput.addEventListener(Event.CHANGE, changeHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var margin:int = 5;
			_descriptionInput.height = 100;
			_nameLabel.x = _nameInput.x = _descriptionLabel.x = _descriptionInput.x = margin;
			_nameLabel.width = _nameInput.width = _descriptionLabel.width = _descriptionInput.width = _width - margin*2;
			_submit.x = Math.round((_width - _submit.width) * .5);
			PosUtils.vPlaceNext(2, _nameLabel, _nameInput, _descriptionLabel, _descriptionInput, _submit);
			_submit.y += margin;
			
			roundPos(_nameLabel, _nameInput, _descriptionLabel, _descriptionInput, _submit);
			
			var h:int = Math.round(_submit.y + _submit.height) + margin * 2;
			
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
		
		/**
		 * Called when form is submitted
		 */
		private function submitHandler(event:MouseEvent):void {
			_submit.enabled = false;
			_spinning.open(Label.getLabel("loader-saving"));
			FrontControler.getInstance().save(title, description, onSaveResult);
		}
		
		/**
		 * Called when saving completes/fails
		 */
		private function onSaveResult(success:Boolean, errorID:String = "", progress:Number = NaN):void {
			progress;//Cannot get progression fo upload :(
//			if(!isNaN(progress)) {
//				_spinning.label = Label.getLabel("loader-saving")+" "+Math.round(progress*100)+"%";
//				return;
//			}
			_submit.enabled = true;
			if(success) {
				_spinning.close(Label.getLabel("loader-savingOK"));
				setTimeout(close, 1000);
			}else{
				_spinning.close(Label.getLabel("loader-savingKO"));
				trace(errorID);
			}
		}
		
		/**
		 * Called when an input's value changes
		 */
		private function changeHandler(event:Event):void {
			_submit.enabled = StringUtils.trim(title).length > 0 && StringUtils.trim(description).length > 0;
		}
		
	}
}