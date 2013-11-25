package com.twinoid.kube.quest.player.model {
	import com.twinoid.kube.quest.player.vo.SaveVersion;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.events.QuestManagerEvent;
	import com.twinoid.kube.quest.player.utils.computeTreeGUIDs;
	import com.twinoid.kube.quest.player.utils.getPositionId;
	import com.twinoid.kube.quest.player.vo.InventoryManager;
	import com.twinoid.kube.quest.player.vo.InventoryObject;
	import com.twinoid.kube.quest.player.vo.PositionManager;
	import com.twinoid.kube.quest.player.vo.TimeAccessManager;
	import com.twinoid.kube.quest.player.vo.TreeManager;

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
		
		private var _lastPosData:*;//Contains a Point or Point3D or ActionPlace (in debug mode)
		private var _positionManager:PositionManager;
		private var _nodeToTreeID:Dictionary;
		private var _timeAcessManager:TimeAccessManager;
		private var _inventoryManager:InventoryManager;
		private var _currentEvent:KuestEvent;
		private var _treeManager:TreeManager;
		private var _positionToIndex:Object;
		private var _eventsHistory:Vector.<String>;
		private var _guidToEvent:Object;
		private var _save:ByteArray;
		private var _questComplete:Boolean;
		private var _questLost:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>QuestEventManager</code>.
		 */
		public function QuestManager() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the current event.
		 */
		public function get currentEvent():KuestEvent { return _currentEvent; }
		
		/**
		 * Gets the inventory content.
		 */
		public function get inventory():Vector.<InventoryObject> { return _inventoryManager.objects; }
		
		/**
		 * Gets if the quest has been completed
		 */
		public function get questComplete():Boolean { return _questComplete; }
		
		/**
		 * Gets if the quest has been lost
		 */
		public function get questLost():Boolean { return _questLost; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the quest's data loaded from the server
		 */
		public function loadData(nodes:Vector.<KuestEvent>, objects:Vector.<ObjectItemData>, save:ByteArray, timeOffset:uint, testMode:Boolean, debugMode:Boolean):void {
			_save = save;//Save is parsed when tree computation completes
			
			//Builds fast accesses to the events to grab them from a specific position.
			_nodeToTreeID = new Dictionary();
			_positionManager.populate(nodes, debugMode);
			_inventoryManager.initialize(objects);
			_timeAcessManager.initialize(timeOffset, testMode, debugMode);
			
			computeTreeGUIDs(nodes, onTreeComputeComplete);
		}
		
		/**
		 * Gets the quest's data to be saved to the server
		 */
		public function exportSave():ByteArray {
			var version:uint = SaveVersion.V1;
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt( version );
			ba.writeObject( _treeManager.exportData(version) );
			ba.writeObject( _inventoryManager.exportData(version) );
			ba.writeUTF( _eventsHistory.join(',') );
			ba.writeBoolean( _questComplete );
			ba.writeBoolean( _questLost );
			ba.deflate();
			return ba;
		}
		
		/**
		 * Forces an event.
		 * This is used for debug purpose only !
		 */
		public function forceEvent(event:KuestEvent):void {
			if(event.isEmpty()) return;//Ignore empty events
			
			_lastPosData = event.actionPlace.clone().getAsPoint();
			var pos:* = event.actionPlace == null? new Point() : event.actionPlace.clone();
			_positionToIndex[getPositionId(pos)] = 0;
//			setCurrentPosition(pos);
			setCurrentEvent(event);
		}
		
		/**
		 * Gets an avent from a position
		 * 
		 * @param pos	a Point or Point3D or an ActionPlace instance
		 */
		public function setCurrentPosition(pos:*, debugDate:Date = null):void {
			if(!(pos is Point) && !(pos is Point3D) && !(pos is ActionPlace)) throw new KuestException('pos parameter must be a Point, a Point3D or an ActionPlace instance !', '#215');
			_lastPosData = pos['clone']();
			if(debugDate != null) {
				_timeAcessManager.currentDate = debugDate;
			}
			
			//If the previous event has no custom answer and is still accessible, automatically flag it as complete
			if(_currentEvent != null
			&& (_currentEvent.actionChoices == null || _currentEvent.actionChoices.choices.length == 0)
			&& _treeManager.isEventAccessible(_currentEvent)) {
				completeEvent(0, false);
			}
			
			//Define the loop's index.
			//This allows to fo through multiple events on a same position.
			if(_positionToIndex[getPositionId(pos)] == undefined) {
				_positionToIndex[getPositionId(pos)] = 0;
			}else{
				_positionToIndex[getPositionId(pos)] ++;
			}
			
			//Gets the items of the current position ordered by "position" priority
			var items:Vector.<KuestEvent> = _positionManager.getEventsFromPos(pos);
			var i:int, len:int, loopsLen:int;
			len = items == null? 0 : items.length;
			i = _positionToIndex[getPositionId(pos)] % len;//Loop offset to switch from item to item
			loopsLen = len + i;
			for(i; i < loopsLen; ++i) {
				if(_timeAcessManager.isEventAccessible(items[i%len])//If it's the right periode or if there are no periode limitation
					&& _treeManager.isEventAccessible(items[i%len])) {//If the event is part of the current priority of its tree
						if(setCurrentEvent(items[i%len])) 
							return;//If the event has been selected, stop for searching one.
					}
			}
			
			//No event selected, clear the current one
			_currentEvent = null;
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.NEW_EVENT));
		}
		
		/**
		 * Completes an event.
		 * This should be called when user answer's a question.
		 * 
		 * @param answerIndex		answer's index choosen by the user.
		 * @param autoContinue		automatically search for next event to display at the current place.
		 * 
		 * @param answerIndex	answer index
		 */
		public function completeEvent(answerIndex:int = 0, autoContinue:Boolean = true):void {
			//Adds the event to the history
			if(_currentEvent != null) {
				_eventsHistory.push(_currentEvent.guid);
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.HISTORY_UPDATE));
			}else{
				return;
			}
			
			var i:int, len:int, children:Vector.<KuestEvent>, child:KuestEvent;
			children = _currentEvent.getChildren();
			len = children.length;
			//The current event has 1 or no choices, go for a simpler solution
			//where all the children will get the priority.
			if(_currentEvent.actionChoices == null
			|| _currentEvent.actionChoices.choices.length < 2) {
				_treeManager.givePriorityTo( children, _currentEvent );
			}else{
				//The event has two or more choices
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
							break;
						}
					}
					//Do not break the main loop !
					//There can be multiple event depending on the same answer !
				}
				_treeManager.givePriorityTo( priorities );
			}
			
			//Search for next item
			if(autoContinue) setCurrentPosition(_lastPosData);
		}
		
		/**
		 * Use an object on a specific event.
		 * If the object has been used, the event 
		 * 
		 * @return if the object has been used or not.
		 */
		public function useObject(object:InventoryObject, verifyNumber:Boolean = true):Boolean {
			var events:Vector.<KuestEvent> = _positionManager.getEventsFromPos(_lastPosData);
			if(events == null) return false;
			var i:int, len:int, event:KuestEvent;
			len = events.length;
			//Search for an event asking for this object
			for(i = 0; i < len; ++i) {
				event = events[i];
				if(event.actionType.type == ActionType.TYPE_OBJECT) {
					if(_timeAcessManager.isEventAccessible(event)//If it's the right periode or if there are no periode limitation
					&& _treeManager.isEventAccessible(event)) {//If the event is part of the current priority of its tree
						if(!event.actionType.takeMode) {//If an object has to be put here
							if(event.actionType.getItem().guid == object.vo.guid) {//If we put the good object
								if(!verifyNumber || _inventoryManager.useObject(object.vo.guid)) {//Use the object
									dispatchEvent(new QuestManagerEvent(QuestManagerEvent.INVENTORY_UPDATE));
									setCurrentEvent(event, true);//Unlock the object's event
									return true;
								}
							}
						}
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Clears the player's progression
		 */
		public function clearProgression():void {
			_eventsHistory = new Vector.<String>();
			_treeManager.reset();
			_inventoryManager.reset();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_positionManager	= new PositionManager();
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
			
			_treeManager.initialize(_nodeToTreeID);//Do this before the loop because the dictionnary is used on givePriorityTo() method.
			
			//Define the start points of each trees
			var id:int, k:KuestEvent;
			for(var j:* in _nodeToTreeID) {
				k = j as KuestEvent;
				id = _nodeToTreeID[k];
				k.setTreeID(id);
				_guidToEvent[k.guid] = k;
				if(k.startsTree) {
					_treeManager.givePriorityTo( new <KuestEvent>[ k ] );
				}else{
					//If the event has no dependencies, set it as the start point of its tree.
					//The tree manager will actually look if there is a higher priority by position
					//or by user input (editor) before setting it as the priority.
//					if(k.dependencies.length == 0) {
						_treeManager.givePriorityTo( new <KuestEvent>[ k ], null, true );
//					}
				}
			}
			
			_treeManager.guidToEvent = _guidToEvent;
			//Load save data if necessary
			if(_save != null) {
				_save.inflate();
				var version:uint = _save.readUnsignedInt();
				switch(version){
					case SaveVersion.V1:
						_treeManager.importData( _save.readObject(), version );
						_inventoryManager.importData( _save.readObject(), version );
						
						_eventsHistory = new Vector.<String>();
						var tmp:Array = _save.readUTF().split('');
						var i:int, len:int;
						len = tmp.length;
						for(i = 0; i < len; ++i) _eventsHistory[i] = tmp[i];
						break;
					default:
						dispatchEvent(new QuestManagerEvent(QuestManagerEvent.WRONG_SAVE_FILE_FORMAT));
				}
			}
			
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.READY));
		}
		
		/**
		 * Sets the current event.
		 * 
		 * @return true if the event have been selected
		 */
		private function setCurrentEvent(event:KuestEvent, objectUsed:Boolean = false):Boolean {
			//If this new event is an object related event.
			if(event.actionType != null && event.actionType.type == ActionType.TYPE_OBJECT && !objectUsed) {
				//If its a "take mode", put it in the inventory
				if(event.actionType.takeMode) {
					_inventoryManager.takeObject(event.actionType.itemGUID);
					dispatchEvent(new QuestManagerEvent(QuestManagerEvent.INVENTORY_UPDATE));
				}else{
					//If an object has to be put, ignore it.
					//When the user will put the object, this event will be
					//checked and the object used.
					return false;
				}
			}
			
			_currentEvent = event;
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.NEW_EVENT, _currentEvent));
			
			if(_currentEvent.endsQuest) {
				_questComplete = true;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.QUEST_COMPLETE, _currentEvent));
			}
			
			if(_currentEvent.loosesQuest) {
				_questLost = true;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.QUEST_FAILED, _currentEvent));
			}
			
			return true;
		}
		
	}
}