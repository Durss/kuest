package com.twinoid.kube.quest.player.utils {
	import flash.external.ExternalInterface;
	/**
	 * Resizes the SWF file to a specific height.
	 * 
	 * @author Francois
	 */
	public function resizeFlashTo(height:int):void {
		if(ExternalInterface.available) {
			ExternalInterface.call("resizeSWF", height);
		}
	}
}
