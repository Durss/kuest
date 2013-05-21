package com.twinoid.kube.quest.player.model {
	import com.twinoid.kube.quest.editor.utils.logJS;
	import flash.utils.getTimer;
	import com.nurun.core.commands.SequentialCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.editor.cmd.KeepSessionAliveCmd;
	import com.twinoid.kube.quest.editor.cmd.LoadQuestCmd;
	import com.twinoid.kube.quest.editor.cmd.LoginCmd;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.events.LCManagerEvent;
	import com.twinoid.kube.quest.editor.utils.initSerializableClasses;
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.cmd.IsLoggedCmd;
	import com.twinoid.kube.quest.player.cmd.LoadKuestDetailsCmd;
	import com.twinoid.kube.quest.player.cmd.LoadProgressionCmd;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
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
		private var _time:*;
		private var _date:Date;
		
		
		
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
		public function get currentEvent():KuestEvent { return _currentEvent; }
		
		/**
		 * Gets the current date
		 */
		public function get currentDate():Date {
			_date.time = _time + getTimer();
			return _date;
		}
		
		
		
		
		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(progressCallback:Function):void {
			_inGamePosition = new Point(int.MAX_VALUE, int.MAX_VALUE);
			_progressCallback = progressCallback;
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
				Config.addVariable("kuestID", "5194100a4a94f");
				Config.addVariable("currentUID", "89");
			}
			if(Config.getVariable("kuestID") != null) {
				var spool:SequentialCommand = new SequentialCommand();
				if(Capabilities.playerType == "StandAlone") {
					//Force login if testing locally as session are fucked up instandalone mode...
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
			_save[_currentEvent.guid].complete = true;
			_save[_currentEvent.guid].answerIndex = index;
			selectEventFromPos(_lastPosData);
		}
		
		/**
		 * Load next event
		 */
		public function next():void {
			_save[getPosId(_currentEvent.actionPlace)].index ++;
			_save[_currentEvent.guid].complete = true;
			selectEventFromPos(_lastPosData);
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
			logJS(px, py)
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
	
				_loadDetailsCmd = new LoadKuestDetailsCmd();
				_loadDetailsCmd.addEventListener(CommandEvent.COMPLETE, loadDetailsCompleteHandler);
				_loadDetailsCmd.addEventListener(CommandEvent.ERROR, loadDetailsErrorsHandler);
				
				_loadProgressionCmd = new LoadProgressionCmd();
				_loadProgressionCmd.addEventListener(CommandEvent.COMPLETE, loadProgressionCompleteHandler);
				_loadProgressionCmd.addEventListener(CommandEvent.ERROR, loadProgressionErrorHandler);
				_loadProgressionCmd.addEventListener(ProgressEvent.PROGRESS,  loadProgressHandler);
				
				_loadKuestCmd = new LoadQuestCmd(true);
				_loadKuestCmd.addEventListener(CommandEvent.COMPLETE, loadQuestCompleteHandler);
				_loadKuestCmd.addEventListener(CommandEvent.ERROR, loadQuestErrorHandler);
				_loadKuestCmd.addEventListener(ProgressEvent.PROGRESS,  loadProgressHandler);
				
				_loadKuestCmd.populate( Config.getVariable("kuestID") );
				_loadDetailsCmd.populate( Config.getVariable("kuestID") );
				_loadProgressionCmd.populate( Config.getVariable("kuestID") );
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
			XOR(bytes, "ErrorEvent :: kuest cannot be optimised...");//Decrypt data
			bytes.inflate();
			bytes.position = 0;
			var fileVersion:int = bytes.readInt();
			fileVersion;
			_kuest = new KuestData();
			_kuest.deserialize(bytes);
			preAnalyseQuest();
			_timer.start();
			attemptToConnectToGame();
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_COMPLETE));
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
				bytes.position = 0;
				bytes.inflate();
				bytes.position = 0;
				_save = bytes.readObject();
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
		private function loadDetailsErrorsHandler(event:CommandEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_ERROR));
			var label:String = Label.getLabel("exception-"+event.data);
			if(/^\[missing.*/gi.test(label)) label = event.data as String;
			throw new KuestException(label, "loading");
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
				if(_placeToEvents[id] == undefined) _placeToEvents[id] = new Vector.<KuestEvent>();
				(_placeToEvents[id] as Vector.<KuestEvent>).push(nodes[i]);
				
				if(_save[nodes[i].guid] == undefined) {
					var data:Object = {};
					data.complete = false;
					_save[nodes[i].guid] = data;
					data = {};
					data.index = 0;
					_save[id] = data;
				}
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
			//TODO Manage time limitations
			var i:int, len:int, item:KuestEvent, selectedEvent:KuestEvent;
			var j:int, lenJ:int, dates:Vector.<Date>, allowed:Boolean, days:Array, timestamp:int;
			var today:Date = currentDate;
			timestamp = today.hours * 60 + today.minutes;
			_lastPosData = pos;
			var id:String = getPosId(pos);
			//Grab all the event located at the current position.
			var items:Vector.<KuestEvent> = _placeToEvents[id]==null? new Vector.<KuestEvent>() : _placeToEvents[id] as Vector.<KuestEvent>;
			items.sort(sortByPosition);
			len = items.length;
			//Search for the active one.
			if(_save[id] == undefined) _save[id] = {index:0};
			var offset:int = _save[id].index % len;
			mainloop: for(i = offset; i < offset + len; ++i) {
				item = items[i%len];
				
				//Item complete, skip it
				if(_save[item.guid].complete) continue;
				
				//==================================================
				//================= TIME SELECTION =================
				//==================================================
				dates = item.actionDate.dates;
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
					if(!allowed) continue;
				}
				
				days = item.actionDate.days;
				if (days != null && days.length > 0 ) {
					//Test days and hours
					len = days.length;
					allowed = false;
					for(i = 0; i < len; ++i) {
						if(days[i] == today.day
							&& timestamp >= item.actionDate.startTime
							&& timestamp < item.actionDate.endTime) {
								allowed = true;
								break;
							}
					}
					//Day and jours not found, skip this loop turn
					if(!allowed) continue;
				}
				
				
				
				//===================================================
				//============= DEPENDENCIES MANAGEMENT =============
				//===================================================
				//If the event has no dependency, just select it !
				if(item.dependencies.length == 0) {
					selectedEvent = item;
					break mainloop;
				}
				//If the event has one or more dependency, check if one of them
				//has been complete or not.
				lenJ = item.dependencies.length;
				for(j = 0; j < lenJ; ++j) {
					if(_save[item.dependencies[j].event.guid].complete == true) {
						if(item.dependencies[j].event.actionChoices.choices.length > 0) {
							if(_save[item.dependencies[j].event.guid] != undefined && item.dependencies[j].choiceIndex == _save[item.dependencies[j].event.guid].answerIndex) {
								selectedEvent = item;
								break mainloop;
							}
						}else{
							selectedEvent = item;
							break mainloop;
						}
					}
				}
			}
			
			//===================================================
			//============= DEPENDENCIES MANAGEMENT =============
			//===================================================
			if (selectedEvent != null) {
				_currentEvent = selectedEvent;
				//Flag as complete only if the event proposes no choice.
				//If the event proposes choices, it will be flagged as complete
				//when the user answers it.
				if (selectedEvent.actionChoices == null || selectedEvent.actionChoices.choices.length == 0) {
					_save[selectedEvent.guid].complete = true;
				}
				_save[id].index ++;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
			}
			if(_currentEvent != null && selectedEvent == null) {
				_currentEvent = null;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NEW_EVENT));
			}
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