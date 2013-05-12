package com.twinoid.kube.quest.editor.cmd {
	import com.nurun.core.commands.ProgressiveCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	/**
	 * The  LoadCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to load a kuest from the server.
	 *
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class LoadCmd extends LoadFileCmd implements ProgressiveCommand {
		
		private var _id:String;
		private var _callback:Function;
		private var _release:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */

		public function LoadCmd(release:Boolean = false) {
			_release = release;
			super(Config.getPath("loadWS"), URLLoaderDataFormat.BINARY);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
			_loader.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the kuest's ID
		 */
		public function get id():String { return _id; }

		/**
		 * Gets the method to be called when saving completes
		 */
		public function get callback():Function { return _callback; }

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
		public function get total():Number { return Math.max(1, _loader.bytesTotal); }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the command
		 */
		public function populate(id:String, callback:Function = null):void {
			_callback = callback;
			_id = id;
			_urlVariables['id'] = id;
			if(_release) _urlVariables['release'] = "";
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function loadCompleteHandler(event:Event = null):void {
			var ba:ByteArray = loader.data as ByteArray;
			var str:String = ba.readUTFBytes(ba.length);
			if(str.search("<root>") == -1) {
				ba.position = 0;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, ba));
				return;
			}
			try {
				var xml:XML = new XML(str);
			}catch(error:Error) {
				//Not a valid XML, most probably a kuest binary data.
				ba.position = 0;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, ba));
				return;
			}
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, xml.child("error")[0].@id));
		}

		override protected function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "IOERROR"));
		}
	}
}
