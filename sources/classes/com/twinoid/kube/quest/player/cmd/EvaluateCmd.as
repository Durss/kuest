package com.twinoid.kube.quest.player.cmd {
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.error.KuestException;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * The EvaluateCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to send an evaluation to the server.
	 *
	 * @author Francois
	 * @date 2 juin 2013;
	 */
	public class EvaluateCmd extends LoadFileCmd implements Command {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  EvaluateCmd() {
			super(Config.getPath("evaluateWS"));
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
		public function populate(guid:String, pubkey:String, note:int):void {
			_urlVariables["id"] = guid;
			_urlVariables["key"] = pubkey;
			_urlVariables["note"] = note;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when upload completes
		 */
		override protected function loadCompleteHandler(event:Event = null):void {
			try {
				var xml:XML = new XML(_loader.data);
			}catch(error:Error) {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
				return;
			}
			
			if(parseBoolean(xml.child("result")[0].@success)) {
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}else{
				var code:String = xml.child("error")[0].@id;
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, code));
				throw new KuestException(Label.getLabel("exception-"+code), "55");
			}
		}
		
		/**
		 * Called if upload failled
		 */
		override protected function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "IOERROR"));
		}
	}
}
