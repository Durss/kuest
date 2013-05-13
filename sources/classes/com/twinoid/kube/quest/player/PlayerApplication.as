package com.twinoid.kube.quest.player {
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TransformAroundCenterPlugin;
	import gs.plugins.TweenPlugin;
	import gs.plugins.VisiblePlugin;

	import com.muxxu.kub3dit.graphics.KeyFocusGraphics;
	import com.nurun.components.button.AbstractNurunButton;
	import com.nurun.components.button.focus.NurunButtonKeyFocusManager;
	import com.nurun.components.form.Input;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.spikything.utils.MouseWheelTrap;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.window.BackWindow;
	import com.twinoid.kube.quest.editor.views.ExceptionView;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import org.libspark.ui.SWFWheel;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;

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
			
			DataManager.getInstance().initialize(onLoadProgress);
			
			_splitter	= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			_background	= addChild(new BackWindow(false)) as BackWindow;
			_spinning	= addChild(new LoaderSpinning()) as LoaderSpinning;
			_title		= addChild(new CssTextField("kuest-title")) as CssTextField;
			addChild(new ExceptionView());
			
			_title.text = Label.getLabel("player-loading-kuest");
			_title.filters = [new DropShadowFilter(2, 135, 0x265367, 1, 1, 1, 10, 2)];
			
			_spinning.open(Label.getLabel("loader-loading"));
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, loadQuestCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_ERROR, loadQuestErrorHandler);
			
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0x2D89B0, 1);
			graphics.drawRect(0, 0, stage.stageWidth, 30);
			graphics.endFill();
			
			_background.x		= 0;
			_background.y		= 0;
			_background.width	= stage.stageWidth;
			_background.height	= stage.stageHeight;
			
			_splitter.width		= stage.stageWidth - BackWindow.CELL_WIDTH * 2;
			_splitter.x			= BackWindow.CELL_WIDTH;
			_splitter.y			= 25;
			
			_title.x			= 10;
			
			_spinning.y			= _spinning.height * .5 + 40;
			_spinning.x			= stage.stageWidth * .5;
			roundPos(_spinning);
		}

		private function onLoadProgress(percent:Number):void {
			_spinning.label = Label.getLabel("loader-loading") + " " + Math.round(percent * 100) + "%";
		}

		
		/**
		 * Called when quest loading completes
		 */
		private function loadQuestCompleteHandler(event:DataManagerEvent):void {
			_title.text = DataManager.getInstance().title;
			_spinning.close(Label.getLabel("loader-loginOK"));
//			_title.text = DataManager.getInstance().kuest.
		}
		
		/**
		 * Called if quest loading fails
		 */
		private function loadQuestErrorHandler(event:DataManagerEvent):void {
			_spinning.close(Label.getLabel("loader-loginKO"));
		}
		
	}
}