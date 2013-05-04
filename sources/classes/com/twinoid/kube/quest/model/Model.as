package com.twinoid.kube.quest.model {
	import com.nurun.utils.commands.BrowseForFileCmd;
	import flash.net.FileReference;
	import by.blooddy.crypto.SHA1;

	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.twinoid.kube.quest.cmd.LoginCmd;
	import com.twinoid.kube.quest.events.ViewEvent;
	import com.twinoid.kube.quest.vo.ActionDate;
	import com.twinoid.kube.quest.vo.ActionPlace;
	import com.twinoid.kube.quest.vo.ActionType;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.vo.KuestData;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.vo.ObjectItemData;
	import com.twinoid.kube.quest.vo.SerializableBitmapData;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.setTimeout;

	
	/**
	 * Application's model.
	 * 
	 * @author francois.dursus
	 * @date 3 mai 2012;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _lcName:String;
		private var _receiver:LocalConnection;
		private var _sender:LocalConnection;
		private var _inGamePosition:Point;
		private var _checkTimeout:uint;
		private var _connectTimeout:uint;
		private var _kuestData:KuestData;
		private var _currentBoxToEdit:KuestEvent;
//		private var _objects:Vector.<ObjectItemData>;
//		private var _characters:Vector.<CharItemData>;
		private var _connectedToGame:Boolean;
		private var _isConnected:Boolean;
		private var _loginCmd:LoginCmd;
		private var _uid:String;
		private var _name:String;
		private var _pubkey:String;
		private var _so:SharedObject;
		private var _charactersUpdate:Boolean;
		private var _objectsUpdate:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Model</code>.
		 */
		public function Model() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the data tree
		 */
		public function get kuestData():KuestData { return _kuestData; }
		
		/**
		 * Gets the current box data to edit.
		 */
		public function get currentBoxToEdit():KuestEvent { return _currentBoxToEdit; }
		
		/**
		 * Gets the objects list
		 */
		public function get objects():Vector.<ObjectItemData> { return _kuestData.objects; }

		/**
		 * Gets the characters list
		 */
		public function get characters():Vector.<CharItemData> { return _kuestData.characters; }
		
		/**
		 * Gets the in game's position.
		 */
		public function get inGamePosition():Point { return _inGamePosition; }
		
		/**
		 * Gets if the application is connected to the Kube game.
		 */
		public function get connectedToGame():Boolean { return _connectedToGame && _inGamePosition.x != int.MAX_VALUE && _inGamePosition.y != int.MAX_VALUE; }
		
		/**
		 * Gets if there has been an update in the characters list.
		 */
		public function get charactersUpdate():Boolean { return _charactersUpdate; }
		
		/**
		 * Gets if there has been an update in the objects list.
		 */
		public function get objectsUpdate():Boolean { return _objectsUpdate; }
		



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Stats the application
		 */
		public function start():void {
			_isConnected = !isEmpty(Config.getVariable("uid")) && !isEmpty(Config.getVariable("pubkey"));
			
			testSerializableClasses();
			
			_charactersUpdate = _objectsUpdate = true;
			update();
			_charactersUpdate = _objectsUpdate = false;
			
			
			if(_isConnected) {
				_loginCmd.populate(Config.getVariable("uid"), Config.getVariable("pubkey"));
				_loginCmd.execute();
				ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGING_IN));
			}
		}
		
		/**
		 * Adds an entry point to the scenario
		 */
		public function addEntryPoint(px:int, py:int):void {
			_kuestData.addEntryPoint(px, py);
			update();
		}
		
		/**
		 * Deletes a node from the kuest
		 */
		public function deleteNode(data:KuestEvent):void {
			_kuestData.deleteNode(data);
		}
		
		/**
		 * Starts a box edition
		 */
		public function edit(data:KuestEvent):void {
			_currentBoxToEdit = data;
			update();
		}
		
		/**
		 * Cancels the current box edition
		 */
		public function cancelBoxEdition():void {
			_currentBoxToEdit = null;
			update();
		}
		
		/**
		 * Deletes a character
		 */
		public function deleteCharacter(item:CharItemData):void {
			_kuestData.deleteCharacter(item);
			_charactersUpdate = true;
			update();
			_charactersUpdate = false;
		}
		
		/**
		 * Deletes an object
		 */
		public function deleteObject(item:ObjectItemData):void {
			_kuestData.deleteObject(item);
			_objectsUpdate = true;
			update();
			_objectsUpdate = false;
		}
		
		/**
		 * Adds a character
		 */
		public function addCharacter():void {
			_kuestData.addCharacter();
			_charactersUpdate = true;
			update();
			_charactersUpdate = false;
		}
		
		/**
		 * Adds an object
		 */
		public function addObject():void {
			_kuestData.addObject();
			_objectsUpdate = true;
			update();
			_objectsUpdate = false;
		}
		
		/**
		 * Logs the user in.
		 */
		public function login(uid:String, pubkey:String):void {
			_loginCmd.populate(uid, pubkey);
			_loginCmd.execute();
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGING_IN));
		}
		
		/**
		 * Saves the current quest
		 */
		public function save():void {
			//Grab only the used characters and objects.
			//TODO probably remove this. With this optimization we loose the potentially configured items for later use. 
			var i:int, len:int, item:IItemData;
			var chars:Vector.<CharItemData> = new Vector.<CharItemData>();
			var objs:Vector.<ObjectItemData> = new Vector.<ObjectItemData>();
			var charsDone:Object = {};
			var objsDone:Object = {};
			len = _kuestData.nodes.length;
			for(i = 0; i < len; ++i) {
				item = _kuestData.nodes[i].actionType.getItem();
				if(item == null) continue;
				if(item is CharItemData) {
					if(charsDone[item.guid] == undefined) {
						charsDone[item.guid] = true;
						chars.push(item);
					}
				}else
				if(item is ObjectItemData) {
					if(objsDone[item.guid] == undefined) {
						objsDone[item.guid] = true;
						objs.push(item);
					}
				}
			}
			
			//TODO save to the server
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(chars);
			bytes.writeObject(objs);
			bytes.writeObject(_kuestData.nodes);
			bytes.deflate();
			new FileReference().save(bytes, "kuest.kst");
		}
		
		/**
		 * Saves the current quest
		 */
		public function load():void {
			//TODO load from the server
			var cmd:BrowseForFileCmd = new BrowseForFileCmd("Kuest file", "*.kst");
			cmd.addEventListener(CommandEvent.COMPLETE, loadKuestCompleteHandler);
			cmd.execute();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_so = SharedObject.getLocal("kuest");
			
			_kuestData = new KuestData();
			_inGamePosition = new Point(int.MAX_VALUE, int.MAX_VALUE);
			
			_loginCmd = new LoginCmd();
			_loginCmd.addEventListener(CommandEvent.COMPLETE, loginCompleteHandler);
			_loginCmd.addEventListener(CommandEvent.ERROR, loginErrorHandler);
			
			if(_so.data["uid"] != null) {
				Config.addVariable("uid", _so.data["uid"]);
				Config.addVariable("pubkey", _so.data["pubkey"]);
			}
			
			//================
			//LOCAL CONNECTION
			//================
			_lcName = "_kuest_"+SHA1.hash(Math.random()+""+Math.random())+"_";
			
			//using anonymous objects provides a way not to break callbacks in case
			//of code obfuscation.
			var client:Object = {};
			client["_updatePos"] = onUpdatePosition;
			client["_action"] = onAction;
			
			_receiver = new LocalConnection();
			_sender = new LocalConnection();
			_sender.addEventListener(StatusEvent.STATUS, statusHandler);
			_receiver.client = client;
			_receiver.allowDomain("*");
			try {
				_receiver.connect(_lcName);
			}catch(error:Error) {
				trace("ERROR :: A connection with the same name is already active");
			}
			attemptToConnect();
		}
		
		/**
		 * Fires an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}

		
		
		
		
		//__________________________________________________________ SERIALIZE/DESERIALZE
		
		/**
		 * Test for serializable classes validity
		 */
		private function testSerializableClasses():void {
			//Check if the value objects are all serializable and registers aliases
			//so that ByteArray.readObject() can instanciate the value objects.
			var serializableClasses:Array = [Point, Date, KuestEvent, ActionDate, ActionPlace, ActionType, IItemData, ObjectItemData, CharItemData, SerializableBitmapData];
			var i:int, len:int;
			var j:int, lenJ:int;
			len = serializableClasses.length;
			for (i = 0; i < len; ++i) {
				
				var xml:XML = describeType(serializableClasses[i]);
				var nodes:XMLList = XML(xml.child("factory")[0]).child("accessor");
				var cName:String = String(xml.@name).replace(/.*::(.*)/gi, "$1");
				registerClassAlias(cName, serializableClasses[i]);
				
				if(serializableClasses[i] != Point && serializableClasses[i] != Date) {
					lenJ = nodes.length();
					for(j = 0; j < lenJ; ++j) {
						if(nodes[j].@access != "readwrite") {
							trace("Class "+cName+"'s '"+nodes[j].@name+"' property is '"+nodes[j].@access+"'. Must be 'readwrite'.");
						}
					}
				}
			}
			
			/*
			var c:Vector.<KuestEvent> = new Vector.<KuestEvent>();
			var e1:KuestEvent = new KuestEvent();
			e1.boxPosition = new Point(69,96);
			e1.actionDate = new ActionDate();
			e1.actionDate.days = [0,1,4];
			e1.actionDate.startTime = 12;
			e1.actionDate.endTime = 82;
			
			e1.actionPlace = new ActionPlace();
			e1.actionPlace.x = 42;
			e1.actionPlace.y = 43;
			e1.actionPlace.z = 44;
			
			e1.actionType = new ActionType();
			e1.actionType.type = ActionType.TYPE_CHARACTER;
			e1.actionType.setItem(_kuestData.characters[0]);
			e1.actionType.text = "Zizi !!";
			
			//====================
			
			var e2:KuestEvent = new KuestEvent();
			e2.actionDate = new ActionDate();
			e2.actionDate.dates = new <Date>[new Date()];
			e2.actionDate.startTime = 12;
			e2.actionDate.endTime = 82;
			
			e2.actionPlace = new ActionPlace();
			e2.actionPlace.x = 89;
			e2.actionPlace.y = 12;
			e2.actionPlace.z = 8;
			
			e2.actionType = new ActionType();
			e2.actionType.type = ActionType.TYPE_OBJECT;
			e2.actionType.setItem(_kuestData.objects[0]);
			e2.actionType.text = "Cacaaa !!";
			e2.addDependency(e1);
			
			c.push(e1);
			c.push(e2);
			
			//Simulate serialization / deserialization just to be sure everything's ok.
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(_kuestData.characters);
			bytes.writeObject(_kuestData.objects);
			bytes.writeObject(c);
			bytes.deflate();
			
			bytes.inflate();
//			_kuestData = new KuestData();
			_kuestData.deserialize(bytes);
			//*/
		}

		
		
		
		
		//__________________________________________________________ LOGIN HANDLERS
		
		/**
		 * Called when login operation completes
		 */
		private function loginCompleteHandler(event:CommandEvent):void {
			_uid = event.data["uid"];
			_name = event.data["name"];
			_pubkey = event.data["pubkey"];
			
			_so.data["uid"] = _uid;
			_so.data["pubkey"] = _pubkey;
			_so.flush();
			
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_SUCCESS));
		}

		/**
		 * Called if login operation fails
		 */
		private function loginErrorHandler(event:CommandEvent):void {
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_FAIL, event.data));
		}

		
		
		
		
		//__________________________________________________________ LocalConnection HANDLERS
		
		/**
		 * Attempts to connect to the game
		 */
		private function attemptToConnect():void {
			_sender.send("_lc_mx_kube_", "_requestUpdates", _lcName);
		}
		
		/**
		 * Attempts to connect to the game
		 */
		private function checkForConnection():void {
			setText(null);
		}
		
		private function setText(txt:String):void {
			_sender.send("_lc_mx_kube_", "_setText", txt, "");
		}

		/**
		 * Called when player enters a new zone
		 */
		private function onUpdatePosition(px:int, py:int):void {
			if(px == 0xffffff && py == 0xffffff) return; //first undefined coord fired by the game. Ignore it.
			_inGamePosition.x = px;
			_inGamePosition.y = py;
			update();
		}
		 
		/**
		 * Called when tuto's popin button is clicked.
		 */
		private function onAction():void {
			trace("On ACTION");
		}
 
		/**
		 * Called if a data sending succeeds or fails.
		 */
		private function statusHandler(event:StatusEvent):void {
			clearTimeout(_checkTimeout);
			clearTimeout(_connectTimeout);
			switch (event.level) {
				case "status":
				//sending success!
				if(!_connectedToGame) {
					_connectedToGame = true;
					update();
				}
				_checkTimeout = setTimeout(checkForConnection, 1000);
				break;
			case "error":
				if(_connectedToGame) {
					_connectedToGame = false;
					update();
				}
				_connectTimeout = setTimeout(attemptToConnect, 500);
				break;
			}
		}
		
		/**
		 * Called when a map's loading completes
		 */
		private function loadKuestCompleteHandler(event:CommandEvent):void {
			var bytes:ByteArray = event.data as ByteArray;
			bytes.inflate();
//			_kuestData = new KuestData();
			_kuestData.deserialize(bytes);
			_charactersUpdate = _objectsUpdate = true;
			update();
			_charactersUpdate = _objectsUpdate = false;
		}
		
	}
}