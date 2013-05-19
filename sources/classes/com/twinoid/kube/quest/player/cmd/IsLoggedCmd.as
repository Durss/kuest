package com.twinoid.kube.quest.player.cmd {
	import flash.utils.ByteArray;
	import by.blooddy.crypto.Base64;

	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;
	import com.nurun.utils.crypto.XOR;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	
	/**
	 * The IsLoggedCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to test if the user is logged in.
	 *
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class IsLoggedCmd extends LoadFileCmd implements Command {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function IsLoggedCmd() {
			super(Config.getPath("isLoggedWS"));
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function loadCompleteHandler(event:Event = null):void {
			try {
				var xml:XML = new XML(loader.data);
			}catch(error:Error) {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
				return;
			}
			
			if(parseBoolean(xml.child("result")[0].@success)) {
				var ba:ByteArray = Base64.decode(xml.child("time")[0]);
				XOR(ba, "DataManagerEvent");//Decode time
				var ret:Object = {};
				ret["logged"]	= parseBoolean(xml.child("logged")[0]);
				ret["uid"]		= xml.child("uid")[0];
				ret["name"]		= xml.child("name")[0];
				ret["pubkey"]	= xml.child("pubkey")[0];
				ret["lang"]		= xml.child("lang")[0];
				ret["time"]		= parseFloat(ba.readUTFBytes(ba.length)) * 1000;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, ret));
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, xml.child("error")[0].@id));
			}
		}

		override protected function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "IOERROR"));
		}
	}
}
