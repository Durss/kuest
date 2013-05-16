package com.twinoid.kube.quest.editor.utils {
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.CharItemData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	
	/**
	 * When data are deserialized from the ByteArray events dependencies are broken.
	 * Every object is actually cloned instead of having a pointer to the real one.
	 * 
	 * This method restores all the dependencies by looking at the GUIDs stored
	 * in every nodes.
	 * 
	 * Also, the characters and objects' references are stored as GUIDs to prevent
	 * from having multiple times the same BitmapData which would be a huge loss of
	 * size for nothing.
	 * This methods resets the links to the concrete IItem instance reference.
	 * 
	 * @author Francois
	 */
	public function restoreDependencies(items:Vector.<KuestEvent>, chars:Vector.<CharItemData>, objs:Vector.<ObjectItemData>):void {
		var i:int, len:int;
		var j:int, lenJ:int;
		var guidToVo:Array = [];
		var guidToChar:Array = [];
		var guidToObj:Array = [];
		
		len = chars.length;
		for(i = 0; i < len; ++i) guidToChar[chars[i].guid] = chars[i];
		len = objs.length;
		for(i = 0; i < len; ++i) guidToObj[objs[i].guid] = objs[i];
		
		len = items.length;
		for(i = 0; i < len; ++i) {
			if(guidToVo[items[i].guid] == undefined) {
				//New VO, register it
				guidToVo[items[i].guid] = items[i];
				if(items[i].actionType != null) {
					if(items[i].actionType.type == ActionType.TYPE_CHARACTER) {
						items[i].actionType.setItem( guidToChar[items[i].actionType.itemGUID] );
					}else
					if(items[i].actionType.type == ActionType.TYPE_OBJECT) {
						items[i].actionType.setItem( guidToObj[items[i].actionType.itemGUID] );
					}
				}
			}else{
				//VO already registered, load it from cache
				items[i] = guidToVo[items[i].guid];
			}
		}
		
		//Restore links dependencies
		for(i = 0; i < len; ++i) {
			lenJ = items[i].dependencies.length;
			for(j = 0; j < lenJ; ++j) {
				items[i].dependencies[j].event = guidToVo[ items[i].dependencies[j].event.guid ];
			}
		}
	}
}
