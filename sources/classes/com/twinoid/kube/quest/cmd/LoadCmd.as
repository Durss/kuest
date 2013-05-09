package com.twinoid.kube.quest.cmd {
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
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
	public class LoadCmd extends LoadFileCmd implements Command {
		
		private var _id:String;
		private var _callback:Function;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */

		public function LoadCmd() {
			super(Config.getPath("loadWS"), URLLoaderDataFormat.BINARY);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the kuest's ID
		 */
		public function get id():String { return _id; }

		public function get callback():Function { return _callback; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the command
		 */
		public function populate(id:String, callback:Function):void {
			_callback = callback;
			_id = id;
			_urlVariables['id'] = id;
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function loadCompleteHandler(event:Event = null):void {
			var ba:ByteArray = loader.data as ByteArray;
			var str:String = ba.readUTFBytes(ba.length);
			if(str.substr(0, 6) != "<root>") {
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
