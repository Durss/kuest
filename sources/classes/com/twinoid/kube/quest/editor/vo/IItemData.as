package com.twinoid.kube.quest.editor.vo {
	import flash.events.IEventDispatcher;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * @author Francois
	 */
	public interface IItemData extends IEventDispatcher {
		
		function get guid():int;
		
		function set guid(value:int):void;
		
		function get name():String;
		
		function set name(value:String):void;
		
		function get image():SerializableBitmapData;
		
		function set image(value:SerializableBitmapData):void;
		
		function isKilled():Boolean;
		
		function kill():void;
		
	}
}
