package com.twinoid.kube.quest.editor.cmd {
	import com.nurun.core.commands.ProgressiveCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.string.StringUtils;

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
	public class SaveCmd extends EventDispatcher implements ProgressiveCommand {
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _callback:Function;
		private var _title:String;
		private var _description:String;
		private var _publish:Boolean;
		private var _id:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function SaveCmd() {
			super();
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, uploadCompleteHandler);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, uploadErrorHandler);
//			_loader.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);//Can't capture upload progress... :(. Only work with FileReference.upload()
			
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

		/**
		 * Gets the kuest title
		 */
		public function get title():String { return _title; }
		
		/**
		 * Gets the kuest description
		 */
		public function get description():String { return _description; }

		/**
		 * Gets the kuest's ID if in update mode
		 */
		public function get id():String { return _id; }
		
		/**
		 * Gets if we just published the quest
		 */
		public function get publish():Boolean { return _publish; }

		/**
		 * @inheritDoc
		 */
		public function get done():Number { return _loader.bytesLoaded; }

		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return done/total; }

		/**
		 * @inheritDoc
		 */
		public function get total():Number { return _loader.bytesTotal; }



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
		public function populate(title:String, description:String, data:ByteArray, friends:Array, callback:Function, id:String = "", publish:Boolean = false):void {
			_publish = publish;
			_description = description;
			_title = title;
			_callback = callback;
			_request.data = data;
			_id = id;
			data.position = 0;
			var url:String = Config.getPath("saveWS") + "?title=" + escape(title) + "&description=" + escape(description);
			if(StringUtils.trim(id).length > 0) url = url+"&id="+id;
			if(publish) url = url+"&publish";
			url = url+"&friends="+friends.join(",");
			url = url+"&size="+data.length;
			
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
				var ret:Object = {};
				ret["id"] = xml.child("id")[0];
				ret["guid"] = xml.child("guid")[0];
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
