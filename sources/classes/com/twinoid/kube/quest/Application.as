package com.twinoid.kube.quest {
	import com.twinoid.kube.quest.views.SideMenuView;
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TransformAroundCenterPlugin;
	import gs.plugins.TweenPlugin;
	import gs.plugins.VisiblePlugin;

	import com.muxxu.kub3dit.graphics.KeyFocusGraphics;
	import com.nurun.components.button.AbstractNurunButton;
	import com.nurun.components.button.focus.NurunButtonKeyFocusManager;
	import com.nurun.components.form.Input;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.views.BackgroundView;
	import com.twinoid.kube.quest.views.BoxesView;
	import com.twinoid.kube.quest.views.EditBoxView;
	import com.twinoid.kube.quest.views.ToolTipView;

	import flash.display.MovieClip;
	import flash.events.Event;



	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author francois.dursus
	 * @date 3 mai 2012;
	 */
	 
	[SWF(width="1280", height="900", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="com.twinoid.kube.quest.ApplicationLoader")]
	public class Application extends MovieClip {
		private var _model:Model;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Application() {
			initialize();
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
		private function initialize():void {
			TweenPlugin.activate([TransformAroundCenterPlugin, RemoveChildPlugin, VisiblePlugin]);
			
			_model = new Model();
			
			ViewLocator.getInstance().initialise(_model);
			FrontControler.getInstance().initialize(_model);
			
			addChild(new BackgroundView());
			addChild(new BoxesView());
			addChild(new EditBoxView());
			addChild(new SideMenuView());
			addChild(new ToolTipView());
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when stage is available
		 */
		private function addedToStageHandler(event:Event):void {
			var types:Array = [AbstractNurunButton, CssTextField, Input];
			NurunButtonKeyFocusManager.getInstance().initialize(stage, new KeyFocusGraphics(), types);
			addChild(NurunButtonKeyFocusManager.getInstance());
			stage.stageFocusRect = false;
			
			_model.start();
		}
		
	}
}