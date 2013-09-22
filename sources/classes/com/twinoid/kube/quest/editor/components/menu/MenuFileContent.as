package com.twinoid.kube.quest.editor.components.menu {
	import gs.TweenLite;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.menu.file.FileForm;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;

	import flash.display.Sprite;
	import flash.events.Event;


	
	/**
	 * Displays main menu.
	 * Allows the user to log in or to save/load/etc.. his quests
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class MenuFileContent extends AbstractMenuContent {
		private var _spinning:LoaderSpinning;
		private var _formHolder:Sprite;
		private var _fileForm:FileForm;
		private var _tabIndex:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuFileContent</code>.
		 */

		public function MenuFileContent(width:int) {
			super(width);
			
			ViewLocator.getInstance().addEventListener(ViewEvent.LOGING_IN, loggingHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.LOGIN_SUCCESS, loginResultHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.LOGIN_FAIL, loginResultHandler);
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
			if(_fileForm == null) return;
			_fileForm.update(model);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize(event:Event):void {
			super.initialize(event);
			
			_title.text		= Label.getLabel("menu-file");
			_formHolder		= _holder.addChild(new Sprite()) as Sprite;
			_spinning		= _holder.addChild(new LoaderSpinning()) as LoaderSpinning;
			_fileForm		= new FileForm(_width * .9);
			
			_fileForm.tabIndex = _tabIndex;
			
			_fileForm.addEventListener(Event.RESIZE, computePositions);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			_spinning.x = Math.round(_width * .5);
			_spinning.y = 50;
			
			_fileForm.x = Math.round((_width - _fileForm.width) * .5);
			
			super.computePositions(event);
		}
		
		/**
		 * Called when application is trying to log in
		 */
		private function loggingHandler(event:ViewEvent):void {
			_spinning.open(Label.getLabel("loader-login"));
		}
		
		/**
		 * Called when server responds.
		 */
		private function loginResultHandler(event:ViewEvent):void {
			if(event.type == ViewEvent.LOGIN_SUCCESS) {
				_spinning.close(Label.getLabel("loader-loginOK"));
				_formHolder.addChild(_fileForm);
				_fileForm.alpha = 0;
				TweenLite.to(_fileForm, .25, {alpha:1, delay:.15});
			}else{
				_spinning.close(Label.getLabel("loader-loginKO"));
			}
		}
		
	}
}