package com.twinoid.kube.quest.editor.model {
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.editor.events.LCManagerEvent;
	import flash.geom.Point;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	[Event(name="connectionStateChange", type="com.twinoid.kube.quest.editor.events.LCManagerEvent")]
	[Event(name="zoneChange", type="com.twinoid.kube.quest.editor.events.LCManagerEvent")]
	
	/**
	 * Manages the local connections to the game and to the player.
	 * 
	 * @author Francois
	 * @date 11 mai 2013;
	 */
	public class LCManager extends EventDispatcher {
		
		private var _lcGameName:String;
		private var _lcPlayerName:String;
		
		private var _receiverGame:LocalConnection;
		private var _senderGame:LocalConnection;
		private var _senderPlayer:LocalConnection;
		private var _receiverPlayer:LocalConnection;
		
		private var _checkTimeoutGame:uint;
		private var _connectTimeoutGame:uint;
		private var _checkTimeoutPlayer:uint;
		private var _connectTimeoutPlayer:uint;
		
		private var _connectedToGame:Boolean;
		private var _connectedToPlayer:Boolean;
		private var _inGamePosition:Point;
		private var _forumPosition:Point3D;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LCManager</code>.
		 */
		public function LCManager() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the app is connected to the game
		 */
		public function get connectedToGame():Boolean { return _connectedToGame; }
		
		/**
		 * Gets if the app is connected to the kuest player
		 */
		public function get connectedToPlayer():Boolean { return _connectedToPlayer; }
		
		/**
		 * Gets the in game's position of the player
		 */
		public function get inGamePosition():Point { return _inGamePosition; }
		
		/**
		 * Gets the last touched forum coordinates
		 */
		public function get forumPosition():Point3D { return _forumPosition; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_inGamePosition	= new Point();
			_forumPosition	= new Point3D();
			_lcGameName		= "_kuestGame_"+new Date().getTime()+"_";
			_lcPlayerName	= "_kuestPlayer_"+new Date().getTime()+"_";
			
			//using anonymous objects provides a way not to break callbacks in case
			//of code obfuscation.
			var client:Object = {};
			client["_updatePos"]	= onUpdatePosition;
			client["_action"]		= onAction;
			client["_touchForum"]	= onTouchForum;
			
			_senderGame = new LocalConnection();
			_senderGame.addEventListener(StatusEvent.STATUS, statusHandler);
			
			_receiverGame = new LocalConnection();
			_receiverGame.client = client;
			_receiverGame.allowDomain("*");
			_receiverGame.connect(_lcGameName);
			
			_senderPlayer = new LocalConnection();
			_senderPlayer.addEventListener(StatusEvent.STATUS, statusHandler);
			
			_receiverPlayer = new LocalConnection();
			_receiverPlayer.client = client;
			_receiverPlayer.allowDomain("*");
			_receiverPlayer.connect(_lcPlayerName);
			
			attemptToConnectToGame();
			attemptToConnectToPlayer();
		}
 
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
			}else{
				clearTimeout(_checkTimeoutPlayer);
				clearTimeout(_connectTimeoutPlayer);
				switch (event.level) {
					case "status":
					//sending success!
					if(!_connectedToPlayer) {
						_connectedToPlayer = true;
						dispatchEvent(new LCManagerEvent(LCManagerEvent.PLAYER_CONNECTION_STATE_CHANGE));
					}
					_checkTimeoutPlayer = setTimeout(checkForPlayerConnection, 1000);
					break;
				case "error":
					if(_connectedToPlayer) {
						_connectedToPlayer = false;
						dispatchEvent(new LCManagerEvent(LCManagerEvent.PLAYER_CONNECTION_STATE_CHANGE));
					}
					_connectTimeoutPlayer = setTimeout(attemptToConnectToPlayer, 500);
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
		 * Attempts to connect to the kuest player
		 */
		private function attemptToConnectToPlayer():void {
			_senderPlayer.send("_lc_kuest_", "_requestUpdates", _lcPlayerName);
		}
		
		/**
		 * Attempts to connect to the game
		 */
		private function checkForGameConnection():void {
			setText(null);
		}
		
		/**
		 * Attempts to connect to the kuest player
		 */
		private function checkForPlayerConnection():void {
			_senderPlayer.send("_lc_kuest_", "_checkForConnection");
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
			if(px == 0xffffff && py == 0xffffff //first undefined coord fired by the game. Ignore it.
			|| (_inGamePosition.x == px && _inGamePosition.y == py)) return;
			_inGamePosition.x = px;
			_inGamePosition.y = py;
			dispatchEvent(new LCManagerEvent(LCManagerEvent.ZONE_CHANGE));
		}
		 
		/**
		 * Called when tuto's popin button is clicked.
		 */
		private function onAction():void {
		}
		
		/**
		 * Called when a forum is touched
		 */
		private function onTouchForum(x:int, y:int, z:int):void {
			_forumPosition.x = x;
			_forumPosition.y = y;
			_forumPosition.z = z;
			dispatchEvent(new LCManagerEvent(LCManagerEvent.FORUM_TOUCHED));
		}
		
	}
}