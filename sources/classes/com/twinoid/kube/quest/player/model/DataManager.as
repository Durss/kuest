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
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.cmd.ClearProgressionCmd;
	import com.twinoid.kube.quest.player.cmd.IsLoggedCmd;
	import com.twinoid.kube.quest.player.cmd.LoadKuestDetailsCmd;
	import com.twinoid.kube.quest.player.cmd.LoadProgressionCmd;
	import com.twinoid.kube.quest.player.cmd.SaveProgressionCmd;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.utils.computeTreeGUIDs;
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
	import flash.utils.Dictionary;
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
		private var _lastTouchPosition:Point3D;
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
		private var _uid:String;
		private var _pubkey:String;
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
		private var _placeToEvents:Object;
		private var _lcName:String;
		private var _lcKillCallbackReceive:LocalConnection;
		private var _loadProgressionCmd:LoadProgressionCmd;
		private var _save:Object;
		private var _currentEvent:KuestEvent;
		private var _lastPosData:*;
		private var _time:Number;
		private var _date:Date;
		private var _timeoutSave:uint;
		private var _saveProgressionCmd:SaveProgressionCmd;
		private var _currentQuestGUID:String;
		private var _clearProgression:ClearProgressionCmd;
		private var _testMode : Boolean;
		private var _isObjectPut:Boolean;
		private var _nodeToTreeID:Dictionary;
		private var _loadingAlreadyFired:Boolean;
		private var _so:SharedObject;
		
		
		
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
		public function get currentEvent():KuestEvent { return _isObjectPut? null : _currentEvent; }
		
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
			var res:Vector.<InventoryObject> = new Vector.<InventoryObject>();
			var i:int, len:int, guidToObject:Object;
			len = _kuest.objects.length;
			guidToObject = {};
			for(i = 0; i < len; ++i) {
				guidToObject[ _kuest.objects[i].guid ] = _kuest.objects[i];
			}
			
			for(var k:String in _save["objects"]) {
				res.push(new InventoryObject(guidToObject[ parseInt(k) ], _save["objects"][k]) );
			}
			
			return res;
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
			_inGamePosition = new Point(int.MAX_VALUE, int.MAX_VALUE);
			_progressCallback = progressCallback;
			_so = SharedObject.getLocal("_kuestPlayer_", "/");
			initSerializableClasses();
			
			_lcClientNames = [];
				
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
				//Ask to the existing connection to suicide and wait for its
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
			
			_lcGameName		= "_kuestGame_"+new Date().getTime()+"_";
			
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
			if(Capabilities.playerType == "StandAlone") {
				//XXX repère local conf
				//structure tester - 51a272f115f96
				//MlleNolwenn - 51a1e15e398b4
				//TFS bordel - 519e7fe42ff5a
				//Test Lilith - 51a207ff98070
				//Cristal Atlante - 5194100a4a94f
				//Tubasa labyrinthe - 51aa7b6cbe1ef
				//4) Exemple poser/prendre objets - 51ad12eca65b6
				Config.addVariable("kuestID", "51ad12eca65b6");
				Config.addVariable("currentUID", "89");
				Config.addVariable("testMode", 'true');
			}
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
					//Force login if testing locally as session are fucked up in standalone mode...
					var login:LoginCmd = new LoginCmd();
					login.populate("89", "f20b165d");
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
		 * Answers a question
		 */
		public function answer(index:int):void {
			_save[getPosId(_currentEvent.actionPlace)].index ++;
			_save[_currentEvent.guid].answerIndex = index;
			flagAsComplete(_currentEvent);
			selectEventFromPos(_lastPosData);
		}
		
		/**
		 * Load next event
		 */
		public function next():void {
			_save[getPosId(_currentEvent.actionPlace)].index ++;
			flagAsComplete(_currentEvent);
			selectEventFromPos(_lastPosData);
		}
		
		/**
		 * Simulates a zone change
		 */
		public function simulateZoneChange(x:Number, y:Number):void {
			_inGamePosition.x = x;
			_inGamePosition.y = y;
			selectEventFromPos(_inGamePosition);
		}
		
		/**
		 * Simulate a forum touch
		 */
		public function simulateForumChange(x:Number, y:Number, z:Number):void {
			_lastTouchPosition.x = x;
			_lastTouchPosition.y = y;
			_lastTouchPosition.z = z;
			selectEventFromPos(_lastTouchPosition);
		}
		
		/**
		 * Clears the user's progression.
		 */
		public function clearProgression():void {
			_clearProgression.populate(_currentQuestGUID);
			if(_testMode) {
				_clearProgression.execute();
			}else{
				prompt("player-restTitle", "player-restContent", _clearProgression.execute, "resetQuest");
			}
		}
		
		/**
		 * Use an object
		 */
		public function useObject(data:InventoryObject):void {
			//If the action consists of putting an object in place
			if(_currentEvent != null && _currentEvent.actionType != null
			 && _currentEvent.actionType.type == ActionType.TYPE_OBJECT
			 && !_currentEvent.actionType.takeMode) {
				//If the object put is the good one
				if(_currentEvent.actionType.getItem().guid == data.vo.guid) {
					_isObjectPut = false;
					flagAsComplete(_currentEvent);
					dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
				}else{
					dispatchEvent(new DataManagerEvent(DataManagerEvent.WRONG_OBJECT));
				}
			}else{
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NO_NEED_FOR_OBJECT));
			}
		}
		
		/**
		 * Flags the quest as evaluated
		 */
		public function questEvaluated():void {
			_save["evaluated"] = true;
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
			//It's grabbed from the HTML page.
			_logged = event.data["logged"] && event.data["uid"] == Config.getVariable("currentUID");
			if(_logged) {
				_uid	= event.data["uid"];
				_pseudo	= event.data["name"];
				_pubkey	= event.data["pubkey"];
				_lang	= event.data["lang"];
				_time	= event.data["time"];
				_date	= new Date();
				
				Config.addVariable("lang", _lang);
				
				_ksaCmd = new KeepSessionAliveCmd();//Don't care about succes/fail
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
			preAnalyseQuest();
			
			if(_save["questComplete"] === true && _save["evaluated"] !== true) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.QUEST_COMPLETE));
			}
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
		
		/**
		 * Called when user's progression loading completes.
		 */
		private function loadProgressionCompleteHandler(event:CommandEvent):void {
			if (event.data == null) {
				_save = {};
			}else{
				var bytes:ByteArray = event.data as ByteArray;
				bytes.inflate();
				bytes.position = 0;
				_save = bytes.readObject();
			}
		}
		
		/**
		 * Called when progression is cleared.
		 */
		private function clearProgressionCompleteHandler(event:CommandEvent):void {
			_save = {};
			preAnalyseQuest();
			if(_lastPosData is Point) selectEventFromPos(_lastPosData);
			else _lastPosData = null;
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

		/**
		 * Called if user's progression loading fails.
		 */
		private function loadProgressionErrorHandler(event:CommandEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_ERROR));
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
		}
		
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
			var ba:ByteArray = new ByteArray();
			ba.writeObject( _save );
			ba.deflate();
			_saveProgressionCmd.populate(_currentQuestGUID, ba);
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
			throw new KuestException(String(event.data), "0");
		}
		
		
		
		
		
		//__________________________________________________________ QUEST LOGIC !
		
		/**
		 * Gets an ID representing the action's position or an external Point/Point3D
		 */
		public function getPosId(src:* = null):String {
			if(src is Point) {
				return Point(src).x+"_"+Point(src).y;
			}else if(src is Point3D) {
				return Point3D(src).x+"_"+Point3D(src).y+"_"+Point3D(src).z;
			}else if(src is ActionPlace){
				return !ActionPlace(src).kubeMode? ActionPlace(src).x+"_"+ActionPlace(src).y : ActionPlace(src).x+"_"+ActionPlace(src).y+"_"+ActionPlace(src).z;
			}
			return null;
		}
		
		/**
		 * Makes a pre-analyse of the quest to create fast accesses to events
		 */
		private function preAnalyseQuest():void {
			var i:int, len:int, id:String;
			var nodes:Vector.<KuestEvent> = _kuest.nodes;
			len = nodes.length;
			_placeToEvents = {};
			for(i = 0; i < len; ++i) {
				id = getPosId(nodes[i].actionPlace);
				//Register the event to the place
				if(_placeToEvents[id] == undefined) _placeToEvents[id] = new Vector.<KuestEvent>();
				(_placeToEvents[id] as Vector.<KuestEvent>).push(nodes[i]);
				
				//Init properties
				if(_save[nodes[i].guid] == undefined) {
					var data:Object = {};
					data.complete = false;
					_save[nodes[i].guid] = data;
					
					data = {};
					data.index = 0;
					_save[id] = data;
				}
			}
			
			if(_save["objects"] == undefined) _save["objects"] = {};
			if(_save["priorities"] == undefined) _save["priorities"] = {};
			if(_save["treePriority"] == undefined) _save["treePriority"] = {};
			
			_nodeToTreeID = new Dictionary();
			computeTreeGUIDs(_kuest.nodes, _nodeToTreeID, onTreeComputeComplete);
		}
		
		/**
		 * Called when tree IDs are computed
		 */
		private function onTreeComputeComplete():void {
			var id:int, k:KuestEvent;
			for(var j:* in _nodeToTreeID) {
				k = j as KuestEvent;
				id = _nodeToTreeID[k];
				k.setTreeID(id);
				if(k.startsTree) addPriorityTo(k);
			}
			if(_lastPosData != null) selectEventFromPos(_lastPosData);
			
			if(!_loadingAlreadyFired) {
				_timer.start();
				attemptToConnectToGame();
				_loadingAlreadyFired = true;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_COMPLETE));
			}
		}

		
		/**
		 * Called when entering a new zone
		 */
		private function onZoneChange():void { selectEventFromPos(_inGamePosition); }
		
		/**
		 * Called when touching a forum
		 */
		private function onTouchForum():void { selectEventFromPos(_lastTouchPosition); }
		
		/**
		 * Determines which event is the current one depending on the current user's action position
		 */
		private function selectEventFromPos(pos:*):void {
			_lastPosData = pos['clone']();//Dirty dynamic call.. can't put an interface on Point class, and too lazy to create a custom Point :(
			if(_nodeToTreeID == null) return;
			
			var i:int, len:int, item:KuestEvent, selectedEvent:KuestEvent;
			var id:String = getPosId(pos);
			var treeID:int;
			
			//Grab all the event located at the current position.
			var items:Vector.<KuestEvent> = _placeToEvents[id]==null? new Vector.<KuestEvent>() : _placeToEvents[id] as Vector.<KuestEvent>;
			items.sort(sortByPosition);
			len = items.length;
			
			//Search for the active one.
			//If an item has the priority, check if it's accessible and if it
			//corresponds to the tree's priority.
			trace('_save["priorities"]['+id+']: ' + (_save["priorities"][id]));
			if (_save["priorities"][id] != undefined) {
				var guid:int = _save["priorities"][id][0];
				for(i = 0; i < len; ++i) {
					treeID = _nodeToTreeID[ items[i] ];
					//Check if the current related tree has a priority, if so,
					//check if the tree's priority is that item.
					if(items[i].guid == guid
					&& (_save["treePriority"][treeID] == undefined || _save["treePriority"][treeID] == items[i].guid)
					&& isEventAccessible(items[i], false)) {
						selectedEvent = items[i];
					}
				}
				if(selectedEvent != null) {
					len = 0;//Prevents from useless loop
				}
			}else
			
			//No matching priority has been found.
			//Go through all the events to find an active one
			if(_save["priorities"][id] == undefined) {
				if(_save[id] == undefined) _save[id] = {index:0};
				var offset:int = _save[id].index % len;
				for(i = offset; i < offset + len; ++i) {
					item = items[i%len];
					treeID = _nodeToTreeID[ item ];
					//Item complete, skip it
					trace('treeID: ' + (treeID));
					trace('prio: ' + (_save["treePriority"][treeID]));
					if (_save[item.guid].complete === true || (_save["treePriority"][treeID] != undefined && _save["treePriority"][treeID] != items[i].guid)) {
						continue;
					}
					
					if(isEventAccessible(item)) {
						selectedEvent = item;
						break;
					}else{
//						trace(item.guid + " not accessible")
					}
				}
			}
			
			//Resets the index to a correct value. WIthout that it would be fucked up.
			//Lets say we have 5 items, only the 2 first are acessible, from index 2 to 4
			//the loop would go back to the 1st item until the index equals 0 or 1 again.
			//This index reset prevents from that problem.
			if(len > 0 && selectedEvent != null) {
				_save[id].index = i%len;
			}
			
			//If no item has been selected give the priority
			//FIXME si on arrive sur une zone qui n'est pas le début d'un arbre
			//et qu'aucune priorité n'a été définie pour cet arbre, ça va sélectionner
			//l'événement même s'il n'est pas censé être accessible à cause de
			//ses dépendences.
			//Faudrait pré-calculer les points d'entrée au chargement de la quête je pense
			//et/ou juste virer ça et ajouter une case à cocher sur l'édition d'un
			//évenement dans l'édituer pour dire que c'est un point d'entrée. 
			if(selectedEvent == null && _save[id].index == 0 && len > 0) {
				for(i = 0; i < len; ++i) {
					if(_save["treePriority"][ _nodeToTreeID[ items[i] ] ] == undefined) {
						selectedEvent = items[i];
						addPriorityTo( items[i] );
						break;
					}
				}
			}
			
			
			//==================================================
			//================ EVENT SUBMISSION ================
			//==================================================
			if (selectedEvent != null) {
				_currentEvent = selectedEvent;
				//Flag as complete only if the event proposes no choice.
				//If the event proposes choices, it will be flagged as complete
				//when the user answers it.
				//Same thing if the event proposes to put an object.
				_isObjectPut = selectedEvent.actionType != null && selectedEvent.actionType.type == ActionType.TYPE_OBJECT && !selectedEvent.actionType.takeMode;
				if ((selectedEvent.actionChoices == null || selectedEvent.actionChoices.choices.length < 2) && !_isObjectPut) {
					//If there is only one choice, answer automatically
					if(selectedEvent.actionChoices.choices.length == 1) {
						_save[id].index ++;
						_save[selectedEvent.guid].answerIndex = 0;
					}
					flagAsComplete(selectedEvent);
				}
				//If it's not an object put and if the event has no children, go forward.
				if(!_isObjectPut && selectedEvent.getChildren().length < 2) _save[id].index ++;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
			}
			
			//If there was an event selected and there is no new one, tell the
			//view to update with nothing (so it clears)
			if(_currentEvent != null && selectedEvent == null) {
				_currentEvent = null;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
			}
		}
		
		/**
		 * Checks if an event is accessible or not
		 */
		private function isEventAccessible(item:KuestEvent, checkDependencies:Boolean = true):Boolean {
			var i:int, len:int, allowed:Boolean;
			var j:int, lenJ:int;
			var today:Date = currentDate;
			var timestamp:int = today.hours * 60 + today.minutes;
			//==================================================
			//================= TIME SELECTION =================
			// ==================================================
			var dates:Vector.<Date> = item.actionDate.dates;
			if (dates != null && dates.length > 0 ) {
				//Test dates
				len = dates.length;
				allowed = false;
				for(i = 0; i < len; ++i) {
					//Allowed date, break this loop and continue.
					if(dates[i].date == today.date && dates[i].fullYear == today.fullYear && dates[i].month == dates[i].month) {
						allowed = true;
						break;
					}
				}
				//Today not found in dates, skip this loop turn
				if(!allowed) return false;
			}

			var days:Array = item.actionDate.days;
			if (days != null && days.length > 0 ) {
				//Test days and hours
				len = days.length;
				allowed = false;
				for(i = 0; i < len; ++i) {
					if (days[i] == today.day) {
						var start:int = item.actionDate.startTime;
						var end:int = item.actionDate.endTime;
						if(start > end) {
							if(timestamp >= start || timestamp < end) {
								allowed = true;
								break;
							}
						}else
						if(timestamp >= start && timestamp < end) {
							allowed = true;
							break;
						}
					}
				}
				//Day and hours not found, skip this loop turn
				if(!allowed) return false;
			}
			
			if(!checkDependencies) return true;
			
			
			//===================================================
			//============= DEPENDENCIES MANAGEMENT =============
			//===================================================
			//If the event has no dependency, just select it !
			if(item.dependencies.length == 0) {
				return true;
			}
			//If the event has one or more dependency, check if one of them
			//has been complete or not.
			lenJ = item.dependencies.length;
			for(j = 0; j < lenJ; ++j) {
				if(_save[item.dependencies[j].event.guid].complete === true) {
					if(item.dependencies[j].event.actionChoices.choices.length > 0) {
						if(_save[item.dependencies[j].event.guid] != undefined && item.dependencies[j].choiceIndex == _save[item.dependencies[j].event.guid].answerIndex) {
							return true;
						}
					}else{
						return true;
					}
				}
			}
			
			//If the event is the first one of a loop, check if all its
			//dependencies are part of the loop or not.
			//If not, go fuck up !
//			trace('item.isFirstOfLoop(): ' + (item.isFirstOfLoop()));
//			if (item.isFirstOfLoop()) {
//				var allLoop:Boolean = true, children:Vector.<KuestEvent>;
//				for(j = 0; j < lenJ; ++j) {
//					children = item.loopsFrom(item.dependencies[j].event);
//					allLoop &&= children != null;
//				}
//				if (allLoop) {
//					return true;
//				}
//			}
			
			return false;
		}
		
		/**
		 * Flags an event as complete.
		 * If the item is part of a looped dependency and it's next dependent
		 * is the first of the loop, reset all the items of the loop and flag
		 * them as "no complete" so they can be played again.
		 */
		private function flagAsComplete(event:KuestEvent):void {
			if(_save[event.guid].complete === true) return;//Uncool test... flagsAsComplete is called twice on some/every events.
			//Looped references management
			_save[event.guid].complete = true;
			var i:int, len:int, children:Vector.<KuestEvent>;
			var j:int, lenJ:int;
			children = event.getChildren();
			len = children.length;
//			for(i = 0; i < len; ++i) {
//				//If one of our child is the first of a loop, and if the current
//				//item is actually part of that loop, reset the loop's event to
//				// "not complete" state.
//				if (children[i].isFirstOfLoop()) {
//					var tree:Vector.<KuestEvent> = children[i].loopsFrom(event);
//					if(tree != null) {
//						lenJ = tree.length;
//						for(j = 0; j < lenJ; ++j) {
//							_save[tree[j].guid].complete = false;
//						}
//					}
//				}
//			}
			
			//Remove or add object if the vent consists of an objet'x put/get
			if(event.actionType != null && event.actionType.type == ActionType.TYPE_OBJECT) {
				var guid:int = event.actionType.getItem() != null? event.actionType.getItem().guid : -1;
				if(guid > -1) {
					if(_save["objects"][ guid ] == undefined) {
						_save["objects"][ guid ] = 1;
					} else {
						_save["objects"][ guid ] += event.actionType.takeMode? 1 : -1;
					}
				}
			}
			
			//Give the priority to the child related to the choosen answer
			if(children.length > 0) {
				//If there are choices available
				if(event.actionChoices != null && event.actionChoices.choices.length > 0) {
					var answerIndex:int = _save[event.guid].answerIndex;
					len = children.length;
					for(i = 0; i < len; ++i) {
						lenJ = children[i].dependencies.length;
						for(j = 0; j < lenJ; ++j) {
							if(children[i].dependencies[j].event == event && children[i].dependencies[j].choiceIndex == answerIndex) {
								addPriorityTo( children[i] );
								break;
							}
						}
					}
				}else{
					//Give priority to objects put
					var isAnObject:Boolean = false;
					len = children.length;
					for(i = 0; i < len; ++i) {
						var isObjectPut:Boolean = children[i].actionType != null && children[i].actionType.type == ActionType.TYPE_OBJECT && !children[i].actionType.takeMode;
						if (isObjectPut) {
							isAnObject = true;
							addPriorityTo(children[i]);
						}
					}
					//If no object, just select the first
					if(!isAnObject) addPriorityTo(children[0]);
				}
			}
			
			//Remove the priority if the event had it
			var id:String = getPosId(event.actionPlace.getAsPoint());
			if(_save["priorities"][id] != undefined) {
				var priorities:Array = _save["priorities"][ id ] as Array;
				if(priorities != null) {
					len = priorities.length;
					for(i = 0; i < len; ++i) {
						if(priorities[i] == event.guid) {
							priorities.splice(i, 1);
							i --;
							len --;
						}
					}
				}
			}
			
			if(event.endsQuest) {
				_save["questComplete"] = true;
				if(_save["evaluated"] !== true) {
					dispatchEvent(new DataManagerEvent(DataManagerEvent.QUEST_COMPLETE));
				}
			}
			
			//Send to server
			clearTimeout(_timeoutSave);
			_timeoutSave = setTimeout(onSaveProgression, 3000);
		}
		
		/**
		 * Adds the priority to a specific event
		 */
		private function addPriorityTo(event:KuestEvent):void {
			var id:String = getPosId( event.actionPlace.getAsPoint() );
			if(_save["priorities"][id] == undefined) {
				_save["priorities"][id] = [];
			}
			trace("Add priority, treeID="+_nodeToTreeID[event], event.getTreeID(), "guid="+event.guid)
			_save["treePriority"][ _nodeToTreeID[event] ] = event.guid;
			if((_save["priorities"][id] as Array).indexOf(event.guid) == -1) {
				(_save["priorities"][id] as Array).unshift( event.guid );
			}
			_save[event.guid].complete = false;
		}
		
		/**
		 * Sorts items by their position. The most at left first.
		 */
		private function sortByPosition(a:KuestEvent, b:KuestEvent):int {
			if(a.boxPosition.x < b.boxPosition.x) return -1;
			if(a.boxPosition.x == b.boxPosition.x) return a.boxPosition.y < b.boxPosition.y? - 1 : 1;
			if(a.boxPosition.x > b.boxPosition.x) return 1;
			return 0;
		}
		
	}
}

internal class SingletonEnforcer{}