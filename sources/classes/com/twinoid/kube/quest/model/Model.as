package com.twinoid.kube.quest.model {
	import by.blooddy.crypto.SHA1;

	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.cmd.LoadCmd;
	import com.twinoid.kube.quest.cmd.LoginCmd;
	import com.twinoid.kube.quest.cmd.SaveCmd;
	import com.twinoid.kube.quest.error.KuestException;
	import com.twinoid.kube.quest.events.ViewEvent;
	import com.twinoid.kube.quest.utils.prompt;
	import com.twinoid.kube.quest.vo.ActionChoices;
	import com.twinoid.kube.quest.vo.ActionDate;
	import com.twinoid.kube.quest.vo.ActionPlace;
	import com.twinoid.kube.quest.vo.ActionType;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.Dependency;
	import com.twinoid.kube.quest.vo.IItemData;
	import com.twinoid.kube.quest.vo.KuestData;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.vo.KuestInfo;
	import com.twinoid.kube.quest.vo.ObjectItemData;
	import com.twinoid.kube.quest.vo.SerializableBitmapData;
	import com.twinoid.kube.quest.vo.Version;

	import flash.display.GraphicsPath;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		private var _connectedToGame:Boolean;
		private var _isConnected:Boolean;
		private var _loginCmd:LoginCmd;
		private var _uid:String;
		private var _name:String;
		private var _pubkey:String;
		private var _so:SharedObject;
		private var _charactersUpdate:Boolean;
		private var _objectsUpdate:Boolean;
		private var _comments:Vector.<GraphicsPath>;
		private var _commentsViewports:Vector.<Rectangle>;
		private var _saveCmd:SaveCmd;
		private var _currentKuestId:String;
		private var _kuests:Vector.<KuestInfo>;
		private var _loadCmd:LoadCmd;
		
		
		
		
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
		 * Gets the user's ID
		 */
		public function get uid():String { return _uid; }

		/**
		 * Gets the user's pubkey
		 */
		public function get pubkey():String { return _pubkey; }
		
		/**
		 * Gets the shared object's reference
		 */
		public function get sharedObjects():SharedObject { return _so; }
		
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
		
		/**
		 * Gets the comments drawing data.
		 */
		public function get comments():Vector.<GraphicsPath> { return _comments; }
		
		/**
		 * Gets the comments drawing viewports.
		 */
		public function get commentsViewports():Vector.<Rectangle> { return _commentsViewports; }
		
		/**
		 * Gets the currently loaded kuest's ID
		 */
		public function get currentKuestId():String { return _currentKuestId; }
		
		/**
		 * Gets the kuests list.
		 */
		public function get kuests():Vector.<KuestInfo> { return _kuests; }
		



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
		public function save(title:String, description:String, callback:Function, optimise:Boolean = false):void {
			var chars:Vector.<CharItemData> = new Vector.<CharItemData>();
			var objs:Vector.<ObjectItemData> = new Vector.<ObjectItemData>();
			
			//Optimise the final file by removing unnecessary characters and objects.
			if(optimise) {
				//Grab only the used characters and objects.
				var i:int, len:int, item:IItemData;
				var charsDone:Object = {};
				var objsDone:Object = {};
				len = _kuestData.nodes.length;
				for(i = 0; i < len; ++i) {
					item = _kuestData.nodes[i].actionType == null? null : _kuestData.nodes[i].actionType.getItem();
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
				
			//Unoptimized save file.
			}else{
				objs = _kuestData.objects;
				chars = _kuestData.characters;
			}
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeInt(Version.CURRENT_FILE_VERSION);
			bytes.writeObject(chars);
			bytes.writeObject(objs);
			bytes.writeObject(_kuestData.nodes);
			bytes.writeObject(_comments);//Should be removed when file has to be optimized but it would actually be a quite useless weight gain
			bytes.writeObject(_commentsViewports);//Should be removed when file has to be optimized but it would actually be a quite useless weight gain
			bytes.deflate();
			XOR(bytes, "ErrorEvent :: kuest cannot be saved...");//Shitty XOR key to loose hackers
			
			_saveCmd.populate(title, description, bytes, callback, title == null && description == null? _currentKuestId : "", optimise);
			_saveCmd.execute();
		}
		
		/**
		 * Loads a quest
		 */
		public function load(kuest:KuestInfo, callback:Function):void {
			if(kuest.id == _currentKuestId) {
				callback(true);
				return;
			}
			
			_loadCmd.populate(kuest.id, callback);
			if(_kuestData.nodes.length > 0) {
				prompt("menu-file-load-prompt-title", "menu-file-load-prompt-content", _loadCmd.execute, "loadLooseData");
			}else{
				_loadCmd.execute();
			}
		}
		
		/**
		 * Saves the comments to the model
		 */
		public function saveComments(drawingPaths:Vector.<GraphicsPath>, viewports:Vector.<Rectangle>):void {
			_commentsViewports = viewports;
			_comments = drawingPaths;
		}
		
		/**
		 * Clears the current quest
		 */
		public function clear():void {
			if(_kuestData.nodes.length > 0) {
				prompt("menu-file-new-prompt-title", "menu-file-new-prompt-content", reset, "newLooseData");
			}else{
				reset();
			}
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
			
			_saveCmd = new SaveCmd();
			_saveCmd.addEventListener(CommandEvent.COMPLETE, saveCompleteHandler);
			_saveCmd.addEventListener(CommandEvent.ERROR, saveErrorHandler);
			
			_loadCmd = new LoadCmd();
			_loadCmd.addEventListener(CommandEvent.COMPLETE, loadKuestCompleteHandler);
			_loadCmd.addEventListener(CommandEvent.ERROR, loadKuestErrorHandler);
			
			if(_so.data["uid"] != null) {
				_uid = _so.data["uid"];
				_pubkey = _so.data["pubkey"];
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
		
		/**
		 * Resets the quest
		 */
		private function reset():void {
			_comments = null;
			_currentKuestId = null;
			_commentsViewports = null;
			_kuestData.reset();
			_charactersUpdate = _objectsUpdate = true;
			update();
			_charactersUpdate = _objectsUpdate = false;
		}

		
		
		
		
		//__________________________________________________________ SERIALIZE/DESERIALZE
		
		/**
		 * Test for serializable classes validity
		 */
		private function testSerializableClasses():void {
			//Check if the value objects are all serializable and registers aliases
			//so that ByteArray.readObject() can instanciate the value objects.
			var serializableClasses:Array = [Point, Date, GraphicsPath, Rectangle, String, Dependency, KuestEvent, ActionDate, ActionPlace, ActionType, ActionChoices, IItemData, ObjectItemData, CharItemData, SerializableBitmapData];
			var i:int, len:int;
			var j:int, lenJ:int;
			len = serializableClasses.length;
			for (i = 0; i < len; ++i) {
				
				var xml:XML = describeType(serializableClasses[i]);
				var nodes:XMLList = XML(xml.child("factory")[0]).child("accessor");
				var cName:String = String(xml.@name).replace(/.*::(.*)/gi, "$1");
				registerClassAlias(cName, serializableClasses[i]);
				
				if(serializableClasses[i] != Point
				&& serializableClasses[i] != Date
				&& serializableClasses[i] != String) {
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
			_kuestData.deserialize(bytes);
			//*/
		}

		
		
		
		
		//__________________________________________________________ SAVE HANDLERS
		
		/**
		 * Called when saving completes
		 */
		private function saveCompleteHandler(event:CommandEvent):void {
			_currentKuestId = event.data["id"];
			//If title and description are null, that's because we updated an existing kuest.
			if(_saveCmd.title != null && _saveCmd.description != null) {
				_kuests.push(new KuestInfo(_saveCmd.title, _saveCmd.description, _currentKuestId));
			}
			_saveCmd.callback(true);
			update();
		}
		
		/**
		 * Called if saving fails
		 */
		private function saveErrorHandler(event:CommandEvent):void {
			_saveCmd.callback(false, event.data);
			throw new KuestException(Label.getLabel("exception-"+event.data as String), event.data as String);
		}

		
		
		
		
		//__________________________________________________________ LOGIN HANDLERS
		
		/**
		 * Called when login operation completes
		 */
		private function loginCompleteHandler(event:CommandEvent):void {
			_uid = event.data["uid"];
			_name = event.data["name"];
			_pubkey = event.data["pubkey"];
			_kuests = event.data["kuests"] as Vector.<KuestInfo>;
			
			_so.data["uid"] = _uid;
			_so.data["pubkey"] = _pubkey;
			_so.flush();
			
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_SUCCESS));
		}

		/**
		 * Called if login operation fails
		 */
		private function loginErrorHandler(event:CommandEvent):void {
			var errorCode:String = event.data as String;
			if(errorCode == "INVALID_IDS") {
				ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_FAIL, event.data));
			}else{
				throw new KuestException(Label.getLabel("exception-"+errorCode), errorCode);
			}
		}

		
		
		
		
		//__________________________________________________________ LOADING HANDLERS
		
		/**
		 * Called when a map's loading completes
		 */
		private function loadKuestCompleteHandler(event:CommandEvent):void {
			var bytes:ByteArray = event.data as ByteArray;
			bytes.position = 0;
			XOR(bytes, "ErrorEvent :: kuest cannot be saved...");//Descrypt data
			bytes.inflate();
			bytes.position = 0;
			var fileVersion:int = bytes.readInt();
			
			_kuestData.deserialize(bytes);
			if(bytes.position < bytes.length) _comments = bytes.readObject();
			if(bytes.position < bytes.length) _commentsViewports = bytes.readObject();
			
			_currentKuestId = _loadCmd.id;
			_charactersUpdate = _objectsUpdate = true;
			_loadCmd.callback(true);
			update();
			_charactersUpdate = _objectsUpdate = false;
		}
		
		/**
		 * Called if loading fails
		 */
		private function loadKuestErrorHandler(event:CommandEvent):void {
			_loadCmd.callback(false, errorCode);
			var errorCode:String = event.data as String;
			throw new KuestException(Label.getLabel("exception-"+errorCode), errorCode);
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
		
	}
}