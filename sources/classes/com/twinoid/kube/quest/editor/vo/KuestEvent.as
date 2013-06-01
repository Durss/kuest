package com.twinoid.kube.quest.editor.vo {
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.error.KuestException;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Contains the data about an event.
	 * Fires an Event.CHANGE when data are updated
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class KuestEvent extends EventDispatcher implements Disposable {
		
		internal static var GUID:int;
		
		private var _dependencies:Vector.<Dependency>;
		private var _boxPosition:Point;
		private var _actionPlace:ActionPlace;
		private var _actionDate:ActionDate;
		private var _actionType:ActionType;
		private var _actionChoices:ActionChoices;
		private var _actionSound:ActionSound;
		private var _endsQuest:Boolean;
		private var _guid:int;
		private var _children:Vector.<KuestEvent>;
		private var _treeID:int;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestEvent</code>.
		 */
		public function KuestEvent() {
			initialize();
			_boxPosition = new Point(0, 0);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the box's position
		 */
		public function get boxPosition():Point { return _boxPosition; }
		
		/**
		 * Sets the box's position
		 */
		public function set boxPosition(boxPos:Point):void { _boxPosition = boxPos; }
		
		/**
		 * Gets action's place.
		 * Represents a zone's coordinates or a kube's coordinates.
		 */
		public function get actionPlace():ActionPlace { return _actionPlace; }
		
		/**
		 * Sets action's place.
		 * Represents a zone's coordinates or a kube's coordinates.
		 */
		public function set actionPlace(value:ActionPlace):void {
			if(_actionPlace != null) _actionPlace.dispose();
			_actionPlace = value;
		}
		
		/**
		 * Gets the action's date.
		 * Can contain a time interval, some specific dates, etc..
		 */
		public function get actionDate():ActionDate { return _actionDate; }

		/**
		 * Sets the action's date.
		 * Can contain a time interval, some specific dates, etc..
		 */
		public function set actionDate(value:ActionDate):void {
			if(_actionDate != null) _actionDate.dispose();
			_actionDate = value;
		}
		
		/**
		 * Gets the action's choices.
		 */
		public function get actionChoices():ActionChoices { return _actionChoices; }

		/**
		 * Sets the action's choices.
		 */
		public function set actionChoices(value:ActionChoices):void {
			if(_actionChoices != null) _actionChoices.dispose();
			_actionChoices = value;
		}
		
		/**
		 * Gets the action's type.
		 * Can be a simple character's dialogue or an object put/get
		 */
		public function get actionType():ActionType { return _actionType; }

		/**
		 * Sets the action's type.
		 * Can be a simple character's dialogue or an object put/get
		 */
		public function set actionType(value:ActionType):void {
			if(_actionType != null) {
				_actionType.dispose();
				_actionType.removeEventListener(Event.CLEAR, typeClearedHandler);
				_actionType.removeEventListener(Event.CHANGE, dispatchEvent);
				_actionType = null;
			}
			if(value != null) {
				_actionType = value;
				_actionType.addEventListener(Event.CLEAR, typeClearedHandler);
				_actionType.addEventListener(Event.CHANGE, dispatchEvent);
			}
		}
		
		/**
		 * Gets the action's sound.
		 */
		public function get actionSound():ActionSound {
			return _actionSound;
		}

		/**
		 * Sets the action's sound.
		 */
		public function set actionSound(actionSound:ActionSound):void {
			if(_actionSound != null) _actionSound.dispose();
			_actionSound = actionSound;
		}
		
		/**
		 * Gets if this event validates the quest.
		 */
		public function get endsQuest():Boolean { return _endsQuest; }

		/**
		 * Sets if this event validates the quest.
		 */
		public function set endsQuest(value:Boolean):void { _endsQuest = value; }
		
		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function get dependencies():Vector.<Dependency> { return _dependencies; }

		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function set dependencies(value:Vector.<Dependency>):void {
			_dependencies = value;
			var i:int, len:int;
			len = _dependencies.length;
			for(i = 0; i < len; ++i) {
				_dependencies[i].event.registerChild(this);
			}
//			refreshFirstLoopState();
		}

		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function get guid():int { return _guid; }

		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function set guid(value:int):void {
			_guid = value;
			if(value > GUID) GUID = value + 1;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds a node on which this event will depend.<br>
		 * <br>
		 * This event will be unlocked only when the dependency event is done.<br>
		 * Until then, this event won't exist for the end user.<br>
		 * A dependency node is actually a <strong>PARENT</strong> node.
		 * 
		 * @return if the dependency has been made or not. The dependency cannot be built in case of looped or self dependency.
		 */
		public function addDependency(entry:KuestEvent, choiceIndex:int):Boolean {
			
//			if(!deepDependencyCheck(entry)) {
				//Check if the entry isn't already a direct dependency.
				var i:int, len:int;
				len = _dependencies.length;
				for(i = 0; i < len; ++i) {
					//Already a direct dependency with the same choice index, disalow creation.
					if(_dependencies[i].event == entry && _dependencies[i].choiceIndex == choiceIndex) return false;
				}
				
				_dependencies.push( new Dependency(entry, choiceIndex) );

//				refreshFirstLoopState();
				
				return true;
//			}else{
//				return false;
//			}
		}
		
		/**
		 * Removes one of the event's dependencies.
		 */
		public function removeDependency(entry:KuestEvent, choiceIndex:int = -1):void {
			var i:int, len:int;
			len = _dependencies.length;
			for(i = 0; i < len; ++i) {
				if(_dependencies[i].event == entry
				&& (_dependencies[i].choiceIndex == choiceIndex || choiceIndex == -1)) {
					_dependencies.splice(i, 1);
					i --;
					len --;
				}
			}
//			refreshFirstLoopState();
		}
		
		/**
		 * Submits the data.
		 * Fires an event to tell the data have changed.
		 */
		public function submit():void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Gets if the value object is empty
		 */
		public function isEmpty():Boolean { return _actionDate == null || _actionPlace == null || _actionType == null || _actionChoices == null; }
		
		/**
		 * Gets the boxe's image
		 */
		public function getImage():BitmapData { return (_actionType != null && _actionType.getItem() != null && _actionType.getItem().image != null)? _actionType.getItem().image.getConcreteBitmapData() : null; }
		
		/**
		 * Gets the dependency events.
		 */
		public function getDependencies():Vector.<Dependency> { return _dependencies; }
		
		/**
		 * Gets the boxe's label
		 */
		public function getLabel():String { return _actionType == null? "" : _actionType.text.substr(0, 60).replace(/\r|\n/gi, " "); }
		
		/**
		 * Gets if the item is the first one of a loop
		 */
//		public function isFirstOfLoop():Boolean { return _firstOfLoop; }

		/**
		 * Sets if the item is the first one of a loop
		 */
//		public function setFirstOfLoop(value:Boolean):void { _firstOfLoop = value; }
		
		/**
		 * Checks if the current items loops to the one in paramters.
		 * The test goes upward.
		 * It takes all the dependencies recursively. So, the "from" parameter
		 * mustn't be a direct node's parent or the test will return true even if
		 * there is no loop.
		 */
		public function loopsFrom(from:KuestEvent):Vector.<KuestEvent> {
			return deepDependencyCheck(from);
		}
		
		/**
		 * Sets the tree's ID
		 */
		public function setTreeID(id:int):void {
			_treeID = id;
		}
		
		/**
		 * Gets the tree's ID
		 */
		public function getTreeID():int {
			return _treeID;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			if(_actionPlace != null) _actionPlace.dispose();
			if(_actionDate != null) _actionDate.dispose();
			if(_actionType != null) _actionType.dispose();
			if(_actionChoices != null) _actionChoices.dispose();
			_dependencies = null;
			_boxPosition = null;
			_actionPlace = null;
			_actionDate = null;
			_actionType = null;
			_actionChoices = null;
		}
		
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[KuestEvent :: guid="+guid+" \n\tboxPosition="+boxPosition+" \n\tactionPlace="+actionPlace+" \n\tactionDate="+actionDate+" \n\tactionType="+actionType+", \n\tdependencies=["+dependencies+"]]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_guid = ++GUID;
			_dependencies = new Vector.<Dependency>();
			_children = new Vector.<KuestEvent>();
		}
		
		/**
		 * Registers a child of mine.
		 * Used during deserialization to make some logic easier while playing
		 * the quest.
		 */
		internal function registerChild(event:KuestEvent):void {
			_children.push(event);
		}
		
		/**
		 * Gets this event's children.
		 * DO NOT ACCESS THIS IN THE EDITOR !!!
		 * This is only available in the player module.
		 * The children are defined only at deserialization when loading a quest.
		 */
		public function getChildren():Vector.<KuestEvent> {
			return _children;
		}
		
		/**
		 * Checks deeply for a looped dependency.
		 * Goes through all the dependency tree to check if the current
		 * node is found.
		 * 
		 * @return	if a looped dependency has been found (true) or not (false).
		 */
		private function deepDependencyCheck(entry:KuestEvent, done:Dictionary = null):Vector.<KuestEvent> {
			var i:int, len:int;
			var tree:Vector.<KuestEvent> = new Vector.<KuestEvent>();
			tree.push(entry);
			if(done == null) done = new Dictionary();
			len = entry.getDependencies().length;
			//Go through all parents
			for(i = 0; i < len; ++i) {
				//Prevent from infinite loop.
				if(done[ entry.getDependencies()[i].event ] === true) continue;
				done[ entry.getDependencies()[i].event ] = true;
				
				//If the dependency entry is the current one, stop everything
				//we found what we were searching for.
				if(entry.getDependencies()[i].event == this) {
					tree.push(entry.getDependencies()[i].event);
					return tree;
				}
				
				try {
					//The entry doesn't match, check if its parents do.
					var res:Vector.<KuestEvent> = deepDependencyCheck(entry.getDependencies()[i].event, done);
					if(res != null) {
						tree = tree.concat( res );
						return tree;
					}
				}catch(error:Error) {
					//Stack overflow. 256 recursion level reached :(.
					throw new KuestException(Label.getLabel("exception-DEEP_CHECK_OVERFLOW"), "0");
					return null;
				}
			}
			
			//No loop found or no parent.
			return null;
		}
		
		/**
		 * Refreshes the firstLoop state of the tree from this node.
		 */
//		public function refreshFirstLoopState():void {
//			var i:int, len:int;
//			var path:Vector.<KuestEvent> = new Vector.<KuestEvent>();
//			var done:Dictionary = new Dictionary();
//			if(searchForLoopFromEvent(this, path, done)) {
//				len = path.length;
//				var firstBox:KuestEvent = path[0];
//				var tl:Point = firstBox.boxPosition.clone();
//				for(i = 0; i < len; ++i) {
//					trace("\n"+path[i].guid)
//					path[i].setFirstOfLoop(false);
//					if(path[i].boxPosition.x < tl.x || (path[i].boxPosition.x == tl.x && path[i].boxPosition.y < tl.y)) {
//						trace(path[i].boxPosition.x , tl.x)
//						trace(path[i].guid ,firstBox.guid)
//						tl = path[i].boxPosition.clone();
//						firstBox = path[i];
//						trace("is first "+path[i].guid)
//					}
//				}
//				firstBox.setFirstOfLoop(true);
//				firstBox.submit();
//			}
//		}
		
		/**
		 * Searches for a looped reference
		 */
//		private function searchForLoopFromEvent(target:KuestEvent, path:Vector.<KuestEvent>, done:Dictionary):Boolean {
//			var i:int, len:int;
//			len = target.dependencies.length;
//			if(done[target]) return false;
//			done[target] = true;
//			for(i = 0; i < len; ++i) {
//				if(target.dependencies[i].event == this) {
//					path.push(target.dependencies[i].event);
//					return true;
//				}
//				if(searchForLoopFromEvent(target.dependencies[i].event, path, done)) {
//					path.push(target.dependencies[i].event);
//					return true;
//				}
//			}
//			return false;
//		}
		
		/**
		 * Called when the source data of the event type is cleared.
		 * For example, if an object or a character is delete from the main menu
		 * and this value object is linked to it, this event will be fired.
		 */
		private function typeClearedHandler(event:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}