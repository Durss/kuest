package com.twinoid.kube.quest.editor.vo {
	import com.twinoid.kube.quest.editor.events.BoxEvent;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	/**
	 * Contains the data about a todo.
	 * Todos can be added by pressing the mouse left button half a second on the grid.
	 * 
	 * @author Durss
	 */
	public class TodoData extends EventDispatcher{
		
		//Too lazy to do a clean class :(
		
		public var pos:Point = new Point();
		public var text:String = '';
		
		
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[TodoData :: pos="+pos+", text="+text.substr(0, 15)+"...]";
		}
		
		public function searchForIt():void {
			dispatchEvent(new BoxEvent(BoxEvent.SEARCH_TODO, 0, true));
		}
		
		public function TodoData() { }
	}
}
