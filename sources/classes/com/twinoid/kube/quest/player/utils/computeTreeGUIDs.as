package com.twinoid.kube.quest.player.utils {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	/**
	 * @author Francois
	 */
	public function computeTreeGUIDs(nodes:Vector.<KuestEvent>, tree:Dictionary, completeCallback:Function):void {
		var len:int, pointer:int, _guid:int, nodeToPointer:Dictionary, nodeToCallback:Dictionary;
//		tree = new Dictionary();
		nodeToPointer = new Dictionary();
		nodeToCallback = new Dictionary();
		len = nodes.length;
		
		function nextEvent():void {
			pointer++;
			var callback:Function = (pointer == (len - 1))? onComplete : nextEvent;
			nodeToCallback[nodes[pointer]] = callback;
//			trace("next event "+nodes[pointer].guid)
			setChildrenTo(nodes[pointer], _guid++, getTimer());
		}
		pointer = -1;
		nextEvent();
		
		function setChildrenTo(node:KuestEvent, guid:int, safeTimer:int, parents:Vector.<KuestEvent> = null, isDelayed:Boolean = false):Boolean {
			if(getTimer() - safeTimer > 500 && !isDelayed) {
//				trace("                delay "+node.guid, parents.length, getTimer())
				setTimeout(setChildrenTo, 40, node, guid, getTimer() + 40, parents, true);
				return false;
			}
			var pLoc:Vector.<KuestEvent>;
			
			var children:Vector.<KuestEvent> = node.getChildren();
			var lenR:int = children.length;
			if(nodeToPointer[node] == undefined) nodeToPointer[node] = 0;
			if(tree[node] == undefined || nodeToPointer[node] < lenR-1) {
				
				tree[node] = guid;
				
				var i:int = nodeToPointer[node];
//				trace(node.guid+"="+guid+"	", i, lenR);
				pLoc =  parents == null? new Vector.<KuestEvent>() : parents.concat();//Clone it
				pLoc.push(node);
				for(; i < lenR; i++) {
					nodeToPointer[node] = i;
					if(tree[children[i]] == undefined) {
//						trace("      ch : "+children[i].guid)
						if(!setChildrenTo(children[i], guid, safeTimer, pLoc)) return false;
					}
				}
			}
			
			if(nodeToCallback[node] != undefined && (parents == null || parents.length == 0)) {
//				trace("callback " + node.guid)
				nodeToCallback[node]();
				return false;
			}
			if(isDelayed && parents != null && parents.length > 0){
				pLoc =  parents.concat();//Clone it
				var parent:KuestEvent = pLoc.pop();
//				trace("relaunch : "+node.guid, guid, parent.guid);
				setChildrenTo(parent, guid, safeTimer, pLoc);
			}
			return true;
		}
		
		function onComplete():void {
//			trace("COMPLETE !")
			completeCallback();
		}
	}
}
