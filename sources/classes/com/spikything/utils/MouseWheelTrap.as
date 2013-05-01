package com.spikything.utils {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;

	/**
	 * MouseWheelTrap - Simultaneous browser/Flash mousewheel scroll issue work-around
	 * @version 0.1
	 * @author Liam O'Donnell
	 * @usage Simply call the static method MouseWheelTrap.setup(stage)
	 * @see http://www.spikything.com/blog/?s=mousewheeltrap for updates
	 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	 * (c) 2009 spikything.com
	 */
	public class MouseWheelTrap {
		static private var _mouseWheelTrapped:Boolean;
		private static var _stage:Stage;

		public static function setup(stage:Stage):void {
			_stage = stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function():void {
				allowBrowserScroll(false);
			});
			stage.addEventListener(Event.MOUSE_LEAVE, function():void {
				allowBrowserScroll(true);
			});
			if(ExternalInterface.available) {
				ExternalInterface.addCallback("onMouseWheel", onMouseWheel);
			}
		}

		private static function allowBrowserScroll(allow:Boolean):void {
			createMouseWheelTrap();
			if (ExternalInterface.available) {
				ExternalInterface.call("allowBrowserScroll", allow);
			}
		}

		private static function createMouseWheelTrap():void {
			if (_mouseWheelTrapped) {
				return;
			}
			_mouseWheelTrapped = true;
			if (ExternalInterface.available) {
				ExternalInterface.call("eval", "var browserScrolling;function allowBrowserScroll(value){browserScrolling=value;}function handle(delta){if(!browserScrolling){return false;}return true;}function wheel(event){var delta=0;if(!event){event=window.event;}if(event.wheelDelta){delta=event.wheelDelta/120;if(window.opera){delta=-delta;}}else if(event.detail){delta=-event.detail/3;}if(delta){handle(delta);}if(!browserScrolling){if(event.preventDefault){event.preventDefault();}event.returnValue=false;var flashs=document.getElementsByTagName('object');for(var i=0;i<flashs.length;++i){flashs[i].onMouseWheel(delta);}}}if(window.addEventListener){window.addEventListener('DOMMouseScroll',wheel,false);}window.onmousewheel=document.onmousewheel=wheel;allowBrowserScroll(true);");
			}
		}
		
		private static function onMouseWheel(delta:int):void {
			var objects:Array = _stage.getObjectsUnderPoint(new Point(_stage.mouseX, _stage.mouseY));
			var i:int, len:int, object:DisplayObject;
			len = objects.length;
			for(i = 0; i < len; ++i) {
				object = objects[i];
				object.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, object.mouseX, object.mouseY, null, false, false, false, false, delta));
			}
			
		}
	}
}