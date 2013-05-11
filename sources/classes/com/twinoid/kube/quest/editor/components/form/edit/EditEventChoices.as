package com.twinoid.kube.quest.editor.components.form.edit {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.vo.ActionChoices;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.EventChoiceNoneIcon;
	import com.twinoid.kube.quest.graphics.EventChoiceYupIcon;
	import flash.display.Sprite;

	
	/**
	 * 
	 * @author Francois
	 * @date 4 mai 2013;
	 */
	public class EditEventChoices extends AbstractEditZone {
		
		private var _form:Sprite;
		private var _label:CssTextField;
		private var _choice1:InputKube;
		private var _choice2:InputKube;
		private var _choice3:InputKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventChoices</code>.
		 */
		public function EditEventChoices(width:int) {
			super(Label.getLabel("editWindow-choice-title"), width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configurations to the value object
		 */
		public function save(data:KuestEvent):void {
			switch(selectedIndex){
				case 0:
					data.actionChoices = new ActionChoices();
					break;
				case 1:
					data.actionChoices = new ActionChoices();
					if(StringUtils.trim(_choice1.value as String).length > 0) data.actionChoices.addChoice(_choice1.text);
					if(StringUtils.trim(_choice2.value as String).length > 0) data.actionChoices.addChoice(_choice2.text);
					if(StringUtils.trim(_choice3.value as String).length > 0) data.actionChoices.addChoice(_choice3.text);
					break;
				default:
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			_choice1.text = _choice1.defaultLabel;
			_choice2.text = _choice2.defaultLabel;
			_choice3.text = _choice3.defaultLabel;
			selectedIndex = 0;
			
			if(data.actionChoices != null) {
				if (data.actionChoices.choices.length > 0 && data.actionChoices.choices[0].length > 0) {
					_choice1.text = data.actionChoices.choices[0];
					selectedIndex = 1;
				}
				if(data.actionChoices.choices.length > 1 && data.actionChoices.choices[1].length > 0) {
					_choice2.text = data.actionChoices.choices[1];
				}
				if(data.actionChoices.choices.length > 2 && data.actionChoices.choices[2].length > 0) {
					_choice3.text = data.actionChoices.choices[2];
					selectedIndex = 1;
				}
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
			
			buildForm();
			
			addEntry(new EventChoiceNoneIcon(), new Sprite(), Label.getLabel("editWindow-choice-noneTT"));
			addEntry(new EventChoiceYupIcon(), _form, Label.getLabel("editWindow-choice-yupTT"));
		}
		
		/**
		 * Builds the form
		 */
		private function buildForm():void {
			_form = new Sprite();
			_label = _form.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_label.text = Label.getLabel("editWindow-choice-help");
			_label.width = _width;
			_choice1 = _form.addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, "1"))) as InputKube;
			_choice2 = _form.addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, "2"))) as InputKube;
			_choice3 = _form.addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, "3"))) as InputKube;
			
			_choice1.textfield.maxChars = 
			_choice2.textfield.maxChars = 
			_choice3.textfield.maxChars = 50;
			
			_choice1.width = 
			_choice2.width = 
			_choice3.width = _width - 10;
			
			_choice1.x = 
			_choice2.x = 
			_choice3.x = 11;
			
			PosUtils.vPlaceNext(5, _label, _choice1, _choice2, _choice3);
			
			_form.graphics.beginFill(0xCA4F4F, 1);
			_form.graphics.drawRect(0, _choice1.y, 10, _choice1.height);
			_form.graphics.endFill();
			
			_form.graphics.beginFill(0xDD7600, 1);
			_form.graphics.drawRect(0, _choice2.y, 10, _choice2.height);
			_form.graphics.endFill();
			
			_form.graphics.beginFill(0xDDDD00, 1);
			_form.graphics.drawRect(0, _choice3.y, 10, _choice3.height);
			_form.graphics.endFill();
		}
		
	}
}