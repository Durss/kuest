package com.twinoid.kube.quest.editor.utils {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.vo.PromptData;
	
	/**
	 * Shortcut for prompting something.
	 * 
	 * @param titleID		Label's ID for the window's title
	 * @param contentID		Label's ID for the window's content
	 * @param callback		Function called when form is submitted
	 * @param id			Used to remember if a specific prompt should be ignore and automatically submitted
	 * 
	 * @author Francois
	 */
	public function prompt(titleID:String, contentID:String, callback:Function, id:String, cancelCallback:Function = null, canIgnore:Boolean = true):void {
		var data:PromptData = new PromptData(Label.getLabel(titleID), Label.getLabel(contentID), callback, id, cancelCallback, canIgnore);
		ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.PROMPT, data));
	}
}
