package com.twinoid.kube.quest.editor.model {
	import com.twinoid.kube.quest.editor.views.NotificationView;
	import flash.external.ExternalInterface;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.editor.cmd.DeleteQuestCmd;
	import com.twinoid.kube.quest.editor.cmd.KeepSessionAliveCmd;
	import com.twinoid.kube.quest.editor.cmd.LoadQuestCmd;
	import com.twinoid.kube.quest.editor.cmd.LoginCmd;
	import com.twinoid.kube.quest.editor.cmd.SaveQuestCmd;
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
	import com.twinoid.kube.quest.editor.vo.UserInfo;
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
		private var _loginCmd:LoginCmd;
		private var _uid:String;
		private var _lang:String;
		private var _so:SharedObject;
		private var _charactersUpdate:Boolean;
		private var _objectsUpdate:Boolean;
		private var _comments:Vector.<GraphicsPath>;
		private var _commentsViewports:Vector.<Rectangle>;
		private var _saveCmd:SaveQuestCmd;
		private var _currentKuestGUID:String;
		private var _kuests:Vector.<KuestInfo>;
		private var _loadCmd:LoadQuestCmd;
		private var _ksaCmd:KeepSessionAliveCmd;
		private var _ksaInterval:uint;
		private var _lcManager:LCManager;
		private var _connectedToPlayer:Boolean;
		private var _forumPosition:Point3D;
		private var _cmdDelete:DeleteQuestCmd;
		private var _friends:Vector.<UserInfo>;
		private var _samples:Vector.<KuestInfo>;
		private var _debugMode : Boolean;
		private var _editing : Boolean;
		
		
		
		
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
		public function get currentKuestGUID():String { return _currentKuestGUID; }
		
		/**
		 * Gets the currently loaded kuest's info
		 */
		public function get currentKuest():KuestInfo {
			var i:int, len:int;
			len = _kuests == null? 0 : _kuests.length;
			for(i = 0; i < len; ++i) {
				if (_kuests[i].guid == _currentKuestGUID) return _kuests[i];
			}
			return null;
		}
		
		/**
		 * Gets the kuests list.
		 */
		public function get kuests():Vector.<KuestInfo> { return _kuests; }
		
		/**
		 * Gets the kuests samples list.
		 */
		public function get samples():Vector.<KuestInfo> { return _samples; }
		
		/**
		 * Gets the friends list
		 */
		public function get friends():Vector.<UserInfo> { return _friends; }
		
		/**
		 * Gets the debug mode state
		 */
		public function get debugMode():Boolean { return _debugMode; }
		



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
			
			
			login();
		}
		
		/**
		 * Adds an entry point to the scenario
		 */
		public function addEntryPoint(px:int, py:int, duplicateFrom:KuestEvent = null):void {
			_kuestData.addEntryPoint(px, py, duplicateFrom);
			update();
			flagChange();
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
		public function login():void {
			_loginCmd.execute();
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGING_IN));
		}
		
		/**
		 * Saves the current quest
		 */
		public function save(title:String, description:String, friends:Array, callback:Function, optimise:Boolean = false, updateMode:Boolean = false):void {
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
			XOR(bytes, optimise? "ErrorEvent :: kuest cannot be optimised..." : "ErrorEvent :: kuest cannot be saved...");//Shitty XOR key to loose hackers
			
			var maxSize:Number = Config.getNumVariable("maxFileSize");
			var currentSize:String = (bytes.length / 1024 / 1024).toPrecision(2);
			if(bytes.length > maxSize * 1024 * 1024) {
				callback(false);
				throw new KuestException(Label.getLabel("exception-MAX_SAVE_SIZE").replace(/\{MAX\}/gi, maxSize).replace(/\{SIZE\}/gi, currentSize), "MAX_SAVE_SIZE");
				return;
			}
			
			var guid:String = updateMode || optimise? _currentKuestGUID : "";
			_saveCmd.populate(title, description, bytes, friends, callback, guid, optimise);
			if(optimise) {
				prompt("menu-file-publish-promptTitle", "menu-file-publish-promptContent", _saveCmd.execute, "publish", callback);
			}else{
				_saveCmd.execute();
			}
			
			_editing = false;
			if(ExternalInterface.available) {
				ExternalInterface.call('Editor.setEditMode', false);
			}
		}
		
		/**
		 * Loads a quest
		 * 
		 * @return false if loading is ignored because map is already loaded
		 */
		public function load(kuest:KuestInfo, callback:Function, cancelCallback:Function):Boolean {
			if(kuest.guid == _currentKuestGUID) {
				return false;
			}
			
			_loadCmd.populate(kuest.guid, callback);
			if(_editing) {
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
		
		/**
		 * Deletes a quest.
		 */
		public function deleteSave(data:KuestInfo):void {
			_cmdDelete = new DeleteQuestCmd();
			_cmdDelete.populate(data.guid);
			prompt("menu-file-delete-prompt-title", "menu-file-delete-prompt-content", onDelete, "deleteKuest");
		}
		
		/**
		 * Sets the debug mode state
		 */
		public function setDebugMode(state:Boolean):void {
			_debugMode = state;
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.DEBUG_MODE_CHANGE, state));
		}
		
		/**
		 * Sets the debug start point
		 */
		public function setDebugStart(data:KuestEvent):void {
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.DEBUG_START_POINT, data));
		}
		
		/**
		 * Flags a change in the current quest.
		 * Prevent the browser from closing if editing something.
		 */
		public function flagChange():void {
			_editing = true;
			if(ExternalInterface.available) {
				ExternalInterface.call('Editor.setEditMode', true);
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
			_kuestData		= new KuestData(false);
			_inGamePosition	= new Point(int.MAX_VALUE, int.MAX_VALUE);
			
			_ksaCmd = new KeepSessionAliveCmd();//Don't care about succes/fail
			
			_loginCmd = new LoginCmd();
			_loginCmd.addEventListener(CommandEvent.COMPLETE, loginCompleteHandler);
			_loginCmd.addEventListener(CommandEvent.ERROR, loginErrorHandler);
			
			_saveCmd = new SaveQuestCmd();
			_saveCmd.addEventListener(CommandEvent.COMPLETE, saveCompleteHandler);
			_saveCmd.addEventListener(CommandEvent.ERROR, saveErrorHandler);
//			_saveCmd.addEventListener(ProgressEvent.PROGRESS, progessHandler);
			
			_loadCmd = new LoadQuestCmd();
			_loadCmd.addEventListener(CommandEvent.COMPLETE, loadKuestCompleteHandler);
			_loadCmd.addEventListener(CommandEvent.ERROR, loadKuestErrorHandler);
			_loadCmd.addEventListener(ProgressEvent.PROGRESS, progessHandler);
			
			if(_so.data["lang"] != null) {
				_lang = _so.data["lang"];
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
		private function update(...args):void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		/**
		 * Resets the quest
		 */
		private function reset():void {
			_editing = false;
			if(ExternalInterface.available) {
				ExternalInterface.call('Editor.setEditMode', false);
			}
			_comments = null;
			_currentKuestGUID = null;
			_currentBoxToEdit = null;
			_commentsViewports = null;
			_kuestData.reset();
			_charactersUpdate = _objectsUpdate = true;
			update();
			_charactersUpdate = _objectsUpdate = false;
		}
		
		/**
		 * Called when a quest deletion is confirmed.
		 */
		private function onDelete():void {
			_cmdDelete.execute();
			if(_cmdDelete.guid == _currentKuestGUID) _currentKuestGUID = null;
			var i:int, len:int;
			len = _kuests.length;
			for(i = 0; i < len; ++i) {
				if(_kuests[i].guid == _cmdDelete.guid) {
					_kuests.splice(i, 1);
					i --;
					len --;
				}
			}
			update();
		}

		
		
		
		
		
		
		
		//__________________________________________________________ SAVE HANDLERS
		
		/**
		 * Called when saving completes
		 */
		private function saveCompleteHandler(event:CommandEvent):void {
			_currentKuestGUID = event.data["guid"];
			var vo:KuestInfo = new KuestInfo(_saveCmd.title, _saveCmd.description, _currentKuestGUID, event.data["owner"], _saveCmd.friends, false, _uid);
			if (isEmpty(_saveCmd.guid)) {
				_kuests.unshift(vo);
			}else{
				var i:int, len:int;
				len = _kuests.length;
				for(i = 0; i < len; ++i) {
					if(!_kuests[i].isSample && _kuests[i].guid == _currentKuestGUID) {
						_kuests[i] = vo;
					}
				}
			}
			_saveCmd.callback(true, "", _saveCmd.publish? event.data["guid"] : 0);
			update();
			NotificationView.getInstance().notify(Label.getLabel('global-saveNotification'));
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
			Config.addVariable("uid", _uid);
			_kuests = event.data["kuests"] as Vector.<KuestInfo>;
			_samples = event.data["samples"] as Vector.<KuestInfo>;
			_friends = event.data["friends"] as Vector.<UserInfo>;
			
			_so.data["lang"] = event.data["lang"];
			_so.flush();
			
			//Keep the session alive
			clearInterval(_ksaInterval);
			_ksaInterval = setInterval(_ksaCmd.execute, 10 * 60*1000);//Every 10 minutes
			
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGIN_SUCCESS));
			update();
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
			try {
				var bytes:ByteArray = event.data as ByteArray;
				bytes.position = 0;
				XOR(bytes, "ErrorEvent :: kuest cannot be saved...");//Descrypt data
				bytes.inflate();
				bytes.position = 0;
				var fileVersion:int = bytes.readInt();
				fileVersion;
			}catch(e:Error) {
				_loadCmd.callback(false, "read");
				return;
			}
			
			_kuestData.deserialize(bytes);
			if(bytes.position < bytes.length) _comments = bytes.readObject();
			if(bytes.position < bytes.length) _commentsViewports = bytes.readObject();
			
			_currentKuestGUID = _loadCmd.guid;
			_charactersUpdate = _objectsUpdate = true;
			_loadCmd.callback(true);
			_editing = false;
			if(ExternalInterface.available) {
				ExternalInterface.call('Editor.setEditMode', false);
			}
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