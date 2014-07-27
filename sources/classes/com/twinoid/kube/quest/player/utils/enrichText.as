package com.twinoid.kube.quest.player.utils {
	/**
	 * Puts coordinates in bold, makes links clikable and hglights "xx kubors" patterns
	 * 
	 * @author Durss
	 */
	public function enrichText(text:String):String {
		//Convert links to <a href> tags
		text = text.replace(/(https?:\/\/([-\w\.]+[-\w])+(:\d+)?(\/([\w\/_\.#-]*(\?\S+)?[^\.\s])?)?)/gi, '<a href="$1" target="_blank" class="link">$1</a>');
		//Put un bold following patterns :
		// (x)(y)
		// [x][y]
		// x;y
		// [x;y]
		// (x;y)
		// and some other more due to the regexp tolerence
		text = text.replace(/([\[\(]?-?[0-9]+([\[\];\)\( ]){1,3}-?[0-9]+[\];\)]?)/gi, '<span class="kuest-coordinates">$1</span>');
		text = text.replace(/[0-9]+ ?kubors?/gi, '<span class="kuest-kubors">$&</span>');
		return text;
	}
}
