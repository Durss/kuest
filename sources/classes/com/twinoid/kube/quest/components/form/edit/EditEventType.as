package com.twinoid.kube.quest.components.form.edit {
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.components.form.RadioButtonKube;
	import com.twinoid.kube.quest.components.form.input.TextArea;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
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
			
			var photoZone:ItemPlaceholder = new ItemPlaceholder(false, true);
			_dialogue.addChild(photoZone);
			var textArea:TextArea = new TextArea("promptWindowContent");
			_dialogue.addChild( textArea );
			
			textArea.width = _width - photoZone.width - 5;
			textArea.height = 80;
			textArea.x = photoZone.width + 5;
		}

		/**
		 * Builds the object form
		 */
		private function buildObject():void {
			_object = new Sprite();
			_objectGroup = new FormComponentGroup();
			
			var photoZone:ItemPlaceholder = new ItemPlaceholder(false, true);
			_object.addChild(photoZone);
			var textArea:TextArea = new TextArea("promptWindowContent");
			_object.addChild( textArea );
			var cbTake:RadioButtonKube = new RadioButtonKube(Label.getLabel("editWindow-type-take"), _objectGroup);
			var cbPut:RadioButtonKube = new RadioButtonKube(Label.getLabel("editWindow-type-put"), _objectGroup);
			_object.addChild(cbTake);
			_object.addChild(cbPut);
			
			textArea.width = _width - photoZone.width - 5;
			textArea.height = 80 - Math.round(cbTake.height + 5);
			textArea.x = photoZone.width + 5;
			textArea.validate();
			
			cbTake.x = Math.round(textArea.x + textArea.width * .5 - cbTake.width - 5);
			cbPut.x = Math.round(textArea.x + textArea.width * .5 + 5);
			cbPut.y = cbTake.y = Math.round(textArea.height + 5);
		}
		
	}
}