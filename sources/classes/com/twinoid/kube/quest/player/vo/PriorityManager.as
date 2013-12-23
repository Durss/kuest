package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.player.utils.getPositionId;
	
	/**
	 * 
	 * @author Francois
	 * @date 14 sept. 2013;
	 */
	public class PriorityManager {
		
		private var _priorities:Object;
		private var _positionToIndex:Object;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PriorityManager</code>.
		 */
		public function PriorityManager() {
			_priorities = {};
			_positionToIndex = {};
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gives the priority to an event.
		 * If an event already has the priority on the same place the new one
		 * will be added next to it. The old one will have a higher priority.
		 */
		public function givePriorityTo(event:KuestEvent):void {
			var id:String = getPositionId(event.actionPlace);
			if(_priorities[id] == undefined) {
				_priorities[id] = new Vector.<KuestEvent>();
			}
			Vector.<KuestEvent>(_priorities[id]).push(event);
		}
		
		/**
		 * Gets the event that has the highest priority at a specific place.
		 * 
		 * @param pos	a Point, Point3D or ActionPlace instance.
		 * 
		 * @return	null if no event has the priority here, or a KuestEvent
		 */
		public function getPriorityFromPosition(pos:*):KuestEvent {
			var id:String = getPositionId(pos);
			if(_priorities[id] == undefined) return null;
			if(Vector.<KuestEvent>(_priorities[id]).length == 0) return null;
			return Vector.<KuestEvent>(_priorities[id])[0];
		}
		
		/**
		 * Removes the priority from an event when it has been complete
		 */
		public function removePriorityFrom(event:KuestEvent):void {
			var id:String = getPositionId(event.actionPlace);
			if(_priorities[id] == undefined) return;
			if(Vector.<KuestEvent>(_priorities[id]).length == 0) return;
			var collection:Vector.<KuestEvent> = _priorities[id] as Vector.<KuestEvent>;
			var i:int, len:int;
			len = collection.length;
			for(i = 0; i < len; ++i) {
				if(collection[i].guid == event.guid) {
					collection.splice(i, 1);
					len --;
					i--;
					//Don't break the loop. Just in case there a duplicates. Which shouldn't happen anyway...
				}
			}
		}
		
		/**
		 * Initializes the manager
		 */
		public function initialize(nodes:Vector.<KuestEvent>):void {
			var i:int, len:int;
			len = nodes.length;
			for(i = 0; i < len; ++i) {
				_positionToIndex[ getPositionId(nodes[i].actionPlace) ] = 0;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}