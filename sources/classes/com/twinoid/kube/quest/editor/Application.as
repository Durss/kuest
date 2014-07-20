package com.twinoid.kube.quest.editor {
	import gs.plugins.ScrollRectPlugin;
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
	import com.twinoid.kube.quest.editor.components.item.ItemPlaceholder;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.views.BackgroundView;
	import com.twinoid.kube.quest.editor.views.BoxDebugView;
	import com.twinoid.kube.quest.editor.views.BoxesView;
	import com.twinoid.kube.quest.editor.views.EditBoxView;
	import com.twinoid.kube.quest.editor.views.ExceptionView;
	import com.twinoid.kube.quest.editor.views.ItemSelectorView;
	import com.twinoid.kube.quest.editor.views.MagnifiedTextfield;
	import com.twinoid.kube.quest.editor.views.NotificationView;
	import com.twinoid.kube.quest.editor.views.PatchLogView;
	import com.twinoid.kube.quest.editor.views.PromptWindowView;
	import com.twinoid.kube.quest.editor.views.SideMenuView;
	import com.twinoid.kube.quest.editor.views.ToolTipView;
	import com.twinoid.kube.quest.editor.views.TutorialView;

	import org.libspark.ui.SWFWheel;

	import flash.display.InteractiveObject;
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
	 
	[SWF(width="1000", height="700", backgroundColor="0xBBDDEC", frameRate="31")]
	[Frame(factoryClass="com.twinoid.kube.quest.editor.ApplicationLoader")]
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
			TweenPlugin.activate([TransformAroundCenterPlugin, RemoveChildPlugin, VisiblePlugin, ScrollRectPlugin]);
			
			_model = new Model();
			
			ViewLocator.getInstance().initialise(_model);
			FrontControler.getInstance().initialize(_model);
			
			addChild(new BackgroundView());
			InteractiveObject(addChild(new BoxesView())).tabIndex = 0;
			InteractiveObject(addChild(new EditBoxView())).tabEnabled = false;
			InteractiveObject(addChild(new SideMenuView())).tabIndex = 10000;
			addChild(new ItemSelectorView());
			addChild(new TutorialView());
			addChild(new PatchLogView());
			addChild(new PromptWindowView());
			addChild(new ToolTipView());
			addChild(new BoxDebugView());
			addChild(new MagnifiedTextfield());
			addChild(new ExceptionView());
			addChild(NotificationView.getInstance());
//			addChild(new Stats());
			getChildAt(numChildren - 1).addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);//Wait for the views to be added to stage, not this view
		}
		
		/**
		 * Called when stage is available
		 */
		private function addedToStageHandler(event:Event):void {
			var types:Array = [AbstractNurunButton, CssTextField, Input, ItemPlaceholder];
			NurunButtonKeyFocusManager.getInstance().initialize(stage, new KeyFocusGraphics(), types);
			addChild(NurunButtonKeyFocusManager.getInstance());
			stage.stageFocusRect = false;
			
			SWFWheel.initialize(stage);
			
			_model.start();
		}
		
	}
}