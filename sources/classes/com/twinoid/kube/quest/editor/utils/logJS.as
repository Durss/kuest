package com.twinoid.kube.quest.editor.utils {
	import flash.external.ExternalInterface;
	/**
	 * @author Francois
	 */
	public function logJS(...args):void {
		if(ExternalInterface.available) {
			ExternalInterface.call("console.log", args.join(", "));
		}else{
			trace(args.join(", "));
		}
	}
}
