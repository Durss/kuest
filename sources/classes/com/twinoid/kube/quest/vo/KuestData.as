package com.twinoid.kube.quest.vo {
	import com.nurun.core.lang.io.Serializable;
	
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
	public class KuestData implements Serializable {
		
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
		 * @inheritDoc
		 */
		public function deserialize(input:String):void {
		}

		/**
		 * @inheritDoc
		 */
		public function serialize():String {
//			var obj:Object = {};
//			var i:int, len:int;
//			len = _nodes.length;
//			for(i = 0; i < len; ++i) {
//				
//			}
			return "";
		}
		
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