package com.twinoid.kube.quest.editor.model {
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.editor.cmd.KeepSessionAliveCmd;
	import com.twinoid.kube.quest.editor.cmd.LoadCmd;
	import com.twinoid.kube.quest.editor.cmd.LoginCmd;
	import com.twinoid.kube.quest.editor.cmd.SaveCmd;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.events.LCManagerEvent;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.utils.initSerializableClasses;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.vo.CharItemData;
	import com.twinoid.kube.quest.editor.vo.IItemData;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.KuestInfo;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.editor.vo.Version;

	import flash.display.GraphicsPath;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;



	/**
	 * Application's model.
	 * 
	 * @author francois.dursus
	 * @date 3 mai 2012;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _inGamePosition:Point;
		private var _kuestData:KuestData;
		private var _currentBoxToEdit:KuestEvent;
		private var _connectedToGame:Boolean;
		private var _isConnected:Boolean;
		private var _loginCmd:LoginCmd;
		private var _uid:String;
		private var _name:String;
		private var _pubkey:String;
		private var _lang:String;
		private var _so:SharedObject;
		private var _charactersUpdate:Boolean;
		private var _objectsUpdate:Boolean;
		private var _comments:Vector.<GraphicsPath>;
		private var _commentsViewports:Vector.<Rectangle>;
		private var _saveCmd:SaveCmd;
		private var _currentKuestId:String;
		private var _kuests:Vector.<KuestInfo>;
		private var _loadCmd:LoadCmd;
		private var _ksaCmd:KeepSessionAliveCmd;
		private var _ksaInterval:uint;
		private var _lcManager:LCManager;
		private var _connectedToPlayer:Boolean;
		private var _forumPosition:Point3D;
		
		
		
		
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
		 * Gets if the application is connected to the kuest player
		 */
		public function get connectedToPlayer():Boolean { return _connectedToPlayer; }
		
		/**
		 * Gets the last touched forum position.
		 */
		public function get forumPosition():Point3D { return _forumPosition; }
		
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
			initSerializableClasses();
			
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
			
			var maxSize:Number = Config.getNumVariable("maxFileSize");
			var currentSize:String = (bytes.length / 1024 / 1024).toPrecision(2);
			if(bytes.length > maxSize * 1024 * 1024) {
				callback(false);
				throw new KuestException(Label.getLabel("exception-MAX_SAVE_SIZE").replace(/\{MAX\}/gi, maxSize).replace(/\{SIZE\}/gi, currentSize), "MAX_SAVE_SIZE");
				return;
			}
			
			_saveCmd.populate(title, description, bytes, callback, title == null && description == null? _currentKuestId : "", optimise);
			if(optimise) {
				prompt("menu-file-publish-promptTitle", "menu-file-publish-promptContent", _saveCmd.execute, "publish", callback);
			}else{
				_saveCmd.execute();
			}
		}
		
		/**
		 * Loads a quest
		 * 
		 * @return false if loading is ignored because map is already loaded
		 */
		public function load(kuest:KuestInfo, callback:Function, cancelCallback:Function):Boolean {
			if(kuest.id == _currentKuestId) {
				return false;
			}
			
			_loadCmd.populate(kuest.id, callback);
			if(_kuestData.nodes.length > 0) {
				prompt("menu-file-load-prompt-title", "menu-file-load-prompt-content", _loadCmd.execute, "loadLooseData", cancelCallback);
			}else{
				_loadCmd.execute();
			}
			return true;
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
			_so				= SharedObject.getLocal("kuest", "/");
			_kuestData		= new KuestData();
			_inGamePosition	= new Point(int.MAX_VALUE, int.MAX_VALUE);
			_isConnected	= !isEmpty(Config.getVariable("uid")) && !isEmpty(Config.getVariable("pubkey"));
			
			_ksaCmd = new KeepSessionAliveCmd();//Don't care about succes/fail
			
			_loginCmd = new LoginCmd();
			_loginCmd.addEventListener(CommandEvent.COMPLETE, loginCompleteHandler);
			_loginCmd.addEventListener(CommandEvent.ERROR, loginErrorHandler);
			
			_saveCmd = new SaveCmd();
			_saveCmd.addEventListener(CommandEvent.COMPLETE, saveCompleteHandler);
			_saveCmd.addEventListener(CommandEvent.ERROR, saveErrorHandler);
//			_saveCmd.addEventListener(ProgressEvent.PROGRESS, progessHandler);
			
			_loadCmd = new LoadCmd();
			_loadCmd.addEventListener(CommandEvent.COMPLETE, loadKuestCompleteHandler);
			_loadCmd.addEventListener(CommandEvent.ERROR, loadKuestErrorHandler);
			_loadCmd.addEventListener(ProgressEvent.PROGRESS, progessHandler);
			
			if(_so.data["lang"] != null) {
				_uid = _so.data["uid"];
				_lang = _so.data["lang"];
				_pubkey = _so.data["pubkey"];
				
				if(!_isConnected) {
					Config.addVariable("uid", _so.data["uid"]);
					Config.addVariable("lang", _so.data["lang"]);
					Config.addVariable("pubkey", _so.data["pubkey"]);
					_isConnected = true;
				}
			}
			
			//================
			//LOCAL CONNECTION
			//================
			_lcManager = new LCManager();
			_lcManager.addEventListener(LCManagerEvent.ZONE_CHANGE, zoneChangeHandler);
			_lcManager.addEventListener(LCManagerEvent.FORUM_TOUCHED, forumTouchedHandler);
			_lcManager.addEventListener(LCManagerEvent.GAME_CONNECTION_STATE_CHANGE, gameConnectionChangeHandler);
			_lcManager.addEventListener(LCManagerEvent.PLAYER_CONNECTION_STATE_CHANGE, playerConnectionChangeHandler);
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
			_currentBoxToEdit = null;
			_commentsViewports = null;
			_kuestData.reset();
			_charactersUpdate = _objectsUpdate = true;
			update();
			_charactersUpdate = _objectsUpdate = false;
		}

		
		
		
		
		
		
		
		//__________________________________________________________ SAVE HANDLERS
		
		/**
		 * Called when saving completes
		 */
		private function saveCompleteHandler(event:CommandEvent):void {
			_currentKuestId = event.data["id"];
			//If title and description are null, that's because we updated an existing kuest.
			if(_saveCmd.title != null && _saveCmd.description != null) {
				_kuests.unshift(new KuestInfo(_saveCmd.title, _saveCmd.description, _currentKuestId));
			}
			_saveCmd.callback(true, "", _saveCmd.publish? event.data["guid"] : 0);
			update();
		}
		
		/**
		 * Called if saving fails
		 */
		private function saveErrorHandler(event:CommandEvent):void {
			_saveCmd.callback(false, event.data);
			throw new KuestException(Label.getLabel("exception-"+event.data), String(event.data));
		}
		
		/**
		 * Called when a command progression changes
		 */
		private function progessHandler(event:ProgressEvent):void {
			var percent:Number = event.bytesLoaded/event.bytesTotal;
			if(event.target == _saveCmd) {
				_saveCmd.callback(false, null, percent);
			}else{
				_loadCmd.callback(false, null, percent);
			}
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
			_so.data["lang"] = event.data["lang"];
			_so.data["pubkey"] = _pubkey;
			_so.flush();
			
			//Keep the session alive
			clearInterval(_ksaInterval);
			_ksaInterval = setInterval(_ksaCmd.execute, 10 * 60*1000);//Every 10 minutes
			
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_SUCCESS));
		}

		/**
		 * Called if login operation fails
		 */
		private function loginErrorHandler(event:CommandEvent):void {
			var errorCode:String = String(event.data);
			clearInterval(_ksaInterval);
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_FAIL, errorCode));
			if (errorCode != "INVALID_IDS") {
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
			fileVersion;
			
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
			var errorCode:String = String(event.data);
			throw new KuestException(Label.getLabel("exception-"+errorCode), errorCode);
		}

		
		
		
		
		//__________________________________________________________ LocalConnection HANDLERS
		
		/**
		 * Called when user enters a new zone.
		 */
		private function zoneChangeHandler(event:LCManagerEvent):void {
			_inGamePosition = _lcManager.inGamePosition;
			update();
		}

		/**
		 * Called when game's connection state changes.
		 */
		private function gameConnectionChangeHandler(event:LCManagerEvent):void {
			_connectedToGame = _lcManager.connectedToGame;
			update();
		}
		
		/**
		 * Called when user touches a forum kube
		 */
		private function forumTouchedHandler(event:LCManagerEvent):void {
			_forumPosition = _lcManager.forumPosition;
			update();
		}

		/**
		 * Called when connection state to kuest player changes.
		 */
		private function playerConnectionChangeHandler(event:LCManagerEvent):void {
			_connectedToPlayer = _lcManager.connectedToPlayer;
			update();
		}
		
	}
}