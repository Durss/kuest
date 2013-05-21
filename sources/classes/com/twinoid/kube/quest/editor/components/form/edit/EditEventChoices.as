package com.twinoid.kube.quest.editor.components.form.edit {
	import com.twinoid.kube.quest.editor.components.box.BoxLink;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.box.Box;
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
		private var _choices:Vector.<InputKube>;
		
		
		
		
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
					var i:int, len:int;
					len = _choices.length;
					for(i = 0; i < len; ++i) {
						if(StringUtils.trim(_choices[i].value as String).length > 0) data.actionChoices.addChoice(_choices[i].text);
					}
					break;
				default:
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			var i:int, len:int;
			len = _choices.length;
			for(i = 0; i < len; ++i) {
				_choices[i].text = _choices[i].defaultLabel;
			}
			selectedIndex = 0;
			
			if(data.actionChoices != null) {
				for(i = 0; i < len; ++i) {
					if (data.actionChoices.choices.length > i && data.actionChoices.choices[i].length > 0) {
						_choices[i].text = data.actionChoices.choices[0];
						selectedIndex = 1;
					}
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
			var i:int, len:int, py:int, colors:Array;
			len = Box.NUM_CHOICES;
			py = _label.height + 5;
			colors = BoxLink.COLORS;
			_choices = new Vector.<InputKube>();
			for(i = 0; i < len; ++i) {
				_choices[i] = _form.addChild(new InputKube(Label.getLabel("editWindow-choice-defaultText").replace(/\{I\}/gi, (i+1).toString()))) as InputKube;
				_choices[i].textfield.maxChars = 50;
				_choices[i].width = _width - 10;
				_choices[i].x = 11;
				_choices[i].y = py;
				py += _choices[i].height + 5;
				_form.graphics.beginFill(colors[i], 1);
				_form.graphics.drawRect(0, _choices[i].y, 10, _choices[i].height);
				_form.graphics.endFill();
			}
		}
		
	}
}