package com.twinoid.kube.quest.vo {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import by.blooddy.crypto.MD5;
	import com.nurun.core.lang.io.Serializable;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Contains the data about an event.
	 * Fires an Event.CHANGE when data are updated
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class KuestEvent extends EventDispatcher implements Serializable {
		
		private var _locked:Boolean;
		private var _dependents:Vector.<KuestEvent>;
		private var _guid:String;
		private var _boxPos:Point;
		private var _actionPlace:ActionPlace;
		private var _actionDate:ActionDate;
		private var _actionType:ActionType;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestEvent</code>.
		 */
		public function KuestEvent(boxX:int, boxY:int) {
			initialize();
			_boxPos = new Point(boxX, boxY);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the unique identifier that represents this specific event.
		 */
		public function get guid():String { return _guid; }
		
		/**
		 * Gets the dependent events.
		 */
		public function get dependents():Vector.<KuestEvent> { return _dependents; }
		
		/**
		 * Gets the boxe's position
		 */
		public function get boxPosition():Point { return _boxPos; }
		
		/**
		 * Gets action's place.
		 * Represents a zone's coordinates or a kube's coordinates.
		 */
		public function get actionPlace():ActionPlace { return _actionPlace.clone(); }
		
		/**
		 * Sets action's place.
		 * Represents a zone's coordinates or a kube's coordinates.
		 */
		public function set actionPlace(value:ActionPlace):void { _actionPlace = value; }
		
		/**
		 * Gets the action's date.
		 * Can contain a time interval, some specific dates, etc..
		 */
		public function get actionDate():ActionDate { return _actionDate; }

		/**
		 * Sets the action's date.
		 * Can contain a time interval, some specific dates, etc..
		 */
		public function set actionDate(value:ActionDate):void { _actionDate = value; }
		
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
				_actionType.removeEventListener(Event.CLEAR, typeClearedHandler);
			}
			_actionType = value;
			_actionType.addEventListener(Event.CLEAR, typeClearedHandler);
		}
		
		/**
		 * Gets the boxe's label
		 */
		public function get label():String { return _actionType.text.substr(0, 60).replace(/\r|\n/gi, " "); }
		
		/**
		 * Gets the boxe's image
		 */
		public function get image():BitmapData { return (_actionType != null && _actionType.item != null)? _actionType.item.image : null; }
		
		/**
		 * Gets if the value object is empty
		 */
		public function get isEmpty():Boolean { return _actionDate == null || _actionPlace == null || _actionType == null; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds a node on which this event will depend.<br>
		 * <br>
		 * This event will be unlocked only we the dependent event is done.<br>
		 * Until then, this event won't exist for the end user.<br>
		 * A dependent node is actually a <strong>PARENT</strong> node.
		 * 
		 * @return if the dependency has been made or not. The dependency cannot be built in case of looped or self dependency.
		 */
		public function addDependent(entry:KuestEvent):Boolean {
			if(deepDependencyCheck(entry)) {
				//Check if the entry isn't already a direct dependent.
				var i:int, len:int;
				len = _dependents.length;
				for(i = 0; i < len; ++i) {
					//Already a direct dependent!
					if(_dependents[i] == entry) return false;
				}
				
				_dependents.push( entry );
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * Removes one of the event's dependents.
		 */
		public function removeDependent(entry:KuestEvent):void {
			var i:int, len:int;
			len = _dependents.length;
			for(i = 0; i < len; ++i) {
				if(_dependents[i] == entry) {
					_dependents.splice(i, 1);
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
		 * @inheritDoc
		 */
		public function deserialize(input:String):void {
			
		}

		/**
		 * @inheritDoc
		 */
		public function serialize():String {
			return "";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_guid = MD5.hash(new Date().getTime().toString()+"_"+Math.random());
			_locked = true;
			_dependents = new Vector.<KuestEvent>();
		}
		
		/**
		 * Checks deeply for a looped dependency.
		 * Goes through all the dependencies tree to check if the current
		 * node is found. If so, the dependency cannot be built because it
		 * wouldn't make sens.
		 * 
		 * @return	if the dependency is authorized (true) or not (false).
		 */
		private function deepDependencyCheck(entry:KuestEvent):Boolean {
			var i:int, len:int;
			len = entry.dependents.length;
			//Go through all parents
			for(i = 0; i < len; ++i) {
				//If the dependent entry is the current one, stop everything
				//we found what we were searching for.
				if(entry.dependents[i] == this) return false;
				
				try {
					//The entry doesn't match, check if its parents match.
					if(deepDependencyCheck(entry.dependents[i]) === false) {
						return false;
					}
				}catch(error:Error) {
					//Stack overflow. 256 recursion level reached :(.
					//Let's just consider there are no looped reference :/
					return true;
				}
			}
			
			//No problem found or no parent, tell that everything's OK.
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