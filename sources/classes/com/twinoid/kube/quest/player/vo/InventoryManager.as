package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	
	/**
	 * Creates fast accesses to an object via its guid.
	 * 
	 * @author Francois
	 * @date 15 sept. 2013;
	 */
	public class InventoryManager {
		
		private var _guidToObject:Object;
		private var _objects:Vector.<InventoryObject>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>InventoryManager</code>.
		 */
		public function InventoryManager() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the objects.
		 */
		public function get objects():Vector.<InventoryObject> { return _objects; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initializes the class.
		 */
		public function initialize(objects:Vector.<ObjectItemData>):void {
			_objects = new Vector.<InventoryObject>();
			_guidToObject = {};
			
			var i:int, len:int;
			len = objects.length;
			for(i = 0; i < len; ++i) {
				_objects.push(new InventoryObject(objects[i], 0));
				_guidToObject[ objects[i].guid ] = _objects[i];
			}
		}
		
		/**
		 * Uses an object.
		 * 
		 * @param guid	object's GUID to use
		 * 
		 * @return	if the object can be used or not.
		 */
		public function useObject(guid:int):Boolean {
			var object:InventoryObject = _guidToObject[ guid ] as InventoryObject;
			if(object.total > 0) {
				object.total --;
				return true;//Say it's ok.
			}
			return false;//No more objects of this kind
		}
		
		/**
		 * Adds an object to the inventory
		 */
		public function getObject(itemGUID:int):void {
			InventoryObject(_guidToObject[ itemGUID ]).total++;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}