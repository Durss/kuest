package com.twinoid.kube.quest.player.cmd {
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * The  ClearProgressionCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to clear the user's progression.
	 *
	 * @author Francois
	 * @date 24 mai 2013;
	 */
	public class ClearProgressionCmd extends LoadFileCmd {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  ClearProgressionCmd() {
			super(Config.getPath("clearProgressionWS"));
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
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, xml.child("error")[0].@id));
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
