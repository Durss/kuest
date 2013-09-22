package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.player.utils.getPositionId;
	import com.twinoid.kube.quest.player.utils.sortByPosition;
	
	/**
	 * Simply provides a fast access to an event collection by a position.
	 * 
	 * @author Francois
	 * @date 14 sept. 2013;
	 */
	public class PositionManager {
		private var _posToEvents:Object;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PositionManager</code>.
		 */
		public function PositionManager() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Stores fast accesses to get all the events linked to a specific position.
		 */
		public function populate(nodes:Vector.<KuestEvent>):void {
			_posToEvents = {};
			var i:int, len:int;
			len = nodes.length;
			for (i = 0; i < len; ++i) {
				var id:String = getPositionId(nodes[i].actionPlace);
				if(_posToEvents[id] == undefined) _posToEvents[id] = new Vector.<KuestEvent>();
				(_posToEvents[id] as Vector.<KuestEvent>).push(nodes[i]);
			}
		}
		
		/**
		 * Gets the events of a specific position.
		 */
		public function getEventsFromPos(pos:*):Vector.<KuestEvent> {
			var items:Vector.<KuestEvent> = _posToEvents[getPositionId(pos)] as Vector.<KuestEvent>;
			//Sort them to get them with "natural" loop priorities
			if(items != null) items.sort(sortByPosition);
			return items;
		}

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}