package com.twinoid.kube.quest.components.menu {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;

	import flash.events.Event;
	import flash.system.Capabilities;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 mai 2013;
	 */
	public class MenuCreditsContent extends AbstractMenuContent {
		private var _content:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuCreditsContent</code>.
		 */
		public function MenuCreditsContent(width:int) {
			super(width);
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
		override protected function initialize(event:Event):void {
			super.initialize(event);
			
			_label.text = Label.getLabel("menu-credits");
			_content = _holder.addChild(new CssTextField("menu-label")) as CssTextField;
			
			_content.selectable = true;
			if (Capabilities.playerType.toLowerCase() == "standalone") {
				//Correct relative image paths so that they also work in standalone
				//mode and i don't get errors every time i launch the app
				_content.text = Label.getLabel("menu-credits-content").replace(/src=\".\//gi, "src=\"../");
			}else{
				_content.text = Label.getLabel("menu-credits-content");
			}
			
			//Capture loading error on images of the textfield.
//			var matches:Array = _content.text.match(/id=".*?"/gi);
//			var id:String;;
//			for(var i:int = 0; i < matches.length; ++i) {
//				id = String(matches[i]).replace(/id="(.*)"/i, "$1");
//				var ldr:Loader = _content.getImageReference(id) as Loader;
//				if(ldr != null) {
//					ldr.addEventListener(IOErrorEvent.IO_ERROR, imageLoadingErrorHandler);
//				}
//			}
			
			computePositions();
		}

		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			var margin:int = 10;
			_content.width = _width - margin * 2;
			_content.x = margin;
			
			super.computePositions(event);
		}
		
	}
}