package com.twinoid.kube.quest.vo {
	import flash.geom.Point;
	import by.blooddy.crypto.MD5;
	import com.nurun.core.lang.io.Serializable;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class KuestEvent implements Serializable {
		
		private var _locked:Boolean;
		private var _dependents:Vector.<KuestEvent>;
		private var _guid:String;
		private var _boxPos:Point;
		private var _actionPlace:ActionPlace;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestEvent</code>.
		 */
		public function KuestEvent(px:int, py:int) {
			initialize();
			_boxPos = new Point(px, py);
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
		public function get position():Point { return _boxPos; }
		
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Links an event to the current one.
		 * When the current event is done, it will unlock the specified one that
		 * will became accessible.
		 * Until then, the event won't exist for the end user.
		 * 
		 * @return if the dependency has been made or not. The dependency cannot be built in case of looped dependencies.
		 */
		public function addDependent(entry:KuestEvent):Boolean {
			if(deepDependencyCheck(entry)) {
				//Check if the entry isn't already a direct dependent.
				var i:int, len:int;
				len = _dependents.length;
				for(i = 0; i < len; ++i) {
					//Already a direct dependent!
					if(_dependents[i].guid == entry.guid) return false;
				}
				
				_dependents.push( entry );
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * Removes one off the event's dependents.
		 */
		public function removeDependent(entry:KuestEvent):void {
			
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
		 * items is found. If so, the dependency cannot be built 'cause it
		 * wouldn't make sens.
		 * 
		 * @return	if the dependency is authorized (true) or not (false).
		 */
		private function deepDependencyCheck(entry:KuestEvent):Boolean {
			while(entry.dependents.length > 0) {
				var i:int, len:int;
				len = entry.dependents.length;
				for(i = 0; i < len; ++i) {
					//If the dependent entry is the current one, stop everything
					//we found what we were searching for.
					if(entry.dependents[i].guid == _guid) return false;
					
					//The entry doesn't match, check if its children match.
					if(deepDependencyCheck(entry.dependents[i]) === false) {
						return false;
					}
				}
			}
			
			//No problem found or no children, tell that everything's OK.
			return true;
		}
		
	}
}