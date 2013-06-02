package com.twinoid.kube.quest.editor.components.menu.file {
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.ComboboxKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.components.form.input.TextArea;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.vo.KuestInfo;
	import com.twinoid.kube.quest.editor.vo.UserInfo;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;


	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Displays the save form
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
		private var _rightsLabel:CssTextField;
		private var _friendsCB:ComboboxKube;
		private var _friends:Vector.<UserInfo>;
		private var _editMode:Boolean;
		
		
		
		
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
		
		/**
		 * Gets the friends allowed to access this quest
		 */
		public function get friends():Array { return _friendsCB.list.scrollableList.selectedDatas; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Toggles the open state.
		 */
		public function toggle(editMode:Boolean = false):void {
			if (_closed || editMode != _editMode) open(editMode);
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open(editMode:Boolean = false):void {
			if (_closed) stage.focus = _nameInput;
			_editMode = editMode;
			_closed = false;
			_submit.label = editMode? Label.getLabel("menu-file-new-edit") : Label.getLabel("menu-file-new-submit");
			var oldH:int = _mask.height;
			_mask.scaleY = 1;
			var h:int = _mask.height;
			_mask.height = oldH;
			_friendsCB.close();
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
		public function populate(info:KuestInfo, friends:Vector.<UserInfo>):void {
			var i:int, len:int;
			if (info != null) {
				_nameInput.text = info.title;
				_descriptionInput.text = info.description;
				if(!_closed) open(true);
			}else{
				_nameInput.text = _descriptionInput.text = "";
			}
			
			if (friends != null && _friendsCB.list.scrollableList.length == 0) {
				_friends = friends;
				len = _friends.length;
				var amIIn:Boolean = false;
				for(i = 0; i < len; ++i) {
					if(!amIIn && _friends[i].uid == "89") amIIn = true;
					_friendsCB.addSkinnedItem(_friends[i].uname+" <span class='friendItemId'>(ID:"+_friends[i].uid+")</span>", _friends[i].uid);
				}
				//Add myself for debug eventual technical support on quests
				if(!amIIn) {
					_friendsCB.addSkinnedItem("Durss <span class='friendItemId'>(ID:89)</span>", 89);
				}
			}
			
			//Select users
			if(_friends != null && info != null) {
				_friendsCB.selectedDatas = info.users;
			}
			changeHandler();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mask					= addChild(createRect()) as Shape;
			_nameLabel				= addChild(new CssTextField("menu-label")) as CssTextField;
			_nameInput				= addChild(new InputKube()) as InputKube;
			_descriptionLabel		= addChild(new CssTextField("menu-label")) as CssTextField;
			_descriptionInput		= addChild(new TextArea("textarea", "", false)) as TextArea;
			_submit					= addChild(new ButtonKube(Label.getLabel("menu-file-new-submit"), new SubmitIcon())) as ButtonKube;
			_spinning				= addChild(new LoaderSpinning()) as LoaderSpinning;
			_rightsLabel			= addChild(new CssTextField("menu-label")) as CssTextField;
			_friendsCB				= addChild(new ComboboxKube(Label.getLabel("menu-file-rightsCB"), true)) as ComboboxKube;
			
			mask					= _mask;
			_nameInput.style		= "input-menu";
			_nameLabel.text			= Label.getLabel("menu-file-new-name");
			_descriptionLabel.text	= Label.getLabel("menu-file-new-description");
			_rightsLabel.text		= Label.getLabel("menu-file-rights");
			makeEscapeClosable(this, 1);
			
			computePositions();
			
			_closed = true;
			_mask.scaleY = 0;
			_submit.enabled = false;
			_nameInput.textfield.maxChars = 50;
			_descriptionInput.textfield.maxChars = 255;
			_friendsCB.allowMultipleSelection = true;
			
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
			_nameLabel.x = _nameInput.x = _descriptionLabel.x =
			_descriptionInput.x = _rightsLabel.x = _friendsCB.x = margin;
			
			_nameLabel.width = _nameInput.width = _descriptionLabel.width =
			_descriptionInput.width = _friendsCB.width = _width - margin*2;
			
			_submit.x = Math.round((_width - _submit.width) * .5);
			
			PosUtils.vPlaceNext(2, _nameLabel, _nameInput, _descriptionLabel, _descriptionInput, _rightsLabel, _friendsCB, _submit);
			_submit.y += margin;
			_friendsCB.listHeight = _friendsCB.y - margin;
			
			roundPos(_nameLabel, _nameInput, _descriptionLabel, _descriptionInput, _submit, _rightsLabel, _friendsCB);
			
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
			FrontControler.getInstance().save(title, description, friends, onSaveResult, false, _editMode);
		}
		
		/**
		 * Called when saving completes/fails
		 */
		private function onSaveResult(success:Boolean, errorID:String = "", progress:Number = NaN):void {
			progress;//Cannot get progression fo upload :(
			errorID;
			
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
			}
		}
		
		/**
		 * Called when an input's value changes
		 */
		private function changeHandler(event:Event = null):void {
			_submit.enabled = StringUtils.trim(title).length > 0 && StringUtils.trim(description).length > 0;
		}
		
	}
}