package com.twinoid.kube.quest.player.model {
	import com.twinoid.kube.quest.player.vo.MoneyManager;
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
	import com.twinoid.kube.quest.player.vo.SaveVersion;
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
		private var _timeAccessManager:TimeAccessManager;
		private var _inventoryManager:InventoryManager;
		private var _currentEvent:KuestEvent;
		private var _treeManager:TreeManager;
		private var _positionToIndex:Object;
		private var _eventsHistory:Vector.<String>;
		private var _save:ByteArray;
		private var _questComplete:Boolean;
		private var _questLost:Boolean;
		private var _quesEvaluated:Boolean;
		private var _guidToEvent:Object;
		private var _historyFavorites:Vector.<String>;
		private var _moneyManager:MoneyManager;
		
		
		
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
		
		/**
		 * Gets if the quest has been evaluated
		 */
		public function get questEvaluated():Boolean { return _quesEvaluated; }
		
		/**
		 * Sets if the quest has been evaluated
		 */
		public function set questEvaluated(value:Boolean):void { _quesEvaluated = value; }
		
		/**
		 * Gets the guids history
		 */
		public function get eventsHistory():Vector.<KuestEvent>{
			var i:int, len:int, ret:Vector.<KuestEvent>;
			len = _eventsHistory.length;
			ret = new Vector.<KuestEvent>();
			for(i = 0; i < len; ++i) {
				ret.push( _guidToEvent[_eventsHistory[i]] );
			}
			return ret;
		}
		
		/**
		 * Gets the guids favorites
		 */
		public function get eventsFavorites():Vector.<KuestEvent>{
			var i:int, len:int, ret:Vector.<KuestEvent>;
			len = _historyFavorites.length;
			ret = new Vector.<KuestEvent>();
			for(i = 0; i < len; ++i) {
				ret.push( _guidToEvent[_historyFavorites[i]] );
			}
			return ret;
		}
		
		/**
		 * Gets the money earned
		 */
		public function get money():uint { return _moneyManager.money; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the quest's data loaded from the server
		 */
		public function loadData(nodes:Vector.<KuestEvent>, objects:Vector.<ObjectItemData>, save:ByteArray, timeOffset:uint, testMode:Boolean, debugMode:Boolean):void {
			_save = save;//Save is parsed when tree computation completes
			
			//Builds fast accesses to the events to grab them from a specific position.
			_positionManager.populate(nodes, debugMode);
			_inventoryManager.initialize(objects);
			_timeAccessManager.initialize(timeOffset, testMode, debugMode);
			
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
			ba.writeObject( _positionToIndex );
			ba.writeUTF( _eventsHistory.join(',') );
			ba.writeUTF( _historyFavorites.join(',') );
			ba.writeBoolean( _questComplete );
			ba.writeBoolean( _questLost );
			ba.writeBoolean( _quesEvaluated );
			ba.writeObject( _moneyManager.exportData(version) );
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
			if(pos == null) return;
			if(!(pos is Point) && !(pos is Point3D) && !(pos is ActionPlace)) throw new KuestException('pos parameter must be a Point, a Point3D or an ActionPlace instance !', '#215');
			_lastPosData = pos['clone']();
			if(debugDate != null) {
				_timeAccessManager.currentDate = debugDate;
			}
			
			//If the previous event has no custom answer and is still accessible, automatically flag it as complete
			if(_currentEvent != null
			&& (_currentEvent.actionChoices == null || _currentEvent.actionChoices.choices.length == 0)
			&& _treeManager.isEventAccessible(_currentEvent)
			&& _moneyManager.isEventAccessible(_currentEvent)) {
				completeEvent(0, false);
			}
			
			if(_questLost) {
				_currentEvent = null;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.NEW_EVENT));
				return;
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
				if(_timeAccessManager.isEventAccessible(items[i%len])//If it's the right periode or if there are no periode limitation
					&& _treeManager.isEventAccessible(items[i%len])//If the event is part of the current priority of its tree
					&& _moneyManager.isEventAccessible(items[i%len])) {
						if(setCurrentEvent(items[i%len])) { 
							return;//If the event has been selected, stop for searching one.
						}
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
			
				//Remove as much money as the answer's cost.
				if(_currentEvent.actionChoices.choicesCost.length > answerIndex) {
					if(_moneyManager.money >= _currentEvent.actionChoices.choicesCost[answerIndex]) {
						_moneyManager.answerChoice( _currentEvent.actionChoices.choicesCost[answerIndex] );
						dispatchEvent(new QuestManagerEvent(QuestManagerEvent.MONEY_UPDATE));
					}
				}
			
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
					if(_timeAccessManager.isEventAccessible(event)//If it's the right periode or if there are no periode limitation
					&& _treeManager.isEventAccessible(event)//If the event is part of the current priority of its tree
					&& _moneyManager.isEventAccessible(event)) {//If the event
						if(!event.actionType.takeMode) {//If an object has to be put here
							if(event.actionType.getItem().guid == object.vo.guid) {//If we put the good object
								if(_inventoryManager.useObject(object.vo.guid) || !verifyNumber) {//Use the object
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
			_questLost = false;
			_currentEvent = null;
			_questComplete = false;
			_eventsHistory = new Vector.<String>();
			_historyFavorites = new Vector.<String>();
			_treeManager.reset();
			_inventoryManager.reset();
			_moneyManager.reset();
		}
		
		/**
		 * Adds an event to the history favorites
		 */
		public function addToFavorites(event:KuestEvent):void {
			var i:int, len:int, guid:String;
			guid = event.guid.toString();
			len = _historyFavorites.length;
			for(i = 0; i < len; ++i) {
				if(_historyFavorites[i] == guid) return;
			}
			_historyFavorites.push(guid);
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.HISTORY_UPDATE));
		}
		
		/**
		 * Removes an item from the favorites
		 */
		public function removeFromFavorites(event:KuestEvent):void {
			var i:int, len:int, guid:String;
			guid = event.guid.toString();
			len = _historyFavorites.length;
			for(i = 0; i < len; ++i) {
				if(_historyFavorites[i] == guid) {
					_historyFavorites.splice(i, 1);
					i--;
					len--;
				}
			}
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.HISTORY_FAVORITES_UPDATE));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_positionManager	= new PositionManager();
			_timeAccessManager	= new TimeAccessManager();
			_inventoryManager	= new InventoryManager();
			_treeManager		= new TreeManager();
			_moneyManager		= new MoneyManager();
			_eventsHistory		= new Vector.<String>();//stores events guids
			_historyFavorites	= new Vector.<String>();//stores events guids
			_positionToIndex	= {};//Stores loop indexes for every action places.
		}
		
		/**
		 * Called when tree IDs are computed
		 */
		private function onTreeComputeComplete(tree:Dictionary):void {
			
			_treeManager.initialize(tree);//Do this before the loop because the dictionnary is used on givePriorityTo() method.
			
			//Define the start points of each trees
			var id:int, k:KuestEvent, guidToEvent:Object;
			guidToEvent = {};//Links an event's guid to the actual VO.
			for(var j:* in tree) {
				k = j as KuestEvent;
				id = tree[k];
				k.setTreeID(id);
				guidToEvent[k.guid] = k;
				_treeManager.givePriorityTo( new <KuestEvent>[ k ], null, !k.startsTree, true);
			}
			
			_treeManager.guidToEvent = _guidToEvent = guidToEvent;
			
			//Load save data if necessary
			if(_save != null) {
				try {
					_save.inflate();
				}catch(error:Error) {
					dispatchEvent(new QuestManagerEvent(QuestManagerEvent.WRONG_SAVE_FILE_FORMAT));
					return;
				}
				var version:uint = _save.readUnsignedInt();
				switch(version){
					case SaveVersion.V1:
						_treeManager.importData( _save.readObject(), version );
						_inventoryManager.importData( _save.readObject(), version );
						_positionToIndex = _save.readObject();
						
						//Load favorites
						_eventsHistory = new Vector.<String>();
						var tmp:Array = _save.readUTF().split(',');
						var i:int, len:int;
						len = tmp.length;
						for(i = 0; i < len; ++i) {
							_eventsHistory[i] = tmp[i];
						}
						
						//Load history favorites
						_historyFavorites = new Vector.<String>();
						tmp = _save.readUTF().split(',');
						len = tmp.length;
						for(i = 0; i < len; ++i) {
							_historyFavorites[i] = tmp[i];
						}
						
						_questComplete	= _save.readBoolean();
						_questLost		= _save.readBoolean();
						_quesEvaluated	= _save.readBoolean();
						
						_moneyManager.importData(_save.readObject(), version);
						break;
						
					default:
						dispatchEvent(new QuestManagerEvent(QuestManagerEvent.WRONG_SAVE_FILE_FORMAT));
				}
			}
			
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.READY));
		}
		
		/**
		 * Sets the current event.
		 * Return false if its an object put related event or if the new event
		 * is the current event 
		 * 
		 * @return true if the event has been selected
		 */
		private function setCurrentEvent(event:KuestEvent, objectUsed:Boolean = false):Boolean {
			//In case of unique event on a zone, we loop to it as soon as we
			//complete it. This prevents from displaying the same event twice.
			if(event == _currentEvent) return false;
			
			//If this new event is an object related event.
			if(event.actionType != null && event.actionType.type == ActionType.TYPE_OBJECT && !objectUsed) {
				//If its a "take mode", put it in the inventory
				if(event.actionType.takeMode) {
					_inventoryManager.takeObject(event.actionType.itemGUID);
					dispatchEvent(new QuestManagerEvent(QuestManagerEvent.INVENTORY_UPDATE));
				}else if(event.actionType.putMode) {
					//If an object has to be put, ignore it.
					//When the user will put the object, this event will be
					//checked and the object used.
					return false;
				}
			}
			
			_currentEvent = event;
			dispatchEvent(new QuestManagerEvent(QuestManagerEvent.NEW_EVENT, _currentEvent));
			
			if (_currentEvent.endsQuest) {
				_questComplete = true;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.QUEST_COMPLETE, _currentEvent));
			}
			
			if(_currentEvent.loosesQuest) {
				_questLost = true;
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.QUEST_FAILED, _currentEvent));
			}
			
			if(_moneyManager.selectEvent(_currentEvent)){
				dispatchEvent(new QuestManagerEvent(QuestManagerEvent.MONEY_UPDATE));
			}
			
			return true;
		}

	}
}