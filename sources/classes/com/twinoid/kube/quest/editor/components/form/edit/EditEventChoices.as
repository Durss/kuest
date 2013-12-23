package com.twinoid.kube.quest.editor.components.form.edit {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.box.Box;
	import com.twinoid.kube.quest.editor.components.box.BoxLink;
	import com.twinoid.kube.quest.editor.components.form.EventChoiceEntry;
	import com.twinoid.kube.quest.editor.vo.ActionChoices;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
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
		private var _choices:Vector.<EventChoiceEntry>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventChoices</code>.
		 */
		public function EditEventChoices(width:int) {
			super(Label.getLabel("editWindow-choice-title"), width, true);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			super.tabIndex			= value;
			var i:int, len:int;
			len = _choices.length;
			for(i = 0; i < len; ++i) {
				_choices[i].tabIndex = value + 10 + i;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configurations to the value object
		 */
		public function save(data:KuestEvent):void {
			if(!enabled) {
				data.actionChoices = new ActionChoices();
			}else{
				data.actionChoices = new ActionChoices();
				var i:int, len:int;
				len = _choices.length;
				for(i = 0; i < len; ++i) {
					if(StringUtils.trim(_choices[i].value as String).length > 0) {
						data.actionChoices.addChoice(_choices[i].text, _choices[i].choiceCost);
					}
				}
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			var i:int, len:int;
			len = _choices.length;
			for(i = 0; i < len; ++i) {
				_choices[i].reset();
			}
			
			if(data.actionChoices != null) {
				var enabled:Boolean;
				for(i = 0; i < len; ++i) {
					if (data.actionChoices.choices.length > i && data.actionChoices.choices[i].length > 0) {
						enabled = true;
						_choices[i].populate( data.actionChoices.choices[i], data.actionChoices.choicesCost[i] );
					}
				}
				super.onload(enabled, 0);
			}else{
				super.onload(false, 0);
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
			_choices = new Vector.<EventChoiceEntry>();
			for(i = 0; i < len; ++i) {
				_choices[i] = _form.addChild(new EventChoiceEntry(i, _width, colors[i])) as EventChoiceEntry;
				_choices[i].y = py;
				py += _choices[i].height + 5;
			}
		}
		
	}
}