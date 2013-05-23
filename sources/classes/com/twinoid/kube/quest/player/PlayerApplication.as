package com.twinoid.kube.quest.player {
	import com.twinoid.kube.quest.player.views.ActionSimulatorView;
	import gs.TweenLite;
	import gs.easing.Sine;
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TransformAroundCenterPlugin;
	import gs.plugins.TweenPlugin;
	import gs.plugins.VisiblePlugin;

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
	import com.twinoid.kube.quest.editor.views.ToolTipView;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;
	import com.twinoid.kube.quest.player.utils.resizeFlashTo;
	import com.twinoid.kube.quest.player.views.PlayerDefaultView;
	import com.twinoid.kube.quest.player.views.PlayerEventView;
	import com.twinoid.kube.quest.player.views.PlayerInventoryView;

	import org.libspark.ui.SWFWheel;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setInterval;

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
			
			TweenPlugin.activate([TransformAroundCenterPlugin, RemoveChildPlugin, VisiblePlugin]);
			var types:Array = [AbstractNurunButton, CssTextField, Input];
			NurunButtonKeyFocusManager.getInstance().initialize(stage, new KeyFocusGraphics(), types);
			addChild(NurunButtonKeyFocusManager.getInstance());
			stage.stageFocusRect = false;
			
			SWFWheel.initialize(stage);
			MouseWheelTrap.setup(stage);
			
			_spinning	= addChild(new LoaderSpinning()) as LoaderSpinning;
			_spinning.open(Label.getLabel("loader-loading"));
			_spinning.y	= _spinning.height * .5;
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
				_title		= addChild(new CssTextField("kuest-title")) as CssTextField;
				_holder		= addChild(new Sprite()) as Sprite;
				_mask		= addChild(createRect(0xffff0000)) as Shape;
				_default	= _holder.addChild(new PlayerDefaultView(stage.stageWidth - 20)) as PlayerDefaultView;
				_event		= _holder.addChild(new PlayerEventView(stage.stageWidth - 20)) as PlayerEventView;
				_inventory	= _holder.addChild(new PlayerInventoryView(stage.stageWidth - 20)) as PlayerInventoryView;
				if (Config.getBooleanVariable("testMode")) addChild(new ActionSimulatorView());
				addChild(new ToolTipView());
				addChild(new ExceptionView(true));
				
				_mask.height = 0;
				_holder.mask = _mask;
				_title.selectable = true;
				_title.text = Label.getLabel("player-loading-kuest");
				_title.filters = [new DropShadowFilter(2, 135, 0x265367, 1, 1, 1, 10, 2)];
				
				DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, loadQuestCompleteHandler);
				DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_ERROR, loadQuestErrorHandler);
				
				stage.addEventListener(Event.RESIZE, computePositions);
				computePositions();
			}
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
			var margin:int = 10;
			
			graphics.clear();
			graphics.beginFill(0x2D89B0, 1);
			graphics.drawRect(0, 0, stage.stageWidth, 30);
			graphics.endFill();
			
			_splitter.width		= stage.stageWidth - BackWindow.CELL_WIDTH * 2;
			_splitter.x			= BackWindow.CELL_WIDTH;
			_splitter.y			= 25;
			
			_holder.x = _mask.x = BackWindow.CELL_WIDTH + margin;
			_holder.y = _mask.y = _splitter.y + _splitter.height + margin;
			
			_background.x		= 0;
			_background.y		= 0;
			_background.width	= stage.stageWidth;
			var prevMaskHeight:int	= _mask.height;
			var prevBackHeight:int	= _background.height;
			if(event == null || event.target == stage) {
				_mask.height		= 0;
				_background.height	= Math.max(30, stage.stageHeight);
			}else{
				_mask.height		= DisplayObject(event.target).height;
				_background.height	= Math.max(30, _mask.y + _mask.height + margin + BackWindow.CELL_WIDTH);
			}
			
			_title.x		= 10;
			_title.width	= _background.width - 20;
			_mask.width		= _title.width;
			
			_spinning.y		= _spinning.height * .5 + 40;
			_spinning.x		= stage.stageWidth * .5;
			roundPos(_spinning);
			if(event == null || event.target != stage) {
				resizeFlashTo(_background.height);
				TweenLite.from(_mask, .35, {height:prevMaskHeight, ease:Sine.easeInOut});
				TweenLite.from(_background, .35, {height:prevBackHeight, ease:Sine.easeInOut});
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
			_title.text = DataManager.getInstance().title;
			setInterval(updateTime, 1000);
			updateTime();
			_spinning.close(Label.getLabel("loader-loadingOK"));
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