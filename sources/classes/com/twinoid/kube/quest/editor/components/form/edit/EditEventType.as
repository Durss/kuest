package com.twinoid.kube.quest.editor.components.form.edit {
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.components.form.RadioButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.TextArea;
	import com.twinoid.kube.quest.editor.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.editor.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.EventTypeDialogueIcon;
	import com.twinoid.kube.quest.graphics.EventTypeObjectIcon;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	
	/**
	 * Displays the dialogue/object forms.
	 * The user can choose to specify a dialogue or an object action to the event.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class EditEventType extends AbstractEditZone {
		
		private var _dialogue:Sprite;
		private var _object:Sprite;
		private var _objectGroup:FormComponentGroup;
		private var _charHolder:ItemPlaceholder;
		private var _objectHolder:ItemPlaceholder;
		private var _charDialogue:TextArea;
		private var _objectDialogue:TextArea;
		private var _cbTake:RadioButtonKube;
		private var _cbPut:RadioButtonKube;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventType</code>.
		 */
		public function EditEventType(width:int) {
			super(Label.getLabel("editWindow-type-title"), width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configuration to the value object
		 */
		public function save(data:KuestEvent):void {
			switch(selectedIndex){
				case 0:
					data.actionType = new ActionType();
					data.actionType.type = ActionType.TYPE_CHARACTER;
					data.actionType.setItem(_charHolder.data);
					data.actionType.text = _charDialogue.text;
					break;
				case 1:
					data.actionType = new ActionType();
					data.actionType.type = ActionType.TYPE_OBJECT;
					data.actionType.setItem(_objectHolder.data);
					data.actionType.text = _objectDialogue.text;
					data.actionType.takeMode = _cbTake.selected;
					break;
				default:
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			if(data.actionType == null) {
				selectedIndex = 0;
				_objectHolder.data = null;
				_objectDialogue.text = "";
				_charHolder.data = null;
				_charDialogue.text = "";
				return;
			}
			
			if(data.actionType.type == ActionType.TYPE_CHARACTER) {
				selectedIndex = 0;
				_charHolder.data = data.actionType.getItem();
				_charDialogue.text = data.actionType.text;
				_objectHolder.data = null;
				_objectDialogue.text = "";
				_cbTake.selected = true;
				_cbPut.selected = false;
			}else{
				selectedIndex = 1;
				_charHolder.data = null;
				_charDialogue.text = "";
				_objectHolder.data = data.actionType.getItem();
				_objectDialogue.text = data.actionType.text;
				_cbTake.selected = data.actionType.takeMode;
				_cbPut.selected = !data.actionType.takeMode;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			buildDialogue();
			buildObject();
			
			addEntry(new EventTypeDialogueIcon(), _dialogue, Label.getLabel("editWindow-type-dialogueTT"));
			addEntry(new EventTypeObjectIcon(), _object, Label.getLabel("editWindow-type-objectTT"));
		}
		
		/**
		 * Builds the dialogue form
		 */
		private function buildDialogue():void {
			_dialogue = new Sprite();
			
			_charHolder = new ItemPlaceholder(false, true);
			_dialogue.addChild(_charHolder);
			_charDialogue = new TextArea("editWindow-label", Label.getLabel("editWindow-type-dialogueDefault"));
			_dialogue.addChild( _charDialogue );
			
			_charDialogue.width = _width - _charHolder.width - 5;
			_charDialogue.height = _charHolder.height;
			_charDialogue.x = _charHolder.width + 5;
			
			_charHolder.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		}

		/**
		 * Builds the object form
		 */
		private function buildObject():void {
			_object = new Sprite();
			_objectGroup = new FormComponentGroup();
			
			_objectHolder = new ItemPlaceholder(false, true, ItemSelectorEvent.ITEM_TYPE_OBJECT);
			_object.addChild(_objectHolder);
			_objectDialogue = new TextArea("editWindow-label", Label.getLabel("editWindow-type-objectDefault"));
			_object.addChild( _objectDialogue );
			_cbTake = new RadioButtonKube(Label.getLabel("editWindow-type-take"), _objectGroup);
			_cbPut = new RadioButtonKube(Label.getLabel("editWindow-type-put"), _objectGroup);
			_object.addChild(_cbTake);
			_object.addChild(_cbPut);
			
			_objectDialogue.width = _width - _objectHolder.width - 5;
			_objectDialogue.height = _objectHolder.height - Math.round(_cbTake.height + 5);
			_objectDialogue.x = _objectHolder.width + 5;
			_objectDialogue.validate();
			
			_cbTake.x = Math.round(_objectDialogue.x + _objectDialogue.width * .5 - _cbTake.width - 5);
			_cbPut.x = Math.round(_objectDialogue.x + _objectDialogue.width * .5 + 5);
			_cbPut.y = _cbTake.y = Math.round(_objectDialogue.height + 5);
			
			_objectHolder.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		}

		private function rollOverHandler(event:MouseEvent):void {
			if(event.currentTarget == _objectHolder) {
				_objectHolder.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("editWindow-type-placeHolderObjectTT"), ToolTipAlign.TOP_RIGHT));
			}else{
				_charHolder.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("editWindow-type-placeHolderCharacterTT"), ToolTipAlign.TOP_RIGHT));
			}
		}
		
	}
}