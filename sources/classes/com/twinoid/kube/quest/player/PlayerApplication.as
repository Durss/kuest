package com.twinoid.kube.quest.player {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.MovieClip;
	import flash.events.Event;

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
			
			DataManager.getInstance().initialize();
			
			_spinning = addChild(new LoaderSpinning()) as LoaderSpinning;
			_spinning.open(Label.getLabel("loader-loading"));
			
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions():void {
			_spinning.y = _spinning.height * .5;
			_spinning.x = stage.stageWidth * .5;
			roundPos(_spinning);
		}
		
	}
}