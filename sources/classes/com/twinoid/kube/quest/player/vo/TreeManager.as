package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.player.utils.sortByPosition;

	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 sept. 2013;
	 */
	public class TreeManager {
		
		private var _nodeToTreeID:Dictionary;
		private var _treeIDToPriorities:Dictionary;
		private var _guidToEvent:Object;
		private var _treeIDToPriorities_backup:Dictionary;
		
		
		
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
		/**
		 * Sets the a fast GUID to KuestEvent accessor.
		 */
		public function set guidToEvent(value:Object):void {
			_guidToEvent = value;
			_guidToEvent[-1] = new KuestEvent(true);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(nodeToTreeID:Dictionary):void {
			_nodeToTreeID = nodeToTreeID;
			_treeIDToPriorities = new Dictionary();
			_treeIDToPriorities_backup = new Dictionary();
		}
		
		/**
		 * Gets if an event is accessible.
		 * Checks if its current tree has a priority and if the priority matches
		 * the event.
		 */
		public function isEventAccessible(event:KuestEvent):Boolean {
			var treeID:String = _nodeToTreeID[event];
			var i:int, len:int, isAccessible:Boolean, priorities:Vector.<KuestEvent>;
			priorities = _treeIDToPriorities[ treeID ];
			if(priorities == null) {
				return false;
			}
			len = priorities.length;
			for(i = 0; i < len; ++i) {
				if(priorities[i].guid == event.guid) {
					isAccessible = true;
					break;
				}
			}
			return isAccessible;
		}
		
		/**
		 * Gives the priority to an event.
		 * If an event already has the priority on the same place the new one
		 * will be added next to it. The old one will have a higher priority.
		 * 
		 * @param events						events to be given priority
		 * @param reference						contains the event the user comes from
		 * @param comparePositionWithCurrent	if true and only 1 event is given, it will compare the current priorities and set the new one as prioritary only if its box is placed at a higher left/top position.
		 * @param initMode						set to true on first quest' parsing. Creates a tree priorities backup to manage reset.
		 */
		public function givePriorityTo(events:Vector.<KuestEvent>, reference:KuestEvent = null, comparePositionWithCurrent:Boolean = false, initMode:Boolean = false):void {
			var i:int, len:int, treeID:String;
			
			//If compare mode is enabled, the current priorities of the tree will be compared
			//by position to the new event. If the new event is more at left nor top than
			//all the current priorities, it will override them and be the new priority.
			if(events.length == 1 && comparePositionWithCurrent) {
				var event:KuestEvent = events[0];
				treeID = _nodeToTreeID[ event ];
				var priorities:Vector.<KuestEvent> = _treeIDToPriorities[ treeID ] as Vector.<KuestEvent>;
				len = priorities == null?  0 : priorities.length;
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
					if(initMode) _treeIDToPriorities_backup[ treeID ] = events.concat();
				}
				return;
			}
			
			
			
			len = events.length;
			if (len == 0 && reference != null && reference.dependencies.length > 0) {
				//No children, clear the tree to end it.
				treeID = _nodeToTreeID[ reference ];
				//Sets an empty event as the next priority so that it can
				//never be reached and the tree never started again.
				_treeIDToPriorities[ treeID ] = new <KuestEvent>[_guidToEvent[-1]];
				return;
			}else{
				//Here we could probably be satisfied with a simple
				//		_treeIDToPriorities[ _nodeToTreeID[ events[i] ] ] = events;
				//because the events are most probably all linked to the same event
				//and so are all part of the same tree.
				//But, just in case, we split the events by tree IDs and override the
				//corresponding priorities. 
				var treeIDsToEvents:Object = {};
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
					if(initMode) _treeIDToPriorities_backup[ treeID ] = Vector.<KuestEvent>(treeIDsToEvents[ treeID ]).concat();
				}
			}
		}
		
		/**
		 * Exports the data as anonymous object ready to be stored to a ByteArray.
		 * These data will then be imported back with importData().
		 * It basically keeps the same structur but in anonymous arrays instead of
		 * dictionary and vectors. And it replaces the KuestEvent instances by
		 * their GUID.
		 * In the end we'll have something like this :
		 * 	[
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 	]
		 * 	
		 * 	Where guids are the KuesEvent's GUIDs.
		 */
		public function exportData(version:uint):Array {
			version;
			var data:Array = [];
			for (var treeID:* in _treeIDToPriorities) {
				var events:Vector.<KuestEvent> = _treeIDToPriorities[treeID];
				var i:int, len:int;
				len = events.length;
				data[treeID] = [];
				for(i = 0; i < len; ++i) {
					data[treeID][i] = events[i].guid;
				}
			}
			return data;
		}
		
		/**
		 * Imports data that have been previously exported by exportData() .
		 */
		public function importData(data:Array, version:uint):void {
			if(_guidToEvent == null) {
				throw new KuestException('TreeManager.initialize method must be called before importData !', 'TreeManager');
			}
			
			switch(version){
				case SaveVersion.V1:
					_treeIDToPriorities = new Dictionary();
					for (var treeID:* in data) {
						var vector:Vector.<KuestEvent> = new Vector.<KuestEvent>();
						var events:Array = data[treeID];
						var i:int, len:int;
						len = events.length;
						
						for(i = 0; i < len; ++i) {
							vector.push( _guidToEvent[data[treeID][i]] );
						}
						
						_treeIDToPriorities[treeID] = vector;
					}
					break;
				default:
			}
		}
		
		/**
		 * Resets the pointers to the defaults to restart the quest from scratch
		 */
		public function reset():void {
			_treeIDToPriorities = new Dictionary();
			//resets the trees priorities from backup or the quest logic would
			//be quite fucked up.
			for (var i:* in _treeIDToPriorities_backup) {
				_treeIDToPriorities[ i ] = Vector.<KuestEvent>(_treeIDToPriorities_backup[ i ]).concat();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}