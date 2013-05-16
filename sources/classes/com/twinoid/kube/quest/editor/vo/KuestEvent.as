package com.twinoid.kube.quest.editor.vo {
	import com.nurun.core.lang.Disposable;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
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
		private var _endsQuest:Boolean;
		private var _guid:int;
		
		
		
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
				_actionType = null;
			}
			if(value != null) {
				_actionType = value;
				_actionType.addEventListener(Event.CLEAR, typeClearedHandler);
			}
		}
		
		/**
		 * Gets if this event validates the quest.
		 */
		public function get endsQuest():Boolean { return _endsQuest; }

		/**
		 * Sets if this event validates the quest.
		 */
		public function set endsQuest(endsQuest:Boolean):void { _endsQuest = endsQuest; }
		
		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function get dependencies():Vector.<Dependency> { return _dependencies; }

		/**
		 * @private
		 * here for serialization purpose only!
		 */
		public function set dependencies(dependencies:Vector.<Dependency>):void { _dependencies = dependencies; }

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
			if(deepDependencyCheck(entry)) {
				//Check if the entry isn't already a direct dependency.
				var i:int, len:int;
				len = _dependencies.length;
				for(i = 0; i < len; ++i) {
					//Already a direct dependency with the same choice index, disalow creation.
					if(_dependencies[i].event == entry && _dependencies[i].choiceIndex == choiceIndex) return false;
				}
				
				_dependencies.push( new Dependency(entry, choiceIndex) );
				return true;
			}else{
				return false;
			}
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
			return "[KuestEvent :: guid="+guid+" boxPosition="+boxPosition+" actionPlace="+actionPlace+" actionDate="+actionDate+" actionType="+actionType+", dependencies=["+dependencies+"]]";
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
		}
		
		/**
		 * Checks deeply for a looped dependency.
		 * Goes through all the dependencies tree to check if the current
		 * node is found.
		 * 
		 * @return	if a looped dependency has been found (true) or not (false).
		 */
		private function deepDependencyCheck(entry:KuestEvent):Boolean {
			var i:int, len:int;
			len = entry.getDependencies().length;
			//Go through all parents
			for(i = 0; i < len; ++i) {
				//If the dependency entry is the current one, stop everything
				//we found what we were searching for.
				if(entry.getDependencies()[i].event == this) return false;
				
				try {
					//The entry doesn't match, check if its parents matches.
					if(deepDependencyCheck(entry.getDependencies()[i].event) === false) {
						return false;
					}
				}catch(error:Error) {
					//Stack overflow. 256 recursion level reached :(.
					//Let's just consider there are no looped reference :/
					return true;
				}
			}
			
			//No loop found or no parent.
			return true;
		}
		
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