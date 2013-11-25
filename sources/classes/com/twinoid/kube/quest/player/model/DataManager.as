package com.twinoid.kube.quest.player.model {
	import com.nurun.core.commands.SequentialCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.editor.cmd.KeepSessionAliveCmd;
	import com.twinoid.kube.quest.editor.cmd.LoadQuestCmd;
	import com.twinoid.kube.quest.editor.cmd.LoginCmd;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.events.LCManagerEvent;
	import com.twinoid.kube.quest.editor.utils.initSerializableClasses;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.cmd.ClearProgressionCmd;
	import com.twinoid.kube.quest.player.cmd.IsLoggedCmd;
	import com.twinoid.kube.quest.player.cmd.LoadKuestDetailsCmd;
	import com.twinoid.kube.quest.player.cmd.LoadProgressionCmd;
	import com.twinoid.kube.quest.player.cmd.SaveProgressionCmd;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.events.QuestManagerEvent;
	import com.twinoid.kube.quest.player.vo.InventoryObject;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	
	/**
	 * Singleton DataManager
	 * 
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	public class DataManager extends EventDispatcher {
		
		private static var _instance:DataManager;
		private var _timer:Timer;
		private var _lcSend:LocalConnection;
		private var _lcReceive:LocalConnection;
		private var _lcClientNames:Array;
		private var _loadKuestCmd:LoadQuestCmd;
		private var _kuest:KuestData;
		private var _loadDetailsCmd:LoadKuestDetailsCmd;
		private var _progressCallback:Function;
		private var _title:String;
		private var _description:String;
		private var _isLoggedCmd:IsLoggedCmd;
		private var _logged:Boolean;
		private var _ksaCmd:KeepSessionAliveCmd;
		private var _ksaInterval:uint;
		private var _pseudo:String;
		private var _lang:String;
		private var _lcGameName:String;
		private var _senderGame:LocalConnection;
		private var _receiverGame:LocalConnection;
		private var _checkTimeoutGame:uint;
		private var _connectTimeoutGame:uint;
		private var _connectedToGame:Boolean;
		private var _inGamePosition:Point;
		private var _lcName:String;
		private var _lcKillCallbackReceive:LocalConnection;
		private var _loadProgressionCmd:LoadProgressionCmd;
		private var _timeoutSave:uint;
		private var _saveProgressionCmd:SaveProgressionCmd;
		private var _currentQuestGUID:String;
		private var _clearProgression:ClearProgressionCmd;
		private var _testMode:Boolean;
		private var _so:SharedObject;
		private var _pubkey:String;
		private var _date:Date;
		private var _time:Number;
		private var _lastTouchPosition:Point3D;
		private var _questManager:QuestManager;
		private var _save:ByteArray;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DataManager</code>.
		 */
		public function DataManager(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():DataManager {
			if(_instance == null)_instance = new  DataManager(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Gets the quest data
		 */
		public function get kuest():KuestData { return _kuest; }
		
		/**
		 * Gets the quest's title
		 */
		public function get title():String { return _title; }

		/**
		 * Gets the quest's description
		 */
		public function get description():String { return _description; }
		
		/**
		 * Gets if the user's logged or not
		 */
		public function get logged():Boolean { return _logged; }
		
		/**
		 * Gets if we are in test mode
		 */
		public function get testMode():Boolean { return _testMode; }
		
		/**
		 * Gets the user's name
		 */
		public function get pseudo():String { return _pseudo; }
		
		/**
		 * Gets the user's language
		 */
		public function get lang():String { return _lang; }
		
		/**
		 * Gets the current event
		 */
		public function get currentEvent():KuestEvent { return _questManager.currentEvent; }
		
		/**
		 * Gets the current date
		 */
		public function get currentDate():Date {
			if(_testMode) return new Date();
			_date.time = _time + getTimer();
			return _date;
		}
		
		/**
		 * Gets the inventory objects.
		 */
		public function get objects():Vector.<InventoryObject> {
			var inventory:Vector.<InventoryObject> = _questManager.inventory;
			var ret:Vector.<InventoryObject> = new Vector.<InventoryObject>();
			var i:int, len:int;
			len = inventory.length;
			for(i = 0; i < len; ++i) {
				if(inventory[i].unlocked) ret.push(inventory[i]);
			}
			return ret;
		}
		
		/**
		 * Gets the user's pubkey
		 */
		public function get pubkey():String { return _pubkey; }
		
		/**
		 * Gets the current quest's guid
		 */
		public function get currentQuestGUID():String { return _currentQuestGUID; }
		
		
		
		
		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(progressCallback:Function):void {
			_questManager		= new QuestManager();
			_inGamePosition		= new Point(int.MAX_VALUE, int.MAX_VALUE);
			_progressCallback	= progressCallback;
			_so = SharedObject.getLocal("_kuestPlayer_", "/");
			initSerializableClasses();
			
			_questManager.addEventListener(QuestManagerEvent.READY, questReadyHandler);
			_questManager.addEventListener(QuestManagerEvent.NEW_EVENT, newEventHandler);
			_questManager.addEventListener(QuestManagerEvent.WRONG_SAVE_FILE_FORMAT, saveLoadingErrorHandler);
			
			initLocalConnections();
			
			//Local debugging
			if(Capabilities.playerType == "StandAlone") {
				//XXX repère local conf
				//structure tester - 51a272f115f96
				//MlleNolwenn - 51a1e15e398b4
				//TFS bordel - 519e7fe42ff5a
				//Test Lilith - 51a207ff98070
				//Cristal Atlante - 5194100a4a94f
				//Tubasa labyrinthe - 51aa7b6cbe1ef
				//MlleGray _Tom - 51ec728f16b49
				//4) Exemple poser/prendre objets - 51ad12eca65b6
				Config.addVariable("kuestID", "51ec728f16b49");
				Config.addVariable("currentUID", "48");
				Config.addVariable("testMode", 'true');
			}
			
			loadCurrentQuest();
		}
		
		/**
		 * Called when a new event is available
		 */
		private function newEventHandler(event:QuestManagerEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
		}
		
		/**
		 * Loads the current quest.
		 */
		private function loadCurrentQuest():void {
			if(!isEmpty(Config.getVariable("kuestID"))) {
				_testMode			= Config.getBooleanVariable("testMode");
				_currentQuestGUID	= Config.getVariable("kuestID");
				_so.data["test"]	= _testMode;
				_so.data["guid"]	= _currentQuestGUID;
			}else{
				_testMode			= _so.data["test"];
				_currentQuestGUID	= _so.data["guid"];
			}
			if(isEmpty(_currentQuestGUID)) {
				if(ExternalInterface.available) ExternalInterface.call("noQuest");
				return;
			}
			if(_currentQuestGUID != null) {
				var spool:SequentialCommand = new SequentialCommand();
				if(Capabilities.playerType == "StandAlone") {
					//Force login if testing locally as sessions are fucked up in standalone mode...
					var login:LoginCmd = new LoginCmd();
					login.addEventListener(CommandEvent.ERROR, loginErrorHandler);
					spool.addCommand(login);
				}
				_isLoggedCmd = new IsLoggedCmd();
				_isLoggedCmd.addEventListener(CommandEvent.COMPLETE, loginCompleteHandler);
				_isLoggedCmd.addEventListener(CommandEvent.ERROR, loginErrorHandler);
				spool.addCommand(_isLoggedCmd);
				spool.execute();
			}else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NO_KUEST_SELECTED));
			}
		}
		
		/**
		 * Initializes the local connections stuff.
		 */
		private function initLocalConnections():void {_lcClientNames = [];
			_lcSend = new LocalConnection();
			_lcSend.addEventListener(StatusEvent.STATUS, statusHandler);
			
			var client:Object = {};
			client["_kill"]					= killLC;
			client["_onKill"]				= onKill;
			client["_requestUpdates"]		= requestForumUpdates;
			client["_checkForConnection"]	= connectCheck;
			
			_lcName = "_lc_kuest_";
			_lcReceive = new LocalConnection();
			
			_lcReceive.client = client;
			_lcReceive.allowDomain("*");
			try {
				_lcReceive.connect(_lcName);
			} catch(error:Error) {
				//Connection is already active.
				//Ask to the existing connection to close itself and wait for its
				//callback before trying to connect again.
				var connectionName:String = "_kuest_LCkiller_"+new Date().getTime()+"_";
				_lcKillCallbackReceive = new LocalConnection();
				_lcKillCallbackReceive.allowDomain("*");
				_lcKillCallbackReceive.client = client;
				_lcKillCallbackReceive.connect(connectionName);
				_lcSend.send("_lc_kuest_", "_kill", connectionName);
			}
				
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, ticTimerHandler);
			
			_lcGameName = "_kuestGame_"+new Date().getTime()+"_";
			
			//using anonymous objects provides a way not to break callbacks in case
			//of code obfuscation.
			client = {};
			client["_updatePos"]	= onUpdatePosition;
			client["_action"]		= onAction;
			client["_touchForum"]	= onTouchForum;
			
			_senderGame = new LocalConnection();
			_senderGame.addEventListener(StatusEvent.STATUS, statusHandler);
			
			_receiverGame = new LocalConnection();
			_receiverGame.client = client;
			_receiverGame.allowDomain("*");
			_receiverGame.connect(_lcGameName);
		}
		
		/**
		 * Answers a question
		 */
		public function answer(index:int):void {
			_questManager.completeEvent(index);
			
			//Send to server after a short delay to prevent from save spamming
			clearTimeout(_timeoutSave);
			_timeoutSave = setTimeout(onSaveProgression, 3000);
		}
		
		/**
		 * Load next event
		 */
		public function next():void {
			_questManager.completeEvent();
			
			//Send to server after a short delay to prevent from save spamming
			clearTimeout(_timeoutSave);
			_timeoutSave = setTimeout(onSaveProgression, 3000);
		}
		
		/**
		 * Simulates a zone change
		 */
		public function simulateZoneChange(x:Number, y:Number):void {
			_inGamePosition = new Point(x,y);
			onZoneChange();
		}
		
		/**
		 * Simulate a forum touch
		 */
		public function simulateForumChange(x:Number, y:Number, z:Number):void {
			_lastTouchPosition = new Point3D(x,y,z);
			onTouchForum();
		}
		
		/**
		 * Clears the user's progression.
		 */
		public function clearProgression():void {
			_clearProgression.populate(_currentQuestGUID);
			if(_testMode) {
				_clearProgression.execute();
			}else{
				prompt("player-resetTitle", "player-resetContent", _clearProgression.execute, "resetQuest");
			}
		}
		
		/**
		 * Use an object
		 */
		public function useObject(data:InventoryObject):void {
			if(!_questManager.useObject(data)) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.WRONG_OBJECT));
			}
		}
		
		/**
		 * Flags the quest as evaluated
		 */
		public function questEvaluated():void {
			//TODO
//			_save["evaluated"] = true;
			clearTimeout(_timeoutSave);
			onSaveProgression();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Called on timer's tic to get the forum's coordinates.
		 */
		private function ticTimerHandler(event:TimerEvent):void {
			if(!ExternalInterface.available) return;
			
			var getZoneInfos:XML = 
		 	   <script><![CDATA[
		            function(){ return document.getElementById('infos').innerHTML; }
		        ]]></script>;
		    
	        var text:String = ExternalInterface.call(getZoneInfos.toString()); 
		    
			//check if picking up a forum
			if(/return removeKube\(-?[0-9]+,-?[0-9]+,-?[0-9]+\)/gi.test(text)) {
				text = text.replace(/.*(removeKube\(.*?\)).*/gi, "$1");
				var matches:Array = text.match(/-?[0-9]+/gi);
				var p:Point3D = new Point3D(parseInt(matches[0]), parseInt(matches[1]), parseInt(matches[2]));
				if(_lastTouchPosition == null || !p.equals(_lastTouchPosition)) {
					_lastTouchPosition = p;
					//Send new position to connected clients
					var i:int, len:int;
					len = _lcClientNames.length;
					for(i = 0; i < len; ++i) {
						onTouchForum();
						_lcSend.send(_lcClientNames[i], "_touchForum", p.x, p.y, p.z);
					}
				}
			}
		}
		
		
		
		
		
		//__________________________________________________________ LOCAL CONNECTION
 
		/**
		 * Called if a data sending succeeds or fails.
		 */
		private function statusHandler(event:StatusEvent):void {
			if(event.currentTarget == _senderGame) {
				clearTimeout(_checkTimeoutGame);
				clearTimeout(_connectTimeoutGame);
				switch (event.level) {
					case "status":
					//sending success!
					if(!_connectedToGame) {
						_connectedToGame = true;
						dispatchEvent(new LCManagerEvent(LCManagerEvent.GAME_CONNECTION_STATE_CHANGE));
					}
					_checkTimeoutGame = setTimeout(checkForGameConnection, 1000);
					break;
				case "error":
					if(_connectedToGame) {
						_connectedToGame = false;
						dispatchEvent(new LCManagerEvent(LCManagerEvent.GAME_CONNECTION_STATE_CHANGE));
					}
					_connectTimeoutGame = setTimeout(attemptToConnectToGame, 500);
					break;
				}
			}
		}
		
		/**
		 * Attempts to connect to the game
		 */
		private function attemptToConnectToGame():void {
			_senderGame.send("_lc_mx_kube_", "_requestUpdates", _lcGameName);
		}
		
		/**
		 * Attempts to connect to the game
		 */
		private function checkForGameConnection():void {
			setText(null);
		}
		
		/**
		 * Sets a text on the tutorial window.
		 */
		private function setText(txt:String):void {
			_senderGame.send("_lc_mx_kube_", "_setText", txt, "");
		}

		/**
		 * Called when player enters a new zone
		 */
		private function onUpdatePosition(px:int, py:int):void {
			if(px == 0xffffff || py == 0xffffff //first undefined coord fired by the game. Ignore it.
			|| (_inGamePosition.x == px && _inGamePosition.y == py)) return;
			_inGamePosition.x = px;
			_inGamePosition.y = py;
			onZoneChange();
		}
		 
		/**
		 * Called when tuto's popin button is clicked.
		 */
		private function onAction():void { }
		
		/**
		 * Kills the local connection receiver.
		 */
		private function killLC(callbackLC:String):void {
			_lcReceive.close();
			_lcSend.send(callbackLC, "_onKill");
		}
		
		/**
		 * Called when existing connection is killed. 
		 */
		private function onKill():void {
			_lcReceive.connect(_lcName);
		}

		
		/**
		 * Called when a client requests forums updates.
		 */
		private function requestForumUpdates(lcName:String):void {
			_lcClientNames.push(lcName);
			if(_lastTouchPosition != null) {
				_lcSend.send(lcName, "_touchForum", _lastTouchPosition.x, _lastTouchPosition.y, _lastTouchPosition.z);
			}
		}
		
		/**
		 * Called by distant LC to check if the SWF is still alive
		 */
		private function connectCheck():void { }
		
		
		
		
		
		//__________________________________________________________ COMMAND HANDLER
		
		/**
		 * Called when login operation completes
		 */
		private function loginCompleteHandler(event:CommandEvent):void {
			//currentUID contains the currently playing user ID.
			//It's grabbed from the HTML page. If it doesn't match the server's
			//ID, the user is considered as disconnected.
			_logged = event.data["logged"] && event.data["uid"] == Config.getVariable("currentUID");
			if(_logged) {
				_pseudo	= event.data["name"];
				_pubkey	= event.data["pubkey"];
				_lang	= event.data["lang"];
				_time	= event.data["time"];
				_date	= new Date();
				
				Config.addVariable("lang", _lang);
				
				_ksaCmd = new KeepSessionAliveCmd();//Don't care about success/fail
				//Keep the session alive
				clearInterval(_ksaInterval);
				_ksaInterval = setInterval(_ksaCmd.execute, 10 * 60*1000);//Every 10 minutes
				
				_clearProgression = new ClearProgressionCmd();
				_clearProgression.addEventListener(CommandEvent.COMPLETE, clearProgressionCompleteHandler);
				_clearProgression.addEventListener(CommandEvent.ERROR, clearProgressionErrorHandler);
				
				_saveProgressionCmd = new SaveProgressionCmd();
				_saveProgressionCmd.addEventListener(CommandEvent.COMPLETE, saveProgressionCompleteHandler);
				_saveProgressionCmd.addEventListener(CommandEvent.ERROR, saveProgressionErrorHandler);
				
				_loadDetailsCmd = new LoadKuestDetailsCmd();
				_loadDetailsCmd.addEventListener(CommandEvent.COMPLETE, loadDetailsCompleteHandler);
				_loadDetailsCmd.addEventListener(CommandEvent.ERROR, loadDetailsErrorHandler);
				
				_loadProgressionCmd = new LoadProgressionCmd();
				_loadProgressionCmd.addEventListener(CommandEvent.COMPLETE, loadProgressionCompleteHandler);
				_loadProgressionCmd.addEventListener(CommandEvent.ERROR, loadProgressionErrorHandler);
				_loadProgressionCmd.addEventListener(ProgressEvent.PROGRESS,  loadProgressHandler);
				
				_loadKuestCmd = new LoadQuestCmd(!_testMode);
				_loadKuestCmd.addEventListener(CommandEvent.COMPLETE, loadQuestCompleteHandler);
				_loadKuestCmd.addEventListener(CommandEvent.ERROR, loadQuestErrorHandler);
				_loadKuestCmd.addEventListener(ProgressEvent.PROGRESS,  loadProgressHandler);
				
				_loadKuestCmd.populate( _currentQuestGUID );
				_loadDetailsCmd.populate( _currentQuestGUID );
				_loadProgressionCmd.populate( _currentQuestGUID );
				var spool:SequentialCommand = new SequentialCommand();
				spool.addCommand(_loadDetailsCmd);
				spool.addCommand(_loadProgressionCmd);
				spool.addCommand(_loadKuestCmd);
				spool.execute();
			}
			dispatchEvent(new DataManagerEvent(DataManagerEvent.ON_LOGIN_STATE));
		}

		/**
		 * Called if login operation fails
		 */
		private function loginErrorHandler(event:CommandEvent):void {
			var errorCode:String = String(event.data);
			clearInterval(_ksaInterval);
			throw new KuestException(Label.getLabel("exception-"+errorCode), errorCode);
		}
		
		
		
		
		//__________________________________________________________ LOAD QUEST
		
		/**
		 * Called when quest loading completes.
		 */
		private function loadQuestCompleteHandler(event:CommandEvent):void {
			var bytes:ByteArray = event.data as ByteArray;
			bytes.position = 0;
			//If testing quest
			if(_testMode) {
				XOR(bytes, "ErrorEvent :: kuest cannot be saved...");//Decrypt data
			}else{
				XOR(bytes, "ErrorEvent :: kuest cannot be optimised...");//Decrypt data
			}
			bytes.inflate();
			bytes.position = 0;
			var fileVersion:int = bytes.readInt();
			fileVersion;
			_kuest = new KuestData(true);
			_kuest.deserialize(bytes);
			
			_questManager.loadData(_kuest.nodes, _kuest.objects, _save, new Date().getTime(), _testMode, false);
			if(_questManager.questComplete && _save["evaluated"] !== true) {//TODO 'evaluated' test!
				dispatchEvent(new DataManagerEvent(DataManagerEvent.QUEST_COMPLETE));
			}
		}
		
		/**
		 * Called when quest is ready to be played (quest parsed and save loaded)
		 */
		private function questReadyHandler(event:QuestManagerEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_COMPLETE));
		}
		
		/**
		 * Called if save file parsing fails
		 */
		private function saveLoadingErrorHandler(event:QuestManagerEvent):void {
			loadQuestErrorHandler(new CommandEvent(CommandEvent.ERROR, 'SAVE_FILE_FORMAT'));
		}

		/**
		 * Called if quest loading fails.
		 */
		private function loadQuestErrorHandler(event:CommandEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_ERROR));
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
		}
		
		
		
		
		//__________________________________________________________ LOAD PROGRESSION
		
		/**
		 * Called when user's progression loading completes.
		 */
		private function loadProgressionCompleteHandler(event:CommandEvent):void {
			if (event.data == null) {
				_save = null;
			}else{
				_save = event.data as ByteArray;
				//Save is then loaded to the quest manager when quest's loading completes
			}
		}

		/**
		 * Called if user's progression loading fails.
		 */
		private function loadProgressionErrorHandler(event:CommandEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_ERROR));
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
		}
		
		
		
		
		//__________________________________________________________ CLEAR PROGRESSION
		
		/**
		 * Called when progression is cleared.
		 */
		private function clearProgressionCompleteHandler(event:CommandEvent):void {
			_questManager.clearProgression();
			dispatchEvent(new DataManagerEvent(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE));
		}
		
		/**
		 * Called if progression clearing failed.
		 */
		private function clearProgressionErrorHandler(event:CommandEvent):void {
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
		}
		
		
		
		
		//__________________________________________________________ LOAD DETAILS
		
		/**
		 * Called details when loading progresses.
		 */
		private function loadProgressHandler(event:ProgressEvent):void {
			_progressCallback( event.bytesLoaded/event.bytesTotal );
		}
		
		/**
		 * Called when quest details are loaded.
		 */
		private function loadDetailsCompleteHandler(event:CommandEvent):void {
			_title = event.data["title"];
			_description = event.data["description"];
		}
		
		/**
		 * Called if quest details loading failed.
		 */
		private function loadDetailsErrorHandler(event:CommandEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_ERROR));
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
		}
		
		
		
		
		//__________________________________________________________ SAVE PROGRESSION
		
		/**
		 * Saves the progression
		 */
		private function onSaveProgression():void {
			_saveProgressionCmd.populate(_currentQuestGUID, _questManager.exportSave());
			_saveProgressionCmd.execute();
		}

		/**
		 * Called when progression save completes.
		 */
		private function saveProgressionCompleteHandler(event:CommandEvent):void {
			//Don't care !
		}
		
		/**
		 * Called if progression save fails.
		 */
		private function saveProgressionErrorHandler(event:CommandEvent):void {
			clearTimeout(_timeoutSave);
			_timeoutSave = setTimeout(onSaveProgression, 5000);//Try again
			throw new KuestException(Label.getLabel("exception-"+event.data), "0");
		}
		
		
		
		
		
		//__________________________________________________________ ZONE CHANGE
		
		/**
		 * Called when entering a new zone
		 */
		private function onZoneChange():void {
			_questManager.setCurrentPosition(_inGamePosition);
		}
		
		/**
		 * Called when touching a forum
		 */
		private function onTouchForum():void {
			_questManager.setCurrentPosition(_lastTouchPosition);
		}
		
		
	}
}

internal class SingletonEnforcer{}