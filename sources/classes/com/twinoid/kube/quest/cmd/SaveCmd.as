package com.twinoid.kube.quest.cmd {
	import com.nurun.utils.string.StringUtils;
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
	 * The  SaveCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to save a kuest to the server.
	 *
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class SaveCmd extends EventDispatcher implements Command {
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _callback:Function;
		private var _title:String;
		private var _description:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function SaveCmd() {
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
		 * Gets the method to be called when saving completes
		 */
		public function get callback():Function { return _callback; }

		public function get title():String { return _title; }

		public function get description():String { return _description; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 * 
		 * @param title			kuest title
		 * @param description	kuest description
		 * @param data			kuest data
		 * @param callback		callback method called when upload completes or fails.
		 * @param id			kuest ID to modify (or empty if new kuest)
		 * @param publish		defines if the quest should be published
		 */
		public function populate(title:String, description:String, data:ByteArray, callback:Function, id:String = "", publish:Boolean = false):void {
			_description = description;
			_title = title;
			_callback = callback;
			_request.data = data;
			var url:String = Config.getPath("saveWS") + "?title=" + escape(title) + "&description=" + escape(description);
			if(StringUtils.trim(id).length > 0) url = url+"&id="+id;
			if(publish) url = url+"&publish";
			_request.url = url;
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
		public function halt():void {
		}



		
		
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
				var ret:Object = {};
				ret["id"] = xml.child("id")[0];
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, ret));
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
