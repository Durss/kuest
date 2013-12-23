package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.error.KuestException;
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
				_objects.push(new InventoryObject(objects[i], 0, false));
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
		 * Adds an object to the inventory.
		 */
		public function takeObject(itemGUID:int):void {
			InventoryObject(_guidToObject[ itemGUID ]).total++;
			InventoryObject(_guidToObject[ itemGUID ]).unlocked = true;
		}
		
		/**
		 * Exports the data as anonymous object ready to be stored to a ByteArray.
		 * These data will then be imported back with importData().
		 * Basically, the exported data will look like this :
		 * 	[
		 * 		{total:x, guid:guid}
		 * 		{total:x, guid:guid}
		 * 		{total:x, guid:guid}
		 * 	]
		 * 	
		 * 	Where total is the total number object of this kind found, and guid
		 * 	is the ObjectItemData's GUID.
		 */
		public function exportData(version:uint):Array {
			version;
			var data:Array = [];
			var i:int, len:int, o:InventoryObject;
			len = _objects.length;
			for(i = 0; i < len; ++i) {
				o = _objects[i];
				data[i] = {total:o.total, guid:o.vo.guid, unlocked:o.unlocked};
			}
			return data;
		}
		
		/**
		 * Imports data that have been previously exported by exportData() .
		 */
		public function importData(data:Array, version:uint):void {
			if(_guidToObject == null) {
				throw new KuestException('InventoryManager.initialize method must be called before importData !', 'InventoryManager');
				return;
			}
			
			switch(version){
				case SaveVersion.V1:
					var i:int, len:int;
					len = data.length;
					for(i = 0; i < len; ++i) {
						//In release mode, only used objects are compiled to the binary file.
						//this prevents from crash if first playing in test mode and making
						//a save file containing the objects references, and then playing
						//in release mode with potential disapeared objects.
						if(_guidToObject[data[i]['guid']] != null) {
							InventoryObject(_guidToObject[data[i]['guid']]).total = data[i]['total'];
							InventoryObject(_guidToObject[data[i]['guid']]).unlocked = data[i]['unlocked'];
						}
					}
					break;
				default:
			}
		}

		
		/**
		 * Resets the number of objects to the defaults to restart the quest from scratch
		 */
		public function reset():void {
			if (_objects == null) return;
			var i:int, len:int;
			len = _objects.length;
			for(i = 0; i < len; ++i) {
				_objects[i].total = 0;
				_objects[i].unlocked = false;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}