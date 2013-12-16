package com.twinoid.kube.quest.player.components {
	import com.nurun.components.button.visitors.applyDefaultFrameVisitor;
	import com.twinoid.kube.quest.graphics.DeleteIcon;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 déc. 2013;
	 */
	public class HistoryFavoritesTileItem extends HistoryTileItem {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>HistoryFavoritesTileItem</code>.
		 */
		public function HistoryFavoritesTileItem() {
			super();
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
		override protected function initialize():void {
			super.initialize();
			_favBt.icon = new DeleteIcon();
			applyDefaultFrameVisitor(_favBt, _favBt.icon);
		}
		
		/**
		 * Called when the component is clicked.
		 */
		override protected function clickHandler(event:MouseEvent):void {
			if(event.target == _favBt) {
				DataManager.getInstance().removeFromFavorites(_data);
			}else{
				DataManager.getInstance().simulateEvent(_data);
			}
		}
		
	}
}