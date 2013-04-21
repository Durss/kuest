package com.twinoid.kube.quest.components.selector {
	import com.nurun.components.text.CssTextField;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.components.item.ItemPlaceholder;
	import com.nurun.components.tile.ITileEngineItem2D;
	import com.nurun.components.tile.TileEngine2D;
	import com.nurun.core.lang.Disposable;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 avr. 2013;
	 */
	public class SelectorItem extends Sprite implements ITileEngineItem2D {
		
		public static const WIDTH:int = 140;
		public static const HEIGHT:int = 160;
		private var _image:ItemPlaceholder;
		private var _label:CssTextField;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SelectorItem</code>.
		 */
		public function SelectorItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component.
		 */
		public function populate(data:*, engineRef:TileEngine2D):void {
			var d:IItemData = data as IItemData;
			_image.image = d.image;
			_label.text = d.name;
			_label.y = WIDTH;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_image = addChild(new ItemPlaceholder()) as ItemPlaceholder;
			_label = addChild(new CssTextField("item-label")) as CssTextField;
			
			mouseChildren = false;
		}
		
	}
}