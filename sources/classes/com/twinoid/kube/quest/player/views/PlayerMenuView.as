package com.twinoid.kube.quest.player.views {
	import treefortress.sound.SoundAS;

	import com.muxxu.kub3dit.graphics.RubberIcon;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.buttons.ToggleButtonKube;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.MoneyIcon;
	import com.twinoid.kube.quest.graphics.SoundCutIcon;
	import com.twinoid.kube.quest.graphics.SoundIcon;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Displays the menu (erase and sound buttons)
	 * 
	 * @author Francois
	 * @date 24 mai 2013;
	 */
	public class PlayerMenuView extends Sprite {
		
		private var _razBT:GraphicButtonKube;
		private var _soundBT:ToggleButtonKube;
		private var _prevUrl:String;
		private var _width:Number;
		private var _money:BaseButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuView</code>.
		 */
		public function PlayerMenuView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		


		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_razBT		= addChild(new GraphicButtonKube(new RubberIcon())) as GraphicButtonKube;
			_soundBT	= addChild(new ToggleButtonKube("", new SoundIcon(), new SoundCutIcon())) as ToggleButtonKube;
			_money		= addChild(new BaseButton('0', 'buttonBig', null, new MoneyIcon())) as BaseButton;
			
			_soundBT.iconAlign	= IconAlign.CENTER;
			_soundBT.textAlign	= TextAlign.CENTER;
			_money.tabEnabled	= false;
			_money.buttonMode	= false;
			_money.iconAlign	= IconAlign.LEFT;
			_money.textAlign	= TextAlign.LEFT;
			setToolTip(_razBT, Label.getLabel("player-resetTT"), ToolTipAlign.TOP_RIGHT);
			setToolTip(_money, Label.getLabel("player-moneyTT"), ToolTipAlign.TOP_RIGHT);
			
			moneyUpdateHandler(null);
			
			addEventListener(MouseEvent.CLICK, clickRAZHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.NEW_EVENT, newEventHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.MONEY_UPDATE, moneyUpdateHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, moneyUpdateHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_razBT.width		= _razBT.height = 
			_soundBT.width		= _soundBT.height = 19;
			_money.icon.scaleX	=
			_money.icon.scaleY	= 1;
			_money.icon.scaleX	=
			_money.icon.scaleY	= _soundBT.height / _money.icon.height;
			_money.validate();
			
			PosUtils.hPlaceNext(5, _razBT, _soundBT, _money);
			
			roundPos(_razBT, _soundBT);
		}

		/**
		 * Called when RAZ button is clicked
		 */
		private function clickRAZHandler(event:MouseEvent):void {
			if(event.target == _razBT) {
				DataManager.getInstance().clearProgression();
			}else if(event.target == _soundBT) {
				SoundAS.fadeAllTo(_soundBT.selected? 0 : 1);
			}
		}
		
		/**
		 * Called when a new event is available
		 */
		private function newEventHandler(event:DataManagerEvent):void {
			var e:KuestEvent = DataManager.getInstance().currentEvent;
			//If a new sound has to be played
			SoundAS.stopAll();
			if(e != null && e.actionSound != null && !isEmpty(e.actionSound.url) && e.actionSound.url != _prevUrl) {
				if(_soundBT.selected)	SoundAS.mute = true;
				else					SoundAS.mute = false;
				SoundAS.loadSound(e.actionSound.url, "music");
				if(e.actionSound.loop) {
					SoundAS.playLoop("music");
				}else{
					SoundAS.play("music");
				}
			}
		}
		
		/**
		 * Called when money updates
		 */
		private function moneyUpdateHandler(event:DataManagerEvent = null):void {
			_money.text = DataManager.getInstance().money.toString();
		}
		
	}
}