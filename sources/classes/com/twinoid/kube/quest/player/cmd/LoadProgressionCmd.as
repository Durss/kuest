package com.twinoid.kube.quest.player.cmd {
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	/**
	 * The LoadProgressionCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to load the user's progression
	 *
	 * @author Francois
	 * @date 18 mai 2013;
	 */
	public class LoadProgressionCmd extends LoadFileCmd implements Command {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  LoadProgressionCmd() {
			super(Config.getPath("loadProgressionWS"), URLLoaderDataFormat.BINARY);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(id:String):void {
			_urlVariables["id"] = id;
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
			var error:String = xml.child("error")[0].@id;
			if(error == "SAVE_KUEST_NOT_FOUND") {
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, error));
			}
		}

		override protected function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "IOERROR"));
		}
	}
}
