package com.twinoid.kube.quest.player.model {
	import com.twinoid.kube.quest.editor.utils.logJS;
	import com.twinoid.kube.quest.editor.vo.Point3D;

	import flash.errors.IllegalOperationError;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.utils.Timer;
	
	
	/**
	 * Singleton DataManager
	 * 
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	public class DataManager {
		
		private static var _instance:DataManager;
		private var _timer:Timer;
		private var _lastTouchPosition:Point3D;
		private var _lcSend:LocalConnection;
		private var _lcReceive:LocalConnection;
		private var _lcClientNames:Array;
		
		
		
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize():void {
			_lcClientNames = [];
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, ticTimerHandler);
			_timer.start();
			
			_lcSend = new LocalConnection();
			_lcSend.addEventListener(StatusEvent.STATUS, statusSendHandler);
			
			var client:Object = {};
			client["_requestUpdates"]		= requestForumUpdates;
			client["_checkForConnection"]	= connectCheck;
			
			var connectionName:String = "_lc_kuest_";
			_lcReceive = new LocalConnection();
			_lcReceive.client = client;
			_lcReceive.allowDomain("*");
			_lcReceive.connect(connectionName);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Called when sending completes or fails
		 */
		private function statusSendHandler(event:StatusEvent):void {
			//
		}
		
		/**
		 * Called on timer's tic to get the zone coordinates.
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
					logJS("Forum touched !")
					_lastTouchPosition = p;
					//Send new position to connected clients
					var i:int, len:int;
					len = _lcClientNames.length;
					for(i = 0; i < len; ++i) {
						logJS("Send to :"+_lcClientNames[i])
						_lcSend.send(_lcClientNames[i], "_touchForum", p.x, p.y, p.z);
					}
				}
			}
		}
		
		/**
		 * Called when a client requests forums updates.
		 */
		private function requestForumUpdates(lcName:String):void {
			logJS("Request :"+lcName)
			_lcClientNames.push(lcName);
			if(_lastTouchPosition != null) {
				_lcSend.send(lcName, "_touchForum", _lastTouchPosition.x, _lastTouchPosition.y, _lastTouchPosition.z);
			}
		}

		private function connectCheck():void {
			
		}
		
	}
}

internal class SingletonEnforcer{}