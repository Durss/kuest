package com.twinoid.kube.quest.cmd {
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;
	import com.twinoid.kube.quest.vo.KuestInfo;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
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
		 * Populates the command
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
				var nodes:XMLList = XML(xml.child("kuests")[0]).child("k");
				var i:int, len:int, kuests:Vector.<KuestInfo>;
				len = nodes.length();
				kuests = new Vector.<KuestInfo>();
				for(i = 0; i < len; ++i) {
					kuests[i] = new KuestInfo(XML(nodes[i]).child("t")[0], XML(nodes[i]).child("d")[0], nodes[i].@id);
				}
				ret["kuests"] = kuests;
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
