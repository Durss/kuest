package com.twinoid.kube.quest.vo {
	import com.twinoid.kube.quest.utils.restoreDependencies;

	import flash.utils.ByteArray;
	
	/**
	 * Contains all the kuest's entry points.
	 * Can be serialized as a string and can deserialize a string.
	 * 
	 * It basically contains KuestEvent items.
	 * 
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class KuestData {
		
		private var _nodes:Vector.<KuestEvent>;
		private var _lastItemAdded:KuestEvent;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestData</code>.
		 */
		public function KuestData() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the last item added.
		 * This value can only be accessed once !
		 * It's reset after the first read !
		 */
		public function get lastItemAdded():KuestEvent {
			var item:KuestEvent = _lastItemAdded;
			_lastItemAdded = null;
			return item;
		}
		
		/**
		 * Gets all the nodes.
		 */
		public function get nodes():Vector.<KuestEvent> { return _nodes; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Adds an entry point
		 */
		public function addEntryPoint(px:int, py:int):void {
			var e:KuestEvent = new KuestEvent();
			e.boxPosition.x = px;
			e.boxPosition.y = py;
			_nodes.push(e);
			_lastItemAdded = e;
		}
		
		/**
		 * Sets the nodes
		 */
		public function deserialize(data:ByteArray, chars:Vector.<CharItemData>, objs:Vector.<ObjectItemData>):void {
			_nodes = data.readObject();
			restoreDependencies(_nodes, chars, objs);
		}
		
		/**
		 * Deletes a node from the references.
		 */
		public function deleteNode(data:KuestEvent):void {
			var i:int, len:int;
			len = _nodes.length;
			for(i = 0; i < len; ++i) {
				if(_nodes[i] == data) {
					_nodes.splice(i, 1);
					i --;
					len --;
				}
			}
			data.dispose();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_nodes = new Vector.<KuestEvent>();
		}
		
	}
}