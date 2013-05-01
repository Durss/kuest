package com.twinoid.kube.quest.cmd {
	import flash.events.SecurityErrorEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.Command;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	
	/**
	 * The  LoginCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to log the user in.
	 *
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class LoginCmd extends LoadFileCmd implements Command {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function LoginCmd() {
			super(Config.getPath("loginWS"));
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
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
		public function populate(uid:String, pubkey:String):void {
			_urlVariables['uid'] = uid;
			_urlVariables['pubkey'] = pubkey;
		}


		
		
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
				var ret:Object = {};
				ret["uid"] = xml.child("uid")[0];
				ret["name"] = xml.child("name")[0];
				ret["pubkey"] = xml.child("pubkey")[0];
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, ret));
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, xml.child("error")[0].@id));
			}
		}
	}
}
