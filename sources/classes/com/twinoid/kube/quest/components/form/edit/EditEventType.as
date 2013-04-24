package com.twinoid.kube.quest.components.form.edit {
	import com.twinoid.kube.quest.vo.ActionType;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.components.form.RadioButtonKube;
	import com.twinoid.kube.quest.components.form.input.TextArea;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.events.ItemSelectorEvent;
	import com.twinoid.kube.quest.graphics.EventTypeDialogueIcon;
	import com.twinoid.kube.quest.graphics.EventTypeObjectIcon;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.display.Sprite;

	
	/**
	 * Displays the dialogue/object forms.
	 * The user can choose to specify a dialogue or an object action to the event.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class EditEventType extends AbstractEditZone {
		
		private var _width:int;
		private var _dialogue:Sprite;
		private var _object:Sprite;
		private var _objectGroup:FormComponentGroup;
		private var _charHolder:ItemPlaceholder;
		private var _objectHolder:ItemPlaceholder;
		private var _charDialogue:TextArea;
		private var _objectDialogue:TextArea;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventType</code>.
		 */
		public function EditEventType(width:int) {
			_width = width;
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
					data.actionType = new ActionType(ActionType.TYPE_OBJECT, _charHolder.data, _charDialogue.text);
					break;
				case 1:
					data.actionType = new ActionType(ActionType.TYPE_OBJECT, _objectHolder.data, _objectDialogue.text);
					break;
				default:
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
			_charDialogue = new TextArea("promptWindowContent", Label.getLabel("editWindow-type-dialogueDefault"));
			_dialogue.addChild( _charDialogue );
			
			_charDialogue.width = _width - _charHolder.width - 5;
			_charDialogue.height = _charHolder.height;
			_charDialogue.x = _charHolder.width + 5;
		}

		/**
		 * Builds the object form
		 */
		private function buildObject():void {
			_object = new Sprite();
			_objectGroup = new FormComponentGroup();
			
			_objectHolder = new ItemPlaceholder(false, true, ItemSelectorEvent.ITEM_TYPE_OBJECT);
			_object.addChild(_objectHolder);
			_objectDialogue = new TextArea("promptWindowContent", Label.getLabel("editWindow-type-objectDefault"));
			_object.addChild( _objectDialogue );
			var cbTake:RadioButtonKube = new RadioButtonKube(Label.getLabel("editWindow-type-take"), _objectGroup);
			var cbPut:RadioButtonKube = new RadioButtonKube(Label.getLabel("editWindow-type-put"), _objectGroup);
			_object.addChild(cbTake);
			_object.addChild(cbPut);
			
			_objectDialogue.width = _width - _objectHolder.width - 5;
			_objectDialogue.height = _objectHolder.height - Math.round(cbTake.height + 5);
			_objectDialogue.x = _objectHolder.width + 5;
			_objectDialogue.validate();
			
			cbTake.x = Math.round(_objectDialogue.x + _objectDialogue.width * .5 - cbTake.width - 5);
			cbPut.x = Math.round(_objectDialogue.x + _objectDialogue.width * .5 + 5);
			cbPut.y = cbTake.y = Math.round(_objectDialogue.height + 5);
		}
		
	}
}