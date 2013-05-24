package com.twinoid.kube.quest.player.cmd {
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	/**
	 * The SaveProgressionCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to save the user's progression.
	 *
	 * @author Francois
	 * @date 23 mai 2013;
	 */
	public class SaveProgressionCmd extends EventDispatcher implements Command {
		private var _guid:String;
		private var _loader:URLLoader;
		private var _request:URLRequest;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  SaveProgressionCmd() {
			super();
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, uploadCompleteHandler);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, uploadErrorHandler);
			
			var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
			
			_request = new URLRequest();
			_request.requestHeaders.push(header);
			_request.method = URLRequestMethod.POST;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		/**
		 * Gets the kuest's ID if in update mode
		 */
		public function get guid():String { return _guid; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(guid:String, data:ByteArray):void {
			_guid = guid;
			data.position = 0;
			var url:String = Config.getPath("saveProgressionWS") + "?id="+guid;
			url = url+"&size="+data.length;
			_request.url = url;
			_request.data = data;
		}

		/**
		 * @inheritDoc
		 */
		public function execute():void {
			_loader.load(_request);
		}
		
		/**
		 * @inheritDoc
		 */
		public function halt():void { }


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when upload completes
		 */
		private function uploadCompleteHandler(event:Event = null):void {
			try {
				var xml:XML = new XML(_loader.data);
			}catch(error:Error) {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
				return;
			}
			
			if(parseBoolean(xml.child("result")[0].@success)) {
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, xml.child("error")[0].@id));
			}
		}
		
		/**
		 * Called if upload failled
		 */
		private function uploadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "IOERROR"));
		}
	}
}
