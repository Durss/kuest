package com.twinoid.kube.quest.editor.utils {
	import flash.external.ExternalInterface;
	/**
	 * @author Francois
	 */
	public function logJS(text:String):void {
		if(ExternalInterface.available) {
			ExternalInterface.call("console.log", text);
		}else{
			trace(text);
		}
	}
}
