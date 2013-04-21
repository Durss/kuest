package com.twinoid.kube.quest.model {
	import by.blooddy.crypto.SHA1;

	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.twinoid.kube.quest.vo.KuestData;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	
	/**
	 * 
	 * @author francois.dursus
	 * @date 3 mai 2012;
	 */
	public class Model extends EventDispatcher implements IModel {
		private var _lcName:String;
		private var _receiver:LocalConnection;
		private var _sender:LocalConnection;
		private var _position:Point;
		private var _checkTimeout:uint;
		private var _connectTimeout:uint;
		private var _kuestData:KuestData;
		private var _currentBoxToEdit:KuestEvent;
		
		
		
		
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
		public function get kuestData():KuestData {
			return _kuestData;
		}
		
		/**
		 * Gets the current box data to edit.
		 */
		public function get currentBoxToEdit():KuestEvent {
			return _currentBoxToEdit;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Stats the application
		 */
		public function start():void {
			update();
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_kuestData = new KuestData();
			_position = new Point(int.MAX_VALUE, int.MAX_VALUE);
			
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

		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
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
//			if(_texts[_position.x+","+_position.y] != undefined)  {
//				setText(_texts[_position.x+","+_position.y]);
//			}else{
//				setText(null);
//			}
		}

		/**
		 * Called when player enters a new zone
		 */
		private function onUpdatePosition(px:int, py:int):void {
			if(px == 0xffffff && py == 0xffffff) return; //first undefined coord fired by the game. Ignore it.
			_position.x = px;
			_position.y = py;
//			if(_texts[px+","+py] != undefined)  {
//				setText(_texts[px+","+py]);
//			}else{
//				setText(null);
//			}
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
			switch (event.level) {
				case "status":
				//sending success!
				clearTimeout(_checkTimeout);
				_checkTimeout = setTimeout(checkForConnection, 1000);
				break;
			case "error":
//				trace("connection error");
				clearTimeout(_connectTimeout);
				_connectTimeout = setTimeout(attemptToConnect, 500);
				break;
			}
		}
		
	}
}