package com.twinoid.kube.quest.player.model {
	import com.twinoid.kube.quest.player.utils.getPositionId;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.events.QuestManagerEvent;
	import com.twinoid.kube.quest.player.utils.computeTreeGUIDs;
	import com.twinoid.kube.quest.player.vo.InventoryManager;
	import com.twinoid.kube.quest.player.vo.InventoryObject;
	import com.twinoid.kube.quest.player.vo.PositionManager;
	import com.twinoid.kube.quest.player.vo.TimeAccessManager;
	import com.twinoid.kube.quest.player.vo.TreeManager;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	//Fired when a new event is available
	[Event(name="questManagerNewEvent", type="com.twinoid.kube.quest.player.events.QuestManagerEvent")]
	
	//Fired when the manager is ready and the quest can be start
	[Event(name="questManagerReady", type="com.twinoid.kube.quest.player.events.QuestManagerEvent")]
	
	//Fired when the inventory changes
	[Event(name="questManagerInventoryUpdate", type="com.twinoid.kube.quest.player.events.QuestManagerEvent")]
	
	//Fired when the history changes
	[Event(name="questManagerHistoryUpdate", type="com.twinoid.kube.quest.player.events.QuestManagerEvent")]
	
	/**
	 * Singleton QuestManager
	 * Manages all the quest's logic.
	 * From determining which event to show to using objects and inventory management.
	 * 
	 * @author Francois
	 * @date 14 sept. 2013;
	 */
	public class QuestManager extends EventDispatcher {
		
		private static var _instance:QuestManager;
		
		private var _lastPosData:*;//Contains a Point or Point3D
		private var _positionManager:PositionManager;
		private var _nodeToTreeID:Dictionary;
		private var _loadingAlreadyFired:Boolean;
//		private var _priorityManager:PriorityManager;
		private var _timeAcessManager:TimeAccessManager;
		private var _inventoryManager:InventoryManager;
		private var _currentEvent:KuestEvent;
		private var _treeManager:TreeManager;
		private var _positionToIndex:Object;
		private var _eventsHistory:Vector.<String>;
		private var _guidToEvent:Object;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>QuestEventManager</code>.
		 */
		public function QuestManager(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():QuestManager {
			if(_instance == null)_instance = new  QuestManager(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Gets the current event.
		 */
		public function get currentEvent():KuestEvent { return _currentEvent; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the quest's data loaded from the server
		 */
		public function loadData(nodes:Vector.<KuestEvent>, objects:Vector.<ObjectItemData>, save:ByteArray):void {
			//Builds fast accesses to the events to grab them from a specific position.
			_nodeToTreeID = new Dictionary();
			_positionManager.populate(nodes);
//			_priorityManager.initiliaze(nodes);
			_inventoryManager.initialize(objects);
			
			save;//TODO parse save file
			
//			if(_save["objects"] == undefined) _save["objects"] = {};
//			if(_save["priorities"] == undefined) _save["priorities"] = {};
//			if(_save["treePriority"] == undefined) _save["treePriority"] = {};
			
			computeTreeGUIDs(nodes, onTreeComputeComplete);
		}
		
		/**
		 * Gets the quest's data to be saved to the server
		 */
		public function downloadData():void {
			//TODO
		}
		
		/**
		 * Gets an avent from a position
		 * 
		 * @param pos	a Point or Point3D or an ActionPlace instance
		 */
		public function setCurrentPosition(pos:*):void {
			if(!(pos is Point) && !(pos is Point3D) && !(pos is ActionPlace)) throw new KuestException('pos parameter must be a Point, a Point3D or an ActionPlace instance !', '#215');
			_lastPosData = pos['clone']();
			
			//Check for a tree priority
//			var priority:KuestEvent = _priorityManager.getPriorityFromPosition(pos);
//			if(priority != null && _timeAcessManager.isEventAccessible(priority)) {
//				setCurrentEvent(priority);
//				return;
//			}
			
			//Define the loop's index.
			//This allows to fo through multiple events on a same position.
			if(_positionToIndex[getPositionId(pos)] == undefined) {
				_positionToIndex[getPositionId(pos)] = 0;
			}else{
				_positionToIndex[getPositionId(pos)] ++;
			}
			
			//No tree priority. Parse the others.
			//Gets the items of the current position
			var items:Vector.<KuestEvent> = _positionManager.getEventsFromPos(pos);
			var i:int, len:int;
			len = items.length;
			i = _positionToIndex[getPositionId(pos)] % len;//Loop offset
			for(i; i < len; ++i) {
				if(_timeAcessManager.isEventAccessible(items[i])//If it's the right periode or if there are no periode limitation
					&& _treeManager.isEventAccessible(items[i])) {//If the event isn't on a tree or the right tree
						setCurrentEvent(items[i]);
						return;
					}
			}
		}
		
		/**
		 * Completes an event
		 * 
		 * @param answerIndex	answer index
		 */
		public function completeEvent(answerIndex:int = 0):void {
			//Adds the event to the history
			if(_currentEvent != null) {
				_eventsHistory.push(_currentEvent.guid);
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.HISTORY_UPDATE));
			}
			
			var i:int, len:int, children:Vector.<KuestEvent>, child:KuestEvent;
			children = _currentEvent.getChildren();
			len = children.length;
			//The current event has no choices, go for a simpler solution were
			//all the children will get the priority.
			if(_currentEvent.actionChoices.choices.length == 0) {
				for(i = 0; i < len; ++i) {
					child = children[i];
//					_priorityManager.givePriorityTo( child );
					_treeManager.givePriorityTo( new <KuestEvent>[ child ] );
				}
			}else{
				var priorities:Vector.<KuestEvent> = new Vector.<KuestEvent>();
				//Loop through children and check if one of its dependencies is
				//the current event. If so, check if the answer is the good one.
				for(i = 0; i < len; ++i) {
					var j:int, lenJ:int;
					child = children[i];
					lenJ = child.dependencies.length;
					//Loop through all the dependencies of the child to find
					//if the current event is found.
					for(j = 0; j < lenJ; ++j) {
						//If the dependency is the current event and the answer
						//is the good one...
						if(child.dependencies[j].event.guid == _currentEvent.guid && child.dependencies[j].choiceIndex == answerIndex) {
							priorities.push(child);
//							_priorityManager.givePriorityTo( child );
							break;
						}
					}
					//Do not break the main loop !
					//There can be multiple event depending on the same answer !
				}
				_treeManager.givePriorityTo( priorities );
			}
			setCurrentPosition(_lastPosData);
		}
		
		/**
		 * Use an object on a specific event.
		 * If the object has been used, the event 
		 * 
		 * @return if the object has been used or not.
		 */
		public function useObject(object:InventoryObject):void {
			if(_currentEvent.actionType.type == ActionType.TYPE_OBJECT) {
				if(!_currentEvent.actionType.takeMode) {//If an object has to be put here
					if(_currentEvent.actionType.getItem().guid == object.vo.guid) {//If we put the good object
						if(_inventoryManager.useObject(object.vo.guid)) {//Object has been used
							dispatchEvent(new QuestManagerEvent(QuestManagerEvent.INVENTORY_UPDATE));
							setCurrentPosition(_lastPosData);//Get the next event at this place
						}
					}
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_positionManager	= new PositionManager();
//			_priorityManager	= new PriorityManager();
			_timeAcessManager	= new TimeAccessManager();
			_inventoryManager	= new InventoryManager();
			_treeManager		= new TreeManager();
			_eventsHistory		= new Vector.<String>();//stores events guids
			_positionToIndex	= {};//Stores loop indexes for every action places.
			_guidToEvent		= {};//Links an event's guid to the actual VO.
		}
		
		/**
		 * Called when tree IDs are computed
		 */
		private function onTreeComputeComplete(tree:Dictionary):void {
			_nodeToTreeID = tree;
			
			if(!_loadingAlreadyFired) _treeManager.initialize(_nodeToTreeID);//Do this before the loop because the dictionnary is used on givePriorityTo() method.
			
			//Define the start points of each trees
			var id:int, k:KuestEvent;
			for(var j:* in _nodeToTreeID) {
				k = j as KuestEvent;
				id = _nodeToTreeID[k];
				k.setTreeID(id);
				_guidToEvent[k.guid] = k;
				if(k.startsTree) {
					_treeManager.givePriorityTo( new <KuestEvent>[ k ] );
//					_priorityManager.givePriorityTo( k );
				}else{
					//If the event has no dependencies, set it as the start point of its tree.
					//The tree manager will actually look if there is a higher priority by position
					//or by user input (editor) before setting it as the priority.
					if(k.dependencies.length == 0) {
						_treeManager.givePriorityTo( new <KuestEvent>[ k ], true );
//						_priorityManager.givePriorityTo( k );
					}
				}
			}
			
			if(!_loadingAlreadyFired) {
				_loadingAlreadyFired = true;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.READY));
			}
		}
		
		/**
		 * Sets the current event.
		 */
		private function setCurrentEvent(event:KuestEvent):void {
			_currentEvent = event;
			//If this new event is an object take.
			//Store it to the inventory.
			if(event.actionType.type == ActionType.TYPE_OBJECT && event.actionType.takeMode) {
				_inventoryManager.getObject(event.actionType.itemGUID);
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.INVENTORY_UPDATE));
			}
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.NEW_EVENT));
		}
		
	}
}

internal class SingletonEnforcer{}