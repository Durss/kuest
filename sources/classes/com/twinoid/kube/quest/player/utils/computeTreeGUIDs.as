package com.twinoid.kube.quest.player.utils {
	import com.twinoid.kube.quest.editor.vo.Dependency;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * Searches for trees and assigns tree IDs to every KuestEvent entry
	 * 
	 * @author Francois
	 */
	public function computeTreeGUIDs(nodes:Vector.<KuestEvent>, tree:Dictionary, completeCallback:Function, lowConsumption:Boolean = false, completeParams:Array = null):void {
		var len:int, pointer:int, _guid:int, nodeToPointerChildren:Dictionary, nodeToPointerParents:Dictionary;
		var durationMax:int = lowConsumption? 80 : 500;
		var rootNode:KuestEvent;
//		tree = new Dictionary();
		nodeToPointerChildren = new Dictionary();
		nodeToPointerParents = new Dictionary();
		len = nodes.length;
		
		function nextEvent():void {
			if(++pointer == len) {
				onComplete();
				return;
			}
			var callback:Function = (pointer == (len - 1))? onComplete : nextEvent;
//			trace("next event "+nodes[pointer].guid)
			rootNode = nodes[pointer];
			setChildrenTo(rootNode, _guid++, getTimer());
		}
		pointer = -1;
		nextEvent();
		
		function setChildrenTo(node:KuestEvent, treeID:int, safeTimer:int, isDelayed:Boolean = false):Boolean {
			if(getTimer() - safeTimer > durationMax && !isDelayed) {
//				trace("                delay "+node.guid, parents.length, getTimer())
				setTimeout(setChildrenTo, 40, node, treeID, getTimer() + 40, true);
				return false;
			}
			var pLoc:Vector.<KuestEvent>;
			
			//Parse children
			var children:Vector.<KuestEvent> = node.getChildren();
			var lenR:int = children.length;
			var isSet:Boolean = tree[node] != undefined;
			if(nodeToPointerChildren[node] == undefined) nodeToPointerChildren[node] = 0;
			
			if(!isSet || nodeToPointerChildren[node] < lenR-1) {
				tree[node] = treeID;
				var i:int = nodeToPointerChildren[node];
//				trace(node.guid+"="+guid+"	", i, lenR);
				for(; i < lenR; ++i) {
					nodeToPointerChildren[node] = i;
					if(tree[children[i]] == undefined) {
//						trace("      ch : "+children[i].guid)
						if(!setChildrenTo(children[i], treeID, safeTimer)) return false;
					}
				}
			}
			
			//Parse dependencies
			var dependencies:Vector.<Dependency> = node.getDependencies();
			var lenD:int = dependencies.length;
			if(nodeToPointerParents[node] == undefined) nodeToPointerParents[node] = 0;
			if(!isSet || nodeToPointerParents[node] < lenD-1) {
				tree[node] = treeID;
				i = nodeToPointerParents[node];
//				trace(node.guid+"="+guid+"	", i, lenD);
				for(; i < lenD; ++i) {
					nodeToPointerParents[node] = i;
					if(tree[dependencies[i].event] == undefined) {
//						trace("      ch : "+dependencies[i].event.guid)
						if(!setChildrenTo(dependencies[i].event, treeID, safeTimer)) return false;
					}
				}
			}

			if(node == rootNode) nextEvent();
			
			return true;
		}
		
		function onComplete():void {
//			trace("COMPLETE !")
			completeCallback.apply(this, completeParams);
		}
	}
}
