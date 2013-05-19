package com.twinoid.kube.quest.player.views {
	import com.nurun.components.text.CssTextField;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Sprite;
	import flash.events.Event;
	
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 19 mai 2013;
	 */
	public class PlayerDefaultView extends Sprite {
		
		private var _width:int;
		private var _tf:CssTextField;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerDefaultView</code>.
		 */

		public function PlayerDefaultView(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return visible? super.height : 0; }



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
			visible = false;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_COMPLETE, loadCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.NEW_EVENT, newEventHandler);
			_tf = addChild(new CssTextField("kuest-description")) as CssTextField;
			_tf.selectable = true;
		}
		
		/**
		 * Called when a new event is discovered
		 */
		private function newEventHandler(event:DataManagerEvent):void {
			var wasVisible:Boolean = visible;
			visible = false;
			if(wasVisible) dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Called when quest loading completes
		 */
		private function loadCompleteHandler(event:DataManagerEvent):void {
			if(DataManager.getInstance().currentEvent == null) {
				visible = true;
				_tf.text = DataManager.getInstance().description;
				_tf.width = _width;
				dispatchEvent(new Event(Event.RESIZE, true));
			}
		}
		
	}
}