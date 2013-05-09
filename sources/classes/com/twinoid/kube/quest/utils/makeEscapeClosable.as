package com.twinoid.kube.quest.utils {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.InteractiveObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * Makes a component closable by hitting the escape key while having focus.
	 * If the component isn't focused, it will detect if th emouse is over it.
	 * If so, it will call the close method on it.
	 * 
	 * @author Francois
	 */
	public function makeEscapeClosable(target:Closable, priority:int = 0):void {
		if(!(target is DisplayObjectContainer)) throw new Error("target parameter must be a DisplayObjectContainer instance !");
		
		if(DisplayObjectContainer(target).stage == null) {
			DisplayObjectContainer(target).addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			function addedToStageHandler(event:Event):void {
				DisplayObjectContainer(target).stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, priority);
			}
		}else{
			DisplayObjectContainer(target).stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, priority);
		}
		
		function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode != Keyboard.ESCAPE) return;
			
			var f:InteractiveObject = DisplayObjectContainer(target).stage == null? null : DisplayObjectContainer(target).stage.focus;
			if(f == null) {
				if(!target.isClosed && DisplayObject(target).hitTestPoint(DisplayObject(target).stage.mouseX, DisplayObject(target).stage.mouseY, true)) {
					event.stopPropagation();
					event.stopImmediatePropagation();
					target.close();
				}
				return;
			}
			
			if(!target.isClosed) {
				event.stopPropagation();
				event.stopImmediatePropagation();
				target.close();
			}
		}
	}
}
