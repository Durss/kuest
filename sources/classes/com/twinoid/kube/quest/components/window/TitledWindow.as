package com.twinoid.kube.quest.components.window {
	import com.muxxu.kub3dit.graphics.PromptWindowGraphic;
	import com.nurun.components.text.CssTextField;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;

	
	/**
	 * Manages a window's rendering with a pre-skinned title and a custom content.
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class TitledWindow extends Sprite {
		
		private var _background:PromptWindowGraphic;
		private var _title:String;
		private var _content:DisplayObject;
		private var _titleTf:CssTextField;
		private var _width:Number;
		private var _forcedContentHeight:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TitledWindow</code>.
		 */
		public function TitledWindow(title:String, content:DisplayObject) {
			_content = content;
			_title = title;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the window's label
		 */
		public function set label(value:String):void {
			_titleTf.text = _title = value;
			computePositions();
		}
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _background.width; }
		
		/**
		 * Forces the window's width.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _background.height; }
		
		/**
		 * Gets the forced virtual content height
		 */
		public function get forcedContentHeight():Number { return _forcedContentHeight; }
		
		/**
		 * Forces a virtual content's height
		 */
		public function set forcedContentHeight(value:Number):void { _forcedContentHeight = value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Updates the sizes of the window.
		 * Call this method if the content's sizes change.
		 */
		public function updateSizes():void {
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_background = addChild(new PromptWindowGraphic()) as PromptWindowGraphic;
			_titleTf = addChild(new CssTextField("window-title")) as CssTextField;
			
			_titleTf.text = _title;
			_titleTf.filters = [new DropShadowFilter(3, 135, 0x2D89B0, 1, 1, 1, 10, 2)];
			
			addChild(_content);
			
			filters = [new DropShadowFilter(0,0,0,1,10,10,.4,2)];
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_titleTf.wordWrap = false;
			_titleTf.multiline = false;
			_titleTf.autoSize = TextFieldAutoSize.LEFT;
			
			var w:int = isNaN(_width)? _content.width : _width;
			var h:int = isNaN(_forcedContentHeight)? _content.height : _forcedContentHeight;
			
			_titleTf.width = w;
			_background.width = _titleTf.width + 15;
			_background.height = 52 + h;
			_titleTf.x = Math.round((_background.width - _titleTf.width) * .5);
			_titleTf.y = 3;
			_content.y = 40;
			_content.x = 10;
			// Math.round((_background.width - w) * .5);
		}
		
	}
}