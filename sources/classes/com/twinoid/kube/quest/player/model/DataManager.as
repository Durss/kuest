package com.twinoid.kube.quest.player.model {
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.crypto.XOR;
	import com.twinoid.kube.quest.editor.cmd.LoadCmd;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.twinoid.kube.quest.editor.utils.initSerializableClasses;
	import com.twinoid.kube.quest.editor.vo.KuestData;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	
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
		private var _loadKuestCmd:LoadCmd;
		private var _kuest:KuestData;
		
		
		
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize():void {
			initSerializableClasses();
			
			_lcClientNames = [];
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, ticTimerHandler);
			_timer.start();
			
			_lcSend = new LocalConnection();
			_lcSend.addEventListener(StatusEvent.STATUS, statusSendHandler);
			
			_loadKuestCmd = new LoadCmd(true);
			_loadKuestCmd.addEventListener(CommandEvent.COMPLETE, loadQuestCompleteHandler);
			_loadKuestCmd.addEventListener(CommandEvent.ERROR, loadQuestErrorHandler);
			if(Config.getVariable("kuestID") != null) {
				_loadKuestCmd.populate(Config.getVariable("kuestID"));
				_loadKuestCmd.execute();
			}
			
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
					_lastTouchPosition = p;
					//Send new position to connected clients
					var i:int, len:int;
					len = _lcClientNames.length;
					for(i = 0; i < len; ++i) {
						_lcSend.send(_lcClientNames[i], "_touchForum", p.x, p.y, p.z);
					}
				}
			}
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

		private function connectCheck():void {
			
		}
		
		/**
		 * Called when quest loading completes.
		 */
		private function loadQuestCompleteHandler(event:CommandEvent):void {
			var bytes:ByteArray = event.data as ByteArray;
			bytes.position = 0;
			XOR(bytes, "ErrorEvent :: kuest cannot be saved...");//Descrypt data
			bytes.inflate();
			bytes.position = 0;
			var fileVersion:int = bytes.readInt();
			fileVersion;
			_kuest = new KuestData();
			_kuest.deserialize(bytes);
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
		
	}
}

internal class SingletonEnforcer{}