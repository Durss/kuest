package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.player.utils.sortByPosition;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 sept. 2013;
	 */
	public class TreeManager {
		
		private var _nodeToTreeID:Dictionary;
		private var _treeIDToPriorities:Dictionary;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TreeManager</code>.
		 */
		public function TreeManager() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(nodeToTreeID:Dictionary):void {
			_nodeToTreeID = nodeToTreeID;
			_treeIDToPriorities = new Dictionary();
		}
		
		/**
		 * Gets if an event is accessible.
		 * Checks if its current tree has a priority and if the priority matches
		 * the event.
		 */
		public function isEventAccessible(event:KuestEvent):Boolean {
			var treeID:String = _nodeToTreeID[event];
			return _treeIDToPriorities[ treeID ] == event;
		}
		
		/**
		 * Gives the priority to an event.
		 * If an event already has the priority on the same place the new one
		 * will be added next to it. The old one will have a higher priority.
		 * 
		 * @param events						events to be given priority
		 * @param comparePositionWithCurrent	if true and only 1 event is given, it will compare the current priorities and set the new one as prioritary only if its box is placed at a higher left/top position.
		 */
		public function givePriorityTo(events:Vector.<KuestEvent>, comparePositionWithCurrent:Boolean = false):void {
			var i:int, len:int, treeID:String;
			
			//If compare mode is enabled, the current priorities of the tree will be compared
			//by position to the new event. If the new event is more at left nor top than
			//all the current priorities, it will override them and be the new priority.
			if(events.length == 1 && comparePositionWithCurrent) {
				var event:KuestEvent = event[0];
				treeID = _nodeToTreeID[ event ];
				var priorities:Vector.<KuestEvent> = _treeIDToPriorities[ treeID ] as Vector.<KuestEvent>;
				len = priorities.length;
				var isPriority:Boolean = true;
				for(i = 0; i < len; ++i) {
					//If the event has been specified as the start of the tree by the user
					//Then it's more important, so the new one cannot override it.
					if(priorities[i].startsTree) {
						isPriority = false;
						break;
					}
					
					//If event hasn't a priority by position over this event, stop checking.
					if(sortByPosition(event, priorities[i]) > -1 ) {
						isPriority = false;
						break;
					}
				}
				if(isPriority) {
					_treeIDToPriorities[ treeID ] = events;
					return;
				}
			}
			
			
			
			//Here we could probably be satisfied with a simple
			//		_treeIDToPriorities[ _nodeToTreeID[ events[i] ] ] = events;
			//because the events are most probably all linked to the same event
			//and so are all part of the same tree.
			//But, just in case, we split the events by tree IDs and override the
			//corresponding priorities. 
			var treeIDsToEvents:Object = {};
			len = events.length;
			for(i = 0; i < len; ++i) {
				treeID = _nodeToTreeID[ events[i] ];
				if(treeIDsToEvents[treeID] == undefined) {
					treeIDsToEvents[treeID] = new Vector.<KuestEvent>();
				}
				Vector.<KuestEvent>(treeIDsToEvents[treeID]).push( events[i] );
			}
			
			//Store the priorities
			for (treeID in treeIDsToEvents) {
				_treeIDToPriorities[ treeID ] = treeIDsToEvents[ treeID ];
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}