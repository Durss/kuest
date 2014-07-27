package com.twinoid.kube.quest.editor.components.form.edit {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.form.CheckBoxKube;
	import com.twinoid.kube.quest.editor.components.form.input.ComboboxKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.ActionMoney;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.EventChoiceYupIcon;
	import com.twinoid.kube.quest.graphics.HelpSmallIcon;
	import com.twinoid.kube.quest.graphics.MoneyIcon;

	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 16 déc. 2013;
	 */
	public class EditEventMoney extends AbstractEditZone {
		private var _holder:Sprite;
		private var _input:InputKube;
		private var _label:CssTextField;
		private var _helpBt:GraphicButtonKube;
		private var _icon:MoneyIcon;
		private var _rangeCombo:ComboboxKube;
		private var _rangeCb:CheckBoxKube;
		private var _rangeInput:InputKube;
		private var _rangeIcon:MoneyIcon;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventMoney</code>.
		 */
		public function EditEventMoney(width:int) {
			super(Label.getLabel('editWindow-money-title'), width, false);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			super.tabIndex		= value;
			_input.tabIndex		= value + 10;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configurations to the value object
		 */
		public function save(data:KuestEvent):void {
			var a:ActionMoney = new ActionMoney();
			a.kuborsEarned = _input.numValue;
			data.actionMoney = a;
			data.actionMoney.unlockConditionEnabled = _rangeCb.selected;
			if(_rangeCb.selected) {
				data.actionMoney.unlockCondition = _rangeCombo.selectedIndex;
				data.actionMoney.unlockValue = _rangeInput.numValue;
			}
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			if(data.actionMoney != null) {
				_input.text = data.actionMoney.kuborsEarned.toString();
				if(data.actionMoney.unlockConditionEnabled) {
					_rangeCb.selected = true;
					_rangeCombo.selectedIndex = data.actionMoney.unlockCondition;
					_rangeInput.text = data.actionMoney.unlockValue.toString();
				}else{
					_rangeCb.selected = false;
					_rangeCombo.selectedIndex = 0;
					_rangeInput.text = '0';
				}
			}else{
				_rangeCb.selected = false;
				_rangeCombo.selectedIndex = 0;
				_rangeInput.text = '0';
				_input.text = '0';
			}
			super.onload(true, 0);
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
			
			addEntry(new EventChoiceYupIcon(), _holder, '');
		}

		private function buildForm():void {
			_holder		= addChild(new Sprite()) as Sprite;
			_icon		= _holder.addChild(new MoneyIcon()) as MoneyIcon;
			_label		= _holder.addChild(new CssTextField('editWindow-label')) as CssTextField;
			_input		= _holder.addChild(new InputKube('?', true, -999999999, 999999999)) as InputKube;
			_helpBt		= _holder.addChild(new GraphicButtonKube(new HelpSmallIcon(), false)) as GraphicButtonKube;
			_rangeCb	= _holder.addChild(new CheckBoxKube(Label.getLabel('editWindow-money-range'), 'checkBox_fade')) as CheckBoxKube;
			_rangeCombo	= _holder.addChild(new ComboboxKube('', false, true)) as ComboboxKube;
			_rangeInput	= _holder.addChild(new InputKube('?', true, 0, 9999999999)) as InputKube;
			_rangeIcon	= _holder.addChild(new MoneyIcon()) as MoneyIcon;
			
			_label.text		= Label.getLabel('editWindow-money-label');
			_label.width	= _width;
			_input.text		= '0';
			_rangeInput.text= '0';
			_icon.scaleX = _icon.scaleY = 2;
			_rangeIcon.scaleX = _rangeIcon.scaleY = 2;
			_rangeCombo.labelRenderer = renderLabel;
			_rangeCombo.addSkinnedItem(Label.getLabel('editWindow-money-list-+'), 0);
			_rangeCombo.addSkinnedItem(Label.getLabel('editWindow-money-list--'), 1);
			_rangeCombo.addSkinnedItem(Label.getLabel('editWindow-money-list-='), 2);
			_rangeCombo.addSkinnedItem(Label.getLabel('editWindow-money-list-+='), 3);
			_rangeCombo.addSkinnedItem(Label.getLabel('editWindow-money-list--='), 4);
			_rangeCombo.selectedIndex = 0;
			_rangeCombo.enabled = false;
			_rangeCombo.listHeight = 300;
			_rangeCombo.width = 70;
//			_comboRange.list.scrollPane.vScroll['width'] = 0;
			_rangeInput.enabled = false;
			_rangeIcon.alpha = .4;
			
			_input.x		= _icon.x + _icon.width + 5;
			_input.width	= _rangeInput.width = Math.min(100, _width - _input.x - _helpBt.width - 5);
			_helpBt.x		= _input.x + _input.width + 5;
			
			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, _label.height, _icon, _input, _helpBt);
			
			_rangeCb.y		= _icon.y + _icon.height + 20;
			_rangeCb.width	= _width - _rangeCb.x - 2;
			_rangeCombo.x	= 20;
			_rangeCombo.y	= _rangeCb.y + _rangeCb.height;
			_rangeCombo.listWidth = _width - _rangeCombo.x;
			_rangeInput.x	= _rangeCombo.x + _rangeCombo.width + 5;
			_rangeInput.y	= _rangeCombo.y;
			_rangeInput.height= _rangeCombo.height;
			_rangeIcon.x	= _rangeInput.x + _rangeInput.width + 5;
			_rangeIcon.y	= _rangeInput.y + (_rangeInput.height - _rangeIcon.height) * .5;
			
			setToolTip(_helpBt, Label.getLabel('editWindow-money-helpTT'));
			
			roundPos(_icon, _label, _input, _helpBt, _rangeCb, _rangeCombo, _rangeInput, _rangeIcon);
			
			_holder.graphics.clear();
			_holder.graphics.beginFill(0x8BC9E2, 1);
			_holder.graphics.drawRect(0, _rangeCb.y - 10, _width, 1);
			_holder.graphics.endFill();
			
			_rangeCb.addEventListener(Event.CHANGE, changeCbHandler);
		}

		private function changeCbHandler(event:Event):void {
			_rangeCombo.enabled	= _rangeCb.selected;
			_rangeInput.enabled	= _rangeCb.selected;
			_rangeIcon.alpha = _rangeCb.selected ? 1 : .4;
		}

		private function renderLabel():void {
			var indexToLabel:Array = ['&gt;', '&lt;', '=', '&gt;=', '&lt;='];
			ButtonKube(_rangeCombo.button).label = indexToLabel[_rangeCombo.selectedIndex];
		}
		
	}
}