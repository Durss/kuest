package com.twinoid.kube.quest.components.char {
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.utils.commands.BrowseForFileCmd;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.graphics.BrowseIcon;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Displays a character's face.
	 * If in browseMode, provides a way to select an image file on the
	 * user's hard drive by clicking on the component.
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class CharFace extends Sprite implements Disposable {
		
		private const WIDTH:int = 140;
		private const HEIGHT:int = 140;
		
		private var _browseMode:Boolean;
		private var _frame:Shape;
		private var _img:ImageResizer;
		private var _icon:BrowseIcon;
		private var _browseCmd:BrowseForFileCmd;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharFace</code>.
		 */

		public function CharFace(browseMode:Boolean = false) {
			_browseMode = browseMode;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function get isDefined():Boolean {
			return _img.image != null;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_frame.graphics.clear();
			if(_browseMode) {
				_browseCmd.removeEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
				_icon.filters = [];
				removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_frame = addChild(new Shape()) as Shape;
			_frame.graphics.lineStyle(0, 0x2D89B0, 1);
			_frame.graphics.beginFill(0x7EC3DF, 1);
			_frame.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			_frame.graphics.endFill();
			
			if(_browseMode) {
				_browseCmd = new BrowseForFileCmd("Image", null, true);
				_browseCmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
				_icon = addChild(new BrowseIcon()) as BrowseIcon;
				_icon.filters = [new DropShadowFilter(4,135,0,.35,5,5,1,2)];
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, clickHandler);
			}
			
			_img = addChild(new ImageResizer()) as ImageResizer;
			_img.width = WIDTH;
			_img.height = HEIGHT;
			
			computePositions();
		}
		
		/**
		 * Called when the component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			_browseCmd.execute();
		}
		
		/**
		 * Called when an image's loading completes
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			_img.setImage(new Bitmap(event.data as BitmapData));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.centerIn(_icon, _frame);
		}
		
	}
}