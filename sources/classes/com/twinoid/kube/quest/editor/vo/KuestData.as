package com.twinoid.kube.quest.editor.vo {
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.utils.restoreDependencies;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		
		[Embed(source="../../../../../../../assets/spritesheet_chars.jpg")]
		private var _charsBmp:Class;
		
		[Embed(source="../../../../../../../assets/spritesheet_objs.jpg")]
		private var _objsBmp:Class;
		
		private var _nodes:Vector.<KuestEvent>;
		private var _lastItemAdded:KuestEvent;
		private var _characters:Vector.<CharItemData>;
		private var _objects:Vector.<ObjectItemData>;
		private var _guid:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KuestData</code>.
		 */
		public function KuestData() {
			initialize();
			_guid = 1;
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
		
		/**
		 * Gets the characters items.
		 */
		public function get characters():Vector.<CharItemData> { return _characters; }
		
		/**
		 * Gets the objects items.
		 */
		public function get objects():Vector.<ObjectItemData> { return _objects; }
		
		/**
		 * Gets the current kuest's GUID.
		 */
		public function get guid():int { return _guid; }



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
		public function deserialize(data:ByteArray):void {
			reset();
			_characters = data.readObject();
			_objects = data.readObject();
			_nodes = data.readObject();
			restoreDependencies(_nodes, _characters, _objects);
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
		
		/**
		 * Deletes a character
		 */
		public function deleteCharacter(item:CharItemData):void {
			var i:int, len:int;
			len = _characters.length;
			for(i = 0; i < len; ++i) {
				if(_characters[i] == item) {
					_characters.splice(i, 1);
					i--;
					len--;
				}
			}
			item.kill();
		}
		
		/**
		 * Deletes an object
		 */
		public function deleteObject(item:ObjectItemData):void {
			var i:int, len:int;
			len = _objects.length;
			for(i = 0; i < len; ++i) {
				if(_objects[i] == item) {
					_objects.splice(i, 1);
					i--;
					len--;
				}
			}
			item.kill();
		}
		
		/**
		 * Adds a character
		 */
		public function addCharacter():void {
			_characters.push(new CharItemData());
		}
		
		/**
		 * Adds a character
		 */
		public function addObject():void {
			_objects.push(new ObjectItemData());
		}
		
		/**
		 * Resets all the quest.
		 * Removes everything !
		 */
		public function reset():void {
			if(_characters != null) {
				var i:int, len:int;
				len = _characters.length;
				for(i = 0; i < len; ++i) _characters[i].kill();
				len = _objects.length;
				for(i = 0; i < len; ++i) _objects[i].kill();
			}
			_nodes = new Vector.<KuestEvent>();
			setDefaults();
			_lastItemAdded = null;
			_guid ++;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_nodes = new Vector.<KuestEvent>();
			setDefaults();
		}
		
		/**
		 * Creates the default chars and objects
		 */
		private function setDefaults():void {
			var names:Array = Label.getLabel("menu-chars-names").split(",");
			var bmp:Bitmap = new _charsBmp() as Bitmap;
			var src:BitmapData = bmp.bitmapData;
			var i:int, len:int, bmd:BitmapData, rect:Rectangle, pt:Point, obj:ObjectItemData, char:CharItemData;
			len = names.length;
			rect = new Rectangle(0, 0, 100, 100);
			pt = new Point();
			_characters = new Vector.<CharItemData>();
			for(i = 0; i < len; ++i) {
				rect.x = i * 100;
				bmd = new BitmapData(100, 100, true, 0);
				bmd.copyPixels(src, rect, pt);
				bmd.lock();
				char = new CharItemData();
				char.image = new SerializableBitmapData();
				char.image.fromBitmapData(bmd);
				char.name = names[i];
				_characters.push(char);
			}
			
			names = Label.getLabel("menu-objects-names").split(",");
			bmp = new _objsBmp() as Bitmap;
			src = bmp.bitmapData;
			len = names.length;
			rect = new Rectangle(0, 0, 100, 100);
			pt = new Point();
			_objects = new Vector.<ObjectItemData>();
			for(i = 0; i < len; ++i) {
				rect.x = i * 100;
				bmd = new BitmapData(100, 100, true, 0);
				bmd.copyPixels(src, rect, pt);
				bmd.lock();
				obj = new ObjectItemData();
				obj.image = new SerializableBitmapData();
				obj.image.fromBitmapData(bmd);
				obj.name = names[i];
				_objects.push(obj);
			}
		}
		
	}
}