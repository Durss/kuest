package com.twinoid.kube.quest.vo {
	import flash.events.IEventDispatcher;
	import flash.display.BitmapData;
	
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * @author Francois
	 */
	public interface IItemData extends IEventDispatcher {
		
		function get name():String;
		
		function get image():BitmapData;
		
		function kill():void;
		
	}
}
