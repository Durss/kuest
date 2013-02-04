package com.twinoid.kube.quest.utils {
	import com.twinoid.kube.quest.events.ToolTipEvent;

	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	/**
	 * Applies a tooltip to a specific target.
	 * The tooltip is displayed when the component is rolled over
	 * 
	 * @author Francois
	 * 
	 * @see com.twinoid.kube.quest.views.ToolTipView
	 */
	public function setToolTip(target:InteractiveObject, label:String, align:String = "br"):void {
		//See ToolTipView to understand where this ToolTipEvent goes !
		target.addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void { InteractiveObject(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, align)); });
		target.addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void { InteractiveObject(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.CLOSE)); });
	}
}
