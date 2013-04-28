package com.twinoid.kube.quest.components.menu.file {
	import flash.utils.Dictionary;
	import com.twinoid.kube.quest.vo.ToolTipAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.events.ToolTipEvent;
	import com.twinoid.kube.quest.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.graphics.LoadBmp;
	import com.twinoid.kube.quest.graphics.SaveBmp;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class FileForm extends Sprite {
		
		private var _width:int;
		private var _saveBt:GraphicButtonKube;
		private var _loadBt:GraphicButtonKube;
		private var _componentToTTID:Dictionary;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileForm</code>.
		 */

		public function FileForm(width:int) {
			_width = width;
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
			_saveBt = addChild(new GraphicButtonKube(new Bitmap(new SaveBmp(NaN, NaN)))) as GraphicButtonKube;
			_loadBt = addChild(new GraphicButtonKube(new Bitmap(new LoadBmp(NaN, NaN)))) as GraphicButtonKube;
			
			_saveBt.width = _loadBt.width = 
			_saveBt.height = _loadBt.height = _width * .48;
			
			_componentToTTID = new Dictionary();
			_componentToTTID[_saveBt] = "file-saveTT";
			_componentToTTID[_loadBt] = "file-loadTT";
			
			addEventListener(MouseEvent.MOUSE_OVER, rollHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_saveBt.x = _width - _saveBt.width;
		}
		
		/**
		 * Called when a component is rolled over.
		 */
		private function rollHandler(event:MouseEvent):void {
			var labelID:String = _componentToTTID[event.target];
			if(labelID != null) {
				EventDispatcher(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel(labelID), ToolTipAlign.TOP));
			}
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _saveBt) {
				
			}else
			if(event.target == _loadBt) {
				
			}
		}
		
	}
}