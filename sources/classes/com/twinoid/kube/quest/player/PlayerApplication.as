package com.twinoid.kube.quest.player {
	import com.twinoid.kube.quest.player.views.EvaluateQuestView;
	import gs.TweenLite;
	import gs.easing.Sine;
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.ScrollRectPlugin;
	import gs.plugins.TransformAroundCenterPlugin;
	import gs.plugins.TweenPlugin;
	import gs.plugins.VisiblePlugin;

	import com.muxxu.kub3dit.graphics.CheckGraphic;
	import com.muxxu.kub3dit.graphics.KeyFocusGraphics;
	import com.nurun.components.button.AbstractNurunButton;
	import com.nurun.components.button.focus.NurunButtonKeyFocusManager;
	import com.nurun.components.form.Input;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.date.DateUtils;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.spikything.utils.MouseWheelTrap;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.window.BackWindow;
	import com.twinoid.kube.quest.editor.views.ExceptionView;
	import com.twinoid.kube.quest.editor.views.PromptWindowView;
	import com.twinoid.kube.quest.editor.views.ToolTipView;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;
	import com.twinoid.kube.quest.player.utils.resizeFlashTo;
	import com.twinoid.kube.quest.player.views.ActionSimulatorView;
	import com.twinoid.kube.quest.player.views.MenuView;
	import com.twinoid.kube.quest.player.views.PlayerDefaultView;
	import com.twinoid.kube.quest.player.views.PlayerEventView;
	import com.twinoid.kube.quest.player.views.PlayerInventoryView;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	 
	[SWF(width="800", height="200", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="com.twinoid.kube.quest.player.PlayerApplicationLoader")]
	public class PlayerApplication extends MovieClip {
		
		private var _spinning:LoaderSpinning;
		private var _background:BackWindow;
		private var _splitter:Splitter;
		private var _title:CssTextField;
		private var _loginBt:ButtonKube;
		private var _tf:CssTextField;
		private var _default:PlayerDefaultView;
		private var _event:PlayerEventView;
		private var _inventory:PlayerInventoryView;
		private var _holder:Sprite;
		private var _mask:Shape;
		private var _prompt:PromptWindowView;
		private var _check:CheckGraphic;
		private var _exception:ExceptionView;
		private var _menu:DisplayObject;
		private var _timeOutResize:uint;
		private var _evaluation:EvaluateQuestView;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function PlayerApplication() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



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
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			
			TweenPlugin.activate([TransformAroundCenterPlugin, RemoveChildPlugin, VisiblePlugin, ScrollRectPlugin]);
			var types:Array = [AbstractNurunButton, CssTextField, Input];
			NurunButtonKeyFocusManager.getInstance().initialize(stage, new KeyFocusGraphics(), types);
			addChild(NurunButtonKeyFocusManager.getInstance());
			stage.stageFocusRect = false;
			
			MouseWheelTrap.setup(stage);
			
			_spinning	= addChild(new LoaderSpinning()) as LoaderSpinning;
			_spinning.open(Label.getLabel("loader-loading"));
			_spinning.y	= stage.stageHeight * .5;
			_spinning.x	= stage.stageWidth * .5;
			roundPos(_spinning);
			resizeFlashTo(_spinning.height + 20);
			
			DataManager.getInstance().addEventListener(DataManagerEvent.ON_LOGIN_STATE, loginStateHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.NO_KUEST_SELECTED, noKuestHandler);
			DataManager.getInstance().initialize(onLoadProgress);
		}
		
		/**
		 * Called if no quest ID has be provide.
		 */
		private function noKuestHandler(event:DataManagerEvent):void {
			_spinning.close();
			_spinning.visible = false;
			resizeFlashTo(0);
		}
		
		/**
		 * Called when we know if the user is logged in or not
		 */
		private function loginStateHandler(event:DataManagerEvent):void {
			if(!DataManager.getInstance().logged) {
				_tf			= addChild(new CssTextField("kuest-login")) as CssTextField;
				_loginBt	= addChild(new ButtonKube(Label.getLabel("player-login"))) as ButtonKube;
				
				_tf.text	= Label.getLabel("player-loginTitle");
				_tf.width	= stage.stageWidth;
				
				PosUtils.hCenterIn(_loginBt, stage);
				PosUtils.vPlaceNext(5, _tf, _loginBt);
				_loginBt.addEventListener(MouseEvent.CLICK, clickLoginHandler);
				resizeFlashTo(_loginBt.y + _loginBt.height);
				_spinning.close();
				
			}else{
				
				_splitter	= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
				_background	= addChild(new BackWindow(false)) as BackWindow;
				_holder		= addChild(new Sprite()) as Sprite;
				_inventory	= addChild(new PlayerInventoryView(stage.stageWidth - BackWindow.CELL_WIDTH * 2 - 1)) as PlayerInventoryView;
				_evaluation	= addChild(new EvaluateQuestView(stage.stageWidth - BackWindow.CELL_WIDTH * 2 - 1)) as EvaluateQuestView;
				_title		= addChild(new CssTextField("kuest-title")) as CssTextField;
				_mask		= addChild(createRect(0xffff0000)) as Shape;
				_default	= _holder.addChild(new PlayerDefaultView(stage.stageWidth - 20 - BackWindow.CELL_WIDTH * 2)) as PlayerDefaultView;
				_event		= _holder.addChild(new PlayerEventView(stage.stageWidth - 20 - BackWindow.CELL_WIDTH * 2)) as PlayerEventView;
				_exception	= addChild(new ExceptionView(true)) as ExceptionView;
				
				_mask.height = 0;
				_holder.mask = _mask;
				_title.selectable = true;
				_title.text = Label.getLabel("player-loading-kuest");
				_title.filters = [new DropShadowFilter(2, 135, 0x265367, 1, 1, 1, 10, 2)];
				
				DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, loadQuestCompleteHandler);
				DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_ERROR, loadQuestErrorHandler);
				DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, clearProgressionCompleteHandler);
				
				stage.addEventListener(Event.RESIZE, computePositions);
				computePositions();
			}
			addChild(_spinning);
		}
		
		/**
		 * Called when progression is cleared.
		 */
		private function clearProgressionCompleteHandler(event:DataManagerEvent):void {
			if(_check == null) {
				_check = addChild(new CheckGraphic()) as CheckGraphic;
				_check.scaleX = _check.scaleY = 10;
				_check.filters = [new GlowFilter(0xffffffff, 1, 10, 10, 2, 2)];
				_check.addFrameScript(_check.totalFrames-1, onCheck);
			}
			_check.gotoAndStop(1);
			setTimeout(_check.gotoAndPlay, 200, 1);
			_check.alpha = 1;
			_check.visible = true;
			PosUtils.hCenterIn(_check, stage);
			_check.y = _splitter.y + _splitter.height + 10;
			computePositions();
		}

		private function onCheck():void {
			_check.stop();
			TweenLite.to(_check, .25, {autoAlpha:0, onComplete:computePositions});
		}
		
		/**
		 * Called when login button is clicked
		 */
		private function clickLoginHandler(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://muxxu.com/a/kuest"));
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(event != null && event.target == stage) return;
			
			var margin:int = 10;
			
			graphics.clear();
			graphics.beginFill(0x2D89B0, 1);
			graphics.drawRect(0, 0, stage.stageWidth, 30);
			graphics.endFill();
			
			_splitter.width		= stage.stageWidth - BackWindow.CELL_WIDTH * 2;
			_splitter.x			= BackWindow.CELL_WIDTH;
			_splitter.y			= 25;
			
			var prevHolderY:int	= _holder.y;
			_holder.x			= _mask.x = BackWindow.CELL_WIDTH + margin;
			_evaluation.x		= BackWindow.CELL_WIDTH + 1;
			_evaluation.y		= _splitter.y + _splitter.height;
			_holder.y = _mask.y = _evaluation.y + _evaluation.height + margin;
			
			_background.x			= 0;
			_background.y			= 0;
			_background.width		= stage.stageWidth;
			var prevMaskHeight:int	= _mask.height;
			var prevBackHeight:int	= _background.height;
			var items:Vector.<DisplayObject> = new <DisplayObject>[_default, _event, _prompt, _check];
			var i:int, len:int, h:int;
			len = items.length;
			for(i = 0; i < len; ++i) { if(items[i] != null && items[i].visible) h = Math.max(items[i].height, h); }
			
			if(_menu != null) {
				_menu.x = BackWindow.CELL_WIDTH + 2;
				_menu.width = stage.stageWidth - (BackWindow.CELL_WIDTH - 1) * 2;
			}
			
			_mask.height		= h;
			if(_prompt!=null && !_prompt.isClosed) h = Math.max(h, _prompt.height);
			if(_exception!=null && !_exception.isClosed) h = Math.max(h, _exception.height);
			h					= Math.max(50, _mask.y + h + margin + _inventory.height + BackWindow.CELL_WIDTH);
			_background.height	= h;

			var prevInventoryY:Number = _inventory.y;
			_inventory.x = BackWindow.CELL_WIDTH + 1;
			_inventory.y = _background.height - BackWindow.CELL_WIDTH - 2 - _inventory.height;

			var prevMenuY:Number;
			if (_menu != null) {
				prevMenuY = _menu.y;
//				_menu.y = _background.height - BackWindow.CELL_WIDTH - 2 - _menu.height;
				_menu.y = _inventory.y + _inventory.buttonHeight - _menu.height;
			}
			
			_title.x		= 10;
			_title.width	= _background.width - 20;
			_mask.width		= _title.width;
			
			_spinning.x		= stage.stageWidth * .5;
			_spinning.y		= _background.height * .5;
			roundPos(_spinning);
			
			if(event == null || event.target != stage) {
				clearTimeout(_timeOutResize);
				if(h < prevBackHeight) {
					_timeOutResize = setTimeout(resizeFlashTo, 100, h);
				}else{
					resizeFlashTo(h);
				}
				TweenLite.killTweensOf(_mask);
				TweenLite.killTweensOf(_background);
				TweenLite.killTweensOf(_inventory);
				TweenLite.killTweensOf(_menu);
				TweenLite.killTweensOf(_holder);
				TweenLite.killTweensOf(_mask);
				TweenLite.from(_mask, .35, {y:prevHolderY, height:prevMaskHeight, ease:Sine.easeInOut});
				TweenLite.from(_background, .35, {height:prevBackHeight, ease:Sine.easeInOut});
				TweenLite.from(_inventory, .35, {y:prevInventoryY, ease:Sine.easeInOut});
				TweenLite.from(_holder, .35, {y:prevHolderY, ease:Sine.easeInOut});
				if(_menu != null) {
					TweenLite.killTweensOf(_menu);
					TweenLite.from(_menu, .35, {y:prevMenuY, ease:Sine.easeInOut});
				}
			}
		}
		
		/**
		 * Called when loading progresses
		 */
		private function onLoadProgress(percent:Number):void {
			_spinning.label = Label.getLabel("loader-loading") + " " + Math.round(percent * 100) + "%";
		}

		
		/**
		 * Called when quest loading completes
		 */
		private function loadQuestCompleteHandler(event:DataManagerEvent):void {
			if (Config.getBooleanVariable("testMode")) addChild(new ActionSimulatorView());
			_prompt	= addChild(new PromptWindowView(true)) as PromptWindowView;
			_menu	= addChild(new MenuView());
			addChild(new ToolTipView());
			addChild(_exception);
			
			_title.text = DataManager.getInstance().title;
			_spinning.close(Label.getLabel("loader-loadingOK"));
			setInterval(updateTime, 1000);
			updateTime();
			
			computePositions();
		}
		
		/**
		 * Called if quest loading fails
		 */
		private function loadQuestErrorHandler(event:DataManagerEvent):void {
			_spinning.close(Label.getLabel("loader-loadingKO"));
		}
		
		/**
		 * Updates the date/time.
		 */
		private function updateTime():void {
			var date:String = DateUtils.format(DataManager.getInstance().currentDate, Config.getVariable("dateFormat"));
			_title.text = DataManager.getInstance().title + "<p class='kuest-date'><font size='5'><br /><br /></font>" + date + "</p>";
		}
		
	}
}