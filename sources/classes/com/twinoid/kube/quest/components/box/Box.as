package com.twinoid.kube.quest.components.box {
	import com.twinoid.kube.quest.controler.FrontControler;
	import flash.events.MouseEvent;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.BoxEventGraphic;
	import com.nurun.components.text.CssTextField;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class Box extends Sprite {
		
		private var _data:KuestEvent;
		private var _label:CssTextField;
		private var _image:Bitmap;
		private var _background:BoxEventGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Box</code>.
		 */

		public function Box(data:KuestEvent = null) {
			_data = data;
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
			_background	= addChild(new BoxEventGraphic()) as BoxEventGraphic;
			_label		= addChild(new CssTextField()) as CssTextField;
			_image		= addChild(new Bitmap()) as Bitmap;
			
			if(_data != null && _data.position != null) {
				x = _data.position.x;
				y = _data.position.y;
			}
			
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Called when mouse goes over the component
		 */
		private function rollOverHandler(event:MouseEvent):void {
			cacheAsBitmap = false;
		}
		
		/**
		 * Called when mouse goes out the component.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			cacheAsBitmap = true;//TODO check if that's a suficient optimization. If not, remove everything from holder and replace it by a bitmap snapshot
		}
		
		/**
		 * Called when the component is clicked to open the edition view
		 */
		private function clickHandler(event:MouseEvent):void {
			FrontControler.getInstance().edit(_data);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}