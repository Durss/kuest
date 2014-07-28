package com.twinoid.kube.quest.player.utils {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	
	/**
	 * Sorts items by their position. The most at top/left first.
	 * 
	 * if the A event has a higher priority it will return -1 else it will return 1.
	 * 
	 * @return	-1 if the event A has a higher priority by position.
	 * 
	 * @author Francois
	 */
	public function sortByPosition(a:KuestEvent, b:KuestEvent):int {
			if(a.boxPosition.y < b.boxPosition.y) return -1;
			if(a.boxPosition.y == b.boxPosition.y) return a.boxPosition.x < b.boxPosition.x? - 1 : 1;
			if(a.boxPosition.y > b.boxPosition.y) return 1;
			return 0;
	}
}
