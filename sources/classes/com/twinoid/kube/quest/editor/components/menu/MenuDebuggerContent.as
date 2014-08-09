package com.twinoid.kube.quest.editor.components.menu {
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.menu.debugger.GameContextSimulatorForm;
	import com.twinoid.kube.quest.editor.components.menu.debugger.GameInventorySimulatorForm;
	import com.twinoid.kube.quest.editor.components.menu.debugger.KuestEventDisplay;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.MoneyIcon;
	import com.twinoid.kube.quest.player.events.QuestManagerEvent;
	import com.twinoid.kube.quest.player.model.QuestManager;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	/**
	 * Displays the debugger.
	 * 
	 * @author Francois
	 * @date 16 sept. 2013;
	 */
	public class MenuDebuggerContent extends AbstractMenuContent {
		
		private var _questManager:QuestManager;
		private var _header:CssTextField;
		private var _selectStart:CssTextField;
		private var _spin:LoaderSpinning;
		private var _eventDisplay:KuestEventDisplay;
		private var _splitter:DisplayObject;
		private var _simulator:GameContextSimulatorForm;
		private var _tabIndex:int;
		private var _inventory:GameInventorySimulatorForm;
		private var _money:BaseButton;
		private var _model:Model;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuDebuggerContent</code>.
		 */
		public function MenuDebuggerContent(width:int) {
			super(width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			_tabIndex = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(model:Model):void {
			super.update(model);
			_model = model;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize(event:Event):void {
			super.initialize(event);
			_questManager	= new QuestManager();
			_selectStart	= addChild(new CssTextField('menu-debug-selectStart')) as CssTextField;
			_splitter		= _holder.addChild(createRect(0xff2D89B0, _width, 1));
			_header			= _holder.addChild(new CssTextField('menu-label')) as CssTextField;
			_spin			= _holder.addChild(new LoaderSpinning()) as LoaderSpinning;
			_money			= new BaseButton('0', 'buttonBig', null, new MoneyIcon());
			_inventory		= new GameInventorySimulatorForm(_width - 10);
			_simulator		= new GameContextSimulatorForm(_width - 10);
			_eventDisplay	= new KuestEventDisplay(_width - 10);
			
			_simulator.tabIndex	= _tabIndex;
			_title.text			= Label.getLabel('menu-debug-title');
			_header.text		= Label.getLabel('menu-debug-header');
			_selectStart.text	= Label.getLabel('menu-debug-selectStart');
			_money.iconAlign	= IconAlign.LEFT;
			_money.textAlign	= TextAlign.LEFT;
			
			setToolTip(_money, Label.getLabel("player-moneyTT"), ToolTipAlign.TOP_RIGHT);
			
			_eventDisplay.addEventListener(Event.SELECT, answerHandler);
			_questManager.addEventListener(QuestManagerEvent.READY, questTestReadyHandler);
			_questManager.addEventListener(QuestManagerEvent.MONEY_UPDATE, moneyUpdateHandler);
			_questManager.addEventListener(QuestManagerEvent.NEW_EVENT, questTestNewEventHandler);
			_simulator.addEventListener(FormComponentEvent.SUBMIT, submitSimulatorHandler);
			_inventory.addEventListener(Event.SELECT, selectObjectHandler);
			addEventListener(Event.ADDED_TO_STAGE, openHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, closeHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.DEBUG_START_POINT, debugStartHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			if(stage == null) return;
			
			_header.width = _width - 15;
			_selectStart.width = _width - 15;
			_eventDisplay.x = 5;
			_money.x = 5;
			_simulator.x = 5;
			_inventory.x = 5;
			
			var offsetY:int = _title.height + _header.height + 15;
			_selectStart.y = (stage.stageHeight - offsetY - _selectStart.height) * .5 + offsetY;
			if(_selectStart.y < offsetY) _selectStart.y = offsetY;
			_selectStart.x = (_width - _selectStart.width) * .5;
			
			_spin.x = _width * .5;
			_spin.y = _header.height + _spin.height;
			
			_splitter.y		= Math.round(_header.y + _header.height) + 5;
			_simulator.y	= Math.round(_splitter.y + _splitter.height) + 5;
			_inventory.y	= Math.round(_simulator.y + _simulator.height) + 5;
			_money.y		= Math.round(_inventory.y + _inventory.height) + 5;
			_eventDisplay.y	= Math.round(_money.y + _money.height) + 10;
			
			roundPos(_selectStart, _spin, _eventDisplay, _splitter, _inventory, _simulator, _money);
			
			super.computePositions(event);
			if(event == null) dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Called when debug menu is opened
		 */
		private function openHandler(event:Event):void {
			FrontControler.getInstance().setDebugMode(true);
			_questManager.clearProgression();
			_spin.open(Label.getLabel('loader-parsingDebug'));
			_questManager.loadData(_model.kuestData.nodes, _model.kuestData.objects, null, new Date().getTime(), false, true);
			_eventDisplay.clear();
		}

		/**
		 * Called when debug menu is closed
		 */
		private function closeHandler(event:Event):void {
			_selectStart.visible = true;
			if(_holder.contains(_eventDisplay))	_holder.removeChild(_eventDisplay);
			if(_holder.contains(_simulator))	_holder.removeChild(_simulator);
			if(_holder.contains(_inventory))	_holder.removeChild(_inventory);
			if(_holder.contains(_money))		_holder.removeChild(_money);
			_eventDisplay.clear();
			_money.text = '0';
			FrontControler.getInstance().setDebugMode(false);
		}
		
		/**
		 * Called when simulation form is submitted
		 */
		private function submitSimulatorHandler(event:FormComponentEvent):void {
			_questManager.setCurrentPosition(_simulator.coordinates, _simulator.date);
		}
		
		/**
		 * Called when quest parsing completes
		 */
		private function questTestReadyHandler(event:QuestManagerEvent):void {
			setTimeout(_spin.close, 1000, Label.getLabel('loader-parsingDebugOK'));
		}
		
		/**
		 * Called when start point is defined by the user
		 */
		private function debugStartHandler(event:ViewEvent):void {
			_selectStart.visible = false;
			_holder.addChild(_money);
			_holder.addChild(_eventDisplay);
			_holder.addChild(_inventory);
			_holder.addChild(_simulator);
			computePositions();
//			_questManager.clearProgression();//Do not clear, source of missunderstanding when money is cleared
			_questManager.forceEvent(event.data as KuestEvent);
			_inventory.populate(_questManager.inventory);
		}
		
		/**
		 * Called when a new event is available
		 */
		private function questTestNewEventHandler(event:QuestManagerEvent):void {
			if(_questManager.currentEvent!= null) {
				_questManager.currentEvent.activateOnEditor();
			}
			_eventDisplay.populate(_questManager.currentEvent, _questManager.money);
			_inventory.populate(_questManager.inventory);
			computePositions();
		}
		
		/**
		 * Called when the user answers a choice
		 */
		private function answerHandler(event:Event):void {
			if(!_questManager.completeEvent(_eventDisplay.selectedAnswerIndex, true, _eventDisplay.textualAnswer)) {
				_eventDisplay.flashErrorInput();
			}
		}
		
		/**
		 * Called when an object is selected
		 */
		private function selectObjectHandler(event:Event):void {
			_questManager.useObject(_inventory.objectUsed, false);
		}
		
		/**
		 * Called when money value changes
		 */
		private function moneyUpdateHandler(event:QuestManagerEvent):void {
			_money.text = _questManager.money.toString();
		}
		
	}
}