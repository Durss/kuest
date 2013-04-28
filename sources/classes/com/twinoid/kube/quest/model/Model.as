package com.twinoid.kube.quest.model {
	import flash.net.SharedObject;
	import com.twinoid.kube.quest.events.ViewEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.core.commands.events.CommandEvent;
	import com.twinoid.kube.quest.cmd.LoginCmd;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.configuration.Config;
	import by.blooddy.crypto.SHA1;

	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.KuestData;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.vo.ObjectItemData;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.utils.clearTimeout;
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
		private var _objects:Vector.<ObjectItemData>;
		private var _characters:Vector.<CharItemData>;
		private var _connectedToGame:Boolean;
		private var _isConnected:Boolean;
		private var _loginCmd:LoginCmd;
		private var _uid:*;
		private var _name:*;
		private var _pubkey:*;
		private var _so:SharedObject;
		
		
		
		
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
		public function get objects():Vector.<ObjectItemData> { return _objects; }

		/**
		 * Gets the characters list
		 */
		public function get characters():Vector.<CharItemData> { return _characters; }
		
		/**
		 * Gets the in game's position.
		 */
		public function get inGamePosition():Point { return _inGamePosition; }
		
		/**
		 * Gets if the application is connected to the Kube game.
		 */
		public function get connectedToGame():Boolean { return _connectedToGame && _inGamePosition.x != int.MAX_VALUE && _inGamePosition.y != int.MAX_VALUE; }
		



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Stats the application
		 */
		public function start():void {
			_isConnected = !isEmpty(Config.getVariable("uid")) && !isEmpty(Config.getVariable("pubkey"));
			
			update();
			
			if(_isConnected) {
				_loginCmd.populate(Config.getVariable("uid"), Config.getVariable("pubkey"));
				_loginCmd.execute();
				ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGING_IN));
			}
		}
		
		public function setText(txt:String):void {
			_sender.send("_lc_mx_kube_", "_setText", txt, "");
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
		 * Refreshes the objects list
		 */
		public function refreshObjectsList(list:Vector.<ObjectItemData>):void {
			_objects = list;
			update();
		}
		
		/**
		 * Refreshes the objects list
		 */
		public function refreshCharsList(list:Vector.<CharItemData>):void {
			_characters = list;
			update();
		}
		
		/**
		 * Logs the user in.
		 */
		public function login(uid:String, pubkey:String):void {
			_loginCmd.populate(uid, pubkey);
			_loginCmd.execute();
			ViewLocator.getInstance().dispatchToViews(new ViewEvent(ViewEvent.LOGING_IN));
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